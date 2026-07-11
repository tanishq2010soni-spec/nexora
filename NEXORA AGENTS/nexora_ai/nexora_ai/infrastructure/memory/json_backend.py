from __future__ import annotations

import asyncio
import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from nexora_ai.domain.interfaces.memory_interface import (
    MemoryEntry,
    MemoryInterface,
    MemorySearchResult,
)


class JSONMemoryBackend(MemoryInterface):
    def __init__(self, file_path: str | Path) -> None:
        self._file_path = Path(file_path)
        self._lock: asyncio.Lock = asyncio.Lock()
        self._entries: dict[str, dict[str, Any]] = {}
        self._dirty: bool = False
        self._auto_save_task: asyncio.Task[Any] | None = None

    async def _load(self) -> None:
        if self._file_path.exists():
            raw = self._file_path.read_text(encoding="utf-8")
            data = json.loads(raw)
            self._entries = {e["id"]: e for e in data.get("entries", [])}
        else:
            self._entries = {}
        self._dirty = False

    async def _save(self) -> None:
        data = {"entries": list(self._entries.values())}
        self._file_path.parent.mkdir(parents=True, exist_ok=True)
        self._file_path.write_text(json.dumps(data, indent=2, default=str), encoding="utf-8")
        self._dirty = False

    async def _ensure_loaded(self) -> None:
        if not self._entries and self._file_path.exists():
            await self._load()

    async def _start_auto_save(self) -> None:
        if self._auto_save_task is None:
            self._auto_save_task = asyncio.create_task(self._auto_save_loop())

    async def _auto_save_loop(self) -> None:
        while True:
            await asyncio.sleep(30.0)
            async with self._lock:
                if self._dirty:
                    await self._save()

    def _entry_to_dict(self, entry: MemoryEntry) -> dict[str, Any]:
        return {
            "id": entry.id,
            "type": entry.type.value if hasattr(entry.type, "value") else entry.type,
            "content": entry.content,
            "embedding": entry.embedding.hex() if isinstance(entry.embedding, bytes) else (entry.embedding if entry.embedding else None),
            "importance": entry.importance.value if hasattr(entry.importance, "value") else entry.importance,
            "score": entry.score,
            "tags": entry.tags,
            "source": entry.source,
            "conversation_id": entry.conversation_id,
            "user_id": entry.user_id,
            "metadata": entry.metadata,
            "created_at": entry.created_at.isoformat() if entry.created_at else datetime.now(timezone.utc).isoformat(),
            "accessed_at": entry.accessed_at.isoformat() if entry.accessed_at else None,
            "expires_at": entry.expires_at.isoformat() if entry.expires_at else None,
            "is_deleted": getattr(entry, "is_deleted", False),
        }

    def _dict_to_entry(self, data: dict[str, Any]) -> MemoryEntry:
        embedding = None
        if data.get("embedding"):
            embedding = bytes.fromhex(data["embedding"])
        return MemoryEntry(
            id=data["id"],
            type=data["type"],
            content=data["content"],
            embedding=embedding,
            importance=data.get("importance", "medium"),
            score=data.get("score", 0.0),
            tags=data.get("tags", []),
            source=data.get("source", ""),
            conversation_id=data.get("conversation_id", ""),
            user_id=data.get("user_id", ""),
            metadata=data.get("metadata", {}),
            created_at=datetime.fromisoformat(data["created_at"]) if data.get("created_at") else None,
            accessed_at=datetime.fromisoformat(data["accessed_at"]) if data.get("accessed_at") else None,
            expires_at=datetime.fromisoformat(data["expires_at"]) if data.get("expires_at") else None,
            is_deleted=data.get("is_deleted", False),
        )

    async def store(self, entry: MemoryEntry) -> str:
        async with self._lock:
            await self._ensure_loaded()
            entry_dict = self._entry_to_dict(entry)
            entry_dict["is_deleted"] = False
            self._entries[entry.id] = entry_dict
            self._dirty = True
            await self._save()
        return entry.id

    async def retrieve(self, id: str) -> MemoryEntry | None:
        async with self._lock:
            await self._ensure_loaded()
            data = self._entries.get(id)
            if data is None or data.get("is_deleted"):
                return None
            return self._dict_to_entry(data)

    async def search(
        self,
        query: str | MemorySearchQuery | None = None,
        type: str | None = None,
        tags: list[str] | None = None,
        min_score: float | None = None,
        limit: int = 20,
        offset: int = 0,
    ) -> MemorySearchResult:
        from nexora_ai.domain.entities.memory import MemorySearchQuery

        if isinstance(query, MemorySearchQuery):
            search_query = query
        else:
            search_query = MemorySearchQuery(
                text=query or "",
                tags=tags or [],
                min_score=min_score or 0.0,
                limit=limit,
                offset=offset,
            )

        async with self._lock:
            await self._ensure_loaded()
            results: list[MemoryEntry] = []
            for data in self._entries.values():
                if data.get("is_deleted"):
                    continue
                if search_query.types:
                    type_values = [t.value if hasattr(t, "value") else str(t) for t in search_query.types]
                    if data.get("type") not in type_values:
                        continue
                elif type is not None and data.get("type") != type:
                    continue
                if search_query.min_score > 0 and data.get("score", 0.0) < search_query.min_score:
                    continue
                elif min_score is not None and data.get("score", 0.0) < min_score:
                    continue
                if search_query.text and search_query.text.lower() not in data.get("content", "").lower():
                    continue
                if search_query.tags:
                    entry_tags = set(data.get("tags", []))
                    if not entry_tags.intersection(search_query.tags):
                        continue
                elif tags:
                    entry_tags = set(data.get("tags", []))
                    if not entry_tags.intersection(tags):
                        continue
                results.append(self._dict_to_entry(data))

            results.sort(key=lambda e: e.score, reverse=True)
            total = len(results)
            paged = results[search_query.offset:search_query.offset + search_query.limit]
            return MemorySearchResult(entries=paged, total=total, query=search_query)

    async def update(self, id: str | MemoryEntry, entry: MemoryEntry | None = None) -> bool:
        if isinstance(id, MemoryEntry):
            entry = id
            id = entry.id
        if entry is None:
            return False
        async with self._lock:
            await self._ensure_loaded()
            if id in self._entries:
                self._entries[id] = self._entry_to_dict(entry)
                self._dirty = True
                await self._save()
                return True
            return False

    async def delete(self, id: str) -> bool:
        async with self._lock:
            await self._ensure_loaded()
            if id in self._entries and not self._entries[id].get("is_deleted"):
                self._entries[id]["is_deleted"] = True
                self._dirty = True
                await self._save()
                return True
            return False

    async def clear(self, user_id: str | None = None, type: str | None = None) -> int:
        async with self._lock:
            await self._ensure_loaded()
            count = 0
            if user_id is not None:
                for data in self._entries.values():
                    if data.get("user_id") == user_id and not data.get("is_deleted"):
                        data["is_deleted"] = True
                        count += 1
            elif type is not None:
                for data in self._entries.values():
                    if data.get("type") == type and not data.get("is_deleted"):
                        data["is_deleted"] = True
                        count += 1
            else:
                for data in self._entries.values():
                    if not data.get("is_deleted"):
                        data["is_deleted"] = True
                        count += 1
            if count > 0:
                self._dirty = True
                await self._save()
            return count

    async def get_stats(self) -> dict[str, Any]:
        async with self._lock:
            await self._ensure_loaded()
            active = [e for e in self._entries.values() if not e.get("is_deleted")]
            count = len(active)
            avg_score = sum(e.get("score", 0.0) for e in active) / count if count > 0 else 0.0
            return {"count": count, "avg_score": avg_score}
