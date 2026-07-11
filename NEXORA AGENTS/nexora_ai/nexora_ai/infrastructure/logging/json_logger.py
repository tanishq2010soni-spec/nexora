from __future__ import annotations

import asyncio
import json
import logging
import os
import time
import traceback as tb
from contextvars import ContextVar
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from nexora_ai.domain.enums.logging_enums import LogFormat, LogLevel, OutputDestination
from nexora_ai.domain.interfaces.logging_interface import LoggingInterface

_correlation_id: ContextVar[str] = ContextVar("correlation_id", default="")
_request_id: ContextVar[str] = ContextVar("request_id", default="")
_task_id: ContextVar[str] = ContextVar("task_id", default="")
_conversation_id: ContextVar[str] = ContextVar("conversation_id", default="")


class TraceSpan:
    def __init__(
        self,
        name: str,
        parent_span_id: str | None = None,
        trace_id: str | None = None,
    ) -> None:
        self.name = name
        self.span_id = f"span_{int(time.time() * 1000000)}_{id(self)}"
        self.parent_span_id = parent_span_id
        self.trace_id = trace_id or f"trace_{int(time.time())}_{id(self)}"
        self.start_time = time.monotonic()
        self.end_time: float | None = None
        self.attributes: dict[str, Any] = {}

    def finish(self) -> None:
        self.end_time = time.monotonic()

    @property
    def duration_ms(self) -> float:
        end = self.end_time or time.monotonic()
        return (end - self.start_time) * 1000.0

    def to_dict(self) -> dict[str, Any]:
        return {
            "name": self.name,
            "span_id": self.span_id,
            "parent_span_id": self.parent_span_id,
            "trace_id": self.trace_id,
            "duration_ms": self.duration_ms,
            "attributes": self.attributes,
        }


