import asyncio
import math
import random
from collections.abc import AsyncIterator
from typing import Any

from nexora_ai.domain.entities.conversation import StreamingChunk
from nexora_ai.domain.enums.provider_enums import ModelCapability, ProviderStatus, ProviderType
from nexora_ai.domain.interfaces.provider_interface import ProviderInterface


class MockProviderAdapter(ProviderInterface):

    def __init__(self, config: dict[str, Any]) -> None:
        self._config = config
        self._provider_type = ProviderType.MOCK.value
        self._response_content: str = config.get(
            "response_content",
            "This is a mock response from the test provider.",
        )
        self._stream_delay: float = config.get("stream_delay", 0.05)
        self._latency: float = config.get("latency", 0.0)
        self._error_rate: float = config.get("error_rate", 0.0)
        self._embedding_dimension: int = config.get("embedding_dimension", 128)
        self._seed: int = config.get("seed", 42)
        self._rng = random.Random(self._seed)
        self._models: list[str] = ["mock-model-1", "mock-model-2"]
        self._capabilities: list[ModelCapability] = [
            ModelCapability.CHAT,
            ModelCapability.COMPLETION,
            ModelCapability.EMBEDDING,
            ModelCapability.TOOL_CALL,
            ModelCapability.STREAMING,
            ModelCapability.CODE_GENERATION,
        ]

    def _should_fail(self) -> bool:
        if self._error_rate > 0 and self._rng.random() < self._error_rate:
            return True
        return False

    async def _simulate_latency(self) -> None:
        if self._latency > 0:
            await asyncio.sleep(self._latency)

    async def chat(
        self,
        messages: list[dict],
        config: dict | None = None,
    ) -> AsyncIterator[StreamingChunk]:
        await self._simulate_latency()
        if self._should_fail():
            raise RuntimeError("Simulated mock provider error")

        cfg = {**(config or {})}
        stream = cfg.get("stream", True)
        response_text = cfg.get("response_content", self._response_content)
        model = cfg.get("model", "mock-model")

        if stream:
            words = response_text.split(" ")
            for i, word in enumerate(words):
                await asyncio.sleep(self._stream_delay)
                is_last = i == len(words) - 1
                yield StreamingChunk(
                    content=word + (" " if not is_last else ""),
                    finish_reason="stop" if is_last else None,
                    usage={"prompt_tokens": 10, "completion_tokens": len(words)} if is_last else None,
                    provider=self._provider_type,
                    model=model,
                )
        else:
            yield StreamingChunk(
                content=response_text,
                finish_reason="stop",
                usage={"prompt_tokens": 10, "completion_tokens": len(response_text.split())},
                provider=self._provider_type,
                model=model,
            )

    async def complete(
        self,
        prompt: str,
        config: dict | None = None,
    ) -> str:
        await self._simulate_latency()
        if self._should_fail():
            raise RuntimeError("Simulated mock provider error")

        cfg = {**(config or {})}
        return cfg.get("response_content", self._response_content)

    async def embed(
        self,
        texts: list[str],
        config: dict | None = None,
    ) -> list[list[float]]:
        await self._simulate_latency()
        if self._should_fail():
            raise RuntimeError("Simulated mock provider error")

        cfg = {**(config or {})}
        dimension = cfg.get("embedding_dimension", self._embedding_dimension)
        seed = cfg.get("seed", self._seed)
        rng = random.Random(seed)

        results: list[list[float]] = []
        for text in texts:
            rng.seed(hash(text) & 0xFFFFFFFF)
            vector = [rng.gauss(0.0, 1.0) for _ in range(dimension)]
            magnitude = math.sqrt(sum(v * v for v in vector))
            normalized = [v / magnitude for v in vector]
            results.append(normalized)

        return results

    async def generate_tool_call(
        self,
        messages: list[dict],
        tools: list[dict],
        config: dict | None = None,
    ) -> dict:
        await self._simulate_latency()
        if self._should_fail():
            raise RuntimeError("Simulated mock provider error")

        cfg = {**(config or {})}
        if not tools:
            return {
                "role": "assistant",
                "content": cfg.get("response_content", self._response_content),
                "tool_calls": [],
            }

        tool_call = {
            "id": f"call_{self._rng.randint(10000, 99999)}",
            "type": "function",
            "function": {
                "name": tools[0].get("function", {}).get("name", "mock_function"),
                "arguments": '{"mock_arg": "mock_value"}',
            },
        }
        return {
            "role": "assistant",
            "content": "",
            "tool_calls": [tool_call],
        }

    async def get_models(self) -> list[str]:
        return self._models

    async def get_status(self) -> ProviderStatus:
        return ProviderStatus.ACTIVE

    async def get_capabilities(self) -> list[ModelCapability]:
        return self._capabilities

    async def validate_config(self, config: dict) -> bool:
        return True
