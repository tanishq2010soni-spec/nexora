from __future__ import annotations

import asyncio
import importlib
import inspect
import logging
import time
from collections.abc import Awaitable, Callable
from pathlib import Path
from typing import Any

from nexora_ai.domain.enums.event_enums import EventType
from nexora_ai.domain.interfaces.config_interface import ConfigInterface
from nexora_ai.domain.interfaces.event_bus_interface import EventBusInterface
from nexora_ai.domain.interfaces.logging_interface import LoggingInterface
from nexora_ai.domain.interfaces.memory_interface import MemoryInterface
from nexora_ai.domain.interfaces.plugin_interface import PluginInterface
from nexora_ai.domain.interfaces.runtime_interface import RuntimeInterface
from nexora_ai.domain.interfaces.security_interface import SecurityInterface


class CancellationToken:
    def __init__(self) -> None:
        self._cancelled: bool = False
        self._lock: asyncio.Lock = asyncio.Lock()

    async def request_cancel(self) -> None:
        async with self._lock:
            self._cancelled = True

    async def is_cancelled(self) -> bool:
        async with self._lock:
            return self._cancelled

    async def throw_if_cancelled(self) -> None:
        if await self.is_cancelled():
            raise asyncio.CancelledError("Operation was cancelled")


class RetryPolicyExecutor:
    def __init__(
        self,
        max_retries: int = 3,
        base_delay: float = 1.0,
        max_delay: float = 60.0,
        backoff_multiplier: float = 2.0,
    ) -> None:
        self._max_retries = max_retries
        self._base_delay = base_delay
        self._max_delay = max_delay
        self._backoff_multiplier = backoff_multiplier

    async def execute(
        self,
        func: Callable[..., Awaitable[Any]],
        *args: Any,
        retryable_exceptions: tuple[type[Exception], ...] = (Exception,),
        **kwargs: Any,
    ) -> Any:
        last_exception: Exception | None = None
        for attempt in range(self._max_retries):
            try:
                return await func(*args, **kwargs)
            except retryable_exceptions as exc:
                last_exception = exc
                if attempt < self._max_retries - 1:
                    delay = min(self._base_delay * (self._backoff_multiplier ** attempt), self._max_delay)
                    await asyncio.sleep(delay)
        msg = f"All {self._max_retries} retry attempts failed"
        raise RuntimeError(msg) from last_exception


