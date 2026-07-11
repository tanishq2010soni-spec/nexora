from __future__ import annotations

from typing import Any, Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel
from sqlalchemy import select, func, desc
from sqlalchemy.ext.asyncio import AsyncSession

from ..api.auth import get_current_user, require_permission
from ..domain.entities import Organization, PhoneProviderConfig, PromptTemplate, VoiceSettings
from ..infrastructure.database import (OrganizationModel, PhoneProviderConfigModel,
                                       PromptTemplateModel, VoiceSettingsModel, get_session)

router = APIRouter(prefix="/api/v1/settings", tags=["settings"])


class UpdateOrganizationRequest(BaseModel):
    name: Optional[str] = None
    timezone: Optional[str] = None
    brand_color: Optional[str] = None
    brand_logo_url: Optional[str] = None
    business_hours_start: Optional[str] = None
    business_hours_end: Optional[str] = None
    working_days: Optional[list[int]] = None
    default_country_code: Optional[str] = None
    max_concurrent_calls: Optional[int] = None
    max_agents: Optional[int] = None
    recording_enabled: Optional[bool] = None
    transcription_enabled: Optional[bool] = None


class UpdateVoiceSettingsRequest(BaseModel):
    stt_provider: Optional[str] = None
    stt_config: Optional[dict[str, Any]] = None
    tts_provider: Optional[str] = None
    tts_config: Optional[dict[str, Any]] = None
    tts_voice: Optional[str] = None
    tts_speed: Optional[float] = None
    tts_pitch: Optional[float] = None
    tts_emotion: Optional[str] = None
    vad_provider: Optional[str] = None
    vad_config: Optional[dict[str, Any]] = None
    noise_suppression: Optional[bool] = None
    echo_cancellation: Optional[bool] = None
    interruption_enabled: Optional[bool] = None
    silence_timeout_ms: Optional[int] = None


class CreatePhoneProviderRequest(BaseModel):
    name: str
    provider_type: str
    config: dict[str, Any] = {}
    credentials: dict[str, Any] = {}
    phone_numbers: list[str] = []
    default_phone_number: Optional[str] = None
    rate_per_minute: float = 0.0


class UpdatePhoneProviderRequest(BaseModel):
    name: Optional[str] = None
    provider_type: Optional[str] = None
    config: Optional[dict[str, Any]] = None
    credentials: Optional[dict[str, Any]] = None
    phone_numbers: Optional[list[str]] = None
    default_phone_number: Optional[str] = None
    rate_per_minute: Optional[float] = None
    is_active: Optional[bool] = None


class CreatePromptTemplateRequest(BaseModel):
    name: str
    description: Optional[str] = None
    system_prompt: str
    context_prompt: str = ""
    temperature: float = 0.7
    max_tokens: int = 1024
    model: Optional[str] = None


