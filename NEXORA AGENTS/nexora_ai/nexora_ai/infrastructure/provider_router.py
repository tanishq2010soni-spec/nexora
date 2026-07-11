import asyncio
import time
from collections import defaultdict
from collections.abc import AsyncIterator
from dataclasses import dataclass, field
from typing import Any

from nexora_ai.domain.entities.conversation import StreamingChunk
from nexora_ai.domain.enums.provider_enums import (
    ModelCapability,
    ProviderStatus,
    ProviderType,
    RoutingStrategy,
)
from nexora_ai.domain.interfaces.provider_interface import ProviderInterface
from nexora_ai.infrastructure.providers.factory import ProviderFactory


class RateLimiter:

    def __init__(self, tokens_per_second: float, max_tokens: float) -> None:
        self._tokens_per_second = tokens_per_second
        self._max_tokens = max_tokens
        self._tokens = max_tokens
        self._last_refill = time.monotonic()
        self._lock = asyncio.Lock()

    async def acquire(self, tokens: float = 1.0) -> None:
        while True:
            async with self._lock:
                self._refill()
                if self._tokens >= tokens:
                    self._tokens -= tokens
                    return
                deficit = tokens - self._tokens
                wait = deficit / self._tokens_per_second if self._tokens_per_second > 0 else float("inf")
            await asyncio.sleep(min(wait, 0.1))

    def _refill(self) -> None:
        now = time.monotonic()
        elapsed = now - self._last_refill
        self._tokens = min(self._max_tokens, self._tokens + elapsed * self._tokens_per_second)
        self._last_refill = now


@dataclass
class HealthRecord:
    status: ProviderStatus = ProviderStatus.ACTIVE
    consecutive_failures: int = 0
    last_failure: float = 0.0
    last_success: float = 0.0
    recovery_attempts: int = 0
    maintenance_until: float = 0.0


class HealthMonitor:

    def __init__(
        self,
        health_check_interval: float = 30.0,
        failure_threshold: int = 3,
        recovery_delay: float = 60.0,
    ) -> None:
        self._health_check_interval = health_check_interval
        self._failure_threshold = failure_threshold
        self._recovery_delay = recovery_delay
        self._records: dict[str, HealthRecord] = defaultdict(HealthRecord)
        self._task: asyncio.Task[None] | None = None
        self._providers: dict[str, ProviderInterface] = {}

    def register(self, provider_id: str, provider: ProviderInterface) -> None:
        self._records[provider_id] = HealthRecord()
        self._providers[provider_id] = provider

    def unregister(self, provider_id: str) -> None:
        self._records.pop(provider_id, None)
        self._providers.pop(provider_id, None)

    def record_success(self, provider_id: str) -> None:
        record = self._records[provider_id]
        record.status = ProviderStatus.ACTIVE
        record.consecutive_failures = 0
        record.last_success = time.monotonic()

    def record_failure(self, provider_id: str) -> None:
        record = self._records[provider_id]
        record.consecutive_failures += 1
        record.last_failure = time.monotonic()
        if record.consecutive_failures >= self._failure_threshold:
            record.status = ProviderStatus.DOWN
            record.maintenance_until = time.monotonic() + self._recovery_delay

    def is_available(self, provider_id: str) -> bool:
        record = self._records.get(provider_id)
        if record is None:
            return False
        if record.status == ProviderStatus.MAINTENANCE:
            return False
        if record.status == ProviderStatus.DOWN:
            if time.monotonic() >= record.maintenance_until:
                record.status = ProviderStatus.DEGRADED
                return True
            return False
        return True

    def get_status(self, provider_id: str) -> ProviderStatus:
        return self._records.get(provider_id, HealthRecord()).status

    def get_all_status(self) -> dict[str, ProviderStatus]:
        return {pid: rec.status for pid, rec in self._records.items()}

    def start(self) -> None:
        if self._task is None:
            self._task = asyncio.create_task(self._run_health_checks())

    async def stop(self) -> None:
        if self._task:
            self._task.cancel()
            try:
                await self._task
            except asyncio.CancelledError:
                pass
            self._task = None

    async def _run_health_checks(self) -> None:
        while True:
            await asyncio.sleep(self._health_check_interval)
            for provider_id, record in self._records.items():
                if record.status == ProviderStatus.MAINTENANCE:
                    if time.monotonic() >= record.maintenance_until:
                        record.status = ProviderStatus.DEGRADED
                if record.status in (ProviderStatus.DEGRADED, ProviderStatus.ACTIVE):
                    try:
                        provider = self._providers.get(provider_id)
                        if provider is not None:
                            _ = await provider.complete("ping")
                            self.record_success(provider_id)
                    except Exception:
                        self.record_failure(provider_id)


