from __future__ import annotations

from datetime import datetime, timedelta, timezone

import pytest

from nexora_ai.domain.entities.memory import MemoryEntry, MemorySearchQuery, MemorySearchResult
from nexora_ai.domain.enums.memory_enums import MemoryImportance, MemoryType
from tests.mocks import InMemoryMemoryBackend


@pytest.fixture
async def memory() -> InMemoryMemoryBackend:
    mem = InMemoryMemoryBackend()
    await mem.initialize()
    return mem


@pytest.fixture
async def populated_memory(memory: InMemoryMemoryBackend) -> InMemoryMemoryBackend:
    entries = [
        MemoryEntry(
            id="1", type=MemoryType.CONVERSATION, content="Hello world",
            tags=["greeting"], score=0.9, importance=MemoryImportance.HIGH,
        ),
        MemoryEntry(
            id="2", type=MemoryType.FACT, content="The sky is blue",
            tags=["fact", "weather"], score=0.5,
        ),
        MemoryEntry(
            id="3", type=MemoryType.CONVERSATION, content="Goodbye world",
            tags=["farewell"], score=0.3, importance=MemoryImportance.LOW,
        ),
        MemoryEntry(
            id="4", type=MemoryType.WORKFLOW, content="Task completed",
            tags=["task"], score=0.7, user_id="user1",
        ),
    ]
    for entry in entries:
        await memory.store(entry)
    return memory


class TestMemoryManager:

    async def test_store_and_retrieve(self, memory: InMemoryMemoryBackend) -> None:
        entry = MemoryEntry(
            id="test1", type=MemoryType.CONVERSATION, content="Test memory"
        )
        stored_id = await memory.store(entry)
        assert stored_id == "test1"

        retrieved = await memory.retrieve("test1")
        assert retrieved is not None
        assert retrieved.content == "Test memory"
        assert retrieved.type == MemoryType.CONVERSATION

    async def test_search_by_content(self, populated_memory: InMemoryMemoryBackend) -> None:
        query = MemorySearchQuery(text="world")
        result = await populated_memory.search(query)
        assert result.total == 2
        contents = [e.content for e in result.entries]
        assert "Hello world" in contents
        assert "Goodbye world" in contents

        query = MemorySearchQuery(text="nonexistent")
        result = await populated_memory.search(query)
        assert result.total == 0

    async def test_search_by_type(self, populated_memory: InMemoryMemoryBackend) -> None:
        query = MemorySearchQuery(text="", types=[MemoryType.FACT])
        result = await populated_memory.search(query)
        assert result.total == 1
        assert result.entries[0].content == "The sky is blue"

    async def test_search_by_tags(self, populated_memory: InMemoryMemoryBackend) -> None:
        query = MemorySearchQuery(text="", tags=["greeting"])
        result = await populated_memory.search(query)
        assert result.total == 1
        assert result.entries[0].content == "Hello world"

        query = MemorySearchQuery(text="", tags=["fact", "weather"])
        result = await populated_memory.search(query)
        assert result.total == 1

    async def test_delete(self, memory: InMemoryMemoryBackend) -> None:
        entry = MemoryEntry(id="del1", type=MemoryType.CONVERSATION, content="Delete me")
        await memory.store(entry)
        assert await memory.retrieve("del1") is not None
        assert await memory.delete("del1") is True
        assert await memory.retrieve("del1") is None
        assert await memory.delete("nonexistent") is False

    async def test_prune(self, populated_memory: InMemoryMemoryBackend) -> None:
        pruned = await populated_memory.prune(max_entries=2)
        assert pruned == 2
        assert await populated_memory.count() == 2

        old_entry = MemoryEntry(
            id="old", type=MemoryType.CONVERSATION, content="Old",
            created_at=datetime.now(timezone.utc) - timedelta(days=100),
        )
        await populated_memory.store(old_entry)
        pruned = await populated_memory.prune(max_age_days=30)
        assert pruned >= 1

    async def test_score_calculation(self, memory: InMemoryMemoryBackend) -> None:
        high = MemoryEntry(id="h", type=MemoryType.CONVERSATION, content="High", score=0.9)
        low = MemoryEntry(id="l", type=MemoryType.CONVERSATION, content="Low", score=0.1)
        await memory.store(high)
        await memory.store(low)

        query = MemorySearchQuery(text="")
        result = await memory.search(query)
        assert result.entries[0].score >= result.entries[-1].score

    async def test_summarize(self, memory: InMemoryMemoryBackend) -> None:
        from nexora_ai.domain.entities.memory import MemorySummary
        summary = MemorySummary(
            id="sum1", original_entries=3, summary_text="Summary of three entries"
        )
        saved_id = await memory.save_summary(summary)
        assert saved_id == "sum1"

        retrieved = await memory.get_summary("sum1")
        assert retrieved is not None
        assert retrieved.summary_text == "Summary of three entries"
        assert retrieved.original_entries == 3
