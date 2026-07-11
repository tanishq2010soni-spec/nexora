# Production implementation requires mistralai package

from collections.abc import AsyncIterator
from typing import Any

from nexora_ai.domain.entities.conversation import StreamingChunk
from nexora_ai.domain.enums.provider_enums import ModelCapability, ProviderStatus, ProviderType
from nexora_ai.domain.interfaces.provider_interface import ProviderInterface


class MistralProviderAdapter(ProviderInterface):

    def __init__(self, config: dict[str, Any]) -> None:
        self._config = config
        self._provider_type = ProviderType.MISTRAL.value
        self._api_key: str = config.get("api_key", "")
        self._model: str = config.get("model", "mistral-large-latest")

    async def chat(
        self,
        messages: list[dict],
        config: dict | None = None,
    ) -> AsyncIterator[StreamingChunk]:
        raise NotImplementedError("Mistral adapter requires mistralai package")

    async def complete(
        self,
        prompt: str,
        config: dict | None = None,
    ) -> str:
        raise NotImplementedError("Mistral adapter requires mistralai package")

    async def embed(
        self,
        texts: list[str],
        config: dict | None = None,
    ) -> list[list[float]]:
        raise NotImplementedError("Mistral adapter requires mistralai package")

    async def get_models(self) -> list[str]:
        raise NotImplementedError("Mistral adapter requires mistralai package")

    async def get_status(self) -> ProviderStatus:
        raise NotImplementedError("Mistral adapter requires mistralai package")

    async def get_capabilities(self) -> list[ModelCapability]:
        raise NotImplementedError("Mistral adapter requires mistralai package")

    async def validate_config(self, config: dict) -> bool:
        raise NotImplementedError("Mistral adapter requires mistralai package")

    async def generate_tool_call(
        self,
        messages: list[dict],
        tools: list[dict],
        config: dict | None = None,
    ) -> dict:
        raise NotImplementedError("Mistral adapter requires mistralai package")
