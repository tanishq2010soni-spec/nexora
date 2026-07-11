from __future__ import annotations

import asyncio

import pytest

from nexora_ai.domain.enums.event_enums import EventPriority
from tests.mocks import MockEventBus


class TestEventBusWorkflowIntegration:

    async def test_full_publish_subscribe_flow(self, event_bus: MockEventBus) -> None:
        received_events: list[dict] = []

        async def handler_a(event: dict) -> None:
            received_events.append({"handler": "A", "data": event["data"]})

        async def handler_b(event: dict) -> None:
            received_events.append({"handler": "B", "data": event["data"]})

        await event_bus.subscribe("order.created", handler_a)
        await event_bus.subscribe("order.created", handler_b)

        await event_bus.publish("order.created", {"order_id": "123", "amount": 99.99})

        assert len(received_events) == 2
        assert all(e["data"]["order_id"] == "123" for e in received_events)
        assert {e["handler"] for e in received_events} == {"A", "B"}

        published = event_bus.get_published_events("order.created")
        assert len(published) == 1
        assert published[0]["data"]["order_id"] == "123"

    async def test_multi_handler_dispatch(self, event_bus: MockEventBus) -> None:
        results: list[str] = []

        async def handler_a(event: dict) -> None:
            await asyncio.sleep(0.01)
            results.append("A")

        async def handler_b(event: dict) -> None:
            results.append("B")

        async def handler_c(event: dict) -> None:
            await asyncio.sleep(0.005)
            results.append("C")

        await event_bus.subscribe("multi.event", handler_a, priority=EventPriority.LOW)
        await event_bus.subscribe("multi.event", handler_b, priority=EventPriority.HIGH)
        await event_bus.subscribe("multi.event", handler_c, priority=EventPriority.NORMAL)

        await event_bus.publish("multi.event", {"msg": "hello"})

        assert len(results) == 3
        assert results[0] == "B"
        assert results[1] == "C"
        assert results[2] == "A"

    async def test_error_handling_with_retry(self, event_bus: MockEventBus) -> None:
        attempt_count = 0

        async def flaky_handler(event: dict) -> None:
            nonlocal attempt_count
            attempt_count += 1
            if attempt_count < 3:
                raise RuntimeError(f"Attempt {attempt_count} failed")

        await event_bus.subscribe("flaky.event", flaky_handler)

        await event_bus.publish("flaky.event", {"attempt": "test"})

        assert event_bus.get_dead_letter_count() >= 1

    async def test_dead_letter_replay(self, event_bus: MockEventBus) -> None:
        received: list[dict] = []

        async def failing_handler(event: dict) -> None:
            raise RuntimeError("Always fails")

        async def working_handler(event: dict) -> None:
            received.append(event)

        await event_bus.subscribe("dlq.event", failing_handler)
        await event_bus.subscribe("dlq.event", working_handler)

        await event_bus.publish("dlq.event", {"id": 1})
        assert event_bus.get_dead_letter_count() > 0

        await event_bus.publish("dlq.event", {"id": 2})
        assert event_bus.get_dead_letter_count() > 0

        await event_bus.unsubscribe("dlq.event", failing_handler)

        await event_bus.replay_dead_letter()
        assert len(received) > 0
