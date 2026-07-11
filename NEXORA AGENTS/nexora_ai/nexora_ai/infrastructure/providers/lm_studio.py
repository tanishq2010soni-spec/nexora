import json
from collections.abc import AsyncIterator
from typing import Any

from nexora_ai.domain.entities.conversation import StreamingChunk
from nexora_ai.domain.enums.provider_enums import ModelCapability, ProviderStatus, ProviderType
from nexora_ai.infrastructure.providers.base import BaseProviderAdapter


class LMStudioProviderAdapter(BaseProviderAdapter):

    DEFAULT_BASE_URL = "http://localhost:1234/v1"

    def __init__(self, config: dict[str, Any]) -> None:
        super().__init__(config)
        self._provider_type = ProviderType.LM_STUDIO.value
        self._base_url: str = config.get("base_url", self.DEFAULT_BASE_URL)
        self._model: str = config.get("model", "local-model")
        self._max_tokens: int = config.get("max_tokens", 4096)
        self._temperature: float = config.get("temperature", 0.7)
        self._models = [self._model]
        self._capabilities = [
            ModelCapability.CHAT,
            ModelCapability.STREAMING,
            ModelCapability.COMPLETION,
        ]

    def _get_headers(self) -> dict[str, str]:
        return {"Content-Type": "application/json"}

    async def chat(
        self,
        messages: list[dict[str, Any]],
        config: dict[str, Any] | None = None,
    ) -> AsyncIterator[StreamingChunk]:
        cfg = {**self._config, **(config or {})}
        model = cfg.get("model", self._model)
        stream = cfg.get("stream", True)

        payload: dict[str, Any] = {
            "model": model,
            "messages": messages,
            "max_tokens": cfg.get("max_tokens", self._max_tokens),
            "temperature": cfg.get("temperature", self._temperature),
            "stream": stream,
        }

        if stream:
            async for chunk in self._stream_chat(payload):
                yield chunk
        else:
            response = await self._make_request(
                "POST",
                f"{self._base_url}/chat/completions",
                headers=self._get_headers(),
                json=payload,
            )
            data = response.json()
            choices = data.get("choices", [])
            if choices:
                choice = choices[0]
                delta = choice.get("message", {})
                yield StreamingChunk(
                    content=delta.get("content", ""),
                    finish_reason=choice.get("finish_reason"),
                    usage=data.get("usage"),
                    provider=self._provider_type,
                    model=model,
                )

    async def _stream_chat(self, payload: dict[str, Any]) -> AsyncIterator[StreamingChunk]:
        response = await self._make_request(
            "POST",
            f"{self._base_url}/chat/completions",
            headers=self._get_headers(),
            json=payload,
        )
        async for line in response.aiter_lines():
            if not line.startswith("data: "):
                continue
            data_str = line[6:].strip()
            if data_str == "[DONE]":
                break
            try:
                data = json.loads(data_str)
            except json.JSONDecodeError:
                continue
            choices = data.get("choices", [])
            if not choices:
                continue
            choice = choices[0]
            delta = choice.get("delta", {})
            yield StreamingChunk(
                content=delta.get("content", ""),
                finish_reason=choice.get("finish_reason"),
                usage=data.get("usage"),
                provider=self._provider_type,
                model=payload.get("model"),
            )

    async def complete(
        self,
        prompt: str,
        config: dict[str, Any] | None = None,
    ) -> str:
        messages = [{"role": "user", "content": prompt}]
        result: list[str] = []
        async for chunk in self.chat(messages, {**(config or {}), "stream": False}):
            result.append(chunk.content)
        return "".join(result)

    async def embed(
        self,
        texts: list[str],
        config: dict[str, Any] | None = None,
    ) -> list[list[float]]:
        raise NotImplementedError("LM Studio embedding requires local model support")

    async def generate_tool_call(
        self,
        messages: list[dict[str, Any]],
        tools: list[dict[str, Any]],
        config: dict[str, Any] | None = None,
    ) -> dict[str, Any]:
        cfg = {**self._config, **(config or {})}
        payload = {
            "model": cfg.get("model", self._model),
            "messages": messages,
            "tools": tools,
            "max_tokens": cfg.get("max_tokens", self._max_tokens),
            "temperature": cfg.get("temperature", self._temperature),
            "stream": False,
        }
        response = await self._make_request(
            "POST",
            f"{self._base_url}/chat/completions",
            headers=self._get_headers(),
            json=payload,
        )
        data = response.json()
        choices = data.get("choices", [])
        if not choices:
            return {"role": "assistant", "content": "", "tool_calls": []}
        message = choices[0].get("message", {})
        return {
            "role": message.get("role", "assistant"),
            "content": message.get("content", ""),
            "tool_calls": message.get("tool_calls", []),
            "usage": data.get("usage"),
        }

    async def get_models(self) -> list[str]:
        try:
            response = await self._make_request(
                "GET",
                f"{self._base_url}/models",
                headers=self._get_headers(),
            )
            data = response.json()
            return [m.get("id", "") for m in data.get("data", [])]
        except Exception:
            return self._models

    async def get_status(self) -> ProviderStatus:
        try:
            await self._make_request(
                "GET",
                f"{self._base_url}/models",
                headers=self._get_headers(),
            )
            return ProviderStatus.ACTIVE
        except Exception:
            return ProviderStatus.DOWN
