import json
from collections.abc import AsyncIterator
from typing import Any

from nexora_ai.domain.entities.conversation import StreamingChunk
from nexora_ai.domain.enums.provider_enums import ModelCapability, ProviderStatus, ProviderType
from nexora_ai.infrastructure.providers.base import BaseProviderAdapter


class AnthropicProviderAdapter(BaseProviderAdapter):

    BASE_URL = "https://api.anthropic.com/v1"

    SUPPORTED_MODELS: dict[str, list[str]] = {
        "chat": [
            "claude-sonnet-4-20250514",
            "claude-3-5-sonnet-20241022",
            "claude-3-5-haiku-20241022",
            "claude-3-opus-20240229",
            "claude-3-haiku-20240307",
        ],
        "embedding": [],
    }

    def __init__(self, config: dict[str, Any]) -> None:
        super().__init__(config)
        self._provider_type = ProviderType.ANTHROPIC.value
        self._api_key: str = config.get("api_key", "")
        self._model: str = config.get("model", "claude-sonnet-4-20250514")
        self._max_tokens: int = config.get("max_tokens", 4096)
        self._temperature: float = config.get("temperature", 0.7)
        self._models = self.SUPPORTED_MODELS["chat"]
        self._capabilities = [
            ModelCapability.CHAT,
            ModelCapability.STREAMING,
            ModelCapability.TOOL_CALL,
            ModelCapability.VISION,
            ModelCapability.COMPLETION,
            ModelCapability.REASONING,
            ModelCapability.CODE_GENERATION,
        ]

    def _get_headers(self) -> dict[str, str]:
        return {
            "x-api-key": self._api_key,
            "anthropic-version": "2023-06-01",
            "Content-Type": "application/json",
        }

    async def chat(
        self,
        messages: list[dict[str, Any]],
        config: dict[str, Any] | None = None,
    ) -> AsyncIterator[StreamingChunk]:
        cfg = {**self._config, **(config or {})}
        model = cfg.get("model", self._model)
        stream = cfg.get("stream", True)

        system_msg = ""
        chat_messages = []
        for msg in messages:
            if msg.get("role") == "system":
                system_msg = msg.get("content", "")
            else:
                chat_messages.append(msg)

        payload: dict[str, Any] = {
            "model": model,
            "messages": chat_messages,
            "max_tokens": cfg.get("max_tokens", self._max_tokens),
            "temperature": cfg.get("temperature", self._temperature),
            "stream": stream,
        }
        if system_msg:
            payload["system"] = system_msg

        tools = cfg.get("tools")
        if tools:
            payload["tools"] = [
                {
                    "name": t.get("function", {}).get("name", t.get("name", "")),
                    "description": t.get("function", {}).get("description", t.get("description", "")),
                    "input_schema": t.get("function", {}).get("parameters", t.get("input_schema", {})),
                }
                for t in tools
            ]

        if stream:
            async for chunk in self._stream_chat(payload, cfg):
                yield chunk
        else:
            response = await self._make_request(
                "POST",
                f"{self.BASE_URL}/messages",
                headers=self._get_headers(),
                json=payload,
            )
            data = response.json()
            content_blocks = data.get("content", [])
            text = "".join(b.get("text", "") for b in content_blocks if b.get("type") == "text")
            yield StreamingChunk(
                content=text,
                finish_reason=data.get("stop_reason"),
                usage=data.get("usage"),
                provider=self._provider_type,
                model=model,
            )

    async def _stream_chat(
        self,
        payload: dict[str, Any],
        config: dict[str, Any],
    ) -> AsyncIterator[StreamingChunk]:
        response = await self._make_request(
            "POST",
            f"{self.BASE_URL}/messages",
            headers=self._get_headers(),
            json=payload,
        )
        async for line in response.aiter_lines():
            if not line.startswith("data: "):
                continue
            data_str = line[6:].strip()
            try:
                data = json.loads(data_str)
            except json.JSONDecodeError:
                continue
            event_type = data.get("type", "")
            if event_type == "content_block_delta":
                delta = data.get("delta", {})
                if delta.get("type") == "text_delta":
                    yield StreamingChunk(
                        content=delta.get("text", ""),
                        finish_reason=None,
                        provider=self._provider_type,
                        model=payload.get("model"),
                    )
            elif event_type == "message_stop":
                yield StreamingChunk(
                    content="",
                    finish_reason="end_turn",
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
        raise NotImplementedError("Anthropic does not provide embedding API")

    async def generate_tool_call(
        self,
        messages: list[dict[str, Any]],
        tools: list[dict[str, Any]],
        config: dict[str, Any] | None = None,
    ) -> dict[str, Any]:
        cfg = {**self._config, **(config or {})}
        model = cfg.get("model", self._model)

        system_msg = ""
        chat_messages = []
        for msg in messages:
            if msg.get("role") == "system":
                system_msg = msg.get("content", "")
            else:
                chat_messages.append(msg)

        payload: dict[str, Any] = {
            "model": model,
            "messages": chat_messages,
            "tools": [
                {
                    "name": t.get("function", {}).get("name", t.get("name", "")),
                    "description": t.get("function", {}).get("description", t.get("description", "")),
                    "input_schema": t.get("function", {}).get("parameters", t.get("input_schema", {})),
                }
                for t in tools
            ],
            "max_tokens": cfg.get("max_tokens", self._max_tokens),
            "temperature": cfg.get("temperature", self._temperature),
            "stream": False,
        }
        if system_msg:
            payload["system"] = system_msg

        response = await self._make_request(
            "POST",
            f"{self.BASE_URL}/messages",
            headers=self._get_headers(),
            json=payload,
        )
        data = response.json()
        content_blocks = data.get("content", [])
        text = "".join(b.get("text", "") for b in content_blocks if b.get("type") == "text")
        tool_calls = [
            {
                "id": b.get("id", ""),
                "type": "function",
                "function": {
                    "name": b.get("name", ""),
                    "arguments": json.dumps(b.get("input", {})),
                },
            }
            for b in content_blocks if b.get("type") == "tool_use"
        ]
        return {
            "role": "assistant",
            "content": text,
            "tool_calls": tool_calls,
            "usage": data.get("usage"),
        }

    async def get_models(self) -> list[str]:
        return self._models

    async def get_status(self) -> ProviderStatus:
        try:
            await self._make_request(
                "GET",
                f"{self.BASE_URL}/models",
                headers=self._get_headers(),
            )
            return ProviderStatus.ACTIVE
        except Exception:
            return ProviderStatus.DOWN
