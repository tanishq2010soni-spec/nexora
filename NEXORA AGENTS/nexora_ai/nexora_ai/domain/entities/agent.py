from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any

from nexora_ai.domain.enums.agent_enums import AgentStatus, AgentType


@dataclass
class AgentSystemInfo:
    hostname: str = ""
    os: str = ""
    cpu_count: int = 0
    ram_total_mb: float = 0.0
    python_version: str = ""

    def to_json(self) -> dict[str, Any]:
        return {
            "hostname": self.hostname,
            "os": self.os,
            "cpu_count": self.cpu_count,
            "ram_total_mb": self.ram_total_mb,
            "python_version": self.python_version,
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> AgentSystemInfo:
        return cls(
            hostname=data.get("hostname", ""),
            os=data.get("os", ""),
            cpu_count=data.get("cpu_count", 0),
            ram_total_mb=data.get("ram_total_mb", 0.0),
            python_version=data.get("python_version", ""),
        )


@dataclass
class AgentRegistration:
    agent_id: str
    agent_name: str
    agent_type: AgentType
    version: str
    build_number: str = ""
    status: AgentStatus = AgentStatus.STARTING
    capabilities: list[str] = field(default_factory=list)
    supported_models: list[str] = field(default_factory=list)
    installed_plugins: list[str] = field(default_factory=list)
    organization_id: str = ""
    system_info: AgentSystemInfo = field(default_factory=AgentSystemInfo)
    startup_time: str = ""
    api_endpoint: str = ""
    health_endpoint: str = ""
    registered_at: str = ""
    last_heartbeat: str = ""

    def to_json(self) -> dict[str, Any]:
        return {
            "agent_id": self.agent_id,
            "agent_name": self.agent_name,
            "agent_type": self.agent_type.value,
            "version": self.version,
            "build_number": self.build_number,
            "status": self.status.value,
            "capabilities": self.capabilities,
            "supported_models": self.supported_models,
            "installed_plugins": self.installed_plugins,
            "organization_id": self.organization_id,
            "system_info": self.system_info.to_json(),
            "startup_time": self.startup_time,
            "api_endpoint": self.api_endpoint,
            "health_endpoint": self.health_endpoint,
            "registered_at": self.registered_at,
            "last_heartbeat": self.last_heartbeat,
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> AgentRegistration:
        return cls(
            agent_id=data["agent_id"],
            agent_name=data["agent_name"],
            agent_type=AgentType(data["agent_type"]),
            version=data["version"],
            build_number=data.get("build_number", ""),
            status=AgentStatus(data.get("status", "starting")),
            capabilities=data.get("capabilities", []),
            supported_models=data.get("supported_models", []),
            installed_plugins=data.get("installed_plugins", []),
            organization_id=data.get("organization_id", ""),
            system_info=AgentSystemInfo.from_json(data.get("system_info", {})),
            startup_time=data.get("startup_time", ""),
            api_endpoint=data.get("api_endpoint", ""),
            health_endpoint=data.get("health_endpoint", ""),
            registered_at=data.get("registered_at", ""),
            last_heartbeat=data.get("last_heartbeat", ""),
        )


@dataclass
class AgentHeartbeat:
    agent_id: str
    status: AgentStatus
    cpu_percent: float = 0.0
    ram_percent: float = 0.0
    active_sessions: int = 0
    active_conversations: int = 0
    running_tasks: int = 0
    queue_size: int = 0
    uptime_seconds: float = 0.0
    timestamp: str = ""

    def to_json(self) -> dict[str, Any]:
        return {
            "agent_id": self.agent_id,
            "status": self.status.value,
            "cpu_percent": self.cpu_percent,
            "ram_percent": self.ram_percent,
            "active_sessions": self.active_sessions,
            "active_conversations": self.active_conversations,
            "running_tasks": self.running_tasks,
            "queue_size": self.queue_size,
            "uptime_seconds": self.uptime_seconds,
            "timestamp": self.timestamp,
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> AgentHeartbeat:
        return cls(
            agent_id=data["agent_id"],
            status=AgentStatus(data["status"]),
            cpu_percent=data.get("cpu_percent", 0.0),
            ram_percent=data.get("ram_percent", 0.0),
            active_sessions=data.get("active_sessions", 0),
            active_conversations=data.get("active_conversations", 0),
            running_tasks=data.get("running_tasks", 0),
            queue_size=data.get("queue_size", 0),
            uptime_seconds=data.get("uptime_seconds", 0.0),
            timestamp=data.get("timestamp", ""),
        )


@dataclass
class AgentMetrics:
    cpu_percent: float = 0.0
    ram_percent: float = 0.0
    ram_used_mb: float = 0.0
    ram_total_mb: float = 0.0
    active_sessions: int = 0
    active_conversations: int = 0
    running_tasks: int = 0
    queue_size: int = 0
    total_requests: int = 0
    total_errors: int = 0
    uptime_seconds: float = 0.0
    timestamp: str = ""

    def to_json(self) -> dict[str, Any]:
        return {
            "cpu_percent": self.cpu_percent,
            "ram_percent": self.ram_percent,
            "ram_used_mb": self.ram_used_mb,
            "ram_total_mb": self.ram_total_mb,
            "active_sessions": self.active_sessions,
            "active_conversations": self.active_conversations,
            "running_tasks": self.running_tasks,
            "queue_size": self.queue_size,
            "total_requests": self.total_requests,
            "total_errors": self.total_errors,
            "uptime_seconds": self.uptime_seconds,
            "timestamp": self.timestamp,
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> AgentMetrics:
        return cls(
            cpu_percent=data.get("cpu_percent", 0.0),
            ram_percent=data.get("ram_percent", 0.0),
            ram_used_mb=data.get("ram_used_mb", 0.0),
            ram_total_mb=data.get("ram_total_mb", 0.0),
            active_sessions=data.get("active_sessions", 0),
            active_conversations=data.get("active_conversations", 0),
            running_tasks=data.get("running_tasks", 0),
            queue_size=data.get("queue_size", 0),
            total_requests=data.get("total_requests", 0),
            total_errors=data.get("total_errors", 0),
            uptime_seconds=data.get("uptime_seconds", 0.0),
            timestamp=data.get("timestamp", ""),
        )


@dataclass
class AgentVersion:
    version: str
    build_number: str = ""
    commit_hash: str = ""
    build_date: str = ""
    python_version: str = ""
    framework_version: str = ""

    def to_json(self) -> dict[str, Any]:
        return {
            "version": self.version,
            "build_number": self.build_number,
            "commit_hash": self.commit_hash,
            "build_date": self.build_date,
            "python_version": self.python_version,
            "framework_version": self.framework_version,
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> AgentVersion:
        return cls(
            version=data["version"],
            build_number=data.get("build_number", ""),
            commit_hash=data.get("commit_hash", ""),
            build_date=data.get("build_date", ""),
            python_version=data.get("python_version", ""),
            framework_version=data.get("framework_version", ""),
        )


@dataclass
class AgentCapabilities:
    agent_id: str
    capabilities: list[str] = field(default_factory=list)
    supported_models: list[str] = field(default_factory=list)
    supported_tools: list[str] = field(default_factory=list)
    supported_protocols: list[str] = field(default_factory=list)
    max_concurrent_sessions: int = 0
    max_concurrent_conversations: int = 0
    features: dict[str, Any] = field(default_factory=dict)

    def to_json(self) -> dict[str, Any]:
        return {
            "agent_id": self.agent_id,
            "capabilities": self.capabilities,
            "supported_models": self.supported_models,
            "supported_tools": self.supported_tools,
            "supported_protocols": self.supported_protocols,
            "max_concurrent_sessions": self.max_concurrent_sessions,
            "max_concurrent_conversations": self.max_concurrent_conversations,
            "features": self.features,
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> AgentCapabilities:
        return cls(
            agent_id=data["agent_id"],
            capabilities=data.get("capabilities", []),
            supported_models=data.get("supported_models", []),
            supported_tools=data.get("supported_tools", []),
            supported_protocols=data.get("supported_protocols", []),
            max_concurrent_sessions=data.get("max_concurrent_sessions", 0),
            max_concurrent_conversations=data.get("max_concurrent_conversations", 0),
            features=data.get("features", {}),
        )


@dataclass
class AgentStatusInfo:
    agent_id: str
    agent_name: str
    agent_type: AgentType
    status: AgentStatus
    version: str
    uptime_seconds: float
    last_heartbeat: str
    system_info: AgentSystemInfo
    metrics: AgentMetrics
    health_status: str = "healthy"

    def to_json(self) -> dict[str, Any]:
        return {
            "agent_id": self.agent_id,
            "agent_name": self.agent_name,
            "agent_type": self.agent_type.value,
            "status": self.status.value,
            "version": self.version,
            "uptime_seconds": self.uptime_seconds,
            "last_heartbeat": self.last_heartbeat,
            "system_info": self.system_info.to_json(),
            "metrics": self.metrics.to_json(),
            "health_status": self.health_status,
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> AgentStatusInfo:
        return cls(
            agent_id=data["agent_id"],
            agent_name=data["agent_name"],
            agent_type=AgentType(data["agent_type"]),
            status=AgentStatus(data["status"]),
            version=data["version"],
            uptime_seconds=data.get("uptime_seconds", 0.0),
            last_heartbeat=data.get("last_heartbeat", ""),
            system_info=AgentSystemInfo.from_json(data.get("system_info", {})),
            metrics=AgentMetrics.from_json(data.get("metrics", {})),
            health_status=data.get("health_status", "healthy"),
        )