class UpdatePromptTemplateRequest(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    system_prompt: Optional[str] = None
    context_prompt: Optional[str] = None
    temperature: Optional[float] = None
    max_tokens: Optional[int] = None
    model: Optional[str] = None
    is_active: Optional[bool] = None


@router.get("/organization", response_model=Organization)
async def get_organization_settings(
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("view_settings")),
):
    result = await session.execute(
        select(OrganizationModel).where(OrganizationModel.id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Organization not found")
    return Organization.model_validate(model)


@router.put("/organization", response_model=Organization)
async def update_organization_settings(
    req: UpdateOrganizationRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_settings")),
):
    result = await session.execute(
        select(OrganizationModel).where(OrganizationModel.id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Organization not found")

    update_data = req.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        if value is not None:
            setattr(model, field, value)

    session.add(model)
    await session.flush()
    await session.refresh(model)
    return Organization.model_validate(model)


@router.get("/voice", response_model=VoiceSettings)
async def get_voice_settings(
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("view_settings")),
):
    result = await session.execute(
        select(VoiceSettingsModel).where(VoiceSettingsModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        model = VoiceSettingsModel(organization_id=str(current_user.organization_id))
        session.add(model)
        await session.flush()
        await session.refresh(model)
    return VoiceSettings.model_validate(model)


@router.put("/voice", response_model=VoiceSettings)
async def update_voice_settings(
    req: UpdateVoiceSettingsRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_settings")),
):
    result = await session.execute(
        select(VoiceSettingsModel).where(VoiceSettingsModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        model = VoiceSettingsModel(organization_id=str(current_user.organization_id))
        session.add(model)

    update_data = req.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        if value is not None:
            setattr(model, field, value)

    session.add(model)
    await session.flush()
    await session.refresh(model)
    return VoiceSettings.model_validate(model)


@router.get("/phone-providers", response_model=list[PhoneProviderConfig])
async def list_phone_providers(
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("view_settings")),
):
    result = await session.execute(
        select(PhoneProviderConfigModel).where(PhoneProviderConfigModel.organization_id == str(current_user.organization_id))
        .order_by(desc(PhoneProviderConfigModel.created_at))
    )
    models = result.scalars().all()
    return [PhoneProviderConfig.model_validate(m) for m in models]


@router.post("/phone-providers", response_model=PhoneProviderConfig)
async def create_phone_provider(
    req: CreatePhoneProviderRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_phone_providers")),
):
    model = PhoneProviderConfigModel(
        organization_id=str(current_user.organization_id),
        name=req.name,
        provider_type=req.provider_type,
        config=req.config,
        credentials=req.credentials,
        phone_numbers=req.phone_numbers,
        default_phone_number=req.default_phone_number,
        rate_per_minute=req.rate_per_minute,
    )
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return PhoneProviderConfig.model_validate(model)


@router.put("/phone-providers/{provider_id}", response_model=PhoneProviderConfig)
async def update_phone_provider(
    provider_id: UUID,
    req: UpdatePhoneProviderRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_phone_providers")),
):
    result = await session.execute(
        select(PhoneProviderConfigModel).where(PhoneProviderConfigModel.id == str(provider_id))
        .where(PhoneProviderConfigModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Phone provider not found")

    update_data = req.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        if value is not None:
            setattr(model, field, value)

    session.add(model)
    await session.flush()
    await session.refresh(model)
    return PhoneProviderConfig.model_validate(model)


@router.delete("/phone-providers/{provider_id}")
async def delete_phone_provider(
    provider_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_phone_providers")),
):
    result = await session.execute(
        select(PhoneProviderConfigModel).where(PhoneProviderConfigModel.id == str(provider_id))
        .where(PhoneProviderConfigModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Phone provider not found")

    await session.delete(model)
    return {"deleted": True}


@router.get("/prompts", response_model=list[PromptTemplate])
async def list_prompt_templates(
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("view_settings")),
):
    result = await session.execute(
        select(PromptTemplateModel).where(PromptTemplateModel.organization_id == str(current_user.organization_id))
        .order_by(desc(PromptTemplateModel.created_at))
    )
    models = result.scalars().all()
    return [PromptTemplate.model_validate(m) for m in models]


@router.post("/prompts", response_model=PromptTemplate)
async def create_prompt_template(
    req: CreatePromptTemplateRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_settings")),
):
    model = PromptTemplateModel(
        organization_id=str(current_user.organization_id),
        name=req.name,
        description=req.description,
        system_prompt=req.system_prompt,
        context_prompt=req.context_prompt,
        temperature=req.temperature,
        max_tokens=req.max_tokens,
        model=req.model,
        created_by=str(current_user.id),
    )
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return PromptTemplate.model_validate(model)


@router.put("/prompts/{prompt_id}", response_model=PromptTemplate)
async def update_prompt_template(
    prompt_id: UUID,
    req: UpdatePromptTemplateRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_settings")),
):
    result = await session.execute(
        select(PromptTemplateModel).where(PromptTemplateModel.id == str(prompt_id))
        .where(PromptTemplateModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Prompt template not found")

    update_data = req.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        if value is not None:
            setattr(model, field, value)

    session.add(model)
    await session.flush()
    await session.refresh(model)
    return PromptTemplate.model_validate(model)


@router.delete("/prompts/{prompt_id}")
async def delete_prompt_template(
    prompt_id: UUID,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_settings")),
):
    result = await session.execute(
        select(PromptTemplateModel).where(PromptTemplateModel.id == str(prompt_id))
        .where(PromptTemplateModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Prompt template not found")

    await session.delete(model)
    return {"deleted": True}
