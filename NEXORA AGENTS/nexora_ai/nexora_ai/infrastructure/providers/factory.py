from typing import Any

from nexora_ai.domain.enums.provider_enums import ProviderType
from nexora_ai.domain.interfaces.provider_interface import ProviderInterface
from nexora_ai.infrastructure.providers.anthropic import AnthropicProviderAdapter
from nexora_ai.infrastructure.providers.deepseek import DeepSeekProviderAdapter
from nexora_ai.infrastructure.providers.glm import GLMProviderAdapter
from nexora_ai.infrastructure.providers.groq import GroqProviderAdapter
from nexora_ai.infrastructure.providers.lm_studio import LMStudioProviderAdapter
from nexora_ai.infrastructure.providers.mistral import MistralProviderAdapter
from nexora_ai.infrastructure.providers.mock import MockProviderAdapter
from nexora_ai.infrastructure.providers.ollama import OllamaProviderAdapter
from nexora_ai.infrastructure.providers.openai import OpenAIProviderAdapter
from nexora_ai.infrastructure.providers.openai_compatible import (
    GeminiProviderAdapter,
    OpenRouterProviderAdapter,
)


class ProviderFactoryError(Exception):
    ...


class ProviderFactory:

    _registry: dict[ProviderType, type[ProviderInterface]] = {
        ProviderType.GLM: GLMProviderAdapter,
        ProviderType.OPENAI: OpenAIProviderAdapter,
        ProviderType.ANTHROPIC: AnthropicProviderAdapter,
        ProviderType.GEMINI: GeminiProviderAdapter,
        ProviderType.DEEPSEEK: DeepSeekProviderAdapter,
        ProviderType.OPENROUTER: OpenRouterProviderAdapter,
        ProviderType.GROQ: GroqProviderAdapter,
        ProviderType.OLLAMA: OllamaProviderAdapter,
        ProviderType.LM_STUDIO: LMStudioProviderAdapter,
        ProviderType.MISTRAL: MistralProviderAdapter,
        ProviderType.MOCK: MockProviderAdapter,
    }

    @classmethod
    def create(
        cls,
        provider_type: ProviderType,
        config: dict[str, Any] | None = None,
    ) -> ProviderInterface:
        adapter_cls = cls._registry.get(provider_type)
        if adapter_cls is None:
            raise ProviderFactoryError(
                f"No adapter registered for provider type: {provider_type}"
            )
        return adapter_cls(config or {})

    @classmethod
    def register(
        cls,
        provider_type: ProviderType,
        adapter_cls: type[ProviderInterface],
    ) -> None:
        if not issubclass(adapter_cls, ProviderInterface):
            raise ProviderFactoryError(
                f"Adapter class must implement ProviderInterface"
            )
        cls._registry[provider_type] = adapter_cls

    @classmethod
    def unregister(cls, provider_type: ProviderType) -> None:
        cls._registry.pop(provider_type, None)

    @classmethod
    def list_registered(cls) -> list[ProviderType]:
        return list(cls._registry.keys())
