import uuid
import datetime
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel, Field
from sqlalchemy import select, func, delete as sa_delete
from sqlalchemy.ext.asyncio import AsyncSession

from src.infrastructure.database.connection import get_db_session
from src.infrastructure.database.models import Plugin
from src.presentation.api.dependencies import get_current_org_id, require_role
from src.application.services.audit_service import AuditService

router = APIRouter()


# ─── Schemas ───────────────────────────────────────────────────────────────

class PluginResponse(BaseModel):
    id: uuid.UUID
    org_id: uuid.UUID
    name: str
    description: Optional[str] = None
    version: str
    author: Optional[str] = None
    plugin_type: str
    entry_point: Optional[str] = None
    config_schema_json: Optional[str] = None
    is_enabled: bool
    is_official: bool
    metadata_json: Optional[str] = None
    created_at: str
    updated_at: str


class PluginCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    version: str = Field(default="1.0.0")
    author: Optional[str] = None
    plugin_type: str = Field(..., pattern="^(integration|action|trigger|connector|widget)$")
    entry_point: Optional[str] = None
    config_schema_json: Optional[str] = None
    is_enabled: bool = Field(default=True)
    metadata_json: Optional[str] = None


class PluginUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    description: Optional[str] = None
    version: Optional[str] = None
    author: Optional[str] = None
    plugin_type: Optional[str] = Field(None, pattern="^(integration|action|trigger|connector|widget)$")
    entry_point: Optional[str] = None
    config_schema_json: Optional[str] = None
    is_enabled: Optional[bool] = None
    metadata_json: Optional[str] = None


class PluginHookResponse(BaseModel):
    id: uuid.UUID
    plugin_id: uuid.UUID
    hook_name: str
    handler_function: str
    priority: int
    created_at: str


class MarketplacePluginResponse(BaseModel):
    id: uuid.UUID
    name: str
    description: Optional[str] = None
    version: str
    author: Optional[str] = None
    plugin_type: str
    is_official: bool
    metadata_json: Optional[str] = None


# ─── Helpers ───────────────────────────────────────────────────────────────

async def _get_plugin_or_404(db: AsyncSession, plugin_id: uuid.UUID, org_id: uuid.UUID) -> Plugin:
    stmt = select(Plugin).where(Plugin.id == plugin_id, Plugin.org_id == org_id)
    result = await db.execute(stmt)
    plugin = result.scalar_one_or_none()
    if not plugin:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Plugin not found.")
    return plugin


def _plugin_to_response(p: Plugin) -> PluginResponse:
    return PluginResponse(
        id=p.id, org_id=p.org_id, name=p.name,
        description=p.description, version=p.version, author=p.author,
        plugin_type=p.plugin_type, entry_point=p.entry_point,
        config_schema_json=p.config_schema_json, is_enabled=p.is_enabled,
        is_official=p.is_official, metadata_json=p.metadata_json,
        created_at=p.created_at.isoformat(),
        updated_at=p.updated_at.isoformat(),
    )


def _marketplace_to_response(p: Plugin) -> MarketplacePluginResponse:
    return MarketplacePluginResponse(
        id=p.id, name=p.name, description=p.description,
        version=p.version, author=p.author, plugin_type=p.plugin_type,
        is_official=p.is_official, metadata_json=p.metadata_json,
    )


# ─── Endpoints ─────────────────────────────────────────────────────────────

@router.get("/", response_model=List[PluginResponse])
async def list_plugins(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    plugin_type: Optional[str] = Query(default=None),
    is_enabled: Optional[bool] = Query(default=None),
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
) -> List[PluginResponse]:
    stmt = select(Plugin).where(Plugin.org_id == org_id)
    if plugin_type:
        stmt = stmt.where(Plugin.plugin_type == plugin_type)
    if is_enabled is not None:
        stmt = stmt.where(Plugin.is_enabled == is_enabled)
    stmt = stmt.order_by(Plugin.name.asc()).limit(limit).offset(offset)
    result = await db.execute(stmt)
    return [_plugin_to_response(p) for p in result.scalars().all()]


@router.post("/", response_model=PluginResponse, status_code=status.HTTP_201_CREATED)
async def register_plugin(
    data: PluginCreate,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin")),
) -> PluginResponse:
    now = datetime.datetime.now(datetime.timezone.utc)
    plugin = Plugin(
        id=uuid.uuid4(),
        org_id=org_id,
        name=data.name,
        description=data.description,
        version=data.version,
        author=data.author,
        plugin_type=data.plugin_type,
        entry_point=data.entry_point,
        config_schema_json=data.config_schema_json,
        is_enabled=data.is_enabled,
        is_official=False,
        metadata_json=data.metadata_json,
        created_at=now,
        updated_at=now,
    )
    db.add(plugin)
    await db.commit()
    await db.refresh(plugin)

    await AuditService.log(
        db=db, action="create", resource="plugin",
        org_id=org_id, resource_id=str(plugin.id),
        detail=f"Registered plugin: {plugin.name} v{plugin.version}",
    )
    await db.commit()

    return _plugin_to_response(plugin)


