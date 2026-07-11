import uuid
import datetime
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel, Field
from sqlalchemy import select, func, delete as sa_delete
from sqlalchemy.ext.asyncio import AsyncSession

from src.infrastructure.database.connection import get_db_session
from src.infrastructure.database.models import Provider, ModelRegistry
from src.presentation.api.dependencies import get_current_org_id, require_role
from src.application.services.audit_service import AuditService
from src.infrastructure.security.provider_encryption import encrypt_api_key, decrypt_api_key

router = APIRouter()


# ─── Schemas ───────────────────────────────────────────────────────────────

class ProviderResponse(BaseModel):
    id: uuid.UUID
    org_id: uuid.UUID
    name: str
    provider_type: str
    api_endpoint: Optional[str] = None
    config_json: Optional[str] = None
    is_active: bool
    created_at: str
    updated_at: str


class ProviderCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=255)
    provider_type: str = Field(..., pattern="^(openai|anthropic|google|azure|ollama|aws_bedrock|custom)$")
    api_endpoint: Optional[str] = None
    api_key: Optional[str] = None
    config_json: Optional[str] = None
    is_active: bool = Field(default=True)


class ProviderUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    api_endpoint: Optional[str] = None
    api_key: Optional[str] = None
    config_json: Optional[str] = None
    is_active: Optional[bool] = None


class ProviderModelResponse(BaseModel):
    id: uuid.UUID
    provider_id: uuid.UUID
    model_id: str
    name: str
    description: Optional[str] = None
    is_available: bool
    created_at: str


class ProviderHealthCheckResponse(BaseModel):
    provider_id: uuid.UUID
    status: str
    latency_ms: Optional[int] = None
    message: Optional[str] = None
    checked_at: str


# ─── Helpers ───────────────────────────────────────────────────────────────

async def _get_provider_or_404(db: AsyncSession, provider_id: uuid.UUID, org_id: uuid.UUID) -> Provider:
    stmt = select(Provider).where(Provider.id == provider_id, Provider.org_id == org_id)
    result = await db.execute(stmt)
    provider = result.scalar_one_or_none()
    if not provider:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Provider not found.")
    return provider


def _provider_to_response(p: Provider) -> ProviderResponse:
    return ProviderResponse(
        id=p.id, org_id=p.org_id, name=p.name,
        provider_type=p.provider_type, api_endpoint=p.endpoint_url,
        config_json=p.capabilities_json, is_active=p.is_active,
        created_at=p.created_at.isoformat(),
        updated_at=p.updated_at.isoformat(),
    )


# ─── Endpoints ─────────────────────────────────────────────────────────────

@router.get("/", response_model=List[ProviderResponse])
async def list_providers(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    provider_type: Optional[str] = Query(default=None),
    is_active: Optional[bool] = Query(default=None),
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
) -> List[ProviderResponse]:
    stmt = select(Provider).where(Provider.org_id == org_id)
    if provider_type:
        stmt = stmt.where(Provider.provider_type == provider_type)
    if is_active is not None:
        stmt = stmt.where(Provider.is_active == is_active)
    stmt = stmt.order_by(Provider.created_at.desc()).limit(limit).offset(offset)
    result = await db.execute(stmt)
    return [_provider_to_response(p) for p in result.scalars().all()]


@router.post("/", response_model=ProviderResponse, status_code=status.HTTP_201_CREATED)
async def create_provider(
    data: ProviderCreate,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin")),
) -> ProviderResponse:
    now = datetime.datetime.now(datetime.timezone.utc)
    provider = Provider(
        id=uuid.uuid4(),
        org_id=org_id,
        name=data.name,
        provider_type=data.provider_type,
        endpoint_url=data.api_endpoint,
        api_key_encrypted=encrypt_api_key(data.api_key) if data.api_key else None,
        capabilities_json=data.config_json,
        is_active=data.is_active,
        created_at=now,
        updated_at=now,
    )
    db.add(provider)
    await db.commit()
    await db.refresh(provider)

    await AuditService.log(
        db=db, action="create", resource="provider",
        org_id=org_id, resource_id=str(provider.id),
        detail=f"Created {data.provider_type} provider: {provider.name}",
    )
    await db.commit()

    return _provider_to_response(provider)


