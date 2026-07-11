import uuid
import datetime
import json
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel, Field
from sqlalchemy import select, func, delete as sa_delete, or_
from sqlalchemy.ext.asyncio import AsyncSession

from src.infrastructure.database.connection import get_db_session
from src.infrastructure.database.models import MemoryEntry
from src.presentation.api.dependencies import get_current_org_id, require_role

router = APIRouter()


class MemoryEntryResponse(BaseModel):
    id: uuid.UUID
    org_id: uuid.UUID
    customer_id: Optional[uuid.UUID] = None
    memory_type: str
    category: str
    content: str
    metadata_json: Optional[str] = None
    confidence: float
    is_active: bool
    similarity_score: Optional[float] = None
    created_at: str
    updated_at: str


class CreateMemoryRequest(BaseModel):
    customer_id: Optional[uuid.UUID] = None
    memory_type: str = Field(..., pattern="^(long_term|short_term|summary)$")
    category: str = Field(..., pattern="^(preference|intent|behavior|purchase|conversation_summary)$")
    content: str = Field(..., min_length=1, max_length=10000)
    metadata_json: Optional[str] = None
    confidence: float = Field(default=0.5, ge=0.0, le=1.0)


class SearchMemoryRequest(BaseModel):
    query: str = Field(..., min_length=1, max_length=500)
    customer_id: Optional[uuid.UUID] = None
    memory_type: Optional[str] = None
    category: Optional[str] = None
    limit: int = Field(default=20, ge=1, le=100)
    use_vector: bool = Field(default=True)


def _memory_to_response(m, similarity_score: Optional[float] = None) -> MemoryEntryResponse:
    return MemoryEntryResponse(
        id=m.id,
        org_id=m.org_id,
        customer_id=m.customer_id,
        memory_type=m.memory_type,
        category=m.category,
        content=m.content,
        metadata_json=m.metadata_json,
        confidence=m.confidence,
        is_active=m.is_active,
        similarity_score=similarity_score,
        created_at=m.created_at.isoformat(),
        updated_at=m.updated_at.isoformat(),
    )


class MemoryVectorService:
    """Vector search service for memory entries using Qdrant + embeddings."""

    COLLECTION_NAME = "memory_entries"

    def __init__(self, db: AsyncSession, org_id: uuid.UUID):
        self.db = db
        self.org_id = org_id
        self._embedding_service = None
        self._vector_repo = None

    async def _get_embedding_service(self):
        if self._embedding_service is None:
            try:
                from src.presentation.api.dependencies import embedding_service_singleton
                self._embedding_service = embedding_service_singleton
            except Exception:
                self._embedding_service = None
        return self._embedding_service

    async def _get_vector_repo(self):
        if self._vector_repo is None:
            try:
                from src.presentation.api.dependencies import vector_db_singleton
                self._vector_repo = vector_db_singleton
                if self._vector_repo and hasattr(self._vector_repo, '_collection_name'):
                    pass
            except Exception:
                self._vector_repo = None
        return self._vector_repo

    async def store_memory_vector(self, memory_id: str, content: str):
        embedding_svc = await self._get_embedding_service()
        vector_repo = await self._get_vector_repo()
        if not embedding_svc or not vector_repo:
            return

        try:
            vector = await embedding_svc.generate_embedding(content)
            await vector_repo.upsert_chunks(
                org_id=str(self.org_id),
                points=[{
                    "id": str(uuid.uuid5(uuid.UUID(memory_id), "memory")),
                    "vector": vector,
                    "text": content,
                    "document_id": memory_id,
                    "metadata": {"memory_id": memory_id, "org_id": str(self.org_id)},
                }],
            )
        except Exception:
            pass

    async def search_semantic(
        self, query: str, limit: int = 20
    ) -> List[dict]:
        embedding_svc = await self._get_embedding_service()
        vector_repo = await self._get_vector_repo()
        if not embedding_svc or not vector_repo:
            return []

        try:
            query_vector = await embedding_svc.generate_embedding(query)
            results = await vector_repo.search(
                org_id=str(self.org_id),
                vector=query_vector,
                limit=limit,
            )
            return results
        except Exception:
            return []


