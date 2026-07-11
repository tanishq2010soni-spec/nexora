from __future__ import annotations

import asyncio
from collections.abc import AsyncGenerator
from typing import Any

import pytest

from tests.mocks import (
    InMemoryMemoryBackend,
    MockConfigManager,
    MockEventBus,
    MockProviderAdapter,
    MockRuntime,
)


@pytest.fixture
def event_loop() -> asyncio.AbstractEventLoop:
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    yield loop
    if not loop.is_closed():
        loop.close()


@pytest.fixture
async def mock_provider() -> AsyncGenerator[MockProviderAdapter, None]:
    provider = MockProviderAdapter({"model": "test-model"})
    yield provider


@pytest.fixture
async def memory_manager() -> AsyncGenerator[InMemoryMemoryBackend, None]:
    mem = InMemoryMemoryBackend()
    await mem.initialize()
    yield mem
    await mem.clear()
    await mem.close()


@pytest.fixture
async def runtime() -> AsyncGenerator[MockRuntime, None]:
    rt = MockRuntime({"name": "test-runtime"})
    await rt.start()
    yield rt
    await rt.close()


@pytest.fixture
def event_bus() -> MockEventBus:
    return MockEventBus()


@pytest.fixture
def config_manager() -> MockConfigManager:
    return MockConfigManager({
        "provider": {"type": "mock", "model": "test-model"},
        "memory": {"backend": "in_memory"},
        "logging": {"level": "DEBUG", "format": "json"},
        "security": {"permission_mode": "audit_only"},
        "runtime": {"max_tasks": 10},
    })


@pytest.fixture
async def conversation_service(mock_provider: MockProviderAdapter, memory_manager: InMemoryMemoryBackend) -> Any:
    from tests.mocks.mock_event_bus import MockEventBus

    bus = MockEventBus()
    config = MockConfigManager({"provider": {"type": "mock", "model": "test-model"}})

    service = ConversationService(mock_provider, memory_manager, bus, config)
    return service


@pytest.fixture
def logger() -> Any:
    import io
    import json
    from datetime import datetime, timezone

    class BufferLogger:

        def __init__(self) -> None:
            self.buffer: list[dict[str, Any]] = []
            self._correlation_id: str | None = None

        def _log(self, level: str, message: str, **kwargs: Any) -> None:
            record: dict[str, Any] = {
                "timestamp": datetime.now(timezone.utc).isoformat(),
                "level": level,
                "message": message,
                "correlation_id": self._correlation_id,
                **kwargs,
            }
            self.buffer.append(record)

        def debug(self, message: str, **kwargs: Any) -> None:
            self._log("DEBUG", message, **kwargs)

        def info(self, message: str, **kwargs: Any) -> None:
            self._log("INFO", message, **kwargs)

        def warning(self, message: str, **kwargs: Any) -> None:
            self._log("WARNING", message, **kwargs)

        def error(self, message: str, **kwargs: Any) -> None:
            self._log("ERROR", message, **kwargs)

        def critical(self, message: str, **kwargs: Any) -> None:
            self._log("CRITICAL", message, **kwargs)

        def set_correlation_id(self, cid: str | None) -> None:
            self._correlation_id = cid

        def get_records(self, level: str | None = None) -> list[dict[str, Any]]:
            if level:
                return [r for r in self.buffer if r["level"] == level]
            return list(self.buffer)

        def clear(self) -> None:
            self.buffer.clear()

        @property
        def correlation_id(self) -> str | None:
            return self._correlation_id

    return BufferLogger()


class ConversationService:

    def __init__(
        self,
        provider: MockProviderAdapter,
        memory: InMemoryMemoryBackend,
        event_bus: MockEventBus,
        config: MockConfigManager,
    ) -> None:
        self._provider = provider
        self._memory = memory
        self._event_bus = event_bus
        self._config = config
        self._conversations: dict[str, Any] = {}

    async def create_conversation(self, thread_id: str, system_prompt: str | None = None) -> str:
        import uuid
        conv_id = str(uuid.uuid4())
        self._conversations[conv_id] = {
            "id": conv_id,
            "thread_id": thread_id,
            "system_prompt": system_prompt,
            "messages": [],
            "status": "active",
        }
        await self._event_bus.publish("conversation.created", {"conversation_id": conv_id})
        return conv_id

    async def send_message(self, conversation_id: str, content: str) -> str:
        conv = self._conversations.get(conversation_id)
        if not conv:
            raise ValueError(f"Conversation {conversation_id} not found")
        conv["messages"].append({"role": "user", "content": content})
        result_parts: list[str] = []
        async for chunk in self._provider.chat(conv["messages"]):
            result_parts.append(chunk.content)
        result = "".join(result_parts)
        conv["messages"].append({"role": "assistant", "content": result})
        await self._event_bus.publish("message.sent", {"conversation_id": conversation_id, "content": result})
        return result

    async def send_message_streaming(self, conversation_id: str, content: str) -> list[str]:
        conv = self._conversations.get(conversation_id)
        if not conv:
            raise ValueError(f"Conversation {conversation_id} not found")
        conv["messages"].append({"role": "user", "content": content})
        chunks: list[str] = []
        async for chunk in self._provider.chat(conv["messages"], {"stream": True}):
            chunks.append(chunk.content)
        full = "".join(chunks)
        conv["messages"].append({"role": "assistant", "content": full})
        return chunks

    async def get_history(self, conversation_id: str) -> list[dict[str, Any]]:
        conv = self._conversations.get(conversation_id)
        if not conv:
            raise ValueError(f"Conversation {conversation_id} not found")
        return list(conv["messages"])

    async def context_trimming(self, conversation_id: str, max_messages: int = 10) -> int:
        conv = self._conversations.get(conversation_id)
        if not conv:
            raise ValueError(f"Conversation {conversation_id} not found")
        if len(conv["messages"]) > max_messages:
            excess = len(conv["messages"]) - max_messages
            conv["messages"] = conv["messages"][excess:]
            return excess
        return 0

    async def memory_injection(self, conversation_id: str, query: str) -> list[dict[str, Any]]:
        from nexora_ai.domain.entities.memory import MemorySearchQuery
        sq = MemorySearchQuery(text=query)
        result = await self._memory.search(sq)
        return [e.to_json() for e in result.entries]
