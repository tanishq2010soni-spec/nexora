from __future__ import annotations

import json
import os
import re
from collections.abc import Callable
from enum import IntEnum
from pathlib import Path
from typing import Any

from nexora_ai.domain.interfaces.config_interface import ConfigInterface
from nexora_ai.infrastructure.config.encryptor import ConfigEncryptor

import asyncio


class ConfigLayer(IntEnum):
    DEFAULT = 0
    ENV = 1
    FILE = 2
    USER = 3
    RUNTIME = 4


class SchemaField:
    def __init__(
        self,
        type_: type = str,
        required: bool = False,
        default: Any = None,
        constraints: list[Callable[[Any], bool]] | None = None,
        encrypted: bool = False,
    ) -> None:
        self.type_ = type_
        self.required = required
        self.default = default
        self.constraints = constraints or []
        self.encrypted = encrypted


class ConfigManager(ConfigInterface):
    _ENV_PREFIX = "NEXORA_AI_"

    def __init__(
        self,
        config_files: list[str | Path] | None = None,
        schema: dict[str, SchemaField] | None = None,
        encryptor: ConfigEncryptor | None = None,
        encryption_key: bytes | None = None,
    ) -> None:
        self._encryptor = encryptor or ConfigEncryptor()
        self._encryption_key = encryption_key
        self._layers: dict[ConfigLayer, dict[str, Any]] = {
            ConfigLayer.DEFAULT: {},
            ConfigLayer.ENV: {},
            ConfigLayer.FILE: {},
            ConfigLayer.USER: {},
            ConfigLayer.RUNTIME: {},
        }
        self._schema: dict[str, SchemaField] = schema or {}
        self._config_files: list[Path] = [Path(f) for f in (config_files or [])]
        self._watchers: list[Callable[[dict[str, Any]], None]] = []
        self._lock: asyncio.Lock = asyncio.Lock()

    async def set_defaults(self, defaults: dict[str, Any]) -> None:
        async with self._lock:
            self._layers[ConfigLayer.DEFAULT] = dict(defaults)

    async def load(self) -> None:
        async with self._lock:
            self._layers[ConfigLayer.ENV] = self._load_from_env()
            file_config: dict[str, Any] = {}
            for cfg_file in self._config_files:
                if cfg_file.exists():
                    try:
                        data = self._read_file(cfg_file)
                        file_config.update(data)
                    except Exception:
                        pass
            self._layers[ConfigLayer.FILE] = file_config

    async def save(self) -> None:
        async with self._lock:
            if self._config_files:
                file_path = self._config_files[0]
                file_path.parent.mkdir(parents=True, exist_ok=True)
                data = self._layers[ConfigLayer.FILE]
                self._write_file(file_path, data)

    async def get(self, key: str, default: Any = None) -> Any:
        async with self._lock:
            for layer in reversed(sorted(ConfigLayer)):
                if key in self._layers[layer]:
                    value = self._layers[layer][key]
                    field = self._schema.get(key)
                    if field and field.encrypted and self._encryption_key:
                        try:
                            value = self._encryptor.decrypt(str(value), self._encryption_key)
                        except Exception:
                            pass
                    return value
            field = self._schema.get(key)
            if field and field.default is not None:
                return field.default
            return default

    async def set(self, key: str, value: Any, layer: str = "runtime") -> bool:
        layer_enum = ConfigLayer[layer.upper()] if isinstance(layer, str) else layer
        async with self._lock:
            self._layers[layer_enum][key] = value
            await self._notify_watchers()
            return True

    async def has(self, key: str) -> bool:
        async with self._lock:
            for layer in reversed(sorted(ConfigLayer)):
                if key in self._layers[layer]:
                    return True
            return key in self._schema

    async def validate(self, schema: dict | None = None) -> ConfigValidationResult:
        from nexora_ai.domain.entities.configuration import ConfigValidationResult

        errors: list[str] = []
        warnings: list[str] = []
        target_schema = schema or self._schema
        async with self._lock:
            merged = self._merge_layers()
            for key, field in target_schema.items():
                value = merged.get(key, getattr(field, "default", None))
                required = getattr(field, "required", False)
                if required and value is None:
                    errors.append(f"Missing required field: {key}")
                    continue
                if value is not None:
                    type_ = getattr(field, "type_", None)
                    if type_ and not isinstance(value, type_):
                        errors.append(f"Field '{key}' expected type {type_.__name__}, got {type(value).__name__}")
                    constraints = getattr(field, "constraints", [])
                    for constraint in constraints:
                        if callable(constraint) and not constraint(value):
                            errors.append(f"Field '{key}' failed constraint check")
        return ConfigValidationResult(valid=len(errors) == 0, errors=errors, warnings=warnings)

    async def reload(self) -> bool:
        async with self._lock:
            self._layers[ConfigLayer.ENV] = self._load_from_env()
            file_config: dict[str, Any] = {}
            for cfg_file in self._config_files:
                if cfg_file.exists():
                    try:
                        data = self._read_file(cfg_file)
                        file_config.update(data)
                    except Exception:
                        pass
            self._layers[ConfigLayer.FILE] = file_config
            return True

    async def encrypt_value(self, key: str) -> str:
        async with self._lock:
            value = await self.get(key)
            if value is None:
                return ""
            if self._encryption_key:
                return self._encryptor.encrypt(str(value), self._encryption_key)
            return str(value)

    async def decrypt_value(self, key: str) -> str:
        async with self._lock:
            for layer in reversed(sorted(ConfigLayer)):
                if key in self._layers[layer]:
                    value = self._layers[layer][key]
                    if self._encryption_key:
                        try:
                            return self._encryptor.decrypt(str(value), self._encryption_key)
                        except Exception:
                            pass
                    return str(value)
            return ""

    async def export(self, layer: str | None = None) -> dict:
        async with self._lock:
            if layer:
                layer_enum = ConfigLayer[layer.upper()] if isinstance(layer, str) else layer
                return dict(self._layers.get(layer_enum, {}))
            return {layer.name: dict(data) for layer, data in self._layers.items()}

    async def export_config(self) -> dict[str, Any]:
        return await self.export()

    async def import_config(self, data: dict[str, Any], layer: str | None = None, overwrite: bool = True) -> int:
        async with self._lock:
            count = 0
            if layer:
                layer_enum = ConfigLayer[layer.upper()] if isinstance(layer, str) else layer
                target = self._layers[layer_enum]
                for key, value in data.items():
                    if overwrite or key not in target:
                        target[key] = value
                        count += 1
            else:
                for layer_name, layer_data in data.items():
                    try:
                        l_enum = ConfigLayer[layer_name]
                        if overwrite:
                            self._layers[l_enum] = dict(layer_data)
                            count += len(layer_data)
                        else:
                            for k, v in layer_data.items():
                                if k not in self._layers[l_enum]:
                                    self._layers[l_enum][k] = v
                                    count += 1
                    except (KeyError, ValueError):
                        pass
            return count

    async def watch(self, callback: Callable[[dict[str, Any]], None]) -> None:
        self._watchers.append(callback)

    async def _notify_watchers(self) -> None:
        merged = self._merge_layers()
        for callback in self._watchers:
            try:
                if asyncio.iscoroutinefunction(callback):
                    await callback(merged)
                else:
                    callback(merged)
            except Exception:
                pass

    def _load_from_env(self) -> dict[str, Any]:
        config: dict[str, Any] = {}
        prefix = self._ENV_PREFIX
        for env_key, env_value in os.environ.items():
            if env_key.startswith(prefix):
                config_key = env_key[len(prefix):].lower().replace("__", ".")
                config[config_key] = self._coerce_value(env_value)
        return config

    def _coerce_value(self, value: str) -> Any:
        if value.lower() in ("true", "1", "yes"):
            return True
        if value.lower() in ("false", "0", "no"):
            return False
        try:
            return int(value)
        except ValueError:
            pass
        try:
            return float(value)
        except ValueError:
            pass
        return value

    def _read_file(self, path: Path) -> dict[str, Any]:
        content = path.read_text(encoding="utf-8")
        if path.suffix in (".json",):
            return json.loads(content)
        if path.suffix in (".yaml", ".yml"):
            import yaml
            return yaml.safe_load(content)
        return {}

    def _write_file(self, path: Path, data: dict[str, Any]) -> None:
        if path.suffix in (".json",):
            path.write_text(json.dumps(data, indent=2, default=str), encoding="utf-8")
        elif path.suffix in (".yaml", ".yml"):
            import yaml
            path.write_text(yaml.dump(data, default_flow_style=False), encoding="utf-8")

    def _merge_layers(self) -> dict[str, Any]:
        merged: dict[str, Any] = {}
        for layer in sorted(ConfigLayer):
            merged.update(self._layers[layer])
        return merged



