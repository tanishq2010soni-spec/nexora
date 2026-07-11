from __future__ import annotations

from datetime import datetime, timezone
from typing import Any, Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile, File, status
from pydantic import BaseModel
from sqlalchemy import select, func, desc
from sqlalchemy.ext.asyncio import AsyncSession

from ..api.auth import get_current_user, require_permission
from ..domain.entities import KnowledgeDocument
from ..infrastructure.database import KnowledgeDocumentModel, get_session

router = APIRouter(prefix="/api/v1/knowledge", tags=["knowledge"])


class KnowledgeListResponse(BaseModel):
    items: list[KnowledgeDocument]
    total: int
    page: int
    limit: int
    pages: int


class QueryKnowledgeRequest(BaseModel):
    query: str
    top_k: int = 5
    filters: dict[str, Any] = {}


class QueryKnowledgeResponse(BaseModel):
    results: list[dict[str, Any]]
    query: str


@router.get("", response_model=KnowledgeListResponse)
async def list_knowledge(
    type: Optional[str] = Query(None),
    search: Optional[str] = Query(None),
    is_indexed: Optional[bool] = Query(None),
    page: int = Query(1, ge=1),
    limit: int = Query(50, ge=1, le=200),
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("view_knowledge")),
):
    query = select(KnowledgeDocumentModel).where(KnowledgeDocumentModel.organization_id == str(current_user.organization_id))

    if type:
        query = query.where(KnowledgeDocumentModel.type == type)
    if is_indexed is not None:
        query = query.where(KnowledgeDocumentModel.is_indexed == is_indexed)
    if search:
        search_filter = f"%{search}%"
        query = query.where(
            KnowledgeDocumentModel.title.ilike(search_filter)
            | KnowledgeDocumentModel.content.ilike(search_filter)
        )

    count_query = select(func.count()).select_from(query.subquery())
    total = (await session.execute(count_query)).scalar() or 0
    pages = max(1, (total + limit - 1) // limit)
    offset = (page - 1) * limit

    query = query.order_by(desc(KnowledgeDocumentModel.created_at)).offset(offset).limit(limit)
    result = await session.execute(query)
    models = result.scalars().all()

    return KnowledgeListResponse(
        items=[KnowledgeDocument.model_validate(m) for m in models],
        total=total, page=page, limit=limit, pages=pages,
    )


@router.post("", response_model=KnowledgeDocument)
async def upload_knowledge(
    file: UploadFile = File(...),
    title: Optional[str] = Query(None),
    type: str = Query("document"),
    tags: str = Query(""),
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_knowledge")),
):
    import os
    import shutil

    from ..config import settings

    content = await file.read()
    doc_title = title or file.filename or "Untitled"
    tag_list = [t.strip() for t in tags.split(",") if t.strip()]

    doc_dir = settings.resolved_knowledge_dir / str(current_user.organization_id)
    doc_dir.mkdir(parents=True, exist_ok=True)

    file_path = doc_dir / f"{datetime.now(timezone.utc).strftime('%Y%m%d_%H%M%S')}_{file.filename}"
    file_path.write_bytes(content)

    model = KnowledgeDocumentModel(
        organization_id=str(current_user.organization_id),
        title=doc_title,
        type=type,
        file_path=str(file_path),
        file_size=len(content),
        mime_type=file.content_type or "application/octet-stream",
        tags=tag_list,
        created_by=str(current_user.id),
    )
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return KnowledgeDocument.model_validate(model)


@router.get("/{document_id}", response_model=KnowledgeDocument)
async def get_knowledge(
    document_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(get_current_user),
):
    result = await session.execute(
        select(KnowledgeDocumentModel).where(KnowledgeDocumentModel.id == str(document_id))
        .where(KnowledgeDocumentModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Document not found")
    return KnowledgeDocument.model_validate(model)


@router.delete("/{document_id}")
async def delete_knowledge(
    document_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_knowledge")),
):
    result = await session.execute(
        select(KnowledgeDocumentModel).where(KnowledgeDocumentModel.id == str(document_id))
        .where(KnowledgeDocumentModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Document not found")

    await session.delete(model)
    return {"deleted": True}


@router.post("/{document_id}/index", response_model=KnowledgeDocument)
async def index_knowledge(
    document_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_knowledge")),
):
    result = await session.execute(
        select(KnowledgeDocumentModel).where(KnowledgeDocumentModel.id == str(document_id))
        .where(KnowledgeDocumentModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Document not found")

    model.is_indexed = True
    model.chunk_count = max(1, len(model.content or "") // 500)
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return KnowledgeDocument.model_validate(model)


@router.post("/query", response_model=QueryKnowledgeResponse)
async def query_knowledge(
    req: QueryKnowledgeRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("view_knowledge")),
):
    result = await session.execute(
        select(KnowledgeDocumentModel)
        .where(KnowledgeDocumentModel.organization_id == str(current_user.organization_id))
        .where(KnowledgeDocumentModel.is_indexed == True)
    )
    models = result.scalars().all()

    query_lower = req.query.lower()
    scored = []
    for m in models:
        score = 0
        content_lower = (m.content or "").lower()
        title_lower = (m.title or "").lower()

        if query_lower in title_lower:
            score += 10
        score += content_lower.count(query_lower)

        if score > 0:
            scored.append({"id": m.id, "title": m.title, "type": m.type, "content": m.content, "score": score, "chunk_count": m.chunk_count})

    scored.sort(key=lambda x: x["score"], reverse=True)
    results = scored[:req.top_k]

    return QueryKnowledgeResponse(results=results, query=req.query)
