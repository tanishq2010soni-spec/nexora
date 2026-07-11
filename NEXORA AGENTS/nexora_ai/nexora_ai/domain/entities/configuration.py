from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any


@dataclass
class ConfigEntry:
    key: str
    value: Any
    source: str = "manual"
    encrypted: bool = False
    schema: dict[str, Any] | None = None
    validators: list[str] = field(default_factory=list)

    def to_json(self) -> dict[str, Any]:
        return {
            "key": self.key,
            "value": self.value,
            "source": self.source,
            "encrypted": self.encrypted,
            "schema": self.schema,
            "validators": self.validators,
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> ConfigEntry:
        return cls(
            key=data["key"],
            value=data["value"],
            source=data.get("source", "manual"),
            encrypted=data.get("encrypted", False),
            schema=data.get("schema"),
            validators=data.get("validators", []),
        )


@dataclass
class ConfigLayer:
    name: str
    priority: int = 0
    entries: dict[str, ConfigEntry] = field(default_factory=dict)

    def to_json(self) -> dict[str, Any]:
        return {
            "name": self.name,
            "priority": self.priority,
            "entries": {k: v.to_json() for k, v in self.entries.items()},
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> ConfigLayer:
        return cls(
            name=data["name"],
            priority=data.get("priority", 0),
            entries={k: ConfigEntry.from_json(v) for k, v in data.get("entries", {}).items()},
        )


@dataclass
class ConfigValidationResult:
    valid: bool = True
    errors: list[str] = field(default_factory=list)
    warnings: list[str] = field(default_factory=list)

    def to_json(self) -> dict[str, Any]:
        return {
            "valid": self.valid,
            "errors": self.errors,
            "warnings": self.warnings,
        }

    @classmethod
    def from_json(cls, data: dict[str, Any]) -> ConfigValidationResult:
        return cls(
            valid=data.get("valid", True),
            errors=data.get("errors", []),
            warnings=data.get("warnings", []),
        )