@router.get("/{provider_id}", response_model=ProviderResponse)
async def get_provider(
    provider_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> ProviderResponse:
    provider = await _get_provider_or_404(db, provider_id, org_id)
    return _provider_to_response(provider)


@router.put("/{provider_id}", response_model=ProviderResponse)
async def update_provider(
    provider_id: uuid.UUID,
    data: ProviderUpdate,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin")),
) -> ProviderResponse:
    provider = await _get_provider_or_404(db, provider_id, org_id)

    if data.name is not None:
        provider.name = data.name
    if data.api_endpoint is not None:
        provider.endpoint_url = data.api_endpoint
    if data.api_key is not None:
        provider.api_key_encrypted = encrypt_api_key(data.api_key)
    if data.config_json is not None:
        provider.capabilities_json = data.config_json
    if data.is_active is not None:
        provider.is_active = data.is_active
    provider.updated_at = datetime.datetime.now(datetime.timezone.utc)

    await db.commit()
    await db.refresh(provider)

    await AuditService.log(
        db=db, action="update", resource="provider",
        org_id=org_id, resource_id=str(provider.id),
        detail=f"Updated provider: {provider.name}",
    )
    await db.commit()

    return _provider_to_response(provider)


@router.delete("/{provider_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_provider(
    provider_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin")),
) -> None:
    provider = await _get_provider_or_404(db, provider_id, org_id)

    await db.execute(sa_delete(ModelRegistry).where(ModelRegistry.provider_id == provider_id))
    await db.execute(sa_delete(Provider).where(Provider.id == provider_id))
    await db.commit()

    await AuditService.log(
        db=db, action="delete", resource="provider",
        org_id=org_id, resource_id=str(provider_id),
        detail=f"Deleted provider: {provider.name}",
    )
    await db.commit()


@router.post("/{provider_id}/health-check", response_model=ProviderHealthCheckResponse)
async def health_check_provider(
    provider_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin")),
) -> ProviderHealthCheckResponse:
    provider = await _get_provider_or_404(db, provider_id, org_id)

    now = datetime.datetime.now(datetime.timezone.utc)
    import time as time_module
    start = time_module.time()

    try:
        import httpx
        endpoint = provider.endpoint_url or f"https://api.{provider.provider_type}.com"
        async with httpx.AsyncClient(timeout=10.0) as client:
            resp = await client.get(f"{endpoint}/health", headers={"Authorization": "Bearer test"})
            latency = int((time_module.time() - start) * 1000)
            status_val = "healthy" if resp.is_success else "degraded"
            msg = f"Responded with status {resp.status_code}"
    except Exception as e:
        latency = int((time_module.time() - start) * 1000)
        status_val = "unreachable"
        msg = str(e)

    await AuditService.log(
        db=db, action="health_check", resource="provider",
        org_id=org_id, resource_id=str(provider_id),
        detail=f"Health check for provider '{provider.name}': {status_val} ({latency}ms)",
    )
    await db.commit()

    return ProviderHealthCheckResponse(
        provider_id=provider_id,
        status=status_val,
        latency_ms=latency,
        message=msg,
        checked_at=now.isoformat(),
    )


@router.get("/{provider_id}/models", response_model=List[ProviderModelResponse])
async def list_provider_models(
    provider_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
) -> List[ProviderModelResponse]:
    await _get_provider_or_404(db, provider_id, org_id)
    stmt = (
        select(ModelRegistry)
        .where(ModelRegistry.provider_id == provider_id)
        .order_by(ModelRegistry.model_id.asc())
        .limit(limit)
        .offset(offset)
    )
    result = await db.execute(stmt)
    return [
        ProviderModelResponse(
            id=m.id, provider_id=m.provider_id, model_id=m.model_id,
            name=m.display_name or m.model_id, description=m.version,
            is_available=True,
            created_at=m.created_at.isoformat(),
        )
        for m in result.scalars().all()
    ]
