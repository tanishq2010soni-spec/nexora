from __future__ import annotations

from typing import Any, Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel
from sqlalchemy import select, desc
from sqlalchemy.ext.asyncio import AsyncSession

from ..api.auth import get_current_user, require_permission
from ..domain.entities import Plugin
from ..infrastructure.database import PluginModel, get_session

router = APIRouter(prefix="/api/v1/plugins", tags=["plugins"])


class CreatePluginRequest(BaseModel):
    name: str
    version: str = "1.0.0"
    description: Optional[str] = None
    entry_point: str = ""
    config_schema: dict[str, Any] = {}
    config: dict[str, Any] = {}
    is_official: bool = False


class UpdatePluginRequest(BaseModel):
    name: Optional[str] = None
    version: Optional[str] = None
    description: Optional[str] = None
    entry_point: Optional[str] = None
    config_schema: Optional[dict[str, Any]] = None
    config: Optional[dict[str, Any]] = None


class TogglePluginRequest(BaseModel):
    is_enabled: bool


@router.get("", response_model=list[Plugin])
async def list_plugins(
    is_enabled: Optional[bool] = Query(None),
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_plugins")),
):
    query = select(PluginModel).where(PluginModel.organization_id == str(current_user.organization_id))
    if is_enabled is not None:
        query = query.where(PluginModel.is_enabled == is_enabled)
    query = query.order_by(desc(PluginModel.created_at))

    result = await session.execute(query)
    models = result.scalars().all()
    return [Plugin.model_validate(m) for m in models]


@router.post("", response_model=Plugin)
async def install_plugin(
    req: CreatePluginRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_plugins")),
):
    existing = await session.execute(
        select(PluginModel).where(PluginModel.organization_id == str(current_user.organization_id))
        .where(PluginModel.name == req.name)
    )
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Plugin already installed")

    model = PluginModel(
        organization_id=str(current_user.organization_id),
        name=req.name,
        version=req.version,
        description=req.description,
        entry_point=req.entry_point,
        config_schema=req.config_schema,
        config=req.config,
        is_official=req.is_official,
    )
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return Plugin.model_validate(model)


@router.get("/{plugin_id}", response_model=Plugin)
async def get_plugin(
    plugin_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(get_current_user),
):
    result = await session.execute(
        select(PluginModel).where(PluginModel.id == str(plugin_id))
        .where(PluginModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Plugin not found")
    return Plugin.model_validate(model)


@router.put("/{plugin_id}", response_model=Plugin)
async def update_plugin(
    plugin_id: UUID,
    req: UpdatePluginRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_plugins")),
):
    result = await session.execute(
        select(PluginModel).where(PluginModel.id == str(plugin_id))
        .where(PluginModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Plugin not found")

    update_data = req.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        if value is not None:
            setattr(model, field, value)

    session.add(model)
    await session.flush()
    await session.refresh(model)
    return Plugin.model_validate(model)


@router.delete("/{plugin_id}")
async def uninstall_plugin(
    plugin_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_plugins")),
):
    result = await session.execute(
        select(PluginModel).where(PluginModel.id == str(plugin_id))
        .where(PluginModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Plugin not found")

    await session.delete(model)
    return {"deleted": True}


@router.post("/{plugin_id}/toggle", response_model=Plugin)
async def toggle_plugin(
    plugin_id: UUID,
    req: TogglePluginRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_plugins")),
):
    result = await session.execute(
        select(PluginModel).where(PluginModel.id == str(plugin_id))
        .where(PluginModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Plugin not found")

    model.is_enabled = req.is_enabled
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return Plugin.model_validate(model)
