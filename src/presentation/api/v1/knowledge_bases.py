import uuid
import datetime
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel, Field
from sqlalchemy import select, func, delete as sa_delete
from sqlalchemy.ext.asyncio import AsyncSession

from src.infrastructure.database.connection import get_db_session
from src.infrastructure.database.models import KnowledgeBase, Document
from src.presentation.api.dependencies import get_current_org_id, require_role
from src.application.services.audit_service import AuditService

router = APIRouter()


class KnowledgeBaseResponse(BaseModel):
    id: uuid.UUID
    org_id: uuid.UUID
    name: str
    description: Optional[str] = None
    document_count: int = 0
    total_chunks: int = 0
    created_at: str
    updated_at: str


class KnowledgeBaseCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None


class KnowledgeBaseUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    description: Optional[str] = None


@router.get("/", response_model=List[KnowledgeBaseResponse])
async def list_knowledge_bases(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
) -> List[KnowledgeBaseResponse]:
    """List all knowledge bases for the organization."""
    stmt = (
        select(KnowledgeBase)
        .where(KnowledgeBase.org_id == org_id)
        .order_by(KnowledgeBase.created_at.desc())
        .limit(limit)
        .offset(offset)
    )
    result = await db.execute(stmt)
    kbs = result.scalars().all()

    responses = []
    for kb in kbs:
        # Count documents for each KB
        doc_stmt = select(func.count()).select_from(Document).where(Document.kb_id == kb.id)
        doc_result = await db.execute(doc_stmt)
        doc_count = doc_result.scalar_one() or 0

        # Sum chunks
        chunk_stmt = select(func.coalesce(func.sum(Document.chunk_count), 0)).where(Document.kb_id == kb.id)
        chunk_result = await db.execute(chunk_stmt)
        total_chunks = chunk_result.scalar() or 0

        responses.append(KnowledgeBaseResponse(
            id=kb.id,
            org_id=kb.org_id,
            name=kb.name,
            description=kb.description,
            document_count=doc_count,
            total_chunks=total_chunks,
            created_at=kb.created_at.isoformat(),
            updated_at=kb.created_at.isoformat(),
        ))
    return responses


@router.post("/", response_model=KnowledgeBaseResponse, status_code=status.HTTP_201_CREATED)
async def create_knowledge_base(
    data: KnowledgeBaseCreate,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin", "member")),
) -> KnowledgeBaseResponse:
    """Create a new knowledge base."""
    kb = KnowledgeBase(
        id=uuid.uuid4(),
        org_id=org_id,
        name=data.name,
        description=data.description,
        created_at=datetime.datetime.now(datetime.timezone.utc),
    )
    db.add(kb)
    await db.commit()
    await db.refresh(kb)

    await AuditService.log(
        db=db,
        action="create",
        resource="knowledge_base",
        org_id=org_id,
        resource_id=str(kb.id),
        detail=f"Created knowledge base: {kb.name}",
    )
    await db.commit()

    return KnowledgeBaseResponse(
        id=kb.id,
        org_id=kb.org_id,
        name=kb.name,
        description=kb.description,
        document_count=0,
        total_chunks=0,
        created_at=kb.created_at.isoformat(),
        updated_at=kb.created_at.isoformat(),
    )


@router.get("/{kb_id}", response_model=KnowledgeBaseResponse)
async def get_knowledge_base(
    kb_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> KnowledgeBaseResponse:
    """Get a knowledge base by ID."""
    stmt = select(KnowledgeBase).where(KnowledgeBase.id == kb_id, KnowledgeBase.org_id == org_id)
    result = await db.execute(stmt)
    kb = result.scalar_one_or_none()
    if not kb:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Knowledge base not found.")

    doc_stmt = select(func.count()).select_from(Document).where(Document.kb_id == kb.id)
    doc_result = await db.execute(doc_stmt)
    doc_count = doc_result.scalar_one() or 0

    chunk_stmt = select(func.coalesce(func.sum(Document.chunk_count), 0)).where(Document.kb_id == kb.id)
    chunk_result = await db.execute(chunk_stmt)
    total_chunks = chunk_result.scalar() or 0

    return KnowledgeBaseResponse(
        id=kb.id,
        org_id=kb.org_id,
        name=kb.name,
        description=kb.description,
        document_count=doc_count,
        total_chunks=total_chunks,
        created_at=kb.created_at.isoformat(),
        updated_at=kb.created_at.isoformat(),
    )


@router.put("/{kb_id}", response_model=KnowledgeBaseResponse)
async def update_knowledge_base(
    kb_id: uuid.UUID,
    data: KnowledgeBaseUpdate,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin", "member")),
) -> KnowledgeBaseResponse:
    """Update a knowledge base."""
    stmt = select(KnowledgeBase).where(KnowledgeBase.id == kb_id, KnowledgeBase.org_id == org_id)
    result = await db.execute(stmt)
    kb = result.scalar_one_or_none()
    if not kb:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Knowledge base not found.")

    if data.name is not None:
        kb.name = data.name
    if data.description is not None:
        kb.description = data.description

    await db.commit()
    await db.refresh(kb)

    await AuditService.log(
        db=db,
        action="update",
        resource="knowledge_base",
        org_id=org_id,
        resource_id=str(kb.id),
        detail=f"Updated knowledge base: {kb.name}",
    )
    await db.commit()

    doc_stmt = select(func.count()).select_from(Document).where(Document.kb_id == kb.id)
    doc_result = await db.execute(doc_stmt)
    doc_count = doc_result.scalar_one() or 0

    chunk_stmt = select(func.coalesce(func.sum(Document.chunk_count), 0)).where(Document.kb_id == kb.id)
    chunk_result = await db.execute(chunk_stmt)
    total_chunks = chunk_result.scalar() or 0

    return KnowledgeBaseResponse(
        id=kb.id,
        org_id=kb.org_id,
        name=kb.name,
        description=kb.description,
        document_count=doc_count,
        total_chunks=total_chunks,
        created_at=kb.created_at.isoformat(),
        updated_at=kb.created_at.isoformat(),
    )


@router.delete("/{kb_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_knowledge_base(
    kb_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin")),
) -> None:
    """Delete a knowledge base and all its documents."""
    stmt = select(KnowledgeBase).where(KnowledgeBase.id == kb_id, KnowledgeBase.org_id == org_id)
    result = await db.execute(stmt)
    kb = result.scalar_one_or_none()
    if not kb:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Knowledge base not found.")

    # Delete associated documents first
    doc_del = sa_delete(Document).where(Document.kb_id == kb_id)
    await db.execute(doc_del)

    # Delete the KB
    kb_del = sa_delete(KnowledgeBase).where(KnowledgeBase.id == kb_id)
    await db.execute(kb_del)
    await db.commit()

    await AuditService.log(
        db=db,
        action="delete",
        resource="knowledge_base",
        org_id=org_id,
        resource_id=str(kb_id),
        detail=f"Deleted knowledge base: {kb.name}",
    )
    await db.commit()
