from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any

from nexora_ai.domain.enums.event_enums import EventPriority, EventType


@dataclass
class Event:
    id: str
    type: EventType
    name: str
    data: dict[str, Any] = field(default_factory=dict)
    priority: EventPriority = EventPriority.MEDIUM
    source: str = ""
    correlation_id: str | None = None
    causation_id: str | None = None
    timestamp: datetime = field(default_factory=lambda: datetime.now(timezone.utc))

    def to_json(self) -> dict[str, Any]:
        return {
            "id": self.id,
            "type": self.type.value,
            "name": self.name,
            "data": self.data,
            "priority": self.priority.value,
            "source": self.source,
            "correlation_id": self.correlation_id,
            "causation_id": self.causation_id,
            "timestamp": self.timestamp.isoformat(),
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> Event:
        return cls(
            id=data["id"],
            type=EventType(data["type"]),
            name=data["name"],
            data=data.get("data", {}),
            priority=EventPriority(data.get("priority", EventPriority.MEDIUM.value)),
            source=data.get("source", ""),
            correlation_id=data.get("correlation_id"),
            causation_id=data.get("causation_id"),
            timestamp=datetime.fromisoformat(data["timestamp"]) if "timestamp" in data else datetime.now(timezone.utc),
        )


@dataclass
class Subscription:
    id: str
    event_types: list[EventType]
    handler_name: str
    filter: dict[str, Any] | None = None
    priority: int = 0
    max_retries: int = 3
    timeout_seconds: int = 30

    def to_json(self) -> dict[str, Any]:
        return {
            "id": self.id,
            "event_types": [t.value for t in self.event_types],
            "handler_name": self.handler_name,
            "filter": self.filter,
            "priority": self.priority,
            "max_retries": self.max_retries,
            "timeout_seconds": self.timeout_seconds,
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> Subscription:
        return cls(
            id=data["id"],
            event_types=[EventType(t) for t in data["event_types"]],
            handler_name=data["handler_name"],
            filter=data.get("filter"),
            priority=data.get("priority", 0),
            max_retries=data.get("max_retries", 3),
            timeout_seconds=data.get("timeout_seconds", 30),
        )


@dataclass
class DeadLetterEvent:
    original_event: Event
    error: str
    failed_at: datetime = field(default_factory=lambda: datetime.now(timezone.utc))
    retry_count: int = 0
    last_error: str = ""

    def to_json(self) -> dict[str, Any]:
        return {
            "original_event": self.original_event.to_json(),
            "error": self.error,
            "failed_at": self.failed_at.isoformat(),
            "retry_count": self.retry_count,
            "last_error": self.last_error,
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> DeadLetterEvent:
        return cls(
            original_event=Event.from_json(data["original_event"]),
            error=data["error"],
            failed_at=datetime.fromisoformat(data["failed_at"]) if "failed_at" in data else datetime.now(timezone.utc),
            retry_count=data.get("retry_count", 0),
            last_error=data.get("last_error", ""),
        )
