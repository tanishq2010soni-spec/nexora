from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any

from nexora_ai.domain.enums.tool_enums import ToolCategory, ToolPermission, ToolStatus


@dataclass
class ToolParameter:
    name: str
    type: str
    description: str = ""
    required: bool = False
    default: Any = None
    enum_values: list[str] | None = None

    def to_json(self) -> dict[str, Any]:
        return {
            "name": self.name,
            "type": self.type,
            "description": self.description,
            "required": self.required,
            "default": self.default,
            "enum_values": self.enum_values,
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> ToolParameter:
        return cls(
            name=data["name"],
            type=data["type"],
            description=data.get("description", ""),
            required=data.get("required", False),
            default=data.get("default"),
            enum_values=data.get("enum_values"),
        )


@dataclass
class ToolHealth:
    status: str
    last_check: datetime
    response_time_ms: float = 0.0
    error_count: int = 0
    version: str = ""

    def to_json(self) -> dict[str, Any]:
        return {
            "status": self.status,
            "last_check": self.last_check.isoformat(),
            "response_time_ms": self.response_time_ms,
            "error_count": self.error_count,
            "version": self.version,
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> ToolHealth:
        return cls(
            status=data["status"],
            last_check=datetime.fromisoformat(data["last_check"]),
            response_time_ms=data.get("response_time_ms", 0.0),
            error_count=data.get("error_count", 0),
            version=data.get("version", ""),
        )


@dataclass
class ToolDefinition:
    name: str
    description: str
    category: ToolCategory
    version: str = "1.0.0"
    author: str = ""
    permissions: list[ToolPermission] = field(default_factory=list)
    parameters: list[ToolParameter] = field(default_factory=list)
    return_type: str = "str"
    timeout_seconds: int = 30
    status: ToolStatus = ToolStatus.INSTALLED
    health: ToolHealth | None = None
    metadata: dict[str, Any] = field(default_factory=dict)

    def to_json(self) -> dict[str, Any]:
        return {
            "name": self.name,
            "description": self.description,
            "category": self.category.value,
            "version": self.version,
            "author": self.author,
            "permissions": [p.value for p in self.permissions],
            "parameters": [p.to_json() for p in self.parameters],
            "return_type": self.return_type,
            "timeout_seconds": self.timeout_seconds,
            "status": self.status.value,
            "health": self.health.to_json() if self.health else None,
            "metadata": self.metadata,
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> ToolDefinition:
        return cls(
            name=data["name"],
            description=data["description"],
            category=ToolCategory(data["category"]),
            version=data.get("version", "1.0.0"),
            author=data.get("author", ""),
            permissions=[ToolPermission(p) for p in data.get("permissions", [])],
            parameters=[ToolParameter.from_json(p) for p in data.get("parameters", [])],
            return_type=data.get("return_type", "str"),
            timeout_seconds=data.get("timeout_seconds", 30),
            status=ToolStatus(data.get("status", ToolStatus.INSTALLED.value)),
            health=ToolHealth.from_json(data["health"]) if data.get("health") else None,
            metadata=data.get("metadata", {}),
        )


@dataclass
class ToolResult:
    success: bool
    output: Any = None
    error: str | None = None
    execution_time_ms: float = 0.0
    tool_name: str = ""
    metadata: dict[str, Any] = field(default_factory=dict)

    def to_json(self) -> dict[str, Any]:
        return {
            "success": self.success,
            "output": self.output,
            "error": self.error,
            "execution_time_ms": self.execution_time_ms,
            "tool_name": self.tool_name,
            "metadata": self.metadata,
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> ToolResult:
        return cls(
            success=data["success"],
            output=data.get("output"),
            error=data.get("error"),
            execution_time_ms=data.get("execution_time_ms", 0.0),
            tool_name=data.get("tool_name", ""),
            metadata=data.get("metadata", {}),
        )


@dataclass
class ToolContext:
    tool_name: str
    arguments: dict[str, Any] = field(default_factory=dict)
    user_id: str | None = None
    org_id: str | None = None
    conversation_id: str | None = None
    execution_id: str | None = None
    permissions: list[ToolPermission] = field(default_factory=list)
    timeout: int = 30
    cancellation_token: Any = None

    def to_json(self) -> dict[str, Any]:
        return {
            "tool_name": self.tool_name,
            "arguments": self.arguments,
            "user_id": self.user_id,
            "org_id": self.org_id,
            "conversation_id": self.conversation_id,
            "execution_id": self.execution_id,
            "permissions": [p.value for p in self.permissions],
            "timeout": self.timeout,
            "cancellation_token": self.cancellation_token,
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> ToolContext:
        return cls(
            tool_name=data["tool_name"],
            arguments=data.get("arguments", {}),
            user_id=data.get("user_id"),
            org_id=data.get("org_id"),
            conversation_id=data.get("conversation_id"),
            execution_id=data.get("execution_id"),
            permissions=[ToolPermission(p) for p in data.get("permissions", [])],
            timeout=data.get("timeout", 30),
            cancellation_token=data.get("cancellation_token"),
        )
