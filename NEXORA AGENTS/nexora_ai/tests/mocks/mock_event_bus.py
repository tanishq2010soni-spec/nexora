from __future__ import annotations

import asyncio
from collections.abc import Callable, Coroutine
from typing import Any

from nexora_ai.domain.enums.event_enums import EventPriority


EventHandler = Callable[..., Coroutine[Any, Any, None]]


class MockEventBus:

    def __init__(self) -> None:
        self._handlers: dict[str, list[tuple[EventHandler, EventPriority, dict[str, Any]]]] = {}
        self._published_events: list[dict[str, Any]] = []
        self._dead_letter_queue: list[dict[str, Any]] = []
        self._error_handler: EventHandler | None = None

    async def publish(self, event_type: str, data: dict[str, Any] | None = None, **kwargs: Any) -> None:
        event = {"type": event_type, "data": data or {}, **kwargs}
        self._published_events.append(event)
        handlers = self._handlers.get(event_type, [])
        _priority_map = {"low": 0, "medium": 1, "normal": 2, "high": 3, "critical": 4}
        handlers.sort(key=lambda h: _priority_map.get(h[1].value, 1), reverse=True)

        for handler, priority, filter_kwargs in handlers:
            try:
                if filter_kwargs:
                    skip = False
                    for key, value in filter_kwargs.items():
                        if event.get(key) != value:
                            skip = True
                            break
                    if skip:
                        continue
                await handler(event)
            except Exception as exc:
                self._dead_letter_queue.append({"event": event, "error": str(exc), "handler": handler.__name__})
                if self._error_handler:
                    await self._error_handler(event, exc)

    async def subscribe(
        self,
        event_type: str,
        handler: EventHandler,
        priority: EventPriority = EventPriority.NORMAL,
        **kwargs: Any,
    ) -> None:
        if event_type not in self._handlers:
            self._handlers[event_type] = []
        self._handlers[event_type].append((handler, priority, kwargs))

    async def unsubscribe(self, event_type: str, handler: EventHandler) -> bool:
        if event_type in self._handlers:
            before = len(self._handlers[event_type])
            self._handlers[event_type] = [
                (h, p, f) for h, p, f in self._handlers[event_type] if h is not handler
            ]
            return len(self._handlers[event_type]) < before
        return False

    async def replay_dead_letter(self, index: int | None = None) -> None:
        if index is not None and 0 <= index < len(self._dead_letter_queue):
            item = self._dead_letter_queue[index]
            await self.publish(item["event"]["type"], item["event"]["data"])
            self._dead_letter_queue.pop(index)
        elif index is None:
            events = list(self._dead_letter_queue)
            self._dead_letter_queue.clear()
            for item in events:
                await self.publish(item["event"]["type"], item["event"]["data"])

    def get_published_events(self, event_type: str | None = None) -> list[dict[str, Any]]:
        if event_type:
            return [e for e in self._published_events if e["type"] == event_type]
        return list(self._published_events)

    def get_dead_letter_count(self) -> int:
        return len(self._dead_letter_queue)

    def clear(self) -> None:
        self._handlers.clear()
        self._published_events.clear()
        self._dead_letter_queue.clear()
