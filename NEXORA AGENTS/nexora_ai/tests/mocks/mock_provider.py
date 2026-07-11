from __future__ import annotations

import asyncio
from collections.abc import AsyncIterator
from typing import Any

from nexora_ai.domain.entities.conversation import StreamingChunk
from nexora_ai.domain.enums.provider_enums import ProviderStatus, ProviderType
from nexora_ai.domain.interfaces.provider_interface import ProviderInterface


class MockProviderAdapter(ProviderInterface):

    def __init__(self, config: dict[str, Any] | None = None) -> None:
        self._config = config or {}
        self._provider_type = ProviderType.MOCK.value
        self._status = ProviderStatus.ACTIVE
        self._last_error: str | None = None
        self._call_count = 0
        self._chat_history: list[list[dict[str, Any]]] = []
        self._embed_calls: list[list[str]] = []
        self._tool_call_calls: list[tuple[list[dict[str, Any]], list[dict[str, Any]]]] = []
        self._responses: dict[str, Any] = {}
        self._latency_seconds = 0.0

    @property
    def provider_type(self) -> str:
        return self._provider_type

    @property
    def status(self) -> ProviderStatus:
        return self._status

    @status.setter
    def status(self, value: ProviderStatus) -> None:
        self._status = value

    @property
    def last_error(self) -> str | None:
        return self._last_error

    def set_response(self, key: str, response: Any) -> None:
        self._responses[key] = response

    def set_latency(self, seconds: float) -> None:
        self._latency_seconds = seconds

    async def _maybe_sleep(self) -> None:
        if self._latency_seconds > 0:
            await asyncio.sleep(self._latency_seconds)

    async def chat(
        self,
        messages: list[dict[str, Any]],
        config: dict[str, Any] | None = None,
    ) -> AsyncIterator[StreamingChunk]:
        self._call_count += 1
        self._chat_history.append(messages)
        await self._maybe_sleep()

        cfg = {**(config or {})}
        stream = cfg.get("stream", True)
        response_key = cfg.get("response_key", "default_chat")

        if response_key in self._responses:
            content = self._responses[response_key]
        else:
            content = f"Mock response to: {messages[-1].get('content', '')}"

        if stream:
            words = content.split(" ")
            for i, word in enumerate(words):
                yield StreamingChunk(
                    content=word + (" " if i < len(words) - 1 else ""),
                    finish_reason=None,
                    usage=None,
                    provider=self._provider_type,
                    model=cfg.get("model", "mock-model"),
                )
                await asyncio.sleep(0.01)
            yield StreamingChunk(
                content="",
                finish_reason="stop",
                usage={"prompt_tokens": 10, "completion_tokens": len(words), "total_tokens": 10 + len(words)},
                provider=self._provider_type,
                model=cfg.get("model", "mock-model"),
            )
        else:
            yield StreamingChunk(
                content=content,
                finish_reason="stop",
                usage={"prompt_tokens": 10, "completion_tokens": len(content.split()), "total_tokens": 10 + len(content.split())},
                provider=self._provider_type,
                model=cfg.get("model", "mock-model"),
            )

    async def complete(
        self,
        prompt: str,
        config: dict[str, Any] | None = None,
    ) -> str:
        self._call_count += 1
        await self._maybe_sleep()
        cfg = {**(config or {})}
        response_key = cfg.get("response_key", "default_complete")
        if response_key in self._responses:
            return self._responses[response_key]
        return f"Mock completion for: {prompt}"

    async def embed(
        self,
        texts: list[str],
        config: dict[str, Any] | None = None,
    ) -> list[list[float]]:
        self._call_count += 1
        self._embed_calls.append(texts)
        await self._maybe_sleep()
        dimension = (config or {}).get("embedding_dimension", 4)
        return [[float(i + j * 0.1) for i in range(dimension)] for j in range(len(texts))]

    async def generate_tool_call(
        self,
        messages: list[dict[str, Any]],
        tools: list[dict[str, Any]],
        config: dict[str, Any] | None = None,
    ) -> dict[str, Any]:
        self._call_count += 1
        self._tool_call_calls.append((messages, tools))
        await self._maybe_sleep()
        cfg = {**(config or {})}
        response_key = cfg.get("response_key", "default_tool_call")
        if response_key in self._responses:
            return self._responses[response_key]
        return {
            "role": "assistant",
            "content": "",
            "tool_calls": [{"id": "mock_call_1", "type": "function", "function": {"name": "mock_tool", "arguments": '{"arg": "val"}'}}],
            "usage": {"prompt_tokens": 10, "completion_tokens": 5, "total_tokens": 15},
        }

    async def get_models(self) -> list[str]:
        return list(self._config.get("models", ["mock-model"]))

    async def get_status(self) -> ProviderStatus:
        return self._status

    async def get_capabilities(self) -> list[ModelCapability]:
        from nexora_ai.domain.enums.provider_enums import ModelCapability
        cfg_caps = self._config.get("capabilities", None)
        if cfg_caps:
            return [ModelCapability(c) for c in cfg_caps]
        return [ModelCapability.CHAT, ModelCapability.STREAMING, ModelCapability.EMBEDDING]

    async def validate_config(self, config: dict) -> bool:
        return "model" in config

    async def close(self) -> None:
        pass
