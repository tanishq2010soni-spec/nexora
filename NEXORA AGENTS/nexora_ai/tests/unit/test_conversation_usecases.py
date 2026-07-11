from __future__ import annotations

import pytest

from tests.mocks import MockConfigManager, MockEventBus, MockProviderAdapter
from tests.mocks.mock_memory import InMemoryMemoryBackend
from tests.conftest import ConversationService


@pytest.fixture
async def service() -> ConversationService:
    provider = MockProviderAdapter({"model": "test-model"})
    memory = InMemoryMemoryBackend()
    await memory.initialize()
    bus = MockEventBus()
    config = MockConfigManager({"provider": {"type": "mock"}})
    return ConversationService(provider, memory, bus, config)


class TestConversationUseCases:

    async def test_create_conversation(self, service: ConversationService) -> None:
        conv_id = await service.create_conversation("thread-1", "You are a helpful assistant.")
        assert conv_id is not None
        assert isinstance(conv_id, str)
        history = await service.get_history(conv_id)
        assert history == []
        events = service._event_bus.get_published_events("conversation.created")
        assert len(events) == 1
        assert events[0]["data"]["conversation_id"] == conv_id

    async def test_send_message(self, service: ConversationService) -> None:
        conv_id = await service.create_conversation("thread-1")
        response = await service.send_message(conv_id, "Hello!")
        assert response is not None
        assert "Hello!" in response
        history = await service.get_history(conv_id)
        assert len(history) == 2
        assert history[0]["role"] == "user"
        assert history[1]["role"] == "assistant"

    async def test_send_message_streaming(self, service: ConversationService) -> None:
        conv_id = await service.create_conversation("thread-1")
        chunks = await service.send_message_streaming(conv_id, "Tell me a story")
        assert len(chunks) > 0
        full = "".join(chunks)
        assert len(full) > 0

    async def test_get_history(self, service: ConversationService) -> None:
        conv_id = await service.create_conversation("thread-1")
        history = await service.get_history(conv_id)
        assert history == []
        await service.send_message(conv_id, "Hi")
        history = await service.get_history(conv_id)
        assert len(history) == 2

        with pytest.raises(ValueError, match="not found"):
            await service.get_history("nonexistent")

    async def test_context_trimming(self, service: ConversationService) -> None:
        conv_id = await service.create_conversation("thread-1")
        for i in range(15):
            await service.send_message(conv_id, f"Message {i}")
        trimmed = await service.context_trimming(conv_id, max_messages=10)
        assert trimmed == 20
        history = await service.get_history(conv_id)
        assert len(history) <= 10

    async def test_memory_injection(self, service: ConversationService) -> None:
        from nexora_ai.domain.entities.memory import MemoryEntry
        from nexora_ai.domain.enums.memory_enums import MemoryType

        entry = MemoryEntry(
            id="mem1", type=MemoryType.CONVERSATION,
            content="User likes Python programming",
        )
        await service._memory.store(entry)

        conv_id = await service.create_conversation("thread-1")
        memories = await service.memory_injection(conv_id, "Python")
        assert len(memories) >= 1
        assert "Python" in memories[0]["content"]
