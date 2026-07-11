from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any

from nexora_ai.domain.enums.memory_enums import MemoryImportance, MemoryType


@dataclass
class MemoryEntry:
    id: str
    type: MemoryType
    content: str
    embedding: list[float] | None = None
    importance: MemoryImportance = MemoryImportance.MEDIUM
    score: float = 0.0
    tags: list[str] = field(default_factory=list)
    source: str = ""
    conversation_id: str | None = None
    user_id: str | None = None
    metadata: dict[str, Any] = field(default_factory=dict)
    created_at: datetime = field(default_factory=lambda: datetime.now(timezone.utc))
    accessed_at: datetime = field(default_factory=lambda: datetime.now(timezone.utc))
    expires_at: datetime | None = None

    def to_json(self) -> dict[str, Any]:
        return {
            "id": self.id,
            "type": self.type.value,
            "content": self.content,
            "embedding": self.embedding,
            "importance": self.importance.value,
            "score": self.score,
            "tags": self.tags,
            "source": self.source,
            "conversation_id": self.conversation_id,
            "user_id": self.user_id,
            "metadata": self.metadata,
            "created_at": self.created_at.isoformat(),
            "accessed_at": self.accessed_at.isoformat(),
            "expires_at": self.expires_at.isoformat() if self.expires_at else None,
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> MemoryEntry:
        return cls(
            id=data["id"],
            type=MemoryType(data["type"]),
            content=data["content"],
            embedding=data.get("embedding"),
            importance=MemoryImportance(data.get("importance", MemoryImportance.MEDIUM.value)),
            score=data.get("score", 0.0),
            tags=data.get("tags", []),
            source=data.get("source", ""),
            conversation_id=data.get("conversation_id"),
            user_id=data.get("user_id"),
            metadata=data.get("metadata", {}),
            created_at=datetime.fromisoformat(data["created_at"]) if "created_at" in data else datetime.now(timezone.utc),
            accessed_at=datetime.fromisoformat(data["accessed_at"]) if "accessed_at" in data else datetime.now(timezone.utc),
            expires_at=datetime.fromisoformat(data["expires_at"]) if data.get("expires_at") else None,
        )


@dataclass
class MemorySearchQuery:
    text: str
    types: list[MemoryType] = field(default_factory=list)
    tags: list[str] = field(default_factory=list)
    min_score: float = 0.0
    limit: int = 20
    offset: int = 0
    user_id: str | None = None

    def to_json(self) -> dict[str, Any]:
        return {
            "text": self.text,
            "types": [t.value for t in self.types],
            "tags": self.tags,
            "min_score": self.min_score,
            "limit": self.limit,
            "offset": self.offset,
            "user_id": self.user_id,
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> MemorySearchQuery:
        return cls(
            text=data["text"],
            types=[MemoryType(t) for t in data.get("types", [])],
            tags=data.get("tags", []),
            min_score=data.get("min_score", 0.0),
            limit=data.get("limit", 20),
            offset=data.get("offset", 0),
            user_id=data.get("user_id"),
        )


@dataclass
class MemorySearchResult:
    entries: list[MemoryEntry]
    total: int
    query: MemorySearchQuery
    latency_ms: float = 0.0

    def to_json(self) -> dict[str, Any]:
        return {
            "entries": [e.to_json() for e in self.entries],
            "total": self.total,
            "query": self.query.to_json(),
            "latency_ms": self.latency_ms,
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> MemorySearchResult:
        return cls(
            entries=[MemoryEntry.from_json(e) for e in data["entries"]],
            total=data["total"],
            query=MemorySearchQuery.from_json(data["query"]),
            latency_ms=data.get("latency_ms", 0.0),
        )


@dataclass
class MemorySummary:
    id: str
    original_entries: int
    summary_text: str
    metadata: dict[str, Any] = field(default_factory=dict)
    created_at: datetime = field(default_factory=lambda: datetime.now(timezone.utc))

    def to_json(self) -> dict[str, Any]:
        return {
            "id": self.id,
            "original_entries": self.original_entries,
            "summary_text": self.summary_text,
            "metadata": self.metadata,
            "created_at": self.created_at.isoformat(),
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> MemorySummary:
        return cls(
            id=data["id"],
            original_entries=data["original_entries"],
            summary_text=data["summary_text"],
            metadata=data.get("metadata", {}),
            created_at=datetime.fromisoformat(data["created_at"]) if "created_at" in data else datetime.now(timezone.utc),
        )
