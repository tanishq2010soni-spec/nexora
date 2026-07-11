from datetime import datetime
from typing import Any, Optional
from uuid import UUID, uuid4

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from ..api.auth import get_current_user, require_permission
from ..domain.entities import Plugin, User
from ..infrastructure.database import PluginModel, get_session

router = APIRouter(prefix="/api/v1/plugins", tags=["plugins"])


@router.get("/")
async def list_plugins(
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
    page: int = Query(1, ge=1),
    limit: int = Query(50, ge=1, le=100),
    is_enabled: Optional[bool] = Query(None),
):
    org_id = str(current_user.organization_id)
    query = select(PluginModel).where(PluginModel.organization_id == org_id)
    if is_enabled is not None:
        query = query.where(PluginModel.is_enabled == is_enabled)
    query = query.order_by(PluginModel.updated_at.desc())
    total_result = await session.execute(select(func.count()).select_from(query.subquery()))
    total = total_result.scalar()
    offset = (page - 1) * limit
    result = await session.execute(query.offset(offset).limit(limit))
    models = result.scalars().all()
    return {
        "items": [Plugin.model_validate(m) for m in models],
        "total": total,
        "page": page,
        "limit": limit,
    }


@router.post("/", status_code=201)
async def install_plugin(
    name: str,
    entry_point: str,
    version: str = "1.0.0",
    description: Optional[str] = None,
    config_schema: Optional[dict[str, Any]] = None,
    config: Optional[dict[str, Any]] = None,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_plugins")),
):
    org_id = str(current_user.organization_id)
    existing = await session.execute(
        select(PluginModel).where(
            PluginModel.organization_id == org_id,
            PluginModel.name == name,
        )
    )
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=409, detail="Plugin already installed")
    model = PluginModel(
        id=str(uuid4()),
        organization_id=org_id,
        name=name,
        version=version,
        description=description,
        entry_point=entry_point,
        config_schema=config_schema or {},
        config=config or {},
        is_enabled=True,
    )
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return Plugin.model_validate(model)


@router.get("/{plugin_id}")
async def get_plugin(
    plugin_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(PluginModel).where(
            PluginModel.id == str(plugin_id),
            PluginModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Plugin not found")
    return Plugin.model_validate(model)


@router.put("/{plugin_id}")
async def update_plugin(
    plugin_id: UUID,
    config: Optional[dict[str, Any]] = None,
    version: Optional[str] = None,
    description: Optional[str] = None,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_plugins")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(PluginModel).where(
            PluginModel.id == str(plugin_id),
            PluginModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Plugin not found")
    if config is not None:
        model.config = {**(model.config or {}), **config}
    if version is not None:
        model.version = version
    if description is not None:
        model.description = description
    model.updated_at = datetime.utcnow()
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return Plugin.model_validate(model)


@router.delete("/{plugin_id}")
async def uninstall_plugin(
    plugin_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_plugins")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(PluginModel).where(
            PluginModel.id == str(plugin_id),
            PluginModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Plugin not found")
    await session.delete(model)
    await session.flush()
    return {"detail": "Plugin uninstalled"}


@router.post("/{plugin_id}/toggle")
async def toggle_plugin(
    plugin_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_plugins")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(PluginModel).where(
            PluginModel.id == str(plugin_id),
            PluginModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Plugin not found")
    model.is_enabled = not model.is_enabled
    model.updated_at = datetime.utcnow()
    session.add(model)
    await session.flush()
    return {"is_enabled": model.is_enabled}