@dataclass
class CostRecord:
    cost_per_token: float = 0.0
    total_cost: float = 0.0
    total_tokens: int = 0


class CostTracker:

    def __init__(self) -> None:
        self._records: dict[str, CostRecord] = defaultdict(CostRecord)

    def record_usage(
        self,
        provider_id: str,
        tokens: int,
        cost_per_token: float,
    ) -> None:
        record = self._records[provider_id]
        record.cost_per_token = cost_per_token
        record.total_tokens += tokens
        record.total_cost += tokens * cost_per_token

    def get_cost_per_token(self, provider_id: str) -> float:
        return self._records.get(provider_id, CostRecord()).cost_per_token

    def get_total_cost(self, provider_id: str) -> float:
        return self._records.get(provider_id, CostRecord()).total_cost

    def estimate_cost(self, provider_id: str, tokens: int) -> float:
        return tokens * self.get_cost_per_token(provider_id)

    def get_all_costs(self) -> dict[str, float]:
        return {pid: rec.total_cost for pid, rec in self._records.items()}


@dataclass
class LatencyRecord:
    recent_latencies: list[float] = field(default_factory=list)
    window_size: int = 10

    @property
    def average(self) -> float:
        if not self.recent_latencies:
            return 0.0
        return sum(self.recent_latencies) / len(self.recent_latencies)

    def record(self, latency: float) -> None:
        self.recent_latencies.append(latency)
        if len(self.recent_latencies) > self.window_size:
            self.recent_latencies.pop(0)


@dataclass
class ProviderEntry:
    provider_type: ProviderType
    provider: ProviderInterface
    priority: int
    capabilities: set[ModelCapability] = field(default_factory=set)
    is_primary: bool = False


