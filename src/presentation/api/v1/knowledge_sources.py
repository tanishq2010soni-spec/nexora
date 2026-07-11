import uuid
import datetime
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel, Field
from sqlalchemy import select, func, delete as sa_delete
from sqlalchemy.ext.asyncio import AsyncSession

from src.infrastructure.database.connection import get_db_session
from src.infrastructure.database.models import KnowledgeSource, KnowledgeBase
from src.presentation.api.dependencies import get_current_org_id, require_role
from src.application.services.audit_service import AuditService

router = APIRouter()


# ─── Schemas ───────────────────────────────────────────────────────────────

class KnowledgeSourceResponse(BaseModel):
    id: uuid.UUID
    kb_id: uuid.UUID
    source_type: str
    name: str
    description: Optional[str] = None
    config_json: Optional[str] = None
    status: str
    last_indexed_at: Optional[str] = None
    error_message: Optional[str] = None
    created_at: str
    updated_at: str


class KnowledgeSourceCreate(BaseModel):
    kb_id: uuid.UUID
    source_type: str = Field(..., pattern="^(web_page|file_upload|api_endpoint|database|s3_bucket|custom)$")
    name: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    config_json: Optional[str] = None


class KnowledgeSourceUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    description: Optional[str] = None
    config_json: Optional[str] = None
    status: Optional[str] = Field(None, pattern="^(active|inactive|error)$")


class KnowledgeSourceTypeResponse(BaseModel):
    source_type: str
    label: str
    description: str


# ─── Helpers ───────────────────────────────────────────────────────────────

async def _get_source_or_404(db: AsyncSession, source_id: uuid.UUID, org_id: uuid.UUID) -> KnowledgeSource:
    stmt = (
        select(KnowledgeSource)
        .join(KnowledgeBase, KnowledgeBase.id == KnowledgeSource.kb_id)
        .where(KnowledgeSource.id == source_id, KnowledgeBase.org_id == org_id)
    )
    result = await db.execute(stmt)
    source = result.scalar_one_or_none()
    if not source:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Knowledge source not found.")
    return source


async def _get_kb_or_404(db: AsyncSession, kb_id: uuid.UUID, org_id: uuid.UUID) -> KnowledgeBase:
    stmt = select(KnowledgeBase).where(KnowledgeBase.id == kb_id, KnowledgeBase.org_id == org_id)
    result = await db.execute(stmt)
    kb = result.scalar_one_or_none()
    if not kb:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Knowledge base not found.")
    return kb


def _source_to_response(s: KnowledgeSource) -> KnowledgeSourceResponse:
    return KnowledgeSourceResponse(
        id=s.id, kb_id=s.kb_id, source_type=s.source_type,
        name=s.name, description=s.description, config_json=s.config_json,
        status=s.status,
        last_indexed_at=s.last_indexed_at.isoformat() if s.last_indexed_at else None,
        error_message=s.error_message,
        created_at=s.created_at.isoformat(),
        updated_at=s.updated_at.isoformat(),
    )


SUPPORTED_SOURCE_TYPES = [
    KnowledgeSourceTypeResponse(source_type="web_page", label="Web Page", description="Scrape and index content from a public URL."),
    KnowledgeSourceTypeResponse(source_type="file_upload", label="File Upload", description="Upload documents (PDF, DOCX, TXT) directly."),
    KnowledgeSourceTypeResponse(source_type="api_endpoint", label="API Endpoint", description="Fetch data from a REST API endpoint."),
    KnowledgeSourceTypeResponse(source_type="database", label="Database", description="Connect to an external database and ingest tables."),
    KnowledgeSourceTypeResponse(source_type="s3_bucket", label="S3 Bucket", description="Sync files from an Amazon S3-compatible bucket."),
    KnowledgeSourceTypeResponse(source_type="custom", label="Custom", description="Define a custom source with your own ingestion logic."),
]


# ─── Endpoints ─────────────────────────────────────────────────────────────

