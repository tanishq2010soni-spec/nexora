from __future__ import annotations

from abc import ABC, abstractmethod
from typing import Any

from nexora_ai.domain.entities.configuration import ConfigValidationResult


class ConfigInterface(ABC):
    @abstractmethod
    async def get(self, key: str, default: Any = None) -> Any: ...

    @abstractmethod
    async def set(self, key: str, value: Any, layer: str) -> bool: ...

    @abstractmethod
    async def delete(self, key: str, layer: str) -> bool: ...

    @abstractmethod
    async def get_all(self, layer: str | None = None) -> dict: ...

    @abstractmethod
    async def has(self, key: str) -> bool: ...

    @abstractmethod
    async def validate(self, schema: dict) -> ConfigValidationResult: ...

    @abstractmethod
    async def reload(self) -> bool: ...

    @abstractmethod
    async def encrypt_value(self, key: str) -> str: ...

    @abstractmethod
    async def decrypt_value(self, key: str) -> str: ...

    @abstractmethod
    async def export(self, layer: str) -> dict: ...

    @abstractmethod
    async def import_config(self, data: dict, layer: str, overwrite: bool) -> int: ...