class ProviderRouter(ProviderInterface):

    def __init__(self, config: dict[str, Any] | None = None) -> None:
        self._config = config or {}
        self._entries: list[ProviderEntry] = []
        self._round_robin_index: dict[int, int] = defaultdict(int)
        self._health_monitor = HealthMonitor(
            health_check_interval=self._config.get("health_check_interval", 30.0),
            failure_threshold=self._config.get("failure_threshold", 3),
            recovery_delay=self._config.get("recovery_delay", 60.0),
        )
        self._cost_tracker = CostTracker()
        self._latency_records: dict[str, LatencyRecord] = defaultdict(LatencyRecord)
        self._routing_strategy: RoutingStrategy = RoutingStrategy.PRIORITY
        self._rate_limiters: dict[str, RateLimiter] = {}
        self._lock = asyncio.Lock()

    async def register_provider(
        self,
        provider_type: ProviderType,
        config: dict[str, Any] | None = None,
        priority: int = 0,
        capabilities: list[ModelCapability] | None = None,
        rate_limit: dict[str, float] | None = None,
    ) -> None:
        provider = ProviderFactory.create(provider_type, config)
        provider_id = provider_type.value
        if capabilities is not None:
            caps = set(capabilities)
        else:
            try:
                caps = set(await provider.get_capabilities())
            except NotImplementedError:
                caps = set()
            except Exception:
                caps = set()

        entry = ProviderEntry(
            provider_type=provider_type,
            provider=provider,
            priority=priority,
            capabilities=caps,
        )
        self._entries.append(entry)
        self._entries.sort(key=lambda e: e.priority, reverse=True)

        self._health_monitor.register(provider_id, provider)

        if rate_limit:
            self._rate_limiters[provider_id] = RateLimiter(
                tokens_per_second=rate_limit.get("tokens_per_second", 10.0),
                max_tokens=rate_limit.get("max_tokens", 100.0),
            )

    def remove_provider(self, provider_type: ProviderType) -> None:
        provider_id = provider_type.value
        self._entries = [e for e in self._entries if e.provider_type != provider_type]
        self._health_monitor.unregister(provider_id)
        self._rate_limiters.pop(provider_id, None)
        self._latency_records.pop(provider_id, None)
        self._round_robin_index.pop(provider_type.value, None)

    def get_provider(
        self,
        capabilities: list[ModelCapability] | None = None,
        preferred_provider: ProviderType | None = None,
    ) -> ProviderInterface:
        if preferred_provider:
            for entry in self._entries:
                if entry.provider_type == preferred_provider:
                    if self._health_monitor.is_available(entry.provider_type.value):
                        return entry.provider

        required = set(capabilities) if capabilities else set()
        candidates = self._filter_by_strategy(required)
        if not candidates:
            raise RuntimeError(
                f"No available providers matching capabilities: {capabilities}"
            )
        return candidates[0].provider

    def _filter_by_strategy(
        self,
        required_capabilities: set[ModelCapability],
    ) -> list[ProviderEntry]:
        available = [
            e
            for e in self._entries
            if self._health_monitor.is_available(e.provider_type.value)
        ]

        if required_capabilities:
            available = [
                e
                for e in available
                if required_capabilities.issubset(e.capabilities)
            ]

        if not available:
            return []

        strategy = self._routing_strategy

        if strategy == RoutingStrategy.PRIORITY:
            max_priority = max(e.priority for e in available)
            top = [e for e in available if e.priority == max_priority]
            idx = self._round_robin_index.get(max_priority, 0) % len(top)
            self._round_robin_index[max_priority] = idx + 1
            return [top[idx]]

        if strategy == RoutingStrategy.FALLBACK:
            return sorted(available, key=lambda e: e.priority, reverse=True)

        if strategy == RoutingStrategy.LOAD_BALANCE:
            idx = self._round_robin_index.get(0, 0) % len(available)
            self._round_robin_index[0] = idx + 1
            return [available[idx]]

        if strategy == RoutingStrategy.COST_AWARE:
            available.sort(
                key=lambda e: self._cost_tracker.get_cost_per_token(e.provider_type.value)
            )
            return available

        if strategy == RoutingStrategy.LATENCY:
            available.sort(
                key=lambda e: self._latency_records[e.provider_type.value].average
            )
            return available

        if strategy == RoutingStrategy.CAPABILITY:
            def capability_score(entry: ProviderEntry) -> int:
                if not required_capabilities:
                    return 0
                return len(
                    required_capabilities.intersection(entry.capabilities)
                )
            available.sort(key=capability_score, reverse=True)
            return available

        return available[:1]

    async def _execute_with_failover(
        self,
        method: str,
        required_capabilities: set[ModelCapability],
        *args: Any,
        **kwargs: Any,
    ) -> Any:
        strategy = self._routing_strategy
        if strategy != RoutingStrategy.FALLBACK:
            candidates = self._filter_by_strategy(required_capabilities)
            if not candidates:
                raise RuntimeError("No available providers")
            entry = candidates[0]
            provider_id = entry.provider_type.value
            rate_limiter = self._rate_limiters.get(provider_id)

            if rate_limiter:
                await rate_limiter.acquire()

            start = time.monotonic()
            try:
                result = await getattr(entry.provider, method)(*args, **kwargs)
                elapsed = time.monotonic() - start
                self._latency_records[provider_id].record(elapsed)
                self._health_monitor.record_success(provider_id)
                return result
            except Exception as exc:
                self._health_monitor.record_failure(provider_id)
                raise exc
        else:
            candidates = self._filter_by_strategy(required_capabilities)
            errors: list[Exception] = []
            for entry in candidates:
                provider_id = entry.provider_type.value
                rate_limiter = self._rate_limiters.get(provider_id)

                if rate_limiter:
                    await rate_limiter.acquire()

                start = time.monotonic()
                try:
                    result = await getattr(entry.provider, method)(*args, **kwargs)
                    elapsed = time.monotonic() - start
                    self._latency_records[provider_id].record(elapsed)
                    self._health_monitor.record_success(provider_id)
                    return result
                except Exception as exc:
                    self._health_monitor.record_failure(provider_id)
                    errors.append(exc)
                    continue
            raise RuntimeError(
                f"All providers failed: {'; '.join(str(e) for e in errors)}"
            )

    async def chat(
        self,
        messages: list[dict],
        config: dict | None = None,
    ) -> AsyncIterator[StreamingChunk]:
        cfg = {**(config or {})}
        caps = set()
        caps.add(ModelCapability.CHAT)
        if cfg.get("stream", True):
            caps.add(ModelCapability.STREAMING)

        strategy = self._routing_strategy
        candidates = self._filter_by_strategy(caps)

        if not candidates:
            raise RuntimeError("No available providers for chat with streaming")

        if strategy == RoutingStrategy.FALLBACK:
            last_error: Exception | None = None
            for entry in candidates:
                provider_id = entry.provider_type.value
                rate_limiter = self._rate_limiters.get(provider_id)
                if rate_limiter:
                    await rate_limiter.acquire()
                try:
                    start = time.monotonic()
                    async for chunk in entry.provider.chat(messages, cfg):
                        yield chunk
                    elapsed = time.monotonic() - start
                    self._latency_records[provider_id].record(elapsed)
                    self._health_monitor.record_success(provider_id)
                    return
                except Exception as exc:
                    self._health_monitor.record_failure(provider_id)
                    last_error = exc
                    continue
            raise RuntimeError(
                f"All providers failed for chat: {last_error}"
            )
        else:
            entry = candidates[0]
            provider_id = entry.provider_type.value
            rate_limiter = self._rate_limiters.get(provider_id)
            if rate_limiter:
                await rate_limiter.acquire()
            try:
                start = time.monotonic()
                async for chunk in entry.provider.chat(messages, cfg):
                    yield chunk
                elapsed = time.monotonic() - start
                self._latency_records[provider_id].record(elapsed)
                self._health_monitor.record_success(provider_id)
            except Exception as exc:
                self._health_monitor.record_failure(provider_id)
                raise exc

    async def complete(
        self,
        prompt: str,
        config: dict | None = None,
    ) -> str:
        return await self._execute_with_failover(
            "complete",
            {ModelCapability.CHAT},
            prompt,
            config,
        )

    async def embed(
        self,
        texts: list[str],
        config: dict | None = None,
    ) -> list[list[float]]:
        return await self._execute_with_failover(
            "embed",
            {ModelCapability.EMBEDDING},
            texts,
            config,
        )

    async def generate_tool_call(
        self,
        messages: list[dict],
        tools: list[dict],
        config: dict | None = None,
    ) -> dict:
        return await self._execute_with_failover(
            "generate_tool_call",
            {ModelCapability.CHAT, ModelCapability.TOOL_CALL},
            messages,
            tools,
            config,
        )

    async def get_models(self) -> list[str]:
        candidates = self._filter_by_strategy(set())
        if not candidates:
            return []
        models: list[str] = []
        for entry in candidates:
            try:
                models.extend(await entry.provider.get_models())
            except Exception:
                continue
        return models

    async def get_status(self) -> ProviderStatus:
        candidates = self._filter_by_strategy(set())
        if not candidates:
            return ProviderStatus.DOWN
        statuses = [ProviderStatus.DOWN]
        for entry in candidates:
            try:
                statuses.append(await entry.provider.get_status())
            except Exception:
                continue
        if any(s == ProviderStatus.ACTIVE for s in statuses):
            return ProviderStatus.ACTIVE
        if any(s == ProviderStatus.DEGRADED for s in statuses):
            return ProviderStatus.DEGRADED
        return ProviderStatus.DOWN

    async def get_capabilities(self) -> list[ModelCapability]:
        caps: set[ModelCapability] = set()
        for entry in self._entries:
            caps.update(entry.capabilities)
        return list(caps)

    async def validate_config(self, config: dict) -> bool:
        if not config:
            return False
        provider_type = config.get("provider_type")
        if provider_type is None:
            return False
        return True

    def get_health(self) -> dict[str, Any]:
        return {
            "providers": {
                pid: {
                    "status": rec.status.value,
                    "consecutive_failures": rec.consecutive_failures,
                    "last_success": rec.last_success,
                    "last_failure": rec.last_failure,
                }
                for pid, rec in self._health_monitor._records.items()
            },
            "costs": self._cost_tracker.get_all_costs(),
            "latencies": {
                pid: rec.average
                for pid, rec in self._latency_records.items()
            },
            "routing_strategy": self._routing_strategy.value,
        }

    def get_available_providers(self) -> list[ProviderType]:
        return [
            e.provider_type
            for e in self._entries
            if self._health_monitor.is_available(e.provider_type.value)
        ]

    def set_routing_strategy(self, strategy: RoutingStrategy) -> None:
        self._routing_strategy = strategy

    def get_routing_strategy(self) -> RoutingStrategy:
        return self._routing_strategy

    async def start_health_checks(self) -> None:
        self._health_monitor.start()

    async def stop_health_checks(self) -> None:
        await self._health_monitor.stop()
