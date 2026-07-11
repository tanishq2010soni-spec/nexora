from __future__ import annotations

from abc import ABC, abstractmethod
from collections.abc import AsyncIterator

from nexora_ai.domain.entities.conversation import Conversation, Message, StreamingChunk
from nexora_ai.domain.enums.conversation_enums import ContextStrategy


class ConversationInterface(ABC):
    @abstractmethod
    async def send_message(self, conversation_id: str, message: Message) -> AsyncIterator[StreamingChunk]: ...

    @abstractmethod
    async def create_conversation(self, conversation: Conversation) -> str: ...

    @abstractmethod
    async def get_conversation(self, id: str) -> Conversation | None: ...

    @abstractmethod
    async def delete_conversation(self, id: str) -> bool: ...

    @abstractmethod
    async def list_conversations(self, filter: dict) -> list[Conversation]: ...

    @abstractmethod
    async def update_context_window(self, conversation_id: str, strategy: ContextStrategy, max_tokens: int) -> None: ...
