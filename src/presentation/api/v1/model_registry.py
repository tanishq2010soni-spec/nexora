import uuid
import datetime
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel, Field
from sqlalchemy import select, func, delete as sa_delete
from sqlalchemy.ext.asyncio import AsyncSession

from src.infrastructure.database.connection import get_db_session
from src.infrastructure.database.models import ModelRegistry, Provider
from src.presentation.api.dependencies import get_current_org_id, require_role
from src.application.services.audit_service import AuditService

router = APIRouter()


# ─── Schemas ───────────────────────────────────────────────────────────────

class ModelRegistryResponse(BaseModel):
    id: uuid.UUID
    org_id: uuid.UUID
    model_id: str
    name: str
    provider_id: uuid.UUID
    model_type: str
    version: Optional[str] = None
    description: Optional[str] = None
    config_json: Optional[str] = None
    is_favorite: bool
    is_installed: bool
    is_downloaded: bool
    metadata_json: Optional[str] = None
    created_at: str
    updated_at: str


class ModelRegistryCreate(BaseModel):
    model_id: str = Field(..., min_length=1, max_length=255)
    name: str = Field(..., min_length=1, max_length=255)
    provider_id: uuid.UUID
    model_type: str = Field(..., pattern="^(installed|remote|downloaded)$")
    version: Optional[str] = None
    description: Optional[str] = None
    config_json: Optional[str] = None
    is_installed: bool = Field(default=False)
    is_downloaded: bool = Field(default=False)
    metadata_json: Optional[str] = None


class ModelRegistryUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    version: Optional[str] = None
    description: Optional[str] = None
    config_json: Optional[str] = None
    is_installed: Optional[bool] = None
    is_downloaded: Optional[bool] = None
    metadata_json: Optional[str] = None


class ModelFavoriteResponse(BaseModel):
    id: uuid.UUID
    is_favorite: bool


class ModelSyncRequest(BaseModel):
    provider_id: uuid.UUID


class ModelSyncResponse(BaseModel):
    synced_count: int
    message: str


# ─── Helpers ───────────────────────────────────────────────────────────────

async def _get_model_or_404(db: AsyncSession, model_id: uuid.UUID, org_id: uuid.UUID) -> ModelRegistry:
    stmt = select(ModelRegistry).where(ModelRegistry.id == model_id, ModelRegistry.org_id == org_id)
    result = await db.execute(stmt)
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Model not found.")
    return model


def _model_to_response(m: ModelRegistry) -> ModelRegistryResponse:
    return ModelRegistryResponse(
        id=m.id, org_id=m.org_id, model_id=m.model_id,
        name=m.name, provider_id=m.provider_id, model_type=m.model_type,
        version=m.version, description=m.description,
        config_json=m.config_json, is_favorite=m.is_favorite,
        is_installed=m.is_installed, is_downloaded=m.is_downloaded,
        metadata_json=m.metadata_json,
        created_at=m.created_at.isoformat(),
        updated_at=m.updated_at.isoformat(),
    )


# ─── Endpoints ─────────────────────────────────────────────────────────────

@router.get("/", response_model=List[ModelRegistryResponse])
async def list_models(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    model_type: Optional[str] = Query(default=None, pattern="^(installed|remote|favorite|downloaded)$"),
    provider_id: Optional[uuid.UUID] = Query(default=None),
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
) -> List[ModelRegistryResponse]:
    stmt = select(ModelRegistry).where(ModelRegistry.org_id == org_id)

    if model_type == "favorite":
        stmt = stmt.where(ModelRegistry.is_favorite == True)
    elif model_type == "installed":
        stmt = stmt.where(ModelRegistry.is_installed == True)
    elif model_type == "downloaded":
        stmt = stmt.where(ModelRegistry.is_downloaded == True)
    elif model_type == "remote":
        stmt = stmt.where(ModelRegistry.model_type == "remote")

    if provider_id:
        stmt = stmt.where(ModelRegistry.provider_id == provider_id)

    stmt = stmt.order_by(ModelRegistry.name.asc()).limit(limit).offset(offset)
    result = await db.execute(stmt)
    return [_model_to_response(m) for m in result.scalars().all()]


@router.post("/", response_model=ModelRegistryResponse, status_code=status.HTTP_201_CREATED)
async def register_model(
    data: ModelRegistryCreate,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin", "member")),
) -> ModelRegistryResponse:
    provider_stmt = select(Provider).where(Provider.id == data.provider_id, Provider.org_id == org_id)
    provider_result = await db.execute(provider_stmt)
    if not provider_result.scalar_one_or_none():
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Provider not found.")

    now = datetime.datetime.now(datetime.timezone.utc)
    entry = ModelRegistry(
        id=uuid.uuid4(),
        org_id=org_id,
        model_id=data.model_id,
        name=data.name,
        provider_id=data.provider_id,
        model_type=data.model_type,
        version=data.version,
        description=data.description,
        config_json=data.config_json,
        is_favorite=False,
        is_installed=data.is_installed,
        is_downloaded=data.is_downloaded,
        metadata_json=data.metadata_json,
        created_at=now,
        updated_at=now,
    )
    db.add(entry)
    await db.commit()
    await db.refresh(entry)

    await AuditService.log(
        db=db, action="create", resource="model_registry",
        org_id=org_id, resource_id=str(entry.id),
        detail=f"Registered model: {entry.name} ({data.model_type})",
    )
    await db.commit()

    return _model_to_response(entry)


