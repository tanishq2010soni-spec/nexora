from __future__ import annotations

from abc import ABC, abstractmethod
from collections.abc import Callable

from nexora_ai.domain.entities.runtime import RuntimeConfig, RuntimeHealth


class RuntimeInterface(ABC):
    @abstractmethod
    async def start(self) -> None: ...

    @abstractmethod
    async def shutdown(self) -> None: ...

    @abstractmethod
    async def hot_reload(self, plugin_name: str) -> None: ...

    @abstractmethod
    async def get_health(self) -> RuntimeHealth: ...

    @abstractmethod
    async def send_heartbeat(self) -> None: ...

    @abstractmethod
    async def get_status(self) -> RuntimeConfig: ...

    @abstractmethod
    async def register_event_handler(self, event_type: str, handler: Callable) -> None: ...

    @abstractmethod
    async def cancel_task(self, task_id: str) -> None: ...
