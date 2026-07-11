from __future__ import annotations

from typing import Any, Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel
from sqlalchemy import select, func, desc
from sqlalchemy.ext.asyncio import AsyncSession

from ..api.auth import get_current_user, require_permission
from ..domain.entities import Script
from ..domain.enums import ScriptType
from ..infrastructure.database import ScriptModel, get_session

router = APIRouter(prefix="/api/v1/scripts", tags=["scripts"])


class ScriptListResponse(BaseModel):
    items: list[Script]
    total: int
    page: int
    limit: int
    pages: int


class CreateScriptRequest(BaseModel):
    name: str
    type: str
    content: str
    variables: list[dict[str, Any]] = []
    sections: list[dict[str, Any]] = []
    tags: list[str] = []


class UpdateScriptRequest(BaseModel):
    name: Optional[str] = None
    type: Optional[str] = None
    content: Optional[str] = None
    variables: Optional[list[dict[str, Any]]] = None
    sections: Optional[list[dict[str, Any]]] = None
    tags: Optional[list[str]] = None


@router.get("", response_model=ScriptListResponse)
async def list_scripts(
    type: Optional[str] = Query(None),
    search: Optional[str] = Query(None),
    is_active: Optional[bool] = Query(None),
    page: int = Query(1, ge=1),
    limit: int = Query(50, ge=1, le=200),
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("view_scripts")),
):
    query = select(ScriptModel).where(ScriptModel.organization_id == str(current_user.organization_id))

    if type:
        query = query.where(ScriptModel.type == type)
    if is_active is not None:
        query = query.where(ScriptModel.is_active == is_active)
    if search:
        query = query.where(ScriptModel.name.ilike(f"%{search}%"))

    count_query = select(func.count()).select_from(query.subquery())
    total = (await session.execute(count_query)).scalar() or 0
    pages = max(1, (total + limit - 1) // limit)
    offset = (page - 1) * limit

    query = query.order_by(desc(ScriptModel.created_at)).offset(offset).limit(limit)
    result = await session.execute(query)
    models = result.scalars().all()

    return ScriptListResponse(
        items=[Script.model_validate(m) for m in models],
        total=total, page=page, limit=limit, pages=pages,
    )


@router.post("", response_model=Script)
async def create_script(
    req: CreateScriptRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_scripts")),
):
    valid_types = [t.value for t in ScriptType]
    if req.type not in valid_types:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail=f"Invalid type. Valid: {valid_types}")

    model = ScriptModel(
        organization_id=str(current_user.organization_id),
        name=req.name,
        type=req.type,
        content=req.content,
        variables=req.variables,
        sections=req.sections,
        tags=req.tags,
        created_by=str(current_user.id),
    )
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return Script.model_validate(model)


@router.get("/{script_id}", response_model=Script)
async def get_script(
    script_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(get_current_user),
):
    result = await session.execute(
        select(ScriptModel).where(ScriptModel.id == str(script_id))
        .where(ScriptModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Script not found")
    return Script.model_validate(model)


@router.put("/{script_id}", response_model=Script)
async def update_script(
    script_id: UUID,
    req: UpdateScriptRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_scripts")),
):
    result = await session.execute(
        select(ScriptModel).where(ScriptModel.id == str(script_id))
        .where(ScriptModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Script not found")

    update_data = req.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        if value is not None:
            setattr(model, field, value)

    model.version = (model.version or 1) + 1
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return Script.model_validate(model)


@router.delete("/{script_id}")
async def delete_script(
    script_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_scripts")),
):
    result = await session.execute(
        select(ScriptModel).where(ScriptModel.id == str(script_id))
        .where(ScriptModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Script not found")

    await session.delete(model)
    return {"deleted": True}


@router.post("/{script_id}/duplicate", response_model=Script)
async def duplicate_script(
    script_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_scripts")),
):
    result = await session.execute(
        select(ScriptModel).where(ScriptModel.id == str(script_id))
        .where(ScriptModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Script not found")

    duplicate = ScriptModel(
        organization_id=str(current_user.organization_id),
        name=f"{model.name} (Copy)",
        type=model.type,
        content=model.content,
        variables=model.variables,
        sections=model.sections,
        tags=model.tags,
        created_by=str(current_user.id),
    )
    session.add(duplicate)
    await session.flush()
    await session.refresh(duplicate)
    return Script.model_validate(duplicate)


@router.post("/{script_id}/activate", response_model=Script)
async def activate_script(
    script_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_scripts")),
):
    result = await session.execute(
        select(ScriptModel).where(ScriptModel.id == str(script_id))
        .where(ScriptModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Script not found")

    await session.execute(
        select(ScriptModel).where(ScriptModel.organization_id == str(current_user.organization_id))
    )
    other_scripts = await session.execute(
        select(ScriptModel).where(ScriptModel.organization_id == str(current_user.organization_id))
        .where(ScriptModel.id != str(script_id))
    )
    for other in other_scripts.scalars().all():
        other.is_active = False
        session.add(other)

    model.is_active = True
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return Script.model_validate(model)