class AIRuntime(RuntimeInterface):
    def __init__(
        self,
        config: ConfigInterface,
        event_bus: EventBusInterface,
        logger: LoggingInterface,
        security: SecurityInterface,
        memory: MemoryInterface,
        plugin_loader: PluginInterface,
    ) -> None:
        self._config = config
        self._event_bus = event_bus
        self._logger = logger
        self._security = security
        self._memory = memory
        self._plugin_loader = plugin_loader
        self._cancellation_token = CancellationToken()
        self._retry_executor = RetryPolicyExecutor()
        self._tasks: dict[str, asyncio.Task[Any]] = {}
        self._providers: dict[str, Any] = {}
        self._context_store: dict[str, dict[str, Any]] = {}
        self._health_monitor_task: asyncio.Task[Any] | None = None
        self._lock: asyncio.Lock = asyncio.Lock()
        self._started: bool = False
        self._start_time: float = time.monotonic()
        self._logger_std = logging.getLogger(__name__)

    async def start(self) -> None:
        if self._started:
            return
        await self._logger.info("AIRuntime starting...", category="runtime")
        try:
            plugin_dir = await self._config.get("plugin_dir", "plugins")
            await self._plugin_loader.discover(plugin_dir)
            plugin_manifests = await self._plugin_loader.discover(plugin_dir)
            for manifest in plugin_manifests:
                manifest_id = getattr(manifest, "id", None) or (manifest.get("id") if isinstance(manifest, dict) else "")
                try:
                    await self._plugin_loader.load(manifest_id)
                except Exception as exc:
                    await self._logger.error(f"Failed to load plugin {manifest_id}: {exc}", category="runtime")

            provider_configs = await self._config.get("providers", {})
            for provider_name, provider_cfg in provider_configs.items() if isinstance(provider_configs, dict) else []:
                try:
                    provider_type = provider_cfg.get("type", provider_name)
                    module_path = f"nexora_ai.infrastructure.providers.{provider_type}"
                    module = importlib.import_module(module_path)
                    for name, cls in inspect.getmembers(module, inspect.isclass):
                        if name.lower() == f"{provider_type}provideradapter":
                            self._providers[provider_name] = cls(provider_cfg)
                            await self._logger.info(f"Initialized provider: {provider_name}", category="runtime")
                            break
                except Exception as exc:
                    await self._logger.error(f"Failed to initialize provider {provider_name}: {exc}", category="runtime")

            self._health_monitor_task = asyncio.create_task(self._health_monitor_loop())
            await self._event_bus.publish(EventType.RUNTIME, {"action": "started"})
            self._started = True
            self._start_time = time.monotonic()
            await self._logger.info("AIRuntime started successfully", category="runtime")
        except Exception as exc:
            await self._logger.error(f"Failed to start AIRuntime: {exc}", category="runtime")
            raise

    async def shutdown(self) -> None:
        if not self._started:
            return
        await self._logger.info("AIRuntime shutting down...", category="runtime")
        if self._health_monitor_task is not None:
            self._health_monitor_task.cancel()
            try:
                await self._health_monitor_task
            except asyncio.CancelledError:
                pass
        for task_name, task in list(self._tasks.items()):
            task.cancel()
            try:
                await task
            except asyncio.CancelledError:
                pass
        self._tasks.clear()
        for provider_name, provider in self._providers.items():
            try:
                if hasattr(provider, "close"):
                    await provider.close()
            except Exception as exc:
                await self._logger.error(f"Error closing provider {provider_name}: {exc}", category="runtime")
        self._providers.clear()
        self._context_store.clear()
        self._started = False
        await self._event_bus.publish(EventType.RUNTIME, {"action": "shutdown"})
        await self._logger.info("AIRuntime shut down", category="runtime")

    async def hot_reload(self, plugin_name: str | dict[str, Any] | None = None) -> None:
        from nexora_ai.domain.entities.runtime import RuntimeConfig

        await self._logger.info("Hot reload triggered", category="runtime")
        if isinstance(plugin_name, dict):
            for key, value in plugin_name.items():
                await self._config.set(key, value, layer="runtime")
            plugin_name = None

        await self._plugin_loader.discover()
        plugin_manifests = await self._plugin_loader.discover()
        for manifest in plugin_manifests:
            manifest_id = getattr(manifest, "id", None) or (manifest.get("id") if isinstance(manifest, dict) else None)
            if plugin_name and manifest_id != plugin_name:
                continue
            try:
                await self._plugin_loader.hot_reload(manifest_id or "")
            except Exception as exc:
                await self._logger.error(f"Hot reload failed for plugin {manifest_id}: {exc}", category="runtime")
        await self._event_bus.publish(EventType.RUNTIME, {"action": "hot_reload"})

    async def get_status(self) -> RuntimeConfig:
        from nexora_ai.domain.entities.runtime import RuntimeConfig
        from nexora_ai.domain.enums.logging_enums import LogLevel

        return RuntimeConfig(
            name="nexora_ai",
            version="0.1.0",
            environment="development",
            log_level=LogLevel.INFO,
            max_concurrent_tasks=10,
            task_timeout_seconds=300,
            enable_hot_reload=False,
            plugin_dir="plugins",
            data_dir="data",
        )

    async def get_health(self) -> RuntimeHealth:
        from nexora_ai.domain.entities.runtime import RuntimeHealth

        import psutil
        process = psutil.Process()
        mem_info = process.memory_info()

        return RuntimeHealth(
            status="healthy" if self._started else "stopped",
            uptime_seconds=time.monotonic() - self._start_time if hasattr(self, "_start_time") else 0.0,
            task_count=len(self._tasks),
            memory_usage_mb=mem_info.rss / (1024 * 1024),
            cpu_percent=process.cpu_percent(),
            active_plugins=len(self._providers),
        )

    async def send_heartbeat(self) -> None:
        health = await self.get_health()
        await self._event_bus.publish(EventType.RUNTIME, {"action": "heartbeat", "health": health.to_json()})

    async def register_event_handler(self, event_type: str, handler: Callable) -> None:
        from nexora_ai.domain.enums.event_enums import EventType as EventTypeEnum

        try:
            evt_type = EventTypeEnum(event_type)
        except ValueError:
            evt_type = EventTypeEnum.SYSTEM
        await self._event_bus.subscribe(event_type=evt_type, handler=handler)

    async def get_capabilities(self) -> list[dict[str, Any]]:
        capabilities: list[dict[str, Any]] = []
        for provider_name, provider in self._providers.items():
            caps: dict[str, Any] = {"provider": provider_name}
            for attr_name in dir(provider):
                if attr_name.startswith("capability_") or attr_name.startswith("supports_"):
                    try:
                        val = getattr(provider, attr_name)
                        if callable(val):
                            val = val()
                        caps[attr_name] = val
                    except Exception:
                        pass
            capabilities.append(caps)
        return capabilities

    async def execute_task(
        self,
        task_id: str,
        coro: Awaitable[Any],
        timeout: float | None = None,
    ) -> Any:
        async with self._lock:
            if task_id in self._tasks:
                msg = f"Task {task_id} already exists"
                raise RuntimeError(msg)
            task = asyncio.create_task(self._run_task(task_id, coro, timeout))
            self._tasks[task_id] = task
        try:
            return await task
        finally:
            self._tasks.pop(task_id, None)

    async def cancel_task(self, task_id: str) -> None:
        async with self._lock:
            task = self._tasks.get(task_id)
            if task is not None:
                task.cancel()

    async def _run_task(
        self,
        task_id: str,
        coro: Awaitable[Any],
        timeout: float | None = None,
    ) -> Any:
        try:
            if timeout is not None:
                return await asyncio.wait_for(coro, timeout=timeout)
            return await coro
        except asyncio.CancelledError:
            await self._logger.info(f"Task {task_id} cancelled", category="runtime")
            raise
        except Exception as exc:
            await self._logger.error(f"Task {task_id} failed: {exc}", category="runtime")
            raise

    async def set_context(self, conversation_id: str, key: str, value: Any) -> None:
        async with self._lock:
            if conversation_id not in self._context_store:
                self._context_store[conversation_id] = {}
            self._context_store[conversation_id][key] = value

    async def get_context(self, conversation_id: str, key: str, default: Any = None) -> Any:
        async with self._lock:
            return self._context_store.get(conversation_id, {}).get(key, default)

    async def _health_monitor_loop(self) -> None:
        interval = 30.0
        while True:
            try:
                await asyncio.sleep(interval)
                await self._perform_health_check()
            except asyncio.CancelledError:
                break
            except Exception as exc:
                await self._logger.error(f"Health monitor error: {exc}", category="runtime")

    async def _perform_health_check(self) -> None:
        health: dict[str, Any] = {"runtime": "healthy", "providers": {}}
        for provider_name, provider in self._providers.items():
            try:
                status = getattr(provider, "_status", "unknown")
                health["providers"][provider_name] = str(status)
            except Exception:
                health["providers"][provider_name] = "error"
        await self._event_bus.publish(EventType.SYSTEM, {"health": health})
