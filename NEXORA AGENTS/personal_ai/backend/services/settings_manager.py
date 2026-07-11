from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from nexora_ai.domain.enums.event_enums import EventType
from nexora_ai.domain.interfaces.event_bus_interface import EventBusInterface
from nexora_ai.domain.interfaces.logging_interface import LoggingInterface


class AppSettings:
    def __init__(
        self,
        model: str = "gpt-4o",
        temperature: float = 0.7,
        memory_limit: int = 10000,
        tool_permissions: dict[str, bool] | None = None,
        theme: str = "dark",
        voice_enabled: bool = False,
        language: str = "en",
        workspace: str = "",
        plugins_enabled: list[str] | None = None,
        automation_enabled: bool = True,
        max_conversation_history: int = 100,
        context_window: int = 8192,
    ) -> None:
        self.model = model
        self.temperature = temperature
        self.memory_limit = memory_limit
        self.tool_permissions = tool_permissions or {}
        self.theme = theme
        self.voice_enabled = voice_enabled
        self.language = language
        self.workspace = workspace
        self.plugins_enabled = plugins_enabled or []
        self.automation_enabled = automation_enabled
        self.max_conversation_history = max_conversation_history
        self.context_window = context_window

    def to_dict(self) -> dict[str, Any]:
        return {
            "model": self.model,
            "temperature": self.temperature,
            "memory_limit": self.memory_limit,
            "tool_permissions": self.tool_permissions,
            "theme": self.theme,
            "voice_enabled": self.voice_enabled,
            "language": self.language,
            "workspace": self.workspace,
            "plugins_enabled": self.plugins_enabled,
            "automation_enabled": self.automation_enabled,
            "max_conversation_history": self.max_conversation_history,
            "context_window": self.context_window,
        }

    @classmethod
    def from_dict(cls, data: dict[str, Any]) -> AppSettings:
        return cls(
            model=data.get("model", "gpt-4o"),
            temperature=float(data.get("temperature", 0.7)),
            memory_limit=int(data.get("memory_limit", 10000)),
            tool_permissions=data.get("tool_permissions", {}),
            theme=data.get("theme", "dark"),
            voice_enabled=bool(data.get("voice_enabled", False)),
            language=data.get("language", "en"),
            workspace=data.get("workspace", ""),
            plugins_enabled=data.get("plugins_enabled", []),
            automation_enabled=bool(data.get("automation_enabled", True)),
            max_conversation_history=int(data.get("max_conversation_history", 100)),
            context_window=int(data.get("context_window", 8192)),
        )


_VALIDATORS: dict[str, Any] = {
    "model": str,
    "temperature": lambda v: 0.0 <= float(v) <= 2.0,
    "memory_limit": lambda v: int(v) > 0,
    "theme": str,
    "voice_enabled": bool,
    "language": str,
    "workspace": str,
    "automation_enabled": bool,
    "max_conversation_history": lambda v: int(v) > 0,
    "context_window": lambda v: int(v) in (2048, 4096, 8192, 16384, 32768, 65536, 131072),
}


class SettingsManager:
    def __init__(
        self,
        event_bus: EventBusInterface,
        logger: LoggingInterface,
        settings_path: str | Path | None = None,
    ) -> None:
        self._event_bus = event_bus
        self._logger = logger
        if settings_path is None:
            user_data_dir = Path.home() / ".personal_ai"
            settings_path = user_data_dir / "settings.json"
        self._settings_path = Path(settings_path)
        self._settings_path.parent.mkdir(parents=True, exist_ok=True)
        self._settings: AppSettings = AppSettings()
        self._listeners: list[Any] = []

    async def load(self) -> AppSettings:
        if not self._settings_path.exists():
            self._settings = AppSettings()
            await self._save()
            return self._settings
        try:
            raw = self._settings_path.read_text(encoding="utf-8")
            data = json.loads(raw)
            self._settings = AppSettings.from_dict(data)
            await self._logger.info("Settings loaded", category="settings")
        except Exception as exc:
            await self._logger.error(f"Failed to load settings: {exc}", category="settings")
            self._settings = AppSettings()
        return self._settings

    async def get_all(self) -> dict[str, Any]:
        return self._settings.to_dict()

    async def get(self, key: str) -> Any:
        return getattr(self._settings, key, None)

    async def set(self, key: str, value: Any) -> bool:
        if not hasattr(self._settings, key):
            return False
        validator = _VALIDATORS.get(key)
        if validator is not None:
            if validator is bool and not isinstance(value, bool):
                return False
            if validator is str and not isinstance(value, str):
                return False
            if callable(validator) and not validator(value):
                return False
        setattr(self._settings, key, value)
        await self._save()
        await self._event_bus.publish(EventType.SYSTEM, {"action": "settings_changed", "key": key, "value": value})
        for listener in self._listeners:
            try:
                listener(key, value)
            except Exception:
                pass
        return True

    async def update(self, settings: dict[str, Any]) -> dict[str, bool]:
        results: dict[str, bool] = {}
        for key, value in settings.items():
            results[key] = await self.set(key, value)
        return results

    async def _save(self) -> None:
        try:
            self._settings_path.write_text(
                json.dumps(self._settings.to_dict(), indent=2, default=str),
                encoding="utf-8",
            )
        except Exception as exc:
            await self._logger.error(f"Failed to save settings: {exc}", category="settings")

    def on_change(self, listener: Any) -> None:
        self._listeners.append(listener)
