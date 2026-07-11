from datetime import datetime, time
from typing import Any, Optional
from uuid import UUID, uuid4

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from ..api.auth import get_current_user, require_permission
from ..domain.entities import Organization, PromptTemplate, User
from ..infrastructure.database import (OrganizationModel, PromptTemplateModel,
                                       get_session)

router = APIRouter(prefix="/api/v1/settings", tags=["settings"])


def _org_to_entity(m: OrganizationModel) -> Organization:
    return Organization(
        id=UUID(str(m.id)),
        name=m.name,
        slug=m.slug,
        status=m.status,
        timezone=m.timezone,
        brand_color=m.brand_color,
        brand_logo_url=m.brand_logo_url,
        working_hours_start=time.fromisoformat(m.working_hours_start) if m.working_hours_start else time(9, 0),
        working_hours_end=time.fromisoformat(m.working_hours_end) if m.working_hours_end else time(18, 0),
        working_days=m.working_days or [0, 1, 2, 3, 4, 5, 6],
        default_language=m.default_language,
        max_whatsapp_accounts=m.max_whatsapp_accounts,
        max_users=m.max_users,
        max_leads=m.max_leads,
        extra_data=m.extra_data or {},
        created_at=m.created_at,
        updated_at=m.updated_at,
    )


@router.get("/organization")
async def get_organization_settings(
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    result = await session.execute(
        select(OrganizationModel).where(OrganizationModel.id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Organization not found")
    return _org_to_entity(model)


@router.put("/organization")
async def update_organization_settings(
    name: Optional[str] = None,
    timezone: Optional[str] = None,
    brand_color: Optional[str] = None,
    brand_logo_url: Optional[str] = None,
    working_hours_start: Optional[str] = None,
    working_hours_end: Optional[str] = None,
    working_days: Optional[list[int]] = None,
    default_language: Optional[str] = None,
    metadata: Optional[dict[str, Any]] = None,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_settings")),
):
    result = await session.execute(
        select(OrganizationModel).where(OrganizationModel.id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Organization not found")
    if name is not None:
        model.name = name
    if timezone is not None:
        model.timezone = timezone
    if brand_color is not None:
        model.brand_color = brand_color
    if brand_logo_url is not None:
        model.brand_logo_url = brand_logo_url
    if working_hours_start is not None:
        model.working_hours_start = working_hours_start
    if working_hours_end is not None:
        model.working_hours_end = working_hours_end
    if working_days is not None:
        model.working_days = working_days
    if default_language is not None:
        model.default_language = default_language
    if metadata is not None:
        model.extra_data = {**(model.extra_data or {}), **metadata}
    model.updated_at = datetime.utcnow()
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return _org_to_entity(model)


@router.get("/prompts")
async def list_prompt_templates(
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
    page: int = Query(1, ge=1),
    limit: int = Query(50, ge=1, le=100),
):
    org_id = str(current_user.organization_id)
    query = select(PromptTemplateModel).where(PromptTemplateModel.organization_id == org_id)
    query = query.order_by(PromptTemplateModel.updated_at.desc())
    total_result = await session.execute(select(func.count()).select_from(query.subquery()))
    total = total_result.scalar()
    offset = (page - 1) * limit
    result = await session.execute(query.offset(offset).limit(limit))
    models = result.scalars().all()
    return {
        "items": [PromptTemplate.model_validate(m) for m in models],
        "total": total,
        "page": page,
        "limit": limit,
    }


@router.post("/prompts", status_code=201)
async def create_prompt_template(
    name: str,
    system_prompt: str,
    description: Optional[str] = None,
    context_prompt: str = "",
    temperature: float = 0.7,
    max_tokens: int = 1024,
    model: Optional[str] = None,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_settings")),
):
    org_id = str(current_user.organization_id)
    prompt_model = PromptTemplateModel(
        id=str(uuid4()),
        organization_id=org_id,
        name=name,
        description=description,
        system_prompt=system_prompt,
        context_prompt=context_prompt,
        temperature=temperature,
        max_tokens=max_tokens,
        model=model,
        created_by=str(current_user.id),
    )
    session.add(prompt_model)
    await session.flush()
    await session.refresh(prompt_model)
    return PromptTemplate.model_validate(prompt_model)


@router.put("/prompts/{prompt_id}")
async def update_prompt_template(
    prompt_id: UUID,
    name: Optional[str] = None,
    system_prompt: Optional[str] = None,
    description: Optional[str] = None,
    context_prompt: Optional[str] = None,
    temperature: Optional[float] = None,
    max_tokens: Optional[int] = None,
    model: Optional[str] = None,
    is_active: Optional[bool] = None,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_settings")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(PromptTemplateModel).where(
            PromptTemplateModel.id == str(prompt_id),
            PromptTemplateModel.organization_id == org_id,
        )
    )
    prompt = result.scalar_one_or_none()
    if not prompt:
        raise HTTPException(status_code=404, detail="Prompt template not found")
    if name is not None:
        prompt.name = name
    if system_prompt is not None:
        prompt.system_prompt = system_prompt
    if description is not None:
        prompt.description = description
    if context_prompt is not None:
        prompt.context_prompt = context_prompt
    if temperature is not None:
        prompt.temperature = temperature
    if max_tokens is not None:
        prompt.max_tokens = max_tokens
    if model is not None:
        prompt.model = model
    if is_active is not None:
        prompt.is_active = is_active
    prompt.updated_at = datetime.utcnow()
    session.add(prompt)
    await session.flush()
    await session.refresh(prompt)
    return PromptTemplate.model_validate(prompt)


@router.delete("/prompts/{prompt_id}")
async def delete_prompt_template(
    prompt_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_settings")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(PromptTemplateModel).where(
            PromptTemplateModel.id == str(prompt_id),
            PromptTemplateModel.organization_id == org_id,
        )
    )
    prompt = result.scalar_one_or_none()
    if not prompt:
        raise HTTPException(status_code=404, detail="Prompt template not found")
    await session.delete(prompt)
    await session.flush()
    return {"detail": "Prompt template deleted"}


@router.get("/models")
async def get_model_config(
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(OrganizationModel).where(OrganizationModel.id == str(org_id))
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Organization not found")
    meta = model.extra_data or {}
    return {
        "default_model": meta.get("default_model", "gpt-4"),
        "available_models": meta.get("available_models", ["gpt-4", "gpt-3.5-turbo"]),
        "max_tokens": meta.get("max_tokens", 4096),
        "temperature": meta.get("temperature", 0.7),
    }


@router.put("/models")
async def update_model_config(
    default_model: Optional[str] = None,
    available_models: Optional[list[str]] = None,
    max_tokens: Optional[int] = None,
    temperature: Optional[float] = None,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_models")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(OrganizationModel).where(OrganizationModel.id == str(org_id))
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="Organization not found")
    meta = dict(model.extra_data or {})
    if default_model is not None:
        meta["default_model"] = default_model
    if available_models is not None:
        meta["available_models"] = available_models
    if max_tokens is not None:
        meta["max_tokens"] = max_tokens
    if temperature is not None:
        meta["temperature"] = temperature
    model.extra_data = meta
    model.updated_at = datetime.utcnow()
    session.add(model)
    await session.flush()
    return {
        "default_model": meta.get("default_model", "gpt-4"),
        "available_models": meta.get("available_models", ["gpt-4", "gpt-3.5-turbo"]),
        "max_tokens": meta.get("max_tokens", 4096),
        "temperature": meta.get("temperature", 0.7),
    }
