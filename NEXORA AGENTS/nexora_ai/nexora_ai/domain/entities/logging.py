from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any

from nexora_ai.domain.enums.logging_enums import LogCategory, LogLevel


@dataclass
class LogEntry:
    id: str
    level: LogLevel
    category: LogCategory
    message: str
    correlation_id: str | None = None
    request_id: str | None = None
    task_id: str | None = None
    conversation_id: str | None = None
    metadata: dict[str, Any] = field(default_factory=dict)
    timestamp: datetime = field(default_factory=lambda: datetime.now(timezone.utc))
    source: str = ""
    stack_trace: str | None = None

    def to_json(self) -> dict[str, Any]:
        return {
            "id": self.id,
            "level": self.level.value,
            "category": self.category.value,
            "message": self.message,
            "correlation_id": self.correlation_id,
            "request_id": self.request_id,
            "task_id": self.task_id,
            "conversation_id": self.conversation_id,
            "metadata": self.metadata,
            "timestamp": self.timestamp.isoformat(),
            "source": self.source,
            "stack_trace": self.stack_trace,
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> LogEntry:
        return cls(
            id=data["id"],
            level=LogLevel(data["level"]),
            category=LogCategory(data["category"]),
            message=data["message"],
            correlation_id=data.get("correlation_id"),
            request_id=data.get("request_id"),
            task_id=data.get("task_id"),
            conversation_id=data.get("conversation_id"),
            metadata=data.get("metadata", {}),
            timestamp=datetime.fromisoformat(data["timestamp"]) if "timestamp" in data else datetime.now(timezone.utc),
            source=data.get("source", ""),
            stack_trace=data.get("stack_trace"),
        )


@dataclass
class PerformanceMetrics:
    operation: str
    duration_ms: float
    cpu_percent: float = 0.0
    memory_bytes: int = 0
    input_tokens: int = 0
    output_tokens: int = 0
    success: bool = True
    error: str | None = None
    timestamp: datetime = field(default_factory=lambda: datetime.now(timezone.utc))

    def to_json(self) -> dict[str, Any]:
        return {
            "operation": self.operation,
            "duration_ms": self.duration_ms,
            "cpu_percent": self.cpu_percent,
            "memory_bytes": self.memory_bytes,
            "input_tokens": self.input_tokens,
            "output_tokens": self.output_tokens,
            "success": self.success,
            "error": self.error,
            "timestamp": self.timestamp.isoformat(),
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> PerformanceMetrics:
        return cls(
            operation=data["operation"],
            duration_ms=data["duration_ms"],
            cpu_percent=data.get("cpu_percent", 0.0),
            memory_bytes=data.get("memory_bytes", 0),
            input_tokens=data.get("input_tokens", 0),
            output_tokens=data.get("output_tokens", 0),
            success=data.get("success", True),
            error=data.get("error"),
            timestamp=datetime.fromisoformat(data["timestamp"]) if "timestamp" in data else datetime.now(timezone.utc),
        )


@dataclass
class TraceSpan:
    name: str
    trace_id: str
    parent_span_id: str | None = None
    span_id: str = ""
    start_time: datetime = field(default_factory=lambda: datetime.now(timezone.utc))
    end_time: datetime | None = None
    status: str = "ok"
    attributes: dict[str, Any] = field(default_factory=dict)

    def to_json(self) -> dict[str, Any]:
        return {
            "name": self.name,
            "trace_id": self.trace_id,
            "parent_span_id": self.parent_span_id,
            "span_id": self.span_id,
            "start_time": self.start_time.isoformat(),
            "end_time": self.end_time.isoformat() if self.end_time else None,
            "status": self.status,
            "attributes": self.attributes,
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> TraceSpan:
        return cls(
            name=data["name"],
            trace_id=data["trace_id"],
            parent_span_id=data.get("parent_span_id"),
            span_id=data.get("span_id", ""),
            start_time=datetime.fromisoformat(data["start_time"]) if "start_time" in data else datetime.now(timezone.utc),
            end_time=datetime.fromisoformat(data["end_time"]) if data.get("end_time") else None,
            status=data.get("status", "ok"),
            attributes=data.get("attributes", {}),
        )
