from __future__ import annotations

from abc import ABC, abstractmethod

from nexora_ai.domain.entities.event import DeadLetterEvent, Event, Subscription


class EventBusInterface(ABC):
    @abstractmethod
    async def publish(self, event: Event) -> str: ...

    @abstractmethod
    async def subscribe(self, subscription: Subscription) -> str: ...

    @abstractmethod
    async def unsubscribe(self, subscription_id: str) -> bool: ...

    @abstractmethod
    async def get_dead_letter_queue(self) -> list[DeadLetterEvent]: ...

    @abstractmethod
    async def replay_dead_letter(self, event_id: str) -> bool: ...

    @abstractmethod
    async def clear_dead_letter_queue(self) -> int: ...
