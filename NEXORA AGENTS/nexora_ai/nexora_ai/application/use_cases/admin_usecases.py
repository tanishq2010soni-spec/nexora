from __future__ import annotations

from datetime import datetime, timezone
from typing import Any, Protocol

from nexora_ai.application.use_cases.tool_usecases import AuditEntry
from nexora_ai.domain.enums.logging_enums import LogCategory, LogLevel


class PerformanceMetrics:
    def __init__(
        self,
        component: str,
        avg_latency_ms: float = 0.0,
        error_count: int = 0,
        request_count: int = 0,
        memory_usage_mb: float = 0.0,
        timestamp: datetime | None = None,
    ) -> None:
        self.component = component
        self.avg_latency_ms = avg_latency_ms
        self.error_count = error_count
        self.request_count = request_count
        self.memory_usage_mb = memory_usage_mb
        self.timestamp = timestamp or datetime.now(timezone.utc)


class ComponentHealth:
    def __init__(
        self,
        name: str,
        status: str = "healthy",
        latency_ms: float = 0.0,
        error: str | None = None,
    ) -> None:
        self.name = name
        self.status = status
        self.latency_ms = latency_ms
        self.error = error


class SystemStatsProvider(Protocol):
    async def get_memory_usage_mb(self) -> float: ...
    async def get_cpu_usage_percent(self) -> float: ...
    async def get_uptime_seconds(self) -> float: ...


class ProviderManager(Protocol):
    async def get_all_statuses(self) -> dict[str, str]: ...
    async def get_all_latencies(self) -> dict[str, float]: ...


class ConfigManager(Protocol):
    async def reload(self) -> bool: ...


class PluginManager(Protocol):
    async def hot_reload(self, plugin_id: str) -> bool: ...


class AuditRepository(Protocol):
    async def search(self, filter: dict[str, Any]) -> list[AuditEntry]: ...


class PerformanceRepository(Protocol):
    async def get_all_metrics(self) -> list[PerformanceMetrics]: ...


class AdminUseCases:
    def __init__(
        self,
        system_stats_provider: SystemStatsProvider,
        provider_manager: ProviderManager,
        config_manager: ConfigManager,
        plugin_manager: PluginManager,
        audit_repository: AuditRepository,
        performance_repository: PerformanceRepository,
    ) -> None:
        self._system_stats = system_stats_provider
        self._provider_manager = provider_manager
        self._config_manager = config_manager
        self._plugin_manager = plugin_manager
        self._audit_repository = audit_repository
        self._performance_repository = performance_repository

    async def get_system_health(self) -> dict[str, Any]:
        provider_statuses = await self._provider_manager.get_all_statuses()
        provider_latencies = await self._provider_manager.get_all_latencies()
        components: list[dict[str, Any]] = []
        for name, status in provider_statuses.items():
            components.append(
                {
                    "name": f"provider:{name}",
                    "status": status,
                    "latency_ms": provider_latencies.get(name, 0.0),
                }
            )
        return {
            "status": "healthy" if all(c["status"] == "active" for c in components) else "degraded",
            "components": components,
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }

    async def get_system_stats(self) -> dict[str, Any]:
        memory = await self._system_stats.get_memory_usage_mb()
        cpu = await self._system_stats.get_cpu_usage_percent()
        uptime = await self._system_stats.get_uptime_seconds()
        return {
            "memory_usage_mb": memory,
            "cpu_usage_percent": cpu,
            "uptime_seconds": uptime,
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }

    async def reload_config(self) -> bool:
        return await self._config_manager.reload()

    async def hot_reload_plugin(self, plugin_id: str) -> bool:
        return await self._plugin_manager.hot_reload(plugin_id)

    async def get_audit_log(self, filter: dict[str, Any]) -> list[AuditEntry]:
        return await self._audit_repository.search(filter)

    async def get_performance_report(self) -> list[PerformanceMetrics]:
        return await self._performance_repository.get_all_metrics()
