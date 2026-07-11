from __future__ import annotations

import asyncio
import heapq
import time
from collections.abc import Awaitable, Callable
from typing import Any

from nexora_ai.domain.enums.event_enums import EventStatus, EventType
from nexora_ai.domain.interfaces.event_bus_interface import EventBusInterface


class Event:
    def __init__(
        self,
        event_type: EventType,
        data: dict[str, Any],
        correlation_id: str | None = None,
        priority: int = 0,
    ) -> None:
        self.event_type = event_type
        self.data = data
        self.correlation_id = correlation_id
        self.priority = priority
        self.timestamp = time.monotonic()

    def __lt__(self, other: Event) -> bool:
        return (-self.priority, self.timestamp) < (-other.priority, other.timestamp)


class Subscription:
    def __init__(
        self,
        subscription_id: str,
        event_type: EventType,
        handler: Callable[..., Awaitable[Any]],
        filter_condition: dict[str, Any] | None = None,
    ) -> None:
        self.subscription_id = subscription_id
        self.event_type = event_type
        self.handler = handler
        self.filter_condition = filter_condition or {}


class AsyncEventBus(EventBusInterface):
    def __init__(self, max_retries: int = 3) -> None:
        self._subscriptions: dict[str, Subscription] = {}
        self._queue: list[Event] = []
        self._dead_letter_queue: list[dict[str, Any]] = []
        self._lock: asyncio.Lock = asyncio.Lock()
        self._max_retries = max_retries
        self._processor_task: asyncio.Task[Any] | None = None
        self._running: bool = False

    async def start(self) -> None:
        if not self._running:
            self._running = True
            self._processor_task = asyncio.create_task(self._process_loop())

    async def stop(self) -> None:
        self._running = False
        if self._processor_task is not None:
            self._processor_task.cancel()
            try:
                await self._processor_task
            except asyncio.CancelledError:
                pass

    async def publish(
        self,
        event: EventType | Any | None = None,
        data: dict[str, Any] | None = None,
        correlation_id: str | None = None,
        priority: int = 0,
    ) -> str:
        from nexora_ai.domain.enums.event_enums import EventType as EventTypeEnum
        from nexora_ai.domain.enums.event_enums import EventPriority

        if isinstance(event, EventTypeEnum):
            event_type = event
            event_data = data or {}
            evt = Event(
                event_type=event_type,
                data=event_data,
                correlation_id=correlation_id,
                priority=priority,
            )
        elif isinstance(event, dict):
            evt = Event(
                event_type=EventTypeEnum.SYSTEM,
                data=event,
                correlation_id=correlation_id,
                priority=priority,
            )
        elif hasattr(event, "event_type") and hasattr(event, "data"):
            evt = event
        else:
            evt = Event(
                event_type=EventTypeEnum.SYSTEM,
                data=data or {},
                correlation_id=correlation_id,
                priority=priority,
            )

        event_id = f"evt_{int(time.time() * 1000000)}_{id(evt)}"
        async with self._lock:
            heapq.heappush(self._queue, evt)
        return event_id

    async def subscribe(
        self,
        subscription: Any | None = None,
        event_type: EventType | None = None,
        handler: Callable[..., Awaitable[Any]] | None = None,
        filter_condition: dict[str, Any] | None = None,
    ) -> str:
        from nexora_ai.domain.enums.event_enums import EventType as EventTypeEnum

        if hasattr(subscription, "event_types") and hasattr(subscription, "handler_name"):
            sub = subscription
            sub_id = getattr(sub, "id", f"sub_{int(time.time() * 1000000)}_{id(subscription)}")
            domain_sub = Subscription(
                subscription_id=sub_id,
                event_types=sub.event_types,
                handler_name=sub.handler_name,
                filter=sub.filter,
                priority=sub.priority,
                max_retries=sub.max_retries,
                timeout_seconds=sub.timeout_seconds,
            )
            async with self._lock:
                self._subscriptions[sub_id] = domain_sub
            return sub_id

        if event_type is None:
            event_type = EventTypeEnum.SYSTEM
        subscription_id = f"sub_{int(time.time() * 1000000)}_{id(handler)}"
        sub = Subscription(
            subscription_id=subscription_id,
            event_types=[event_type],
            handler_name=getattr(handler, "__name__", str(handler)),
            filter=filter_condition,
        )
        async with self._lock:
            self._subscriptions[subscription_id] = sub
        return subscription_id

    async def unsubscribe(self, subscription_id: str) -> bool:
        async with self._lock:
            if subscription_id in self._subscriptions:
                del self._subscriptions[subscription_id]
                return True
            return False

    async def get_dead_letter_queue(self) -> list[Any]:
        async with self._lock:
            return list(self._dead_letter_queue)

    async def get_dead_letter_count(self) -> int:
        async with self._lock:
            return len(self._dead_letter_queue)

    async def replay_dead_letter(self, event_id: str) -> bool:
        async with self._lock:
            for i, entry in enumerate(self._dead_letter_queue):
                if entry.get("event_id") == event_id:
                    dlq_entry = self._dead_letter_queue.pop(i)
                    from nexora_ai.domain.enums.event_enums import EventType as EventTypeEnum

                    evt = Event(
                        event_type=EventTypeEnum(dlq_entry.get("event_type", "system")),
                        data=dlq_entry.get("data", {}),
                        correlation_id=dlq_entry.get("correlation_id"),
                    )
                    heapq.heappush(self._queue, evt)
                    return True
            return False

    async def clear_dead_letter_queue(self) -> int:
        async with self._lock:
            count = len(self._dead_letter_queue)
            self._dead_letter_queue.clear()
            return count

    async def _process_loop(self) -> None:
        while self._running:
            try:
                event = await self._dequeue()
                if event is None:
                    await asyncio.sleep(0.01)
                    continue
                await self._dispatch(event)
            except asyncio.CancelledError:
                break
            except Exception:
                pass

    async def _dequeue(self) -> Event | None:
        async with self._lock:
            if self._queue:
                return heapq.heappop(self._queue)
            return None

    async def _dispatch(self, event: Event) -> None:
        matching_handlers: list[Callable[..., Awaitable[Any]]] = []
        async with self._lock:
            for sub in self._subscriptions.values():
                event_types = getattr(sub, "event_types", [])
                if event_types and event.event_type not in event_types:
                    continue
                filter_cond = getattr(sub, "filter", None) or getattr(sub, "filter_condition", None)
                if filter_cond:
                    if not self._matches_filter(event.data, filter_cond):
                        continue
                handler_name = getattr(sub, "handler_name", None)
                if handler_name:
                    for h in self._find_handler_by_name(handler_name):
                        matching_handlers.append(h)

        if not matching_handlers:
            return

        results = await asyncio.gather(
            *[self._run_handler(handler, event) for handler in matching_handlers],
            return_exceptions=True,
        )

        for idx, result in enumerate(results):
            if isinstance(result, Exception):
                await self._send_to_dead_letter(event, result)

    def _find_handler_by_name(self, name: str) -> list[Callable[..., Awaitable[Any]]]:
        handlers: list[Callable[..., Awaitable[Any]]] = []
        for sub in self._subscriptions.values():
            if getattr(sub, "handler_name", None) == name:
                handler = getattr(sub, "handler", None)
                if handler is not None:
                    handlers.append(handler)
        return handlers

    async def _run_handler(
        self,
        handler: Callable[..., Awaitable[Any]],
        event: Event,
    ) -> None:
        last_exception: Exception | None = None
        for attempt in range(self._max_retries):
            try:
                await handler(event)
                return
            except Exception as exc:
                last_exception = exc
                if attempt < self._max_retries - 1:
                    await asyncio.sleep(0.5 * (2 ** attempt))
        if last_exception is not None:
            raise last_exception

    async def _send_to_dead_letter(self, event: Event, error: Exception) -> None:
        entry = {
            "event_type": event.event_type.value,
            "data": event.data,
            "correlation_id": event.correlation_id,
            "error": str(error),
            "timestamp": time.monotonic(),
        }
        async with self._lock:
            self._dead_letter_queue.append(entry)

    def _matches_filter(self, data: dict[str, Any], condition: dict[str, Any]) -> bool:
        for key, expected in condition.items():
            actual = data.get(key)
            if isinstance(expected, (list, set)):
                if actual not in expected:
                    return False
            elif actual != expected:
                return False
        return True
