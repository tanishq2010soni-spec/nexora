from __future__ import annotations

from abc import ABC, abstractmethod

from nexora_ai.domain.entities.memory import MemoryEntry, MemorySearchQuery, MemorySearchResult, MemorySummary


class MemoryInterface(ABC):
    @abstractmethod
    async def store(self, entry: MemoryEntry) -> str: ...

    @abstractmethod
    async def retrieve(self, id: str) -> MemoryEntry | None: ...

    @abstractmethod
    async def search(self, query: MemorySearchQuery) -> MemorySearchResult: ...

    @abstractmethod
    async def update(self, id: str, entry: MemoryEntry) -> bool: ...

    @abstractmethod
    async def delete(self, id: str) -> bool: ...

    @abstractmethod
    async def clear(self, user_id: str | None = None) -> int: ...

    @abstractmethod
    async def get_stats(self) -> dict: ...
