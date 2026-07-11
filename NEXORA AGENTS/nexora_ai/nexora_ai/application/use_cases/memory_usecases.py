from __future__ import annotations

from datetime import datetime, timezone
from typing import Any, Protocol
from uuid import uuid4

from nexora_ai.domain.entities.memory import (
    MemoryEntry,
    MemoryImportance,
    MemorySearchQuery,
    MemorySearchResult,
    MemorySummary,
    MemoryType,
)
from nexora_ai.application.services.memory_service import MemoryService


class MemoryRepository(Protocol):
    async def store(self, entry: MemoryEntry) -> str: ...
    async def search(self, query: MemorySearchQuery) -> MemorySearchResult: ...
    async def get_by_conversation(self, conversation_id: str, limit: int) -> list[MemoryEntry]: ...
    async def get_by_user(self, user_id: str, types: list[MemoryType] | None) -> list[MemoryEntry]: ...
    async def delete_older_than(self, cutoff: datetime) -> int: ...


class MemoryUseCases:
    def __init__(
        self,
        memory_service: MemoryService,
        repository: MemoryRepository,
    ) -> None:
        self._memory_service = memory_service
        self._repository = repository

    async def store_conversation_memory(
        self,
        conversation_id: str,
        content: str,
        importance: MemoryImportance = MemoryImportance.MEDIUM,
    ) -> str:
        entry = MemoryEntry(
            id=str(uuid4()),
            type=MemoryType.CONVERSATION,
            content=content,
            importance=importance,
            conversation_id=conversation_id,
        )
        return await self._repository.store(entry)

    async def search_memory(
        self,
        query: str,
        user_id: str | None = None,
        limit: int = 20,
    ) -> list[MemoryEntry]:
        search_query = MemorySearchQuery(
            text=query,
            user_id=user_id,
            limit=limit,
        )
        result = await self._repository.search(search_query)
        return result.entries

    async def get_conversation_context(
        self,
        conversation_id: str,
        max_tokens: int,
    ) -> list[MemoryEntry]:
        entries = await self._repository.get_by_conversation(conversation_id, limit=50)
        scored = [(self._memory_service.score_memory(e), e) for e in entries]
        scored.sort(key=lambda x: x[0], reverse=True)
        total_tokens = 0
        result: list[MemoryEntry] = []
        for score, entry in scored:
            tokens = len(entry.content) // 4
            if total_tokens + tokens > max_tokens:
                break
            result.append(entry)
            total_tokens += tokens
        return result

    async def summarize_memory(
        self,
        user_id: str,
        types: list[MemoryType],
    ) -> MemorySummary:
        entries = await self._repository.get_by_user(user_id, types)
        summary_text = await self._memory_service.summarize_entries(entries, max_tokens=500)
        return MemorySummary(
            id=str(uuid4()),
            original_entries=len(entries),
            summary_text=summary_text,
        )

    async def prune_old_memory(self, max_age_days: int = 30) -> None:
        cutoff = datetime.now(timezone.utc).replace(
            hour=0, minute=0, second=0, microsecond=0
        )
        import datetime as dt

        cutoff = cutoff - dt.timedelta(days=max_age_days)
        await self._repository.delete_older_than(cutoff)
