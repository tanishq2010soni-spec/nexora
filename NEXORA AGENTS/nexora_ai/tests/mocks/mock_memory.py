from __future__ import annotations

from datetime import datetime, timezone
from typing import Any

from nexora_ai.domain.entities.memory import MemoryEntry, MemorySearchQuery, MemorySearchResult, MemorySummary
from nexora_ai.domain.enums.memory_enums import MemoryBackendType


class InMemoryMemoryBackend:

    def __init__(self, config: dict[str, Any] | None = None) -> None:
        self._config = config or {}
        self._store: dict[str, MemoryEntry] = {}
        self._backend_type = MemoryBackendType.IN_MEMORY
        self._summaries: dict[str, MemorySummary] = {}

    @property
    def backend_type(self) -> MemoryBackendType:
        return self._backend_type

    async def initialize(self) -> None:
        pass

    async def store(self, entry: MemoryEntry) -> str:
        entry.accessed_at = datetime.now(timezone.utc)
        self._store[entry.id] = entry
        return entry.id

    async def retrieve(self, entry_id: str) -> MemoryEntry | None:
        entry = self._store.get(entry_id)
        if entry:
            entry.accessed_at = datetime.now(timezone.utc)
        return entry

    async def search(self, query: MemorySearchQuery) -> MemorySearchResult:
        results = list(self._store.values())

        if query.types:
            results = [e for e in results if e.type in query.types]
        if query.tags:
            results = [e for e in results if any(t in e.tags for t in query.tags)]
        if query.min_score > 0:
            results = [e for e in results if e.score >= query.min_score]
        if query.user_id:
            results = [e for e in results if e.user_id == query.user_id]
        if query.text:
            text_lower = query.text.lower()
            results = [e for e in results if text_lower in e.content.lower()]

        results.sort(key=lambda e: (e.score, e.created_at), reverse=True)
        total = len(results)
        paged = results[query.offset:query.offset + query.limit]

        return MemorySearchResult(
            entries=paged,
            total=total,
            query=query,
        )

    async def delete(self, entry_id: str) -> bool:
        if entry_id in self._store:
            del self._store[entry_id]
            return True
        return False

    async def update(self, entry: MemoryEntry) -> bool:
        if entry.id in self._store:
            entry.accessed_at = datetime.now(timezone.utc)
            self._store[entry.id] = entry
            return True
        return False

    async def prune(self, max_entries: int | None = None, max_age_days: int | None = None) -> int:
        now = datetime.now(timezone.utc)
        to_delete: list[str] = []

        if max_age_days is not None:
            for eid, entry in self._store.items():
                age = (now - entry.created_at).days
                if age > max_age_days:
                    to_delete.append(eid)

        for eid in to_delete:
            del self._store[eid]

        if max_entries is not None and len(self._store) > max_entries:
            sorted_entries = sorted(self._store.values(), key=lambda e: (e.score, e.created_at))
            excess = len(sorted_entries) - max_entries
            for entry in sorted_entries[:excess]:
                if entry.id not in to_delete:
                    del self._store[entry.id]
                    to_delete.append(entry.id)

        return len(to_delete)

    async def count(self) -> int:
        return len(self._store)

    async def clear(self) -> None:
        self._store.clear()

    async def get_summary(self, summary_id: str) -> MemorySummary | None:
        return self._summaries.get(summary_id)

    async def save_summary(self, summary: MemorySummary) -> str:
        self._summaries[summary.id] = summary
        return summary.id

    async def close(self) -> None:
        pass
