import json
from collections.abc import AsyncIterator
from typing import Any

from nexora_ai.domain.entities.conversation import StreamingChunk
from nexora_ai.domain.enums.provider_enums import ModelCapability, ProviderStatus, ProviderType
from nexora_ai.infrastructure.providers.base import BaseProviderAdapter


class OpenAICompatibleAdapter(BaseProviderAdapter):
    """Base for providers that implement the OpenAI API format."""

    BASE_URL: str = ""
    PROVIDER_TYPE: ProviderType = ProviderType.OPENAI
    DEFAULT_MODEL: str = ""
    DEFAULT_EMBEDDING_MODEL: str = ""
    CHAT_MODELS: list[str] = []
    EMBEDDING_MODELS: list[str] = []
    CAPABILITIES: list[ModelCapability] = [
        ModelCapability.CHAT,
        ModelCapability.STREAMING,
        ModelCapability.COMPLETION,
    ]
    AUTH_HEADER_KEY: str = "Authorization"
    AUTH_HEADER_PREFIX: str = "Bearer "

    def __init__(self, config: dict[str, Any]) -> None:
        super().__init__(config)
        self._provider_type = self.PROVIDER_TYPE.value
        self._api_key: str = config.get("api_key", "")
        self._model: str = config.get("model", self.DEFAULT_MODEL)
        self._embedding_model: str = config.get("embedding_model", self.DEFAULT_EMBEDDING_MODEL)
        self._max_tokens: int = config.get("max_tokens", 4096)
        self._temperature: float = config.get("temperature", 0.7)
        self._models = self.CHAT_MODELS + self.EMBEDDING_MODELS
        self._capabilities = list(self.CAPABILITIES)

    def _get_headers(self) -> dict[str, str]:
        return {
            self.AUTH_HEADER_KEY: f"{self.AUTH_HEADER_PREFIX}{self._api_key}",
            "Content-Type": "application/json",
        }

    async def chat(
        self, messages: list[dict[str, Any]], config: dict[str, Any] | None = None,
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
        tools = cfg.get("tools")
        if tools:
            payload["tools"] = tools

        if stream:
            async for chunk in self._stream_chat(payload):
                yield chunk
        else:
            response = await self._make_request(
                "POST", f"{self.BASE_URL}/chat/completions", headers=self._get_headers(), json=payload,
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
            "POST", f"{self.BASE_URL}/chat/completions", headers=self._get_headers(), json=payload,
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

    async def complete(self, prompt: str, config: dict[str, Any] | None = None) -> str:
        messages = [{"role": "user", "content": prompt}]
        result: list[str] = []
        async for chunk in self.chat(messages, {**(config or {}), "stream": False}):
            result.append(chunk.content)
        return "".join(result)

    async def embed(self, texts: list[str], config: dict[str, Any] | None = None) -> list[list[float]]:
        if not self.EMBEDDING_MODELS:
            raise NotImplementedError(f"{self._provider_type} does not support embeddings")
        cfg = {**self._config, **(config or {})}
        model = cfg.get("embedding_model", self._embedding_model)
        payload = {"model": model, "input": texts}
        response = await self._make_request(
            "POST", f"{self.BASE_URL}/embeddings", headers=self._get_headers(), json=payload,
        )
        data = response.json()
        embeddings = data.get("data", [])
        embeddings.sort(key=lambda x: x.get("index", 0))
        return [emb["embedding"] for emb in embeddings]

    async def generate_tool_call(
        self, messages: list[dict[str, Any]], tools: list[dict[str, Any]], config: dict[str, Any] | None = None,
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
            "POST", f"{self.BASE_URL}/chat/completions", headers=self._get_headers(), json=payload,
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
        return self._models

    async def get_status(self) -> ProviderStatus:
        try:
            await self._make_request("GET", f"{self.BASE_URL}/models", headers=self._get_headers())
            return ProviderStatus.ACTIVE
        except Exception:
            return ProviderStatus.DOWN


class GroqProviderAdapter(OpenAICompatibleAdapter):
    BASE_URL = "https://api.groq.com/openai/v1"
    PROVIDER_TYPE = ProviderType.GROQ
    DEFAULT_MODEL = "llama-3.3-70b-versatile"
    CHAT_MODELS = [
        "llama-3.3-70b-versatile",
        "llama-3.1-8b-instant",
        "gemma2-9b-it",
        "mixtral-8x7b-32768",
        "meta-llama/llama-4-scout-17b-16e-instruct",
    ]
    CAPABILITIES = [
        ModelCapability.CHAT,
        ModelCapability.STREAMING,
        ModelCapability.TOOL_CALL,
        ModelCapability.COMPLETION,
    ]


class OpenRouterProviderAdapter(OpenAICompatibleAdapter):
    BASE_URL = "https://openrouter.ai/api/v1"
    PROVIDER_TYPE = ProviderType.OPENROUTER
    DEFAULT_MODEL = "openrouter/auto"
    CHAT_MODELS = [
        "openrouter/auto",
        "anthropic/claude-3.5-sonnet",
        "openai/gpt-4o",
        "google/gemini-2.0-flash-001",
        "meta-llama/llama-3.3-70b-instruct:free",
    ]
    CAPABILITIES = [
        ModelCapability.CHAT,
        ModelCapability.STREAMING,
        ModelCapability.TOOL_CALL,
        ModelCapability.COMPLETION,
    ]

    def _get_headers(self) -> dict[str, str]:
        headers = super()._get_headers()
        headers["HTTP-Referer"] = self._config.get("referer", "https://nexora.ai")
        headers["X-Title"] = self._config.get("title", "NEXORA")
        return headers


class MistralProviderAdapter(OpenAICompatibleAdapter):
    BASE_URL = "https://api.mistral.ai/v1"
    PROVIDER_TYPE = ProviderType.MISTRAL
    DEFAULT_MODEL = "mistral-large-latest"
    DEFAULT_EMBEDDING_MODEL = "mistral-embed"
    CHAT_MODELS = [
        "mistral-large-latest",
        "mistral-medium-latest",
        "mistral-small-latest",
        "open-mixtral-8x22b",
        "open-mixtral-8x7b",
        "codestral-latest",
    ]
    EMBEDDING_MODELS = ["mistral-embed"]
    CAPABILITIES = [
        ModelCapability.CHAT,
        ModelCapability.STREAMING,
        ModelCapability.EMBEDDING,
        ModelCapability.TOOL_CALL,
        ModelCapability.COMPLETION,
        ModelCapability.CODE_GENERATION,
    ]


class GeminiProviderAdapter(OpenAICompatibleAdapter):
    BASE_URL = "https://generativelanguage.googleapis.com/v1beta/openai"
    PROVIDER_TYPE = ProviderType.GEMINI
    DEFAULT_MODEL = "gemini-2.0-flash"
    DEFAULT_EMBEDDING_MODEL = "text-embedding-004"
    CHAT_MODELS = [
        "gemini-2.0-flash",
        "gemini-2.0-flash-lite",
        "gemini-1.5-pro",
        "gemini-1.5-flash",
    ]
    EMBEDDING_MODELS = ["text-embedding-004"]
    CAPABILITIES = [
        ModelCapability.CHAT,
        ModelCapability.STREAMING,
        ModelCapability.EMBEDDING,
        ModelCapability.TOOL_CALL,
        ModelCapability.VISION,
        ModelCapability.COMPLETION,
    ]
    AUTH_HEADER_KEY = "Authorization"
    AUTH_HEADER_PREFIX = "Bearer "