@router.get("/entries", response_model=List[MemoryEntryResponse])
async def list_memories(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    customer_id: Optional[uuid.UUID] = Query(default=None),
    memory_type: Optional[str] = Query(default=None),
    category: Optional[str] = Query(default=None),
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
) -> List[MemoryEntryResponse]:
    stmt = select(MemoryEntry).where(MemoryEntry.org_id == org_id, MemoryEntry.is_active == True)
    if customer_id:
        stmt = stmt.where(MemoryEntry.customer_id == customer_id)
    if memory_type:
        stmt = stmt.where(MemoryEntry.memory_type == memory_type)
    if category:
        stmt = stmt.where(MemoryEntry.category == category)
    stmt = stmt.order_by(MemoryEntry.created_at.desc()).limit(limit).offset(offset)
    result = await db.execute(stmt)
    return [_memory_to_response(m) for m in result.scalars().all()]


@router.post("/entries", response_model=MemoryEntryResponse, status_code=status.HTTP_201_CREATED)
async def create_memory(
    data: CreateMemoryRequest,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin", "member")),
) -> MemoryEntryResponse:
    now = datetime.datetime.now(datetime.timezone.utc)
    memory = MemoryEntry(
        id=uuid.uuid4(),
        org_id=org_id,
        customer_id=data.customer_id,
        memory_type=data.memory_type,
        category=data.category,
        content=data.content,
        metadata_json=data.metadata_json,
        confidence=data.confidence,
        is_active=True,
        created_at=now,
        updated_at=now,
    )
    db.add(memory)
    await db.flush()

    vector_svc = MemoryVectorService(db, org_id)
    await vector_svc.store_memory_vector(str(memory.id), data.content)

    await db.commit()
    await db.refresh(memory)
    return _memory_to_response(memory)


@router.post("/search", response_model=List[MemoryEntryResponse])
async def search_memories(
    data: SearchMemoryRequest,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> List[MemoryEntryResponse]:
    if data.use_vector:
        vector_svc = MemoryVectorService(db, org_id)
        semantic_results = await vector_svc.search_semantic(data.query, limit=data.limit)

        if semantic_results:
            memory_ids = []
            score_map = {}
            for r in semantic_results:
                mid = r.get("metadata", {}).get("memory_id") or r.get("document_id")
                if mid:
                    try:
                        memory_ids.append(uuid.UUID(mid))
                        score_map[mid] = r.get("score", 0.0)
                    except (ValueError, TypeError):
                        pass

            if memory_ids:
                stmt = select(MemoryEntry).where(
                    MemoryEntry.id.in_(memory_ids),
                    MemoryEntry.org_id == org_id,
                    MemoryEntry.is_active == True,
                )
                if data.customer_id:
                    stmt = stmt.where(MemoryEntry.customer_id == data.customer_id)
                if data.memory_type:
                    stmt = stmt.where(MemoryEntry.memory_type == data.memory_type)
                if data.category:
                    stmt = stmt.where(MemoryEntry.category == data.category)
                result = await db.execute(stmt)
                memories = result.scalars().all()
                memories_sorted = sorted(
                    memories,
                    key=lambda m: score_map.get(str(m.id), 0.0),
                    reverse=True,
                )
                return [_memory_to_response(m, score_map.get(str(m.id))) for m in memories_sorted[:data.limit]]

    pattern = f"%{data.query}%"
    stmt = select(MemoryEntry).where(
        MemoryEntry.org_id == org_id,
        MemoryEntry.is_active == True,
    )
    if data.customer_id:
        stmt = stmt.where(MemoryEntry.customer_id == data.customer_id)
    if data.memory_type:
        stmt = stmt.where(MemoryEntry.memory_type == data.memory_type)
    if data.category:
        stmt = stmt.where(MemoryEntry.category == data.category)

    stmt = stmt.where(
        or_(
            MemoryEntry.content.ilike(pattern),
            MemoryEntry.category.ilike(pattern),
        )
    )
    stmt = stmt.order_by(MemoryEntry.confidence.desc()).limit(data.limit)
    result = await db.execute(stmt)
    return [_memory_to_response(m) for m in result.scalars().all()]


@router.delete("/entries/{memory_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_memory(
    memory_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin")),
) -> None:
    stmt = select(MemoryEntry).where(MemoryEntry.id == memory_id, MemoryEntry.org_id == org_id)
    result = await db.execute(stmt)
    memory = result.scalar_one_or_none()
    if not memory:
        raise HTTPException(status_code=404, detail="Memory entry not found.")
    memory.is_active = False
    await db.commit()
