from __future__ import annotations

import os
from dataclasses import dataclass, field
from typing import Any

import httpx

from nexora_ai.domain.enums.provider_enums import (
    ModelCapability,
    ProviderStatus,
    ProviderType,
    RoutingStrategy,
)
from nexora_ai.infrastructure.provider_router import ProviderRouter


@dataclass
class ProviderConfig:
    provider_type: str
    name: str
    api_key: str = ""
    endpoint_url: str = ""
    model: str = ""
    embedding_model: str = ""
    is_active: bool = True
    supports_streaming: bool = True
    supports_vision: bool = False
    supports_tool_calling: bool = True
    context_window: int = 4096
    pricing_input_per_1k: float = 0.0
    pricing_output_per_1k: float = 0.0
    priority: int = 0
    rate_limit_rpm: int = 60
    extra: dict[str, Any] = field(default_factory=dict)

    def to_provider_type(self) -> ProviderType | None:
        mapping = {
            "openai": ProviderType.OPENAI,
            "anthropic": ProviderType.ANTHROPIC,
            "google": ProviderType.GEMINI,
            "gemini": ProviderType.GEMINI,
            "deepseek": ProviderType.DEEPSEEK,
            "openrouter": ProviderType.OPENROUTER,
            "groq": ProviderType.GROQ,
            "ollama": ProviderType.OLLAMA,
            "lm_studio": ProviderType.LM_STUDIO,
            "lmstudio": ProviderType.LM_STUDIO,
            "mistral": ProviderType.MISTRAL,
            "glm": ProviderType.GLM,
            "zhipu": ProviderType.GLM,
        }
        return mapping.get(self.provider_type.lower())

    def to_adapter_config(self) -> dict[str, Any]:
        cfg: dict[str, Any] = {
            "api_key": self.api_key,
            "model": self.model,
            "max_tokens": self.context_window,
        }
        if self.endpoint_url:
            cfg["base_url"] = self.endpoint_url
        if self.embedding_model:
            cfg["embedding_model"] = self.embedding_model
        cfg.update(self.extra)
        return cfg


class ProviderConfigService:
    """Fetches provider configuration from Nexora Brain and registers with ProviderRouter."""

    def __init__(
        self,
        provider_router: ProviderRouter,
        control_plane_url: str = "",
        org_id: str = "",
    ) -> None:
        self._router = provider_router
        self._control_plane_url = control_plane_url or os.environ.get(
            "NEXORA_CONTROL_PLANE_URL", "http://localhost:8000"
        )
        self._org_id = org_id or os.environ.get("NEXORA_ORG_ID", "")
        self._configs: dict[str, ProviderConfig] = {}
        self._client: httpx.AsyncClient | None = None

    async def _get_client(self) -> httpx.AsyncClient:
        if self._client is None or self._client.is_closed:
            self._client = httpx.AsyncClient(timeout=30.0)
        return self._client

    async def close(self) -> None:
        if self._client and not self._client.is_closed:
            await self._client.aclose()

    async def fetch_providers(self) -> list[ProviderConfig]:
        """Fetch provider configurations from Nexora Brain."""
        try:
            client = await self._get_client()
            url = f"{self._control_plane_url}/api/v1/providers/"
            params = {"is_active": "true"}
            if self._org_id:
                params["org_id"] = self._org_id

            response = await client.get(url, params=params)
            if response.status_code != 200:
                return []

            providers_data = response.json()
            configs = []
            for p in providers_data:
                config = ProviderConfig(
                    provider_type=p.get("provider_type", ""),
                    name=p.get("name", ""),
                    api_key=p.get("api_key_encrypted", ""),
                    endpoint_url=p.get("endpoint_url", ""),
                    is_active=p.get("is_active", True),
                    supports_streaming=p.get("supports_streaming", True),
                    supports_vision=p.get("supports_vision", False),
                    supports_tool_calling=p.get("supports_tool_calling", True),
                    context_window=p.get("context_window", 4096),
                    pricing_input_per_1k=p.get("pricing_input_per_1k", 0.0),
                    pricing_output_per_1k=p.get("pricing_output_per_1k", 0.0),
                )
                if config.is_active:
                    configs.append(config)
            return configs
        except Exception:
            return []

    async def sync_providers(self) -> int:
        """Fetch providers from Nexora Brain and register with ProviderRouter. Returns count registered."""
        configs = await self.fetch_providers()
        count = 0
        for config in configs:
            provider_type = config.to_provider_type()
            if provider_type is None:
                continue
            try:
                adapter_config = config.to_adapter_config()
                await self._router.register_provider(
                    provider_type=provider_type,
                    config=adapter_config,
                    priority=config.priority,
                    rate_limit={
                        "tokens_per_second": config.rate_limit_rpm / 60.0,
                        "max_tokens": float(config.rate_limit_rpm),
                    },
                )
                self._configs[provider_type.value] = config
                count += 1
            except Exception:
                continue
        return count

    def register_from_env(self) -> int:
        """Register providers from environment variables. Returns count registered."""
        count = 0
        env_providers = [
            ("OPENAI_API_KEY", "openai", ProviderType.OPENAI, "gpt-4o"),
            ("ANTHROPIC_API_KEY", "anthropic", ProviderType.ANTHROPIC, "claude-sonnet-4-20250514"),
            ("GEMINI_API_KEY", "gemini", ProviderType.GEMINI, "gemini-2.0-flash"),
            ("DEEPSEEK_API_KEY", "deepseek", ProviderType.DEEPSEEK, "deepseek-chat"),
            ("OPENROUTER_API_KEY", "openrouter", ProviderType.OPENROUTER, "openrouter/auto"),
            ("GROQ_API_KEY", "groq", ProviderType.GROQ, "llama-3.3-70b-versatile"),
            ("MISTRAL_API_KEY", "mistral", ProviderType.MISTRAL, "mistral-large-latest"),
            ("GLM_API_KEY", "glm", ProviderType.GLM, "glm-4-flash"),
            ("OLLAMA_BASE_URL", "ollama", ProviderType.OLLAMA, "llama3"),
            ("LM_STUDIO_BASE_URL", "lm_studio", ProviderType.LM_STUDIO, "local-model"),
        ]

        for env_key, name, ptype, default_model in env_providers:
            value = os.environ.get(env_key, "")
            if not value:
                continue

            if ptype in (ProviderType.OLLAMA, ProviderType.LM_STUDIO):
                config = {"base_url": value, "model": default_model}
            else:
                config = {"api_key": value, "model": default_model}

            try:
                import asyncio
                loop = asyncio.get_event_loop()
                if loop.is_running():
                    import concurrent.futures
                    with concurrent.futures.ThreadPoolExecutor() as pool:
                        loop.run_in_executor(pool, lambda: None)
                asyncio.ensure_future(
                    self._router.register_provider(ptype, config, priority=count)
                )
                count += 1
            except Exception:
                try:
                    import asyncio
                    loop = asyncio.get_event_loop()
                    if loop.is_running():
                        pass
                    else:
                        loop.run_until_complete(
                            self._router.register_provider(ptype, config, priority=count)
                        )
                        count += 1
                except Exception:
                    count += 1
        return count

    def get_config(self, provider_type: str) -> ProviderConfig | None:
        return self._configs.get(provider_type)

    def get_all_configs(self) -> dict[str, ProviderConfig]:
        return dict(self._configs)

    def set_routing_strategy(self, strategy: RoutingStrategy) -> None:
        self._router.set_routing_strategy(strategy)

    def get_routing_strategy(self) -> RoutingStrategy:
        return self._router.get_routing_strategy()
