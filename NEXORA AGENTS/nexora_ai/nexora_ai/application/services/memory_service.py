from __future__ import annotations

from datetime import datetime, timezone

from nexora_ai.domain.entities.memory import MemoryEntry, MemoryImportance, MemorySearchResult


class MemoryService:

    def score_memory(self, entry: MemoryEntry) -> float:
        now = datetime.now(timezone.utc)
        age_hours = (now - entry.created_at).total_seconds() / 3600.0
        recency = 1.0 / (1.0 + age_hours)
        frequency = entry.metadata.get("frequency", 1)
        if isinstance(frequency, int):
            frequency_score = min(frequency / 10.0, 1.0)
        else:
            frequency_score = 0.1
        importance_weights = {
            MemoryImportance.LOW: 0.25,
            MemoryImportance.MEDIUM: 0.5,
            MemoryImportance.HIGH: 0.75,
            MemoryImportance.CRITICAL: 1.0,
        }
        importance_weight = importance_weights.get(entry.importance, 0.5)
        score = recency * 0.4 + frequency_score * 0.3 + importance_weight * 0.3
        return round(score, 4)

    def prune_memories(self, entries: list[MemoryEntry], max_count: int) -> list[MemoryEntry]:
        if len(entries) <= max_count:
            return list(entries)
        scored = [(self.score_memory(e), e) for e in entries]
        scored.sort(key=lambda x: x[0], reverse=True)
        return [e for _, e in scored[:max_count]]

    async def summarize_entries(self, entries: list[MemoryEntry], max_tokens: int) -> str:
        total_tokens = 0
        parts: list[str] = []
        for entry in entries:
            tokens = len(entry.content) // 4
            if total_tokens + tokens > max_tokens:
                break
            parts.append(entry.content)
            total_tokens += tokens
        return " ".join(parts)

    def merge_results(self, results: list[MemorySearchResult]) -> MemorySearchResult:
        if not results:
            return MemorySearchResult(entries=[], total=0, query=results[0].query if results else None)
        seen: dict[str, MemoryEntry] = {}
        total = 0
        for result in results:
            for entry in result.entries:
                if entry.id not in seen:
                    seen[entry.id] = entry
                else:
                    seen[entry.id].score = max(seen[entry.id].score, entry.score)
            total += result.total
        merged_entries = sorted(seen.values(), key=lambda e: e.score, reverse=True)
        return MemorySearchResult(
            entries=merged_entries,
            total=len(merged_entries),
            query=results[0].query,
        )