@router.get("/", response_model=List[KnowledgeSourceResponse])
async def list_knowledge_sources(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    kb_id: Optional[uuid.UUID] = Query(default=None),
    source_type: Optional[str] = Query(default=None),
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
) -> List[KnowledgeSourceResponse]:
    stmt = (
        select(KnowledgeSource)
        .join(KnowledgeBase, KnowledgeBase.id == KnowledgeSource.kb_id)
        .where(KnowledgeBase.org_id == org_id)
    )
    if kb_id:
        stmt = stmt.where(KnowledgeSource.kb_id == kb_id)
    if source_type:
        stmt = stmt.where(KnowledgeSource.source_type == source_type)

    stmt = stmt.order_by(KnowledgeSource.created_at.desc()).limit(limit).offset(offset)
    result = await db.execute(stmt)
    return [_source_to_response(s) for s in result.scalars().all()]


@router.post("/", response_model=KnowledgeSourceResponse, status_code=status.HTTP_201_CREATED)
async def create_knowledge_source(
    data: KnowledgeSourceCreate,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin", "member")),
) -> KnowledgeSourceResponse:
    await _get_kb_or_404(db, data.kb_id, org_id)

    now = datetime.datetime.now(datetime.timezone.utc)
    source = KnowledgeSource(
        id=uuid.uuid4(),
        kb_id=data.kb_id,
        source_type=data.source_type,
        name=data.name,
        description=data.description,
        config_json=data.config_json,
        status="active",
        created_at=now,
        updated_at=now,
    )
    db.add(source)
    await db.commit()
    await db.refresh(source)

    await AuditService.log(
        db=db, action="create", resource="knowledge_source",
        org_id=org_id, resource_id=str(source.id),
        detail=f"Created {data.source_type} source: {source.name}",
    )
    await db.commit()

    return _source_to_response(source)


@router.get("/{source_id}", response_model=KnowledgeSourceResponse)
async def get_knowledge_source(
    source_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> KnowledgeSourceResponse:
    source = await _get_source_or_404(db, source_id, org_id)
    return _source_to_response(source)


@router.put("/{source_id}", response_model=KnowledgeSourceResponse)
async def update_knowledge_source(
    source_id: uuid.UUID,
    data: KnowledgeSourceUpdate,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin", "member")),
) -> KnowledgeSourceResponse:
    source = await _get_source_or_404(db, source_id, org_id)

    if data.name is not None:
        source.name = data.name
    if data.description is not None:
        source.description = data.description
    if data.config_json is not None:
        source.config_json = data.config_json
    if data.status is not None:
        source.status = data.status
    source.updated_at = datetime.datetime.now(datetime.timezone.utc)

    await db.commit()
    await db.refresh(source)

    await AuditService.log(
        db=db, action="update", resource="knowledge_source",
        org_id=org_id, resource_id=str(source.id),
        detail=f"Updated source: {source.name}",
    )
    await db.commit()

    return _source_to_response(source)


@router.delete("/{source_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_knowledge_source(
    source_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin")),
) -> None:
    source = await _get_source_or_404(db, source_id, org_id)

    await db.execute(sa_delete(KnowledgeSource).where(KnowledgeSource.id == source_id))
    await db.commit()

    await AuditService.log(
        db=db, action="delete", resource="knowledge_source",
        org_id=org_id, resource_id=str(source_id),
        detail=f"Deleted source: {source.name}",
    )
    await db.commit()


@router.post("/{source_id}/reindex", response_model=KnowledgeSourceResponse)
async def reindex_knowledge_source(
    source_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin", "member")),
) -> KnowledgeSourceResponse:
    source = await _get_source_or_404(db, source_id, org_id)

    now = datetime.datetime.now(datetime.timezone.utc)
    source.status = "indexing"
    source.last_indexed_at = now
    source.updated_at = now

    await db.commit()
    await db.refresh(source)

    await AuditService.log(
        db=db, action="reindex", resource="knowledge_source",
        org_id=org_id, resource_id=str(source.id),
        detail=f"Reindex triggered for source: {source.name}",
    )
    await db.commit()

    return _source_to_response(source)


@router.get("/types", response_model=List[KnowledgeSourceTypeResponse])
async def list_source_types() -> List[KnowledgeSourceTypeResponse]:
    return SUPPORTED_SOURCE_TYPES
