from __future__ import annotations

from typing import Any

import pytest

from tests.mocks import MockProviderAdapter


class FakeRateLimiter:

    def __init__(self) -> None:
        self._calls: list[str] = []

    async def acquire(self, provider: str) -> None:
        self._calls.append(provider)


class FakeHealthMonitor:

    def __init__(self) -> None:
        self._failures: dict[str, int] = {}
        self._threshold = 3

    def record_failure(self, provider: str) -> None:
        self._failures[provider] = self._failures.get(provider, 0) + 1

    def is_healthy(self, provider: str) -> bool:
        return self._failures.get(provider, 0) < self._threshold


class ProviderRouter:

    def __init__(self) -> None:
        self._providers: dict[str, MockProviderAdapter] = {}
        self._routing_table: dict[str, list[str]] = {}
        self._load_order: list[str] = []
        self._counter = 0
        self._rate_limiter = FakeRateLimiter()
        self._health_monitor = FakeHealthMonitor()

    def register(self, name: str, provider: MockProviderAdapter, capabilities: list[str] | None = None) -> None:
        self._providers[name] = provider
        caps = capabilities or ["chat"]
        self._routing_table[name] = caps
        self._load_order.append(name)

    def get(self, name: str) -> MockProviderAdapter:
        if name not in self._providers:
            raise KeyError(f"Provider '{name}' not registered")
        return self._providers[name]

    def get_by_capability(self, capability: str) -> MockProviderAdapter | None:
        for name, caps in self._routing_table.items():
            if capability in caps and self._health_monitor.is_healthy(name):
                return self._providers[name]
        return None

    def round_robin(self) -> MockProviderAdapter | None:
        if not self._load_order:
            return None
        healthy = [n for n in self._load_order if self._health_monitor.is_healthy(n)]
        if not healthy:
            return None
        idx = self._counter % len(healthy)
        self._counter += 1
        return self._providers[healthy[idx]]

    def fallback(self, name: str) -> MockProviderAdapter | None:
        if name in self._providers and self._health_monitor.is_healthy(name):
            return self._providers[name]
        for fallback_name in self._load_order:
            if fallback_name != name and self._health_monitor.is_healthy(fallback_name):
                return self._providers[fallback_name]
        return None

    @property
    def rate_limiter(self) -> FakeRateLimiter:
        return self._rate_limiter

    @property
    def health_monitor(self) -> FakeHealthMonitor:
        return self._health_monitor


@pytest.fixture
def router() -> ProviderRouter:
    return ProviderRouter()


@pytest.fixture
def providers() -> list[MockProviderAdapter]:
    return [MockProviderAdapter({"name": f"p{i}"}) for i in range(3)]


class TestProviderRouter:

    async def test_register_and_get_provider(self, router: ProviderRouter) -> None:
        provider = MockProviderAdapter({"name": "test"})
        router.register("test", provider, ["chat", "embedding"])
        retrieved = router.get("test")
        assert retrieved is provider

        with pytest.raises(KeyError):
            router.get("nonexistent")

    async def test_fallback_on_failure(self, router: ProviderRouter) -> None:
        p1 = MockProviderAdapter({"name": "primary"})
        p2 = MockProviderAdapter({"name": "fallback"})
        router.register("primary", p1, ["chat"])
        router.register("fallback", p2, ["chat"])

        fb = router.fallback("primary")
        assert fb is p1

        router.health_monitor.record_failure("primary")
        router.health_monitor.record_failure("primary")
        router.health_monitor.record_failure("primary")

        fb = router.fallback("primary")
        assert fb is p2

    async def test_load_balancing_round_robin(self, router: ProviderRouter, providers: list[MockProviderAdapter]) -> None:
        for i, p in enumerate(providers):
            router.register(f"p{i}", p, ["chat"])
        selected: list[str] = []
        for _ in range(6):
            p = router.round_robin()
            if p:
                for name, pp in router._providers.items():
                    if pp is p:
                        selected.append(name)
                        break
        assert selected == ["p0", "p1", "p2", "p0", "p1", "p2"]

    async def test_capability_routing(self, router: ProviderRouter) -> None:
        p1 = MockProviderAdapter({"name": "chat_only"})
        p2 = MockProviderAdapter({"name": "embed_only"})
        router.register("chat", p1, ["chat"])
        router.register("embed", p2, ["embedding"])

        result = router.get_by_capability("chat")
        assert result is p1

        result = router.get_by_capability("embedding")
        assert result is p2

        result = router.get_by_capability("unknown")
        assert result is None

    async def test_rate_limiter(self, router: ProviderRouter) -> None:
        provider = MockProviderAdapter({"name": "test"})
        router.register("test", provider, ["chat"])
        await router.rate_limiter.acquire("test")
        assert "test" in router.rate_limiter._calls

    async def test_health_monitor_detects_failure(self, router: ProviderRouter) -> None:
        provider = MockProviderAdapter({"name": "test"})
        router.register("test", provider, ["chat"])
        assert router.health_monitor.is_healthy("test") is True
        for _ in range(3):
            router.health_monitor.record_failure("test")
        assert router.health_monitor.is_healthy("test") is False
