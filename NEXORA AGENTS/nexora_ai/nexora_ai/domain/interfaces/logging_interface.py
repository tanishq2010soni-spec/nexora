from __future__ import annotations

from abc import ABC, abstractmethod

from nexora_ai.domain.entities.logging import LogEntry, PerformanceMetrics, TraceSpan


class LoggingInterface(ABC):
    @abstractmethod
    async def log(self, entry: LogEntry) -> None: ...

    @abstractmethod
    async def debug(self, message: str, **kwargs) -> None: ...

    @abstractmethod
    async def info(self, message: str, **kwargs) -> None: ...

    @abstractmethod
    async def warn(self, message: str, **kwargs) -> None: ...

    @abstractmethod
    async def error(self, message: str, **kwargs) -> None: ...

    @abstractmethod
    async def fatal(self, message: str, **kwargs) -> None: ...

    @abstractmethod
    async def start_trace(self, name: str, attributes: dict) -> TraceSpan: ...

    @abstractmethod
    async def end_trace(self, span: TraceSpan) -> None: ...

    @abstractmethod
    async def record_metrics(self, metrics: PerformanceMetrics) -> None: ...

    @abstractmethod
    async def get_correlation_id(self) -> str: ...

    @abstractmethod
    async def set_correlation_id(self, cid: str) -> None: ...

    @abstractmethod
    async def flush(self) -> None: ...
