from __future__ import annotations

import asyncio
import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

import aiosqlite

from nexora_ai.domain.interfaces.memory_interface import (
    MemoryEntry,
    MemoryInterface,
    MemorySearchResult,
)


class SQLiteMemoryBackend(MemoryInterface):
    def __init__(self, db_path: str | Path) -> None:
        self._db_path = Path(db_path)
        self._conn: aiosqlite.Connection | None = None
        self._lock: asyncio.Lock = asyncio.Lock()

    async def _get_conn(self) -> aiosqlite.Connection:
        if self._conn is None:
            self._db_path.parent.mkdir(parents=True, exist_ok=True)
            self._conn = await aiosqlite.connect(str(self._db_path))
            self._conn.row_factory = aiosqlite.Row
            await self._conn.execute("PRAGMA journal_mode=WAL")
            await self._conn.execute("PRAGMA busy_timeout=5000")
            await self._init_tables()
        return self._conn

    async def _init_tables(self) -> None:
        conn = await self._get_conn()
        await conn.execute("""
            CREATE TABLE IF NOT EXISTS memory_entries (
                id TEXT PRIMARY KEY,
                type TEXT NOT NULL,
                content TEXT NOT NULL,
                embedding BLOB,
                importance TEXT NOT NULL DEFAULT 'medium',
                score REAL NOT NULL DEFAULT 0.0,
                tags TEXT NOT NULL DEFAULT '[]',
                source TEXT NOT NULL DEFAULT '',
                conversation_id TEXT NOT NULL DEFAULT '',
                user_id TEXT NOT NULL DEFAULT '',
                metadata TEXT NOT NULL DEFAULT '{}',
                created_at TEXT NOT NULL,
                accessed_at TEXT,
                expires_at TEXT,
                is_deleted INTEGER NOT NULL DEFAULT 0
            )
        """)
        await conn.execute("CREATE INDEX IF NOT EXISTS idx_memory_type ON memory_entries(type)")
        await conn.execute("CREATE INDEX IF NOT EXISTS idx_memory_score ON memory_entries(score)")
        await conn.execute("CREATE INDEX IF NOT EXISTS idx_memory_conversation ON memory_entries(conversation_id)")
        await conn.execute("CREATE INDEX IF NOT EXISTS idx_memory_user ON memory_entries(user_id)")
        await conn.execute("CREATE INDEX IF NOT EXISTS idx_memory_deleted ON memory_entries(is_deleted)")
        await conn.execute("CREATE INDEX IF NOT EXISTS idx_memory_created ON memory_entries(created_at)")
        await conn.commit()

    async def store(self, entry: MemoryEntry) -> str:
        conn = await self._get_conn()
        now = datetime.now(timezone.utc).isoformat()
        await conn.execute(
            """INSERT INTO memory_entries
               (id, type, content, embedding, importance, score, tags, source,
                conversation_id, user_id, metadata, created_at, accessed_at, expires_at, is_deleted)
               VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
            (
                entry.id,
                entry.type.value if hasattr(entry.type, "value") else entry.type,
                entry.content,
                entry.embedding,
                entry.importance.value if hasattr(entry.importance, "value") else entry.importance,
                entry.score,
                json.dumps(entry.tags),
                entry.source,
                entry.conversation_id,
                entry.user_id,
                json.dumps(entry.metadata),
                entry.created_at.isoformat() if entry.created_at else now,
                entry.accessed_at.isoformat() if entry.accessed_at else None,
                entry.expires_at.isoformat() if entry.expires_at else None,
                0,
            ),
        )
        await conn.commit()
        return entry.id

    async def retrieve(self, id: str) -> MemoryEntry | None:
        conn = await self._get_conn()
        cursor = await conn.execute(
            "SELECT * FROM memory_entries WHERE id = ? AND is_deleted = 0",
            (id,),
        )
        row = await cursor.fetchone()
        if row is None:
            return None
        return self._row_to_entry(row)

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

        conn = await self._get_conn()
        conditions: list[str] = ["is_deleted = 0"]
        params: list[Any] = []

        if search_query.text:
            conditions.append("content LIKE ?")
            params.append(f"%{search_query.text}%")
        if search_query.types:
            placeholders = ",".join("?" for _ in search_query.types)
            conditions.append(f"type IN ({placeholders})")
            params.extend(t.value if hasattr(t, "value") else str(t) for t in search_query.types)
        elif type is not None:
            conditions.append("type = ?")
            params.append(type)
        if search_query.tags:
            for tag in search_query.tags:
                conditions.append("tags LIKE ?")
                params.append(f"%{tag}%")
        elif tags:
            for tag in tags:
                conditions.append("tags LIKE ?")
                params.append(f"%{tag}%")
        if search_query.min_score > 0:
            conditions.append("score >= ?")
            params.append(search_query.min_score)
        elif min_score is not None:
            conditions.append("score >= ?")
            params.append(min_score)

        where_clause = " AND ".join(conditions)

        count_cursor = await conn.execute(
            f"SELECT COUNT(*) FROM memory_entries WHERE {where_clause}",
            params,
        )
        count_row = await count_cursor.fetchone()
        total = count_row[0] if count_row else 0

        cursor = await conn.execute(
            f"SELECT * FROM memory_entries WHERE {where_clause} ORDER BY score DESC LIMIT ? OFFSET ?",
            [*params, search_query.limit, search_query.offset],
        )
        rows = await cursor.fetchall()
        entries = [self._row_to_entry(row) for row in rows]

        return MemorySearchResult(entries=entries, total=total, query=search_query)

    async def update(self, id: str | MemoryEntry, entry: MemoryEntry | None = None) -> bool:
        if isinstance(id, MemoryEntry):
            entry = id
            id = entry.id
        if entry is None:
            return False
        conn = await self._get_conn()
        await conn.execute(
            """UPDATE memory_entries SET
               type=?, content=?, embedding=?, importance=?, score=?, tags=?,
               source=?, conversation_id=?, user_id=?, metadata=?,
               accessed_at=?, expires_at=?, is_deleted=?
               WHERE id=?""",
            (
                entry.type.value if hasattr(entry.type, "value") else entry.type,
                entry.content,
                entry.embedding,
                entry.importance.value if hasattr(entry.importance, "value") else entry.importance,
                entry.score,
                json.dumps(entry.tags),
                entry.source,
                entry.conversation_id,
                entry.user_id,
                json.dumps(entry.metadata),
                entry.accessed_at.isoformat() if entry.accessed_at else None,
                entry.expires_at.isoformat() if entry.expires_at else None,
                1 if getattr(entry, "is_deleted", False) else 0,
                id,
            ),
        )
        await conn.commit()
        return True

    async def delete(self, id: str) -> bool:
        conn = await self._get_conn()
        cursor = await conn.execute(
            "UPDATE memory_entries SET is_deleted = 1 WHERE id = ? AND is_deleted = 0",
            (id,),
        )
        await conn.commit()
        return cursor.rowcount > 0

    async def clear(self, user_id: str | None = None, type: str | None = None) -> int:
        conn = await self._get_conn()
        if user_id is not None:
            cursor = await conn.execute(
                "UPDATE memory_entries SET is_deleted = 1 WHERE user_id = ? AND is_deleted = 0",
                (user_id,),
            )
        elif type is not None:
            cursor = await conn.execute(
                "UPDATE memory_entries SET is_deleted = 1 WHERE type = ? AND is_deleted = 0",
                (type,),
            )
        else:
            cursor = await conn.execute(
                "UPDATE memory_entries SET is_deleted = 1 WHERE is_deleted = 0",
            )
        await conn.commit()
        return cursor.rowcount

    async def get_stats(self) -> dict[str, Any]:
        conn = await self._get_conn()
        cursor = await conn.execute("SELECT COUNT(*) as count, AVG(score) as avg_score FROM memory_entries WHERE is_deleted = 0")
        row = await cursor.fetchone()
        count = row[0] if row else 0
        avg_score = row[1] if row and row[1] is not None else 0.0
        return {"count": count, "avg_score": avg_score}

    def _row_to_entry(self, row: aiosqlite.Row) -> MemoryEntry:
        from nexora_ai.domain.enums.memory_enums import MemoryImportance, MemoryType

        raw_type = row["type"]
        raw_importance = row["importance"]
        return MemoryEntry(
            id=row["id"],
            type=MemoryType(raw_type) if raw_type in [e.value for e in MemoryType] else MemoryType.CONVERSATION,
            content=row["content"],
            embedding=row["embedding"],
            importance=MemoryImportance(raw_importance) if raw_importance in [e.value for e in MemoryImportance] else MemoryImportance.MEDIUM,
            score=row["score"],
            tags=json.loads(row["tags"]) if isinstance(row["tags"], str) else (row["tags"] or []),
            source=row["source"],
            conversation_id=row["conversation_id"],
            user_id=row["user_id"],
            metadata=json.loads(row["metadata"]) if isinstance(row["metadata"], str) else (row["metadata"] or {}),
            created_at=datetime.fromisoformat(row["created_at"]) if row["created_at"] else None,
            accessed_at=datetime.fromisoformat(row["accessed_at"]) if row["accessed_at"] else None,
            expires_at=datetime.fromisoformat(row["expires_at"]) if row["expires_at"] else None,
        )

    async def close(self) -> None:
        if self._conn is not None:
            await self._conn.close()
            self._conn = None
