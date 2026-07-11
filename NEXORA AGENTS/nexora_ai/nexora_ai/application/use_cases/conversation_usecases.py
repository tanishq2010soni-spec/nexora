from __future__ import annotations

from collections.abc import AsyncIterator
from typing import Any
from uuid import uuid4

from nexora_ai.application.services.conversation_service import (
    ConversationRepository,
    ConversationService,
    MemoryManager,
    ProviderRouter,
)
from nexora_ai.domain.entities.conversation import (
    Conversation,
    Message,
    StreamingChunk,
)
from nexora_ai.domain.enums.conversation_enums import (
    ContextStrategy,
    MessageRole,
    MessageType,
)
from nexora_ai.domain.enums.memory_enums import MemoryImportance, MemoryType
from nexora_ai.domain.enums.provider_enums import ModelCapability


class ConversationUseCases:
    def __init__(
        self,
        conversation_service: ConversationService,
        provider_router: ProviderRouter,
        memory_manager: MemoryManager,
        repository: ConversationRepository,
    ) -> None:
        self._conversation_service = conversation_service
        self._provider_router = provider_router
        self._memory_manager = memory_manager
        self._repository = repository

    async def send_message(
        self,
        conversation_id: str,
        content: str,
        role: MessageRole = MessageRole.USER,
    ) -> AsyncIterator[StreamingChunk]:
        conversation = await self._conversation_service.get(conversation_id)
        if conversation is None:
            raise ValueError(f"Conversation {conversation_id} not found")

        await self._conversation_service.inject_memory(
            conversation_id,
            conversation.metadata.get("user_id"),
            limit=5,
        )

        if self._conversation_service._repository is not None:
            ctx_window = conversation.context_window
            context_max_tokens = ctx_window - (ctx_window // 4)
            await self._conversation_service.trim_context(
                conversation_id,
                max_tokens=context_max_tokens,
                strategy=ContextStrategy.SLIDING_WINDOW,
            )

        await self._conversation_service.add_message(
            conversation_id,
            role=role,
            content=content,
            type=MessageType.TEXT,
        )

        conversation = await self._conversation_service.get(conversation_id)
        if conversation is None:
            raise RuntimeError("Conversation disappeared after message add")

        messages_dict = [m.to_json() for m in conversation.messages]

        collected_content: list[str] = []
        collected_tool_calls: list[dict[str, Any]] = []
        async for chunk in self._provider_router.route_by_capabilities(
            capabilities=[ModelCapability.CHAT, ModelCapability.STREAMING],
            messages=messages_dict,
            config={"conversation_id": conversation_id},
        ):
            collected_content.append(chunk.content)
            if chunk.tool_calls:
                collected_tool_calls.extend(chunk.tool_calls)
            yield chunk

        full_content = "".join(collected_content)
        assistant_message = await self._conversation_service.add_message(
            conversation_id,
            role=MessageRole.ASSISTANT,
            content=full_content,
            type=MessageType.TEXT,
        )

        await self._memory_manager.store(
            entry_type=MemoryType.EPISODIC,
            content=f"Conversation {conversation_id}: user said '{content}', assistant replied '{full_content[:100]}...'",
            importance=MemoryImportance.MEDIUM,
            conversation_id=conversation_id,
            user_id=conversation.metadata.get("user_id"),
            metadata={"message_count": len(conversation.messages)},
        )

    async def create_conversation(
        self,
        thread_id: str,
        system_prompt: str = "",
        context_window: int = 4096,
    ) -> str:
        conversation = await self._conversation_service.create(
            thread_id=thread_id,
            system_prompt=system_prompt or None,
            context_window=context_window,
        )
        return conversation.id

    async def get_conversation_history(self, conversation_id: str) -> list[Message]:
        return await self._conversation_service.get_messages(conversation_id)

    async def delete_conversation(self, conversation_id: str) -> None:
        await self._conversation_service.delete(conversation_id)

    async def search_conversations(self, query: str) -> list[Conversation]:
        return await self._repository.search(query)
