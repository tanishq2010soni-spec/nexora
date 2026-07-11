from __future__ import annotations

import json
from collections.abc import AsyncIterator
from datetime import datetime, timezone
from typing import Any
from uuid import uuid4

from nexora_ai.application.services.conversation_service import ConversationService
from nexora_ai.application.services.context_service import ContextService
from nexora_ai.application.services.retry_service import RetryService
from nexora_ai.domain.entities.conversation import Conversation, Message, StreamingChunk
from nexora_ai.domain.enums.conversation_enums import (
    ConversationStatus,
    ContextStrategy,
    MessageRole,
    MessageType,
)
from nexora_ai.domain.enums.memory_enums import MemoryImportance, MemoryType
from nexora_ai.domain.enums.provider_enums import ModelCapability
from nexora_ai.domain.interfaces.logging_interface import LoggingInterface
from nexora_ai.infrastructure.memory.memory_manager import MemoryManager
from nexora_ai.infrastructure.provider_router import ProviderRouter


class ConversationManager:
    def __init__(
        self,
        conversation_service: ConversationService,
        provider_router: ProviderRouter,
        memory_manager: MemoryManager,
        context_service: ContextService | None = None,
        retry_service: RetryService | None = None,
        logger: LoggingInterface | None = None,
    ) -> None:
        self._conversation_service = conversation_service
        self._provider_router = provider_router
        self._memory_manager = memory_manager
        self._context_service = context_service or ContextService()
        self._retry_service = retry_service or RetryService()
        self._logger = logger
        self._thread_id: str = str(uuid4())

    async def create_conversation(
        self,
        system_prompt: str | None = None,
        context_window: int = 8192,
        metadata: dict[str, Any] | None = None,
    ) -> Conversation:
        conv = await self._conversation_service.create(
            thread_id=self._thread_id,
            system_prompt=system_prompt,
            context_window=context_window,
            metadata=metadata,
        )
        if self._logger is not None:
            await self._logger.info(f"Created conversation {conv.id}", category="conversation")
        return conv

    async def get_conversation(self, conversation_id: str) -> Conversation | None:
        return await self._conversation_service.get(conversation_id)

    async def list_conversations(self) -> list[dict[str, Any]]:
        convs = await self._conversation_service.list_by_thread(self._thread_id)
        return [c.to_json() for c in convs]

    async def delete_conversation(self, conversation_id: str) -> bool:
        conv = await self._conversation_service.get(conversation_id)
        if conv is None:
            return False
        await self._conversation_service.delete(conversation_id)
        if self._logger is not None:
            await self._logger.info(f"Deleted conversation {conversation_id}", category="conversation")
        return True

    async def chat(
        self,
        message: str,
        conversation_id: str | None = None,
        stream: bool = True,
    ) -> AsyncIterator[StreamingChunk]:
        if conversation_id is None:
            conv = await self.create_conversation()
            conversation_id = conv.id
        else:
            conv = await self._conversation_service.get(conversation_id)
            if conv is None:
                conv = await self.create_conversation()
                conversation_id = conv.id

        await self._conversation_service.add_message(
            conversation_id=conversation_id,
            role=MessageRole.USER,
            content=message,
            type=MessageType.TEXT,
        )

        await self._conversation_service.inject_memory(conversation_id=conversation_id, limit=5)

        conv = await self._conversation_service.get(conversation_id)
        if conv is None:
            return

        should_trim = self._context_service.should_trim(conv.messages, conv.context_window)
        if should_trim:
            await self._conversation_service.trim_context(
                conversation_id=conversation_id,
                max_tokens=conv.context_window,
                strategy=ContextStrategy.SLIDING_WINDOW,
            )
            conv = await self._conversation_service.get(conversation_id)
            if conv is None:
                return

        messages_dict = [m.to_json() for m in conv.messages]

        config = {"stream": stream}

        full_response: list[str] = []
        try:
            async for chunk in self._provider_router.chat(messages_dict, config):
                full_response.append(chunk.content)
                yield chunk
        except Exception as exc:
            if self._logger is not None:
                await self._logger.error(f"Chat error: {exc}", category="conversation")
            yield StreamingChunk(
                content=f"Error: {exc}",
                finish_reason="error",
            )
            return

        response_text = "".join(full_response)
        await self._conversation_service.add_message(
            conversation_id=conversation_id,
            role=MessageRole.ASSISTANT,
            content=response_text,
            type=MessageType.TEXT,
        )

        if self._memory_manager is not None:
            from nexora_ai.domain.entities.memory import MemoryEntry

            summary = response_text[:500]
            entry = MemoryEntry(
                id=str(uuid4()),
                type=MemoryType.CONVERSATION,
                content=f"User: {message[:200]}\nAssistant: {summary}",
                importance=MemoryImportance.MEDIUM,
                conversation_id=conversation_id,
            )
            await self._memory_manager.store(entry)

    async def search_memory(self, query: str) -> list[dict[str, Any]]:
        if self._memory_manager is None:
            return []
        result = await self._memory_manager.search(query=query, limit=20)
        return [e.to_json() for e in result.entries]

    async def store_memory(
        self,
        content: str,
        memory_type: str = "conversation",
        importance: str = "medium",
        tags: list[str] | None = None,
    ) -> str | None:
        if self._memory_manager is None:
            return None
        from nexora_ai.domain.entities.memory import MemoryEntry

        entry = MemoryEntry(
            id=str(uuid4()),
            type=MemoryType(memory_type),
            content=content,
            importance=MemoryImportance(importance),
            tags=tags or [],
        )
        return await self._memory_manager.store(entry)

    async def delete_memory(self, memory_id: str) -> bool:
        if self._memory_manager is None:
            return False
        return await self._memory_manager._primary.delete(memory_id)

    async def export_conversation_json(self, conversation_id: str) -> str | None:
        conv = await self._conversation_service.get(conversation_id)
        if conv is None:
            return None
        return json.dumps(conv.to_json(), indent=2, default=str)

    async def export_conversation_markdown(self, conversation_id: str) -> str | None:
        conv = await self._conversation_service.get(conversation_id)
        if conv is None:
            return None
        lines: list[str] = []
        lines.append(f"# Conversation: {conv.id}")
        lines.append(f"**Created**: {conv.created_at.isoformat()}")
        lines.append("")
        for msg in conv.messages:
            role = msg.role.value.upper()
            content = msg.content
            lines.append(f"## {role}")
            lines.append("")
            lines.append(content)
            lines.append("")
        return "\n".join(lines)

    async def search_across_conversations(self, query: str) -> list[dict[str, Any]]:
        if self._memory_manager is None:
            return []
        result = await self._memory_manager.search(query=query, limit=50)
        return [e.to_json() for e in result.entries]
