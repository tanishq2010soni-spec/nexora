from __future__ import annotations

import pytest

from nexora_ai.domain.enums.event_enums import EventPriority
from tests.mocks import MockEventBus


class TestEventBus:

    async def test_publish_and_receive(self, event_bus: MockEventBus) -> None:
        received: list[dict] = []

        async def handler(event: dict) -> None:
            received.append(event)

        await event_bus.subscribe("test.event", handler)
        await event_bus.publish("test.event", {"key": "value"})
        assert len(received) == 1
        assert received[0]["type"] == "test.event"
        assert received[0]["data"]["key"] == "value"

    async def test_subscription_filtering(self, event_bus: MockEventBus) -> None:
        received: list[dict] = []

        async def handler(event: dict) -> None:
            received.append(event)

        await event_bus.subscribe("filtered.event", handler, source="app1")
        await event_bus.publish("filtered.event", {"key": "value"}, source="app1")
        assert len(received) == 1

        await event_bus.publish("filtered.event", {"key": "value2"}, source="app2")
        assert len(received) == 1

    async def test_priority_order(self, event_bus: MockEventBus) -> None:
        order: list[str] = []

        async def handler_low(event: dict) -> None:
            order.append("low")

        async def handler_high(event: dict) -> None:
            order.append("high")

        async def handler_normal(event: dict) -> None:
            order.append("normal")

        await event_bus.subscribe("priority.event", handler_low, priority=EventPriority.LOW)
        await event_bus.subscribe("priority.event", handler_high, priority=EventPriority.HIGH)
        await event_bus.subscribe("priority.event", handler_normal, priority=EventPriority.NORMAL)
        await event_bus.publish("priority.event", {})
        assert order == ["high", "normal", "low"]

    async def test_dead_letter_queue(self, event_bus: MockEventBus) -> None:
        async def failing_handler(event: dict) -> None:
            raise RuntimeError("Handler failed")

        await event_bus.subscribe("failing.event", failing_handler)
        await event_bus.publish("failing.event", {"data": 1})
        assert event_bus.get_dead_letter_count() == 1

    async def test_handler_error_retry(self, event_bus: MockEventBus) -> None:
        attempt_count = 0

        async def flaky_handler(event: dict) -> None:
            nonlocal attempt_count
            attempt_count += 1
            if attempt_count < 2:
                raise RuntimeError("Temporary failure")

        await event_bus.subscribe("retry.event", flaky_handler)
        await event_bus.publish("retry.event", {})

        assert event_bus.get_dead_letter_count() == 1

    async def test_unsubscribe(self, event_bus: MockEventBus) -> None:
        received: list[dict] = []

        async def handler(event: dict) -> None:
            received.append(event)

        await event_bus.subscribe("unsub.event", handler)
        await event_bus.publish("unsub.event", {})
        assert len(received) == 1

        result = await event_bus.unsubscribe("unsub.event", handler)
        assert result is True

        await event_bus.publish("unsub.event", {})
        assert len(received) == 1

        result = await event_bus.unsubscribe("unsub.event", handler)
        assert result is False
