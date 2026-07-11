from __future__ import annotations

from collections.abc import AsyncIterator
from typing import Any

import pytest

from nexora_ai.domain.entities.conversation import StreamingChunk
from nexora_ai.domain.enums.provider_enums import ModelCapability, ProviderStatus
from nexora_ai.domain.interfaces.provider_interface import ProviderInterface
from tests.mocks import MockProviderAdapter

REQUIRED_METHODS = [
    "chat",
    "complete",
    "embed",
    "generate_tool_call",
]


class SkeletonProvider(ProviderInterface):

    async def chat(self, messages: list[dict[str, Any]], config: dict[str, Any] | None = None) -> AsyncIterator[StreamingChunk]:
        raise NotImplementedError

    async def complete(self, prompt: str, config: dict[str, Any] | None = None) -> str:
        raise NotImplementedError

    async def embed(self, texts: list[str], config: dict[str, Any] | None = None) -> list[list[float]]:
        raise NotImplementedError

    async def generate_tool_call(self, messages: list[dict[str, Any]], tools: list[dict[str, Any]], config: dict[str, Any] | None = None) -> dict[str, Any]:
        raise NotImplementedError

    async def get_models(self) -> list[str]:
        raise NotImplementedError

    async def get_status(self) -> ProviderStatus:
        raise NotImplementedError

    async def get_capabilities(self) -> list[ModelCapability]:
        raise NotImplementedError

    async def validate_config(self, config: dict) -> bool:
        raise NotImplementedError


def get_all_providers() -> list[tuple[str, type[ProviderInterface]]]:
    """Import and return all provider adapter classes."""
    providers: list[tuple[str, type[ProviderInterface]]] = [
        ("MockProviderAdapter", MockProviderAdapter),
        ("SkeletonProvider", SkeletonProvider),
    ]
    try:
        from nexora_ai.infrastructure.providers.glm import GLMProviderAdapter
        providers.append(("GLMProviderAdapter", GLMProviderAdapter))
    except ImportError:
        pass
    try:
        from nexora_ai.infrastructure.providers.openai import OpenAIProviderAdapter
        providers.append(("OpenAIProviderAdapter", OpenAIProviderAdapter))
    except ImportError:
        pass
    try:
        from nexora_ai.infrastructure.providers.anthropic import AnthropicProviderAdapter
        providers.append(("AnthropicProviderAdapter", AnthropicProviderAdapter))
    except ImportError:
        pass
    try:
        from nexora_ai.infrastructure.providers.gemini import GeminiProviderAdapter
        providers.append(("GeminiProviderAdapter", GeminiProviderAdapter))
    except ImportError:
        pass
    try:
        from nexora_ai.infrastructure.providers.deepseek import DeepSeekProviderAdapter
        providers.append(("DeepSeekProviderAdapter", DeepSeekProviderAdapter))
    except ImportError:
        pass
    try:
        from nexora_ai.infrastructure.providers.groq import GroqProviderAdapter
        providers.append(("GroqProviderAdapter", GroqProviderAdapter))
    except ImportError:
        pass
    try:
        from nexora_ai.infrastructure.providers.mistral import MistralProviderAdapter
        providers.append(("MistralProviderAdapter", MistralProviderAdapter))
    except ImportError:
        pass
    try:
        from nexora_ai.infrastructure.providers.ollama import OllamaProviderAdapter
        providers.append(("OllamaProviderAdapter", OllamaProviderAdapter))
    except ImportError:
        pass
    try:
        from nexora_ai.infrastructure.providers.lm_studio import LMStudioProviderAdapter
        providers.append(("LMStudioProviderAdapter", LMStudioProviderAdapter))
    except ImportError:
        pass
    return providers


class TestProviderContract:

    @pytest.mark.parametrize("name,provider_class", get_all_providers())
    def test_all_providers_have_required_methods(self, name: str, provider_class: type) -> None:
        for method in REQUIRED_METHODS:
            assert hasattr(provider_class, method), f"{name} missing method: {method}"
            assert callable(getattr(provider_class, method)), f"{name}.{method} is not callable"

    @pytest.mark.parametrize("name,provider_class", get_all_providers())
    def test_all_providers_return_correct_types(self, name: str, provider_class: type) -> None:
        instance = provider_class({}) if name != "SkeletonProvider" else provider_class()
        import inspect

        sig = inspect.signature(instance.chat)
        return_annotation = sig.return_annotation
        assert "AsyncIterator" in str(return_annotation) or "StreamingChunk" in str(return_annotation) or return_annotation is inspect.Parameter.empty

        sig = inspect.signature(instance.complete)
        return_annotation = sig.return_annotation
        assert return_annotation is str or return_annotation == 'str' or return_annotation is inspect.Parameter.empty

        sig = inspect.signature(instance.embed)
        return_annotation = sig.return_annotation
        assert "list" in str(return_annotation).lower() or return_annotation is inspect.Parameter.empty

    @pytest.mark.asyncio
    async def test_mock_provider_meets_contract(self) -> None:
        provider = MockProviderAdapter({"model": "test"})
        assert isinstance(provider, ProviderInterface)

        async for chunk in provider.chat([{"role": "user", "content": "hello"}]):
            assert isinstance(chunk, StreamingChunk)
            break

        result = await provider.complete("test prompt")
        assert isinstance(result, str)
        assert len(result) > 0

        embeddings = await provider.embed(["text1", "text2"])
        assert isinstance(embeddings, list)
        assert len(embeddings) == 2
        assert all(isinstance(e, list) for e in embeddings)

        tool_result = await provider.generate_tool_call(
            [{"role": "user", "content": "call tool"}],
            [{"name": "test", "description": "test tool"}],
        )
        assert isinstance(tool_result, dict)
        assert "role" in tool_result
        assert "tool_calls" in tool_result

    @pytest.mark.asyncio
    async def test_skeleton_providers_raise_not_implemented(self) -> None:
        provider = SkeletonProvider()

        with pytest.raises(NotImplementedError):
            await provider.complete("test")

        with pytest.raises(NotImplementedError):
            await provider.embed(["test"])

        with pytest.raises(NotImplementedError):
            await provider.generate_tool_call([{"role": "user", "content": "hi"}], [{"name": "test"}])

        with pytest.raises(NotImplementedError):
            await provider.chat([{"role": "user", "content": "hi"}])
