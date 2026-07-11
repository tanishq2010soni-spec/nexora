from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any

from nexora_ai.domain.enums.plugin_enums import PluginPermissionScope, PluginStatus


@dataclass
class PluginDependency:
    name: str
    version: str
    optional: bool = False

    def to_json(self) -> dict[str, Any]:
        return {
            "name": self.name,
            "version": self.version,
            "optional": self.optional,
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> PluginDependency:
        return cls(
            name=data["name"],
            version=data["version"],
            optional=data.get("optional", False),
        )


@dataclass
class PluginManifest:
    name: str
    version: str
    description: str = ""
    author: str = ""
    license: str = ""
    dependencies: list[PluginDependency] = field(default_factory=list)
    permissions: list[PluginPermissionScope] = field(default_factory=list)
    hooks: list[str] = field(default_factory=list)
    capabilities: list[str] = field(default_factory=list)
    entry_point: str = ""
    metadata: dict[str, Any] = field(default_factory=dict)

    def to_json(self) -> dict[str, Any]:
        return {
            "name": self.name,
            "version": self.version,
            "description": self.description,
            "author": self.author,
            "license": self.license,
            "dependencies": [d.to_json() for d in self.dependencies],
            "permissions": [p.value for p in self.permissions],
            "hooks": self.hooks,
            "capabilities": self.capabilities,
            "entry_point": self.entry_point,
            "metadata": self.metadata,
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> PluginManifest:
        return cls(
            name=data["name"],
            version=data["version"],
            description=data.get("description", ""),
            author=data.get("author", ""),
            license=data.get("license", ""),
            dependencies=[PluginDependency.from_json(d) for d in data.get("dependencies", [])],
            permissions=[PluginPermissionScope(p) for p in data.get("permissions", [])],
            hooks=data.get("hooks", []),
            capabilities=data.get("capabilities", []),
            entry_point=data.get("entry_point", ""),
            metadata=data.get("metadata", {}),
        )


@dataclass
class PluginInstance:
    id: str
    manifest: PluginManifest
    status: PluginStatus = PluginStatus.INSTALLED
    config: dict[str, Any] = field(default_factory=dict)
    loaded_at: datetime = field(default_factory=lambda: datetime.now(timezone.utc))
    health: str = "unknown"

    def to_json(self) -> dict[str, Any]:
        return {
            "id": self.id,
            "manifest": self.manifest.to_json(),
            "status": self.status.value,
            "config": self.config,
            "loaded_at": self.loaded_at.isoformat(),
            "health": self.health,
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> PluginInstance:
        return cls(
            id=data["id"],
            manifest=PluginManifest.from_json(data["manifest"]),
            status=PluginStatus(data.get("status", PluginStatus.INSTALLED.value)),
            config=data.get("config", {}),
            loaded_at=datetime.fromisoformat(data["loaded_at"]) if "loaded_at" in data else datetime.now(timezone.utc),
            health=data.get("health", "unknown"),
        )
