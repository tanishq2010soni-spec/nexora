from __future__ import annotations

from datetime import datetime, timezone
from typing import Any

from nexora_ai.domain.enums.conversation_enums import (
    ConversationStatus,
    MessageRole,
    MessageType,
)


class Message:
    def __init__(
        self,
        id: str,
        role: MessageRole,
        content: str,
        type: MessageType = MessageType.TEXT,
        tool_calls: list[dict[str, Any]] | None = None,
        tool_call_id: str | None = None,
        name: str | None = None,
        metadata: dict[str, Any] | None = None,
        tokens: int = 0,
        created_at: datetime | None = None,
    ) -> None:
        self.id = id
        self.role = role
        self.content = content
        self.type = type
        self.tool_calls = tool_calls or []
        self.tool_call_id = tool_call_id
        self.name = name
        self.metadata = metadata or {}
        self.tokens = tokens
        self.created_at = created_at or datetime.now(timezone.utc)

    def to_json(self) -> dict[str, Any]:
        return {
            "id": self.id,
            "role": self.role.value,
            "content": self.content,
            "type": self.type.value,
            "tool_calls": self.tool_calls,
            "tool_call_id": self.tool_call_id,
            "name": self.name,
            "metadata": self.metadata,
            "tokens": self.tokens,
            "created_at": self.created_at.isoformat(),
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> Message:
        return cls(
            id=data["id"],
            role=MessageRole(data["role"]),
            content=data["content"],
            type=MessageType(data.get("type", MessageType.TEXT.value)),
            tool_calls=data.get("tool_calls"),
            tool_call_id=data.get("tool_call_id"),
            name=data.get("name"),
            metadata=data.get("metadata"),
            tokens=data.get("tokens", 0),
            created_at=datetime.fromisoformat(data["created_at"]) if "created_at" in data else None,
        )


class Conversation:
    def __init__(
        self,
        id: str,
        thread_id: str,
        messages: list[Message] | None = None,
        system_prompt: str | None = None,
        context_window: int = 4096,
        status: ConversationStatus = ConversationStatus.ACTIVE,
        metadata: dict[str, Any] | None = None,
        created_at: datetime | None = None,
        updated_at: datetime | None = None,
    ) -> None:
        self.id = id
        self.thread_id = thread_id
        self.messages = messages or []
        self.system_prompt = system_prompt
        self.context_window = context_window
        self.status = status
        self.metadata = metadata or {}
        self.created_at = created_at or datetime.now(timezone.utc)
        self.updated_at = updated_at or datetime.now(timezone.utc)

    def to_json(self) -> dict[str, Any]:
        return {
            "id": self.id,
            "thread_id": self.thread_id,
            "messages": [m.to_json() for m in self.messages],
            "system_prompt": self.system_prompt,
            "context_window": self.context_window,
            "status": self.status.value,
            "metadata": self.metadata,
            "created_at": self.created_at.isoformat(),
            "updated_at": self.updated_at.isoformat(),
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> Conversation:
        return cls(
            id=data["id"],
            thread_id=data["thread_id"],
            messages=[Message.from_json(m) for m in data.get("messages", [])],
            system_prompt=data.get("system_prompt"),
            context_window=data.get("context_window", 4096),
            status=ConversationStatus(data.get("status", ConversationStatus.ACTIVE.value)),
            metadata=data.get("metadata"),
            created_at=datetime.fromisoformat(data["created_at"]) if "created_at" in data else None,
            updated_at=datetime.fromisoformat(data["updated_at"]) if "updated_at" in data else None,
        )


class Thread:
    def __init__(
        self,
        id: str,
        title: str,
        conversations: list[str] | None = None,
        metadata: dict[str, Any] | None = None,
        created_at: datetime | None = None,
        updated_at: datetime | None = None,
    ) -> None:
        self.id = id
        self.title = title
        self.conversations = conversations or []
        self.metadata = metadata or {}
        self.created_at = created_at or datetime.now(timezone.utc)
        self.updated_at = updated_at or datetime.now(timezone.utc)

    def to_json(self) -> dict[str, Any]:
        return {
            "id": self.id,
            "title": self.title,
            "conversations": self.conversations,
            "metadata": self.metadata,
            "created_at": self.created_at.isoformat(),
            "updated_at": self.updated_at.isoformat(),
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> Thread:
        return cls(
            id=data["id"],
            title=data["title"],
            conversations=data.get("conversations", []),
            metadata=data.get("metadata"),
            created_at=datetime.fromisoformat(data["created_at"]) if "created_at" in data else None,
            updated_at=datetime.fromisoformat(data["updated_at"]) if "updated_at" in data else None,
        )


class StreamingChunk:
    def __init__(
        self,
        content: str,
        finish_reason: str | None = None,
        usage: dict[str, Any] | None = None,
        tool_calls: list[dict[str, Any]] | None = None,
        provider: str | None = None,
        model: str | None = None,
    ) -> None:
        self.content = content
        self.finish_reason = finish_reason
        self.usage = usage
        self.tool_calls = tool_calls
        self.provider = provider
        self.model = model

    def to_json(self) -> dict[str, Any]:
        return {
            "content": self.content,
            "finish_reason": self.finish_reason,
            "usage": self.usage,
            "tool_calls": self.tool_calls,
            "provider": self.provider,
            "model": self.model,
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> StreamingChunk:
        return cls(
            content=data["content"],
            finish_reason=data.get("finish_reason"),
            usage=data.get("usage"),
            tool_calls=data.get("tool_calls"),
            provider=data.get("provider"),
            model=data.get("model"),
        )