@router.get("/{plugin_id}", response_model=PluginResponse)
async def get_plugin(
    plugin_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> PluginResponse:
    plugin = await _get_plugin_or_404(db, plugin_id, org_id)
    return _plugin_to_response(plugin)


@router.put("/{plugin_id}", response_model=PluginResponse)
async def update_plugin(
    plugin_id: uuid.UUID,
    data: PluginUpdate,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin")),
) -> PluginResponse:
    plugin = await _get_plugin_or_404(db, plugin_id, org_id)

    if data.name is not None:
        plugin.name = data.name
    if data.description is not None:
        plugin.description = data.description
    if data.version is not None:
        plugin.version = data.version
    if data.author is not None:
        plugin.author = data.author
    if data.plugin_type is not None:
        plugin.plugin_type = data.plugin_type
    if data.entry_point is not None:
        plugin.entry_point = data.entry_point
    if data.config_schema_json is not None:
        plugin.config_schema_json = data.config_schema_json
    if data.is_enabled is not None:
        plugin.is_enabled = data.is_enabled
    if data.metadata_json is not None:
        plugin.metadata_json = data.metadata_json
    plugin.updated_at = datetime.datetime.now(datetime.timezone.utc)

    await db.commit()
    await db.refresh(plugin)

    await AuditService.log(
        db=db, action="update", resource="plugin",
        org_id=org_id, resource_id=str(plugin.id),
        detail=f"Updated plugin: {plugin.name}",
    )
    await db.commit()

    return _plugin_to_response(plugin)


@router.delete("/{plugin_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_plugin(
    plugin_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin")),
) -> None:
    plugin = await _get_plugin_or_404(db, plugin_id, org_id)

    await db.execute(sa_delete(Plugin).where(Plugin.id == plugin_id))
    await db.commit()

    await AuditService.log(
        db=db, action="delete", resource="plugin",
        org_id=org_id, resource_id=str(plugin_id),
        detail=f"Unregistered plugin: {plugin.name}",
    )
    await db.commit()


@router.post("/{plugin_id}/enable", response_model=PluginResponse)
async def enable_plugin(
    plugin_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin")),
) -> PluginResponse:
    plugin = await _get_plugin_or_404(db, plugin_id, org_id)

    plugin.is_enabled = True
    plugin.updated_at = datetime.datetime.now(datetime.timezone.utc)
    await db.commit()
    await db.refresh(plugin)

    await AuditService.log(
        db=db, action="enable", resource="plugin",
        org_id=org_id, resource_id=str(plugin.id),
        detail=f"Enabled plugin: {plugin.name}",
    )
    await db.commit()

    return _plugin_to_response(plugin)


@router.post("/{plugin_id}/disable", response_model=PluginResponse)
async def disable_plugin(
    plugin_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin")),
) -> PluginResponse:
    plugin = await _get_plugin_or_404(db, plugin_id, org_id)

    plugin.is_enabled = False
    plugin.updated_at = datetime.datetime.now(datetime.timezone.utc)
    await db.commit()
    await db.refresh(plugin)

    await AuditService.log(
        db=db, action="disable", resource="plugin",
        org_id=org_id, resource_id=str(plugin.id),
        detail=f"Disabled plugin: {plugin.name}",
    )
    await db.commit()

    return _plugin_to_response(plugin)


@router.get("/{plugin_id}/hooks", response_model=List[PluginHookResponse])
async def list_plugin_hooks(
    plugin_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
) -> List[PluginHookResponse]:
    await _get_plugin_or_404(db, plugin_id, org_id)
    return []


@router.get("/marketplace", response_model=List[MarketplacePluginResponse])
async def list_marketplace_plugins(
    db: AsyncSession = Depends(get_db_session),
    plugin_type: Optional[str] = Query(default=None),
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
) -> List[MarketplacePluginResponse]:
    stmt = select(Plugin).where(Plugin.is_official == True)
    if plugin_type:
        stmt = stmt.where(Plugin.plugin_type == plugin_type)
    stmt = stmt.order_by(Plugin.name.asc()).limit(limit).offset(offset)
    result = await db.execute(stmt)
    return [_marketplace_to_response(p) for p in result.scalars().all()]
