import json
from collections.abc import AsyncIterator
from typing import Any

from nexora_ai.domain.entities.conversation import StreamingChunk
from nexora_ai.domain.enums.provider_enums import ModelCapability, ProviderStatus, ProviderType
from nexora_ai.infrastructure.providers.base import BaseProviderAdapter


class OllamaProviderAdapter(BaseProviderAdapter):

    DEFAULT_BASE_URL = "http://localhost:11434"

    DEFAULT_MODELS = [
        "llama3",
        "llama3.1",
        "mistral",
        "codellama",
        "gemma2",
        "phi3",
        "qwen2",
        "deepseek-coder",
    ]

    def __init__(self, config: dict[str, Any]) -> None:
        super().__init__(config)
        self._provider_type = ProviderType.OLLAMA.value
        self._base_url: str = config.get("base_url", self.DEFAULT_BASE_URL)
        self._model: str = config.get("model", "llama3")
        self._embedding_model: str = config.get("embedding_model", "nomic-embed-text")
        self._max_tokens: int = config.get("max_tokens", 4096)
        self._temperature: float = config.get("temperature", 0.7)
        self._models = self.DEFAULT_MODELS
        self._capabilities = [
            ModelCapability.CHAT,
            ModelCapability.STREAMING,
            ModelCapability.EMBEDDING,
            ModelCapability.COMPLETION,
            ModelCapability.CODE_GENERATION,
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
            "stream": stream,
            "options": {
                "num_predict": cfg.get("max_tokens", self._max_tokens),
                "temperature": cfg.get("temperature", self._temperature),
            },
        }

        if stream:
            async for chunk in self._stream_chat(payload):
                yield chunk
        else:
            response = await self._make_request(
                "POST",
                f"{self._base_url}/api/chat",
                headers=self._get_headers(),
                json=payload,
            )
            data = response.json()
            message = data.get("message", {})
            yield StreamingChunk(
                content=message.get("content", ""),
                finish_reason="stop",
                provider=self._provider_type,
                model=model,
            )

    async def _stream_chat(self, payload: dict[str, Any]) -> AsyncIterator[StreamingChunk]:
        response = await self._make_request(
            "POST",
            f"{self._base_url}/api/chat",
            headers=self._get_headers(),
            json=payload,
        )
        async for line in response.aiter_lines():
            if not line.strip():
                continue
            try:
                data = json.loads(line)
            except json.JSONDecodeError:
                continue
            message = data.get("message", {})
            done = data.get("done", False)
            yield StreamingChunk(
                content=message.get("content", ""),
                finish_reason="stop" if done else None,
                provider=self._provider_type,
                model=payload.get("model"),
            )

    async def complete(
        self,
        prompt: str,
        config: dict[str, Any] | None = None,
    ) -> str:
        cfg = {**self._config, **(config or {})}
        model = cfg.get("model", self._model)

        payload = {
            "model": model,
            "prompt": prompt,
            "stream": False,
            "options": {
                "num_predict": cfg.get("max_tokens", self._max_tokens),
                "temperature": cfg.get("temperature", self._temperature),
            },
        }

        response = await self._make_request(
            "POST",
            f"{self._base_url}/api/generate",
            headers=self._get_headers(),
            json=payload,
        )
        data = response.json()
        return data.get("response", "")

    async def embed(
        self,
        texts: list[str],
        config: dict[str, Any] | None = None,
    ) -> list[list[float]]:
        cfg = {**self._config, **(config or {})}
        model = cfg.get("embedding_model", self._embedding_model)

        embeddings = []
        for text in texts:
            payload = {"model": model, "input": text}
            response = await self._make_request(
                "POST",
                f"{self._base_url}/api/embed",
                headers=self._get_headers(),
                json=payload,
            )
            data = response.json()
            embeddings.append(data.get("embedding", []))
        return embeddings

    async def generate_tool_call(
        self,
        messages: list[dict[str, Any]],
        tools: list[dict[str, Any]],
        config: dict[str, Any] | None = None,
    ) -> dict[str, Any]:
        cfg = {**self._config, **(config or {})}
        model = cfg.get("model", self._model)

        payload = {
            "model": model,
            "messages": messages,
            "tools": tools,
            "stream": False,
            "options": {
                "num_predict": cfg.get("max_tokens", self._max_tokens),
                "temperature": cfg.get("temperature", self._temperature),
            },
        }

        response = await self._make_request(
            "POST",
            f"{self._base_url}/api/chat",
            headers=self._get_headers(),
            json=payload,
        )
        data = response.json()
        message = data.get("message", {})
        return {
            "role": message.get("role", "assistant"),
            "content": message.get("content", ""),
            "tool_calls": message.get("tool_calls", []),
        }

    async def get_models(self) -> list[str]:
        try:
            response = await self._make_request(
                "GET",
                f"{self._base_url}/api/tags",
                headers=self._get_headers(),
            )
            data = response.json()
            return [m.get("name", "") for m in data.get("models", [])]
        except Exception:
            return self._models

    async def get_status(self) -> ProviderStatus:
        try:
            await self._make_request(
                "GET",
                f"{self._base_url}/api/tags",
                headers=self._get_headers(),
            )
            return ProviderStatus.ACTIVE
        except Exception:
            return ProviderStatus.DOWN
