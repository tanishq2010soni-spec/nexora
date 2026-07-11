from __future__ import annotations

from typing import Any

from nexora_ai.domain.interfaces.memory_interface import (
    MemoryEntry,
    MemoryInterface,
    MemorySearchResult,
)


class VectorMemoryBackend(MemoryInterface):
    """Skeleton adapter for vector database integration.

    This is a placeholder for production vector database integration.
    To use this backend in production, install qdrant-client or chromadb
    and implement the abstract methods with the appropriate vector operations.
    """

    async def store(self, entry: MemoryEntry) -> str:
        raise NotImplementedError(
            "Production implementation requires qdrant-client or chromadb"
        )

    async def retrieve(self, id: str) -> MemoryEntry | None:
        raise NotImplementedError(
            "Production implementation requires qdrant-client or chromadb"
        )

    async def search(
        self,
        query: str,
        type: str | None = None,
        tags: list[str] | None = None,
        min_score: float | None = None,
        limit: int = 20,
        offset: int = 0,
    ) -> MemorySearchResult:
        raise NotImplementedError(
            "Production implementation requires qdrant-client or chromadb"
        )

    async def update(self, entry: MemoryEntry) -> None:
        raise NotImplementedError(
            "Production implementation requires qdrant-client or chromadb"
        )

    async def delete(self, id: str) -> None:
        raise NotImplementedError(
            "Production implementation requires qdrant-client or chromadb"
        )

    async def clear(self, type: str | None = None) -> None:
        raise NotImplementedError(
            "Production implementation requires qdrant-client or chromadb"
        )

    async def get_stats(self) -> dict[str, Any]:
        raise NotImplementedError(
            "Production implementation requires qdrant-client or chromadb"
        )
