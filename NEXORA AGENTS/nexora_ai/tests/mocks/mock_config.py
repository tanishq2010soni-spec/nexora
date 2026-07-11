from __future__ import annotations

from typing import Any


class MockConfigManager:

    def __init__(self, defaults: dict[str, Any] | None = None) -> None:
        self._config: dict[str, Any] = dict(defaults or {})
        self._encrypted_keys: set[str] = set()
        self._validation_errors: list[str] = []
        self._env_overrides: dict[str, Any] = {}

    def get(self, key: str, default: Any = None) -> Any:
        keys = key.split(".")
        value: Any = self._config
        try:
            for k in keys:
                if isinstance(value, dict):
                    value = value[k]
                else:
                    return default
            return value
        except (KeyError, TypeError):
            return default

    def set(self, key: str, value: Any) -> None:
        keys = key.split(".")
        target = self._config
        for k in keys[:-1]:
            if k not in target:
                target[k] = {}
            target = target[k]
        target[keys[-1]] = value

    def set_encrypted(self, key: str, value: str) -> None:
        self.set(key, value)
        self._encrypted_keys.add(key)

    def is_encrypted(self, key: str) -> bool:
        return key in self._encrypted_keys

    def set_env_override(self, key: str, value: Any) -> None:
        self._env_overrides[key] = value

    def get_with_override(self, key: str, default: Any = None) -> Any:
        if key in self._env_overrides:
            return self._env_overrides[key]
        return self.get(key, default)

    def validate(self, schema: dict[str, Any]) -> list[str]:
        self._validation_errors = []
        for key, expected_type in schema.items():
            value = self.get(key)
            if value is None:
                self._validation_errors.append(f"Missing required key: {key}")
            elif not isinstance(value, expected_type):
                self._validation_errors.append(
                    f"Key '{key}' expected {expected_type.__name__}, got {type(value).__name__}"
                )
        return list(self._validation_errors)

    def export_config(self) -> dict[str, Any]:
        import json
        return json.loads(json.dumps(self._config))

    def import_config(self, data: dict[str, Any]) -> None:
        self._config = dict(data)

    def load_defaults(self, defaults: dict[str, Any]) -> None:
        for key, value in defaults.items():
            if self.get(key) is None:
                self.set(key, value)

    def all(self) -> dict[str, Any]:
        return dict(self._config)

    def clear(self) -> None:
        self._config.clear()
        self._encrypted_keys.clear()
        self._env_overrides.clear()
