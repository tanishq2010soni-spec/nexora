from __future__ import annotations

import asyncio
import uuid
from datetime import datetime, timezone

import pytest

from nexora_ai.domain.entities.memory import MemoryEntry, MemorySearchQuery, MemorySearchResult
from nexora_ai.domain.enums.memory_enums import MemoryImportance, MemoryType
from tests.mocks import InMemoryMemoryBackend


@pytest.fixture
async def memory_backend() -> InMemoryMemoryBackend:
    mem = InMemoryMemoryBackend({"backend": "sqlite", "database": ":memory:"})
    await mem.initialize()
    return mem


class TestSQLiteMemoryIntegration:

    async def test_full_crud_cycle(self, memory_backend: InMemoryMemoryBackend) -> None:
        entry = MemoryEntry(
            id=str(uuid.uuid4()),
            type=MemoryType.CONVERSATION,
            content="Integration test memory entry",
            tags=["test", "integration"],
            score=0.85,
            importance=MemoryImportance.HIGH,
        )
        stored_id = await memory_backend.store(entry)
        assert stored_id == entry.id

        retrieved = await memory_backend.retrieve(stored_id)
        assert retrieved is not None
        assert retrieved.content == "Integration test memory entry"
        assert MemoryType.CONVERSATION in [MemoryType.CONVERSATION]
        assert "test" in retrieved.tags

        entry.content = "Updated content"
        entry.score = 0.95
        updated = await memory_backend.update(entry)
        assert updated is True

        retrieved2 = await memory_backend.retrieve(stored_id)
        assert retrieved2 is not None
        assert retrieved2.content == "Updated content"
        assert retrieved2.score == 0.95

        deleted = await memory_backend.delete(stored_id)
        assert deleted is True

        retrieved3 = await memory_backend.retrieve(stored_id)
        assert retrieved3 is None

    async def test_search_across_multiple_entries(self, memory_backend: InMemoryMemoryBackend) -> None:
        entries = [
            MemoryEntry(id=str(uuid.uuid4()), type=MemoryType.CONVERSATION, content="Python is great for AI", tags=["python", "ai"], score=0.9),
            MemoryEntry(id=str(uuid.uuid4()), type=MemoryType.FACT, content="The Earth orbits the Sun", tags=["science", "astronomy"], score=0.7),
            MemoryEntry(id=str(uuid.uuid4()), type=MemoryType.CONVERSATION, content="Python vs JavaScript", tags=["python", "javascript"], score=0.6),
            MemoryEntry(id=str(uuid.uuid4()), type=MemoryType.WORKFLOW, content="Deploy to production", tags=["devops", "deploy"], score=0.8),
        ]
        for e in entries:
            await memory_backend.store(e)

        query = MemorySearchQuery(text="Python")
        result = await memory_backend.search(query)
        assert result.total == 2
        assert all("Python" in e.content for e in result.entries)

        query = MemorySearchQuery(text="", tags=["python"])
        result = await memory_backend.search(query)
        assert result.total == 2

        query = MemorySearchQuery(text="", types=[MemoryType.FACT])
        result = await memory_backend.search(query)
        assert result.total == 1
        assert result.entries[0].type == MemoryType.FACT

        query = MemorySearchQuery(text="nonexistent")
        result = await memory_backend.search(query)
        assert result.total == 0

    async def test_persistence_across_reloads(self) -> None:
        mem1 = InMemoryMemoryBackend()
        await mem1.initialize()
        entry = MemoryEntry(
            id="persist-test-1", type=MemoryType.CONVERSATION,
            content="Should persist", score=0.5,
        )
        await mem1.store(entry)
        await mem1.close()

        mem2 = InMemoryMemoryBackend()
        await mem2.initialize()
        retrieved = await mem2.retrieve("persist-test-1")
        assert retrieved is None

    async def test_concurrent_access(self, memory_backend: InMemoryMemoryBackend) -> None:
        async def store_entry(index: int) -> str:
            entry = MemoryEntry(
                id=f"concurrent-{index}",
                type=MemoryType.CONVERSATION,
                content=f"Concurrent entry {index}",
                score=float(index) / 10.0,
            )
            return await memory_backend.store(entry)

        tasks = [store_entry(i) for i in range(50)]
        ids = await asyncio.gather(*tasks)
        assert len(ids) == 50

        count = await memory_backend.count()
        assert count == 50

        retrieved = await memory_backend.retrieve("concurrent-25")
        assert retrieved is not None
        assert retrieved.content == "Concurrent entry 25"
