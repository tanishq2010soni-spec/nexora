from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any

from nexora_ai.domain.enums.security_enums import AuditAction, PermissionEffect, ResourceType, SandboxLevel


@dataclass
class Permission:
    resource: ResourceType
    effect: PermissionEffect
    constraints: dict[str, Any] = field(default_factory=dict)

    def to_json(self) -> dict[str, Any]:
        return {
            "resource": self.resource.value,
            "effect": self.effect.value,
            "constraints": self.constraints,
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> Permission:
        return cls(
            resource=ResourceType(data["resource"]),
            effect=PermissionEffect(data["effect"]),
            constraints=data.get("constraints", {}),
        )


@dataclass
class PermissionCheck:
    resource: ResourceType
    action: str
    user_id: str | None = None
    org_id: str | None = None
    context: dict[str, Any] = field(default_factory=dict)

    def to_json(self) -> dict[str, Any]:
        return {
            "resource": self.resource.value,
            "action": self.action,
            "user_id": self.user_id,
            "org_id": self.org_id,
            "context": self.context,
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> PermissionCheck:
        return cls(
            resource=ResourceType(data["resource"]),
            action=data["action"],
            user_id=data.get("user_id"),
            org_id=data.get("org_id"),
            context=data.get("context", {}),
        )


@dataclass
class PermissionCheckResult:
    allowed: bool
    reason: str | None = None
    audit_required: bool = False
    constraints: dict[str, Any] = field(default_factory=dict)

    def to_json(self) -> dict[str, Any]:
        return {
            "allowed": self.allowed,
            "reason": self.reason,
            "audit_required": self.audit_required,
            "constraints": self.constraints,
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> PermissionCheckResult:
        return cls(
            allowed=data["allowed"],
            reason=data.get("reason"),
            audit_required=data.get("audit_required", False),
            constraints=data.get("constraints", {}),
        )


@dataclass
class AuditEntry:
    id: str
    action: AuditAction
    resource: ResourceType
    resource_id: str
    user_id: str | None = None
    org_id: str | None = None
    details: dict[str, Any] = field(default_factory=dict)
    timestamp: datetime = field(default_factory=lambda: datetime.now(timezone.utc))
    correlation_id: str | None = None

    def to_json(self) -> dict[str, Any]:
        return {
            "id": self.id,
            "action": self.action.value,
            "resource": self.resource.value,
            "resource_id": self.resource_id,
            "user_id": self.user_id,
            "org_id": self.org_id,
            "details": self.details,
            "timestamp": self.timestamp.isoformat(),
            "correlation_id": self.correlation_id,
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> AuditEntry:
        return cls(
            id=data["id"],
            action=AuditAction(data["action"]),
            resource=ResourceType(data["resource"]),
            resource_id=data["resource_id"],
            user_id=data.get("user_id"),
            org_id=data.get("org_id"),
            details=data.get("details", {}),
            timestamp=datetime.fromisoformat(data["timestamp"]) if "timestamp" in data else datetime.now(timezone.utc),
            correlation_id=data.get("correlation_id"),
        )


@dataclass
class SandboxConfig:
    level: SandboxLevel = SandboxLevel.NONE
    allowed_paths: list[str] = field(default_factory=list)
    allowed_commands: list[str] = field(default_factory=list)
    allowed_networks: list[str] = field(default_factory=list)
    memory_limit_mb: int = 512
    time_limit_seconds: int = 60
    disable_network: bool = False
    disable_filesystem: bool = False
    read_only: bool = False

    def to_json(self) -> dict[str, Any]:
        return {
            "level": self.level.value,
            "allowed_paths": self.allowed_paths,
            "allowed_commands": self.allowed_commands,
            "allowed_networks": self.allowed_networks,
            "memory_limit_mb": self.memory_limit_mb,
            "time_limit_seconds": self.time_limit_seconds,
            "disable_network": self.disable_network,
            "disable_filesystem": self.disable_filesystem,
            "read_only": self.read_only,
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> SandboxConfig:
        return cls(
            level=SandboxLevel(data.get("level", SandboxLevel.NONE.value)),
            allowed_paths=data.get("allowed_paths", []),
            allowed_commands=data.get("allowed_commands", []),
            allowed_networks=data.get("allowed_networks", []),
            memory_limit_mb=data.get("memory_limit_mb", 512),
            time_limit_seconds=data.get("time_limit_seconds", 60),
            disable_network=data.get("disable_network", False),
            disable_filesystem=data.get("disable_filesystem", False),
            read_only=data.get("read_only", False),
        )
