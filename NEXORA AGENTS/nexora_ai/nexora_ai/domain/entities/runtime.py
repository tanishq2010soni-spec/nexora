from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any

from nexora_ai.domain.enums.logging_enums import LogLevel


@dataclass
class RuntimeConfig:
    name: str = "nexora_ai"
    version: str = "0.1.0"
    environment: str = "development"
    log_level: LogLevel = LogLevel.INFO
    max_concurrent_tasks: int = 10
    task_timeout_seconds: int = 300
    enable_hot_reload: bool = False
    plugin_dir: str = "plugins"
    data_dir: str = "data"

    def to_json(self) -> dict[str, Any]:
        return {
            "name": self.name,
            "version": self.version,
            "environment": self.environment,
            "log_level": self.log_level.value,
            "max_concurrent_tasks": self.max_concurrent_tasks,
            "task_timeout_seconds": self.task_timeout_seconds,
            "enable_hot_reload": self.enable_hot_reload,
            "plugin_dir": self.plugin_dir,
            "data_dir": self.data_dir,
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> RuntimeConfig:
        return cls(
            name=data.get("name", "nexora_ai"),
            version=data.get("version", "0.1.0"),
            environment=data.get("environment", "development"),
            log_level=LogLevel(data.get("log_level", LogLevel.INFO.value)),
            max_concurrent_tasks=data.get("max_concurrent_tasks", 10),
            task_timeout_seconds=data.get("task_timeout_seconds", 300),
            enable_hot_reload=data.get("enable_hot_reload", False),
            plugin_dir=data.get("plugin_dir", "plugins"),
            data_dir=data.get("data_dir", "data"),
        )


@dataclass
class RuntimeHealth:
    status: str = "healthy"
    uptime_seconds: float = 0.0
    task_count: int = 0
    memory_usage_mb: float = 0.0
    cpu_percent: float = 0.0
    active_plugins: int = 0
    last_heartbeat: datetime = field(default_factory=lambda: datetime.now(timezone.utc))

    def to_json(self) -> dict[str, Any]:
        return {
            "status": self.status,
            "uptime_seconds": self.uptime_seconds,
            "task_count": self.task_count,
            "memory_usage_mb": self.memory_usage_mb,
            "cpu_percent": self.cpu_percent,
            "active_plugins": self.active_plugins,
            "last_heartbeat": self.last_heartbeat.isoformat(),
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> RuntimeHealth:
        return cls(
            status=data.get("status", "healthy"),
            uptime_seconds=data.get("uptime_seconds", 0.0),
            task_count=data.get("task_count", 0),
            memory_usage_mb=data.get("memory_usage_mb", 0.0),
            cpu_percent=data.get("cpu_percent", 0.0),
            active_plugins=data.get("active_plugins", 0),
            last_heartbeat=datetime.fromisoformat(data["last_heartbeat"]) if "last_heartbeat" in data else datetime.now(timezone.utc),
        )


@dataclass
class RuntimeEvent:
    type: str
    source: str
    data: dict[str, Any] = field(default_factory=dict)
    timestamp: datetime = field(default_factory=lambda: datetime.now(timezone.utc))

    def to_json(self) -> dict[str, Any]:
        return {
            "type": self.type,
            "source": self.source,
            "data": self.data,
            "timestamp": self.timestamp.isoformat(),
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> RuntimeEvent:
        return cls(
            type=data["type"],
            source=data["source"],
            data=data.get("data", {}),
            timestamp=datetime.fromisoformat(data["timestamp"]) if "timestamp" in data else datetime.now(timezone.utc),
        )
