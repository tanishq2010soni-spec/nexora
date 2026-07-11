from datetime import datetime
from typing import Optional
from uuid import UUID, uuid4

from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from ..api.auth import get_current_user, require_permission
from ..domain.entities import KnowledgeDocument, User
from ..domain.enums import KnowledgeType
from ..infrastructure.database import KnowledgeDocumentModel, get_session

router = APIRouter(prefix="/api/v1/knowledge", tags=["knowledge"])


@router.get("/")
async def list_knowledge_documents(
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
    page: int = Query(1, ge=1),
    limit: int = Query(50, ge=1, le=100),
    doc_type: Optional[str] = Query(None, alias="type"),
    tags: Optional[str] = Query(None),
    search: Optional[str] = Query(None),
):
    org_id = str(current_user.organization_id)
    query = select(KnowledgeDocumentModel).where(KnowledgeDocumentModel.organization_id == org_id)
    if doc_type:
        query = query.where(KnowledgeDocumentModel.type == doc_type)
    if tags:
        tag_list = [t.strip() for t in tags.split(",")]
        query = query.where(KnowledgeDocumentModel.tags.contains(tag_list))
    if search:
        query = query.where(
            KnowledgeDocumentModel.title.ilike(f"%{search}%") |
            KnowledgeDocumentModel.content.ilike(f"%{search}%")
        )
    query = query.order_by(KnowledgeDocumentModel.updated_at.desc())
    total_result = await session.execute(select(func.count()).select_from(query.subquery()))
    total = total_result.scalar()
    offset = (page - 1) * limit
    result = await session.execute(query.offset(offset).limit(limit))
    models = result.scalars().all()
    return {
        "items": [KnowledgeDocument.model_validate(m) for m in models],
        "total": total,
        "page": page,
        "limit": limit,
    }


@router.post("/", status_code=201)
async def upload_knowledge_document(
    title: str,
    file: UploadFile,
    tags: Optional[str] = None,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_knowledge")),
):
    org_id = str(current_user.organization_id)
    content = await file.read()
    content_str = content.decode("utf-8", errors="replace")
    import os
    file_ext = os.path.splitext(file.filename or "")[1].lower() if file.filename else ""
    type_map = {
        ".pdf": KnowledgeType.pdf.value,
        ".docx": KnowledgeType.docx.value,
        ".xlsx": KnowledgeType.excel.value,
        ".csv": KnowledgeType.csv.value,
        ".md": KnowledgeType.markdown.value,
        ".txt": KnowledgeType.text.value,
    }
    doc_type = type_map.get(file_ext, KnowledgeType.text.value)
    tag_list = [t.strip() for t in tags.split(",")] if tags else []
    model = KnowledgeDocumentModel(
        id=str(uuid4()),
        organization_id=org_id,
        title=title,
        type=doc_type,
        content=content_str,
        file_path=file.filename,
        file_size=len(content),
        mime_type=file.content_type,
        tags=tag_list,
        created_by=str(current_user.id),
    )
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return KnowledgeDocument.model_validate(model)


@router.get("/{doc_id}")
async def get_knowledge_document(
    doc_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(KnowledgeDocumentModel).where(
            KnowledgeDocumentModel.id == str(doc_id),
            KnowledgeDocumentModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Knowledge document not found")
    return KnowledgeDocument.model_validate(model)


@router.delete("/{doc_id}")
async def delete_knowledge_document(
    doc_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_knowledge")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(KnowledgeDocumentModel).where(
            KnowledgeDocumentModel.id == str(doc_id),
            KnowledgeDocumentModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Knowledge document not found")
    await session.delete(model)
    await session.flush()
    return {"detail": "Knowledge document deleted"}


@router.post("/{doc_id}/index")
async def reindex_knowledge_document(
    doc_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_knowledge")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(KnowledgeDocumentModel).where(
            KnowledgeDocumentModel.id == str(doc_id),
            KnowledgeDocumentModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Knowledge document not found")
    import math
    content = model.content or ""
    estimated_chunks = max(1, math.ceil(len(content) / 1000)) if content else 0
    model.is_indexed = True
    model.chunk_count = estimated_chunks
    model.updated_at = datetime.utcnow()
    session.add(model)
    await session.flush()
    return {"is_indexed": True, "chunk_count": model.chunk_count}


@router.post("/query")
async def query_knowledge_base(
    text: str,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(KnowledgeDocumentModel).where(
            KnowledgeDocumentModel.organization_id == org_id,
            KnowledgeDocumentModel.is_indexed == True,
        )
    )
    docs = result.scalars().all()
    chunks = []
    for doc in docs:
        content = doc.content or ""
        words = content.split()
        chunk_size = 200
        for i in range(0, len(words), chunk_size):
            chunk_text = " ".join(words[i:i + chunk_size])
            chunks.append({
                "document_id": doc.id,
                "document_title": doc.title,
                "chunk": chunk_text,
                "score": 0.0,
            })
    query_terms = text.lower().split()
    scored_chunks = []
    for chunk in chunks:
        chunk_lower = chunk["chunk"].lower()
        score = sum(1 for term in query_terms if term in chunk_lower)
        if score > 0:
            chunk["score"] = score / len(query_terms) if query_terms else 0
            scored_chunks.append(chunk)
    scored_chunks.sort(key=lambda c: c["score"], reverse=True)
    return {
        "query": text,
        "results": scored_chunks[:10],
        "total_chunks_found": len(scored_chunks),
    }


@router.post("/faq", status_code=201)
async def add_faq_entry(
    title: str,
    content: str,
    tags: Optional[str] = None,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_knowledge")),
):
    org_id = str(current_user.organization_id)
    tag_list = [t.strip() for t in tags.split(",")] if tags else []
    model = KnowledgeDocumentModel(
        id=str(uuid4()),
        organization_id=org_id,
        title=title,
        type=KnowledgeType.faq.value,
        content=content,
        tags=tag_list,
        is_indexed=True,
        created_by=str(current_user.id),
    )
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return KnowledgeDocument.model_validate(model)
