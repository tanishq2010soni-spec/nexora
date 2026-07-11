from __future__ import annotations

from typing import Any

import pytest


class FakeGLMProviderAdapter:

    BASE_URL = "https://open.bigmodel.cn/api/paas/v4"

    def __init__(self, config: dict[str, Any]) -> None:
        self._config = config
        self._api_key: str = config.get("api_key", "")
        self._model: str = config.get("model", "glm-4-flash")
        self._embedding_model: str = config.get("embedding_model", "glm-embedding-v3")
        self._max_tokens: int = config.get("max_tokens", 4096)
        self._temperature: float = config.get("temperature", 0.7)
        self._call_count = 0

    async def chat(
        self,
        messages: list[dict[str, Any]],
        config: dict[str, Any] | None = None,
    ) -> Any:
        self._call_count += 1
        cfg = {**(config or {})}
        stream = cfg.get("stream", True)
        content = cfg.get("mock_response", f"GLM response to: {messages[-1].get('content', '')}")

        from collections.abc import AsyncIterator
        from nexora_ai.domain.entities.conversation import StreamingChunk

        async def _generate() -> AsyncIterator[StreamingChunk]:
            if stream:
                for chunk_text in content.split(" "):
                    yield StreamingChunk(
                        content=chunk_text + " ",
                        finish_reason=None,
                        usage=None,
                        provider="glm",
                        model=self._model,
                    )
            yield StreamingChunk(
                content=content if not stream else "",
                finish_reason="stop",
                usage={"prompt_tokens": 10, "completion_tokens": 5, "total_tokens": 15},
                provider="glm",
                model=self._model,
            )

        return _generate()

    async def complete(self, prompt: str, config: dict[str, Any] | None = None) -> str:
        self._call_count += 1
        cfg = {**(config or {})}
        return cfg.get("mock_response", f"GLM completion for: {prompt}")

    async def embed(
        self,
        texts: list[str],
        config: dict[str, Any] | None = None,
    ) -> list[list[float]]:
        self._call_count += 1
        dimension = (config or {}).get("embedding_dimension", 4)
        return [[float(i + j * 0.1) for i in range(dimension)] for j in range(len(texts))]

    async def generate_tool_call(
        self,
        messages: list[dict[str, Any]],
        tools: list[dict[str, Any]],
        config: dict[str, Any] | None = None,
    ) -> dict[str, Any]:
        self._call_count += 1
        return {
            "role": "assistant",
            "content": "",
            "tool_calls": [{"id": "call_1", "type": "function", "function": {"name": "test_tool", "arguments": '{"a": 1}'}}],
        }


@pytest.fixture
def glm_adapter() -> FakeGLMProviderAdapter:
    return FakeGLMProviderAdapter({
        "api_key": "test_key",
        "model": "glm-4-flash",
    })


class TestGLMAdapter:

    async def test_initialization(self, glm_adapter: FakeGLMProviderAdapter) -> None:
        assert glm_adapter._api_key == "test_key"
        assert glm_adapter._model == "glm-4-flash"
        assert glm_adapter._embedding_model == "glm-embedding-v3"
        assert glm_adapter._max_tokens == 4096
        assert glm_adapter._temperature == 0.7

    async def test_chat_request_format(self, glm_adapter: FakeGLMProviderAdapter) -> None:
        messages = [{"role": "user", "content": "Hello"}]
        gen = await glm_adapter.chat(messages, {"stream": False})
        chunks = [chunk async for chunk in gen]
        assert len(chunks) > 0
        full = "".join(c.content for c in chunks)
        assert "GLM response" in full

    async def test_streaming_response_parsing(self, glm_adapter: FakeGLMProviderAdapter) -> None:
        messages = [{"role": "user", "content": "Tell me a story"}]
        gen = await glm_adapter.chat(messages, {"stream": True, "mock_response": "Once upon a time"})
        chunks = [chunk async for chunk in gen]
        full = "".join(c.content for c in chunks)
        assert "Once" in full
        assert chunks[-1].finish_reason == "stop"

    async def test_error_handling(self, glm_adapter: FakeGLMProviderAdapter) -> None:
        messages = [{"role": "user", "content": "Hi"}]
        gen = await glm_adapter.chat(messages, {"stream": False, "mock_response": ""})
        chunks = [chunk async for chunk in gen]
        full = "".join(c.content for c in chunks)
        assert isinstance(full, str)

        result = await glm_adapter.complete("test")
        assert isinstance(result, str)

    async def test_embedding(self, glm_adapter: FakeGLMProviderAdapter) -> None:
        texts = ["hello world", "test embedding"]
        embeddings = await glm_adapter.embed(texts)
        assert len(embeddings) == 2
        assert len(embeddings[0]) == 4
        assert all(isinstance(v, float) for v in embeddings[0])
