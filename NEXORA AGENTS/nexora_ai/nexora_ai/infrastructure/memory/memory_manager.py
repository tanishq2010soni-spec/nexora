from __future__ import annotations

import time
from datetime import datetime, timezone
from typing import Any

from nexora_ai.domain.interfaces.memory_interface import (
    MemoryEntry,
    MemoryInterface,
    MemorySearchResult,
    MemorySummary,
)


class MemoryManager:
    def __init__(
        self,
        primary_backend: MemoryInterface,
        secondary_backend: MemoryInterface | None = None,
        vector_backend: MemoryInterface | None = None,
    ) -> None:
        self._primary = primary_backend
        self._secondary = secondary_backend
        self._vector = vector_backend

    async def store(self, entry: MemoryEntry) -> str:
        entry_id = await self._primary.store(entry)
        if self._vector is not None:
            try:
                await self._vector.store(entry)
            except NotImplementedError:
                pass
        return entry_id

    async def retrieve(self, id: str) -> MemoryEntry | None:
        entry = await self._primary.retrieve(id)
        if entry is None and self._secondary is not None:
            entry = await self._secondary.retrieve(id)
            if entry is not None:
                await self._primary.store(entry)
        return entry

    async def search(
        self,
        query: str | MemorySearchQuery | None = None,
        type: str | None = None,
        tags: list[str] | None = None,
        min_score: float | None = None,
        limit: int = 20,
        offset: int = 0,
    ) -> MemorySearchResult:
        from nexora_ai.domain.entities.memory import MemorySearchQuery as MSQ

        if isinstance(query, MSQ):
            search_query = query
        else:
            search_query = MSQ(
                text=query or "",
                tags=tags or [],
                min_score=min_score or 0.0,
                limit=limit,
                offset=offset,
            )

        primary_result = await self._primary.search(search_query)
        if self._secondary is not None:
            secondary_result = await self._secondary.search(search_query)
            seen_ids = {e.id for e in primary_result.entries}
            for entry in secondary_result.entries:
                if entry.id not in seen_ids:
                    primary_result.entries.append(entry)
                    seen_ids.add(entry.id)
            primary_result.total = len(primary_result.entries)
        return primary_result

    async def summarize(self, entries: list[MemoryEntry], max_tokens: int) -> MemorySummary:
        from uuid import uuid4

        content_parts: list[str] = []
        token_count = 0
        for entry in entries:
            approx_tokens = len(entry.content) // 4 + 1
            if token_count + approx_tokens > max_tokens:
                remaining = max_tokens - token_count
                if remaining > 0:
                    content_parts.append(entry.content[:remaining * 4])
                break
            content_parts.append(entry.content)
            token_count += approx_tokens
        summary_text = "\n".join(content_parts)
        return MemorySummary(
            id=str(uuid4()),
            original_entries=len(entries),
            summary_text=summary_text,
            metadata={"token_count": token_count},
        )

    async def prune(self, max_entries: int, strategy: str = "lowest_score") -> int:
        from nexora_ai.domain.entities.memory import MemorySearchQuery

        stats = await self._primary.get_stats()
        count = stats.get("count", 0)
        if count <= max_entries:
            return 0
        to_remove = count - max_entries
        result = await self._primary.search(MemorySearchQuery(text="", limit=count, offset=0))
        sorted_entries = sorted(result.entries, key=lambda e: e.score)
        removed = 0
        for entry in sorted_entries[:to_remove]:
            await self._primary.delete(entry.id)
            removed += 1
        return removed

    async def score(self, entry: MemoryEntry) -> float:
        now = datetime.now(timezone.utc)
        recency_score = 0.0
        if entry.accessed_at is not None:
            hours_since_access = (now - entry.accessed_at).total_seconds() / 3600
            recency_score = max(0.0, 1.0 - hours_since_access / 720.0)
        frequency_score = min(1.0, entry.score * 0.5)
        relevance_score = entry.score * 0.3
        new_score = recency_score * 0.4 + frequency_score * 0.3 + relevance_score * 0.3
        return round(new_score * 10.0, 2)
