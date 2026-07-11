from __future__ import annotations

from abc import ABC, abstractmethod
from collections.abc import AsyncIterator
from typing import Any

from nexora_ai.domain.entities.conversation import StreamingChunk
from nexora_ai.domain.enums.provider_enums import ModelCapability, ProviderStatus


class ProviderInterface(ABC):

    @abstractmethod
    async def chat(
        self,
        messages: list[dict],
        config: dict | None = None,
    ) -> AsyncIterator[StreamingChunk]: ...

    @abstractmethod
    async def complete(
        self,
        prompt: str,
        config: dict | None = None,
    ) -> str: ...

    @abstractmethod
    async def embed(
        self,
        texts: list[str],
        config: dict | None = None,
    ) -> list[list[float]]: ...

    @abstractmethod
    async def get_models(self) -> list[str]: ...

    @abstractmethod
    async def get_status(self) -> ProviderStatus: ...

    @abstractmethod
    async def get_capabilities(self) -> list[ModelCapability]: ...

    @abstractmethod
    async def validate_config(self, config: dict) -> bool: ...

    @abstractmethod
    async def generate_tool_call(
        self,
        messages: list[dict],
        tools: list[dict],
        config: dict | None = None,
    ) -> dict: ...