@router.get("/{model_id}", response_model=ModelRegistryResponse)
async def get_model(
    model_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> ModelRegistryResponse:
    entry = await _get_model_or_404(db, model_id, org_id)
    return _model_to_response(entry)


@router.put("/{model_id}", response_model=ModelRegistryResponse)
async def update_model(
    model_id: uuid.UUID,
    data: ModelRegistryUpdate,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin", "member")),
) -> ModelRegistryResponse:
    entry = await _get_model_or_404(db, model_id, org_id)

    if data.name is not None:
        entry.name = data.name
    if data.version is not None:
        entry.version = data.version
    if data.description is not None:
        entry.description = data.description
    if data.config_json is not None:
        entry.config_json = data.config_json
    if data.is_installed is not None:
        entry.is_installed = data.is_installed
    if data.is_downloaded is not None:
        entry.is_downloaded = data.is_downloaded
    if data.metadata_json is not None:
        entry.metadata_json = data.metadata_json
    entry.updated_at = datetime.datetime.now(datetime.timezone.utc)

    await db.commit()
    await db.refresh(entry)

    await AuditService.log(
        db=db, action="update", resource="model_registry",
        org_id=org_id, resource_id=str(entry.id),
        detail=f"Updated model: {entry.name}",
    )
    await db.commit()

    return _model_to_response(entry)


@router.delete("/{model_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_model(
    model_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin")),
) -> None:
    entry = await _get_model_or_404(db, model_id, org_id)

    await db.execute(sa_delete(ModelRegistry).where(ModelRegistry.id == model_id))
    await db.commit()

    await AuditService.log(
        db=db, action="delete", resource="model_registry",
        org_id=org_id, resource_id=str(model_id),
        detail=f"Removed model: {entry.name}",
    )
    await db.commit()


@router.post("/{model_id}/favorite", response_model=ModelFavoriteResponse)
async def toggle_model_favorite(
    model_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin", "member")),
) -> ModelFavoriteResponse:
    entry = await _get_model_or_404(db, model_id, org_id)

    entry.is_favorite = not entry.is_favorite
    entry.updated_at = datetime.datetime.now(datetime.timezone.utc)
    await db.commit()
    await db.refresh(entry)

    action = "favorited" if entry.is_favorite else "unfavorited"
    await AuditService.log(
        db=db, action="update", resource="model_registry",
        org_id=org_id, resource_id=str(entry.id),
        detail=f"{action} model: {entry.name}",
    )
    await db.commit()

    return ModelFavoriteResponse(id=entry.id, is_favorite=entry.is_favorite)


@router.get("/providers/{provider_id}", response_model=List[ModelRegistryResponse])
async def list_models_by_provider(
    provider_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
) -> List[ModelRegistryResponse]:
    provider_stmt = select(Provider).where(Provider.id == provider_id, Provider.org_id == org_id)
    provider_result = await db.execute(provider_stmt)
    if not provider_result.scalar_one_or_none():
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Provider not found.")

    stmt = (
        select(ModelRegistry)
        .where(ModelRegistry.provider_id == provider_id, ModelRegistry.org_id == org_id)
        .order_by(ModelRegistry.name.asc())
        .limit(limit)
        .offset(offset)
    )
    result = await db.execute(stmt)
    return [_model_to_response(m) for m in result.scalars().all()]


@router.post("/sync", response_model=ModelSyncResponse)
async def sync_models_from_provider(
    data: ModelSyncRequest,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin")),
) -> ModelSyncResponse:
    provider_stmt = select(Provider).where(Provider.id == data.provider_id, Provider.org_id == org_id)
    provider_result = await db.execute(provider_stmt)
    provider = provider_result.scalar_one_or_none()
    if not provider:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Provider not found.")

    synced_count = 0
    now = datetime.datetime.now(datetime.timezone.utc)

    try:
        import httpx
        endpoint = provider.api_endpoint or f"https://api.{provider.provider_type}.com"
        async with httpx.AsyncClient(timeout=30.0) as client:
            resp = await client.get(f"{endpoint}/v1/models", headers={"Authorization": f"Bearer {provider.api_key_encrypted or ''}"})
            if resp.is_success:
                remote_models = resp.json().get("data", [])
                for rm in remote_models:
                    mid = rm.get("id", str(uuid.uuid4()))
                    existing = await db.execute(
                        select(ModelRegistry).where(
                            ModelRegistry.org_id == org_id,
                            ModelRegistry.model_id == mid,
                            ModelRegistry.provider_id == data.provider_id,
                        )
                    )
                    if existing.scalar_one_or_none():
                        continue
                    entry = ModelRegistry(
                        id=uuid.uuid4(),
                        org_id=org_id,
                        model_id=mid,
                        name=rm.get("id", mid),
                        provider_id=data.provider_id,
                        model_type="remote",
                        version=rm.get("version"),
                        description=rm.get("description"),
                        is_favorite=False,
                        is_installed=False,
                        is_downloaded=False,
                        created_at=now,
                        updated_at=now,
                    )
                    db.add(entry)
                    synced_count += 1
    except Exception as exc:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=f"Failed to sync models from provider: {str(exc)}",
        )

    await db.commit()

    await AuditService.log(
        db=db, action="sync", resource="model_registry",
        org_id=org_id, resource_id=str(data.provider_id),
        detail=f"Synced {synced_count} models from provider: {provider.name}",
    )
    await db.commit()

    return ModelSyncResponse(
        synced_count=synced_count,
        message=f"Successfully synced {synced_count} models from {provider.name}.",
    )