class JsonLogger(LoggingInterface):
    def __init__(
        self,
        output_destinations: list[OutputDestination] | None = None,
        log_format: LogFormat = LogFormat.JSON,
        min_level: LogLevel = LogLevel.INFO,
        file_path: str | Path | None = None,
        max_file_size_bytes: int = 10 * 1024 * 1024,
        max_backup_files: int = 3,
        colored_console: bool = True,
    ) -> None:
        self._min_level = min_level
        self._log_format = log_format
        self._destinations = output_destinations or [OutputDestination.CONSOLE]
        self._file_path = Path(file_path) if file_path else None
        self._max_file_size = max_file_size_bytes
        self._max_backup_files = max_backup_files
        self._colored_console = colored_console
        self._file_lock: asyncio.Lock = asyncio.Lock()
        self._console_lock: asyncio.Lock = asyncio.Lock()
        self._logger_std = logging.getLogger(__name__)

    async def set_correlation_id(self, correlation_id: str) -> None:
        _correlation_id.set(correlation_id)

    async def set_request_id(self, request_id: str) -> None:
        _request_id.set(request_id)

    async def set_task_id(self, task_id: str) -> None:
        _task_id.set(task_id)

    async def set_conversation_id(self, conversation_id: str) -> None:
        _conversation_id.set(conversation_id)

    async def log(
        self,
        entry: LogLevel | LogEntry | None = None,
        message: str = "",
        category: str = "system",
        **kwargs: Any,
    ) -> None:
        from nexora_ai.domain.entities.logging import LogEntry as LogEntryEntity
        from nexora_ai.domain.enums.logging_enums import LogLevel as LogLevelEnum

        if isinstance(entry, LogEntryEntity):
            log_entry = entry
            level = log_entry.level
            message = log_entry.message
            category = log_entry.category.value if hasattr(log_entry.category, "value") else str(log_entry.category)
            kwargs["correlation_id"] = log_entry.correlation_id
            kwargs["metadata"] = log_entry.metadata
        elif isinstance(entry, LogLevelEnum):
            level = entry
        else:
            level = LogLevel.INFO

        if not self._should_log(level):
            return
        entry_dict = self._build_entry(level, message, category, kwargs)
        for dest in self._destinations:
            if dest == OutputDestination.CONSOLE:
                await self._write_console(entry_dict)
            elif dest == OutputDestination.FILE:
                await self._write_file(entry_dict)
            elif dest == OutputDestination.BUFFER:
                pass

    async def debug(self, message: str, **kwargs: Any) -> None:
        await self.log(LogLevel.DEBUG, message, **kwargs)

    async def info(self, message: str, **kwargs: Any) -> None:
        await self.log(LogLevel.INFO, message, **kwargs)

    async def warn(self, message: str, **kwargs: Any) -> None:
        await self.log(LogLevel.WARN, message, **kwargs)

    async def error(self, message: str, **kwargs: Any) -> None:
        await self.log(LogLevel.ERROR, message, **kwargs)

    async def fatal(self, message: str, **kwargs: Any) -> None:
        await self.log(LogLevel.FATAL, message, **kwargs)

    async def record_performance(self, operation: str, duration_ms: float, **kwargs: Any) -> None:
        await self.log(
            LogLevel.INFO,
            f"Performance: {operation}",
            category="performance",
            duration_ms=duration_ms,
            operation=operation,
            **kwargs,
        )

    def create_span(self, name: str, parent_span_id: str | None = None) -> TraceSpan:
        return TraceSpan(
            name=name,
            parent_span_id=parent_span_id,
            trace_id=_correlation_id.get() or None,
        )

    def _should_log(self, level: LogLevel) -> bool:
        order = [LogLevel.DEBUG, LogLevel.INFO, LogLevel.WARN, LogLevel.ERROR, LogLevel.FATAL]
        return order.index(level) >= order.index(self._min_level)

    def _build_entry(
        self,
        level: LogLevel,
        message: str,
        category: str,
        extras: dict[str, Any],
    ) -> dict[str, Any]:
        entry: dict[str, Any] = {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "level": level.value,
            "message": message,
            "category": category,
            "correlation_id": _correlation_id.get() or None,
            "request_id": _request_id.get() or None,
            "task_id": _task_id.get() or None,
            "conversation_id": _conversation_id.get() or None,
        }
        if extras.get("exception"):
            entry["exception"] = "".join(tb.format_exception(type(extras["exception"]), extras["exception"], extras["exception"].__traceback__))
            del extras["exception"]
        if extras.get("stack_trace"):
            entry["stack_trace"] = extras["stack_trace"]
            del extras["stack_trace"]
        entry.update(extras)
        return entry

    async def _write_console(self, entry: dict[str, Any]) -> None:
        async with self._console_lock:
            if self._log_format == LogFormat.JSON:
                line = json.dumps(entry, default=str)
            else:
                line = f"[{entry['level'].upper()}] {entry['timestamp']} {entry['message']}"
            if self._colored_console:
                color = self._level_color(entry["level"])
                line = f"{color}{line}\033[0m"
            print(line)

    async def _write_file(self, entry: dict[str, Any]) -> None:
        if self._file_path is None:
            return
        async with self._file_lock:
            await self._rotate_if_needed()
            line = json.dumps(entry, default=str) + "\n"
            self._file_path.parent.mkdir(parents=True, exist_ok=True)
            with open(self._file_path, "a", encoding="utf-8") as f:
                f.write(line)

    async def _rotate_if_needed(self) -> None:
        if not self._file_path or not self._file_path.exists():
            return
        if self._file_path.stat().st_size < self._max_file_size:
            return
        for i in range(self._max_backup_files - 1, 0, -1):
            src = self._file_path.with_suffix(f".{i}.log")
            dst = self._file_path.with_suffix(f".{i + 1}.log")
            if src.exists():
                src.rename(dst)
        if self._file_path.exists():
            self._file_path.rename(self._file_path.with_suffix(".1.log"))

    def _level_color(self, level: str) -> str:
        colors = {
            "debug": "\033[36m",
            "info": "\033[32m",
            "warn": "\033[33m",
            "error": "\033[31m",
            "fatal": "\033[35m",
        }
        return colors.get(level, "\033[0m")

    async def start_trace(self, name: str, attributes: dict) -> TraceSpan:
        from nexora_ai.domain.entities.logging import TraceSpan as DomainTraceSpan

        span = TraceSpan(name=name, trace_id=_correlation_id.get() or f"trace_{int(time.time())}")
        span.attributes = attributes
        domain_span = DomainTraceSpan(
            name=name,
            trace_id=span.trace_id,
            parent_span_id=span.parent_span_id,
            span_id=span.span_id,
            attributes=attributes,
        )
        return domain_span

    async def end_trace(self, span: TraceSpan) -> None:
        if hasattr(span, "end_time"):
            span.end_time = datetime.now(timezone.utc)
        if hasattr(span, "status"):
            span.status = "completed"

    async def record_metrics(self, metrics: PerformanceMetrics) -> None:
        await self.log(
            LogLevel.INFO,
            f"Metrics: {metrics.operation}",
            category="performance",
            duration_ms=metrics.duration_ms,
            operation=metrics.operation,
            success=metrics.success,
            cpu_percent=metrics.cpu_percent,
            memory_bytes=metrics.memory_bytes,
        )

    async def get_correlation_id(self) -> str:
        return _correlation_id.get() or ""

    async def flush(self) -> None:
        pass
