from __future__ import annotations

from datetime import datetime, timezone
from typing import Any, Protocol
from uuid import uuid4

from nexora_ai.domain.entities.conversation import (
    Conversation,
    Message,
    StreamingChunk,
)
from nexora_ai.domain.enums.conversation_enums import (
    ConversationStatus,
    ContextStrategy,
    MessageRole,
    MessageType,
)
from nexora_ai.domain.enums.memory_enums import MemoryImportance, MemoryType
from nexora_ai.domain.enums.provider_enums import ModelCapability


class ConversationRepository(Protocol):
    async def save(self, conversation: Conversation) -> None: ...
    async def get(self, conversation_id: str) -> Conversation | None: ...
    async def delete(self, conversation_id: str) -> None: ...
    async def list_by_thread(self, thread_id: str) -> list[Conversation]: ...
    async def search(self, query: str) -> list[Conversation]: ...


class ProviderRouter(Protocol):
    async def route_by_capabilities(
        self, capabilities: list[ModelCapability], messages: list[dict[str, Any]], config: dict[str, Any] | None
    ) -> AsyncIterator[StreamingChunk]: ...


class MemoryManager(Protocol):
    async def store(self, entry_type: MemoryType, content: str, importance: MemoryImportance, conversation_id: str | None, user_id: str | None, metadata: dict[str, Any]) -> str: ...
    async def search(self, query: str, user_id: str | None, limit: int) -> list[Any]: ...
    async def get_conversation_memories(self, conversation_id: str, limit: int) -> list[Any]: ...


from collections.abc import AsyncIterator


class ConversationService:
    def __init__(
        self,
        repository: ConversationRepository | None = None,
        memory_manager: MemoryManager | None = None,
    ) -> None:
        self._repository = repository
        self._memory_manager = memory_manager
        self._conversations: dict[str, Conversation] = {}

    async def create(
        self,
        thread_id: str,
        system_prompt: str | None = None,
        context_window: int = 4096,
        metadata: dict[str, Any] | None = None,
    ) -> Conversation:
        conversation = Conversation(
            id=str(uuid4()),
            thread_id=thread_id,
            system_prompt=system_prompt,
            context_window=context_window,
            metadata=metadata or {},
        )
        if system_prompt:
            conversation.messages.append(
                Message(
                    id=str(uuid4()),
                    role=MessageRole.SYSTEM,
                    content=system_prompt,
                    type=MessageType.SYSTEM,
                )
            )
        self._conversations[conversation.id] = conversation
        if self._repository:
            await self._repository.save(conversation)
        return conversation

    async def get(self, conversation_id: str) -> Conversation | None:
        candidate = self._conversations.get(conversation_id)
        if candidate is None and self._repository:
            candidate = await self._repository.get(conversation_id)
            if candidate is not None:
                self._conversations[conversation_id] = candidate
        return candidate

    async def update(self, conversation: Conversation) -> None:
        self._conversations[conversation.id] = conversation
        conversation.updated_at = datetime.now(timezone.utc)
        if self._repository:
            await self._repository.save(conversation)

    async def delete(self, conversation_id: str) -> None:
        self._conversations.pop(conversation_id, None)
        if self._repository:
            await self._repository.delete(conversation_id)

    async def list_by_thread(self, thread_id: str) -> list[Conversation]:
        all_candidates: list[Conversation] = []
        if self._repository:
            all_candidates = await self._repository.list_by_thread(thread_id)
        for c in self._conversations.values():
            if c.thread_id == thread_id and c not in all_candidates:
                all_candidates.append(c)
        return all_candidates

    async def add_message(
        self,
        conversation_id: str,
        role: MessageRole,
        content: str,
        type: MessageType = MessageType.TEXT,
        **kwargs: Any,
    ) -> Message:
        conversation = await self.get(conversation_id)
        if conversation is None:
            raise ValueError(f"Conversation {conversation_id} not found")
        message = Message(
            id=str(uuid4()),
            role=role,
            content=content,
            type=type,
            **kwargs,
        )
        conversation.messages.append(message)
        conversation.updated_at = datetime.now(timezone.utc)
        if self._repository:
            await self._repository.save(conversation)
        return message

    async def get_messages(self, conversation_id: str) -> list[Message]:
        conversation = await self.get(conversation_id)
        if conversation is None:
            return []
        return list(conversation.messages)

    async def trim_context(
        self,
        conversation_id: str,
        max_tokens: int,
        strategy: ContextStrategy = ContextStrategy.SLIDING_WINDOW,
    ) -> int:
        from nexora_ai.application.services.context_service import ContextService

        conversation = await self.get(conversation_id)
        if conversation is None:
            return 0
        context_service = ContextService()
        original_count = len(conversation.messages)
        if strategy == ContextStrategy.SLIDING_WINDOW:
            trimmed = context_service.sliding_window(conversation.messages, max_tokens)
        elif strategy == ContextStrategy.SUMMARY_COMPRESSION:
            trimmed = await context_service.compress_with_summary(conversation.messages, max_tokens)
        else:
            trimmed = context_service.trim_messages(conversation.messages, max_tokens, strategy)
        conversation.messages = trimmed
        conversation.updated_at = datetime.now(timezone.utc)
        if self._repository:
            await self._repository.save(conversation)
        return original_count - len(trimmed)

    async def inject_memory(
        self,
        conversation_id: str,
        user_id: str | None = None,
        limit: int = 5,
    ) -> None:
        if self._memory_manager is None:
            return
        conversation = await self.get(conversation_id)
        if conversation is None:
            return
        memories = await self._memory_manager.get_conversation_memories(conversation_id, limit)
        for memory_entry in memories:
            injected = Message(
                id=str(uuid4()),
                role=MessageRole.SYSTEM,
                content=f"[Memory: {memory_entry.content}]",
                type=MessageType.SYSTEM,
            )
            conversation.messages.insert(0, injected)
        conversation.updated_at = datetime.now(timezone.utc)
