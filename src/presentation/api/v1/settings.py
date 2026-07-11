import uuid
import datetime
import hashlib
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel, Field
from sqlalchemy import select, delete as sa_delete
from sqlalchemy.ext.asyncio import AsyncSession

from src.infrastructure.database.connection import get_db_session
from src.infrastructure.database.models import OrganizationSetting, ApiKey, Integration
from src.presentation.api.dependencies import get_current_org_id, require_role

router = APIRouter()


class SettingResponse(BaseModel):
    id: uuid.UUID
    org_id: uuid.UUID
    setting_key: str
    setting_value: Optional[str] = None
    setting_type: str
    category: str
    created_at: str
    updated_at: str


class ApiKeyResponse(BaseModel):
    id: uuid.UUID
    org_id: uuid.UUID
    name: str
    key_prefix: str
    permissions: Optional[str] = None
    is_active: bool
    last_used_at: Optional[str] = None
    expires_at: Optional[str] = None
    created_at: str


class IntegrationResponse(BaseModel):
    id: uuid.UUID
    org_id: uuid.UUID
    provider: str
    name: str
    status: str
    config_json: Optional[str] = None
    last_synced_at: Optional[str] = None
    created_at: str
    updated_at: str


class SettingUpdateRequest(BaseModel):
    setting_key: str = Field(..., min_length=1, max_length=255)
    setting_value: Optional[str] = None
    setting_type: str = Field(default="string", pattern="^(string|boolean|json|integer)$")
    category: str = Field(default="general", pattern="^(general|branding|security|integrations|backup)$")


class ApiKeyCreateRequest(BaseModel):
    name: str = Field(..., min_length=1, max_length=255)
    permissions: Optional[str] = None
    expires_at: Optional[str] = None


class IntegrationUpdateRequest(BaseModel):
    name: Optional[str] = None
    status: Optional[str] = Field(None, pattern="^(disconnected|connected|error)$")
    config_json: Optional[str] = None
    credentials_json: Optional[str] = None


def _setting_to_response(s) -> SettingResponse:
    return SettingResponse(id=s.id, org_id=s.org_id, setting_key=s.setting_key, setting_value=s.setting_value, setting_type=s.setting_type, category=s.category, created_at=s.created_at.isoformat(), updated_at=s.updated_at.isoformat())


def _apikey_to_response(k) -> ApiKeyResponse:
    return ApiKeyResponse(id=k.id, org_id=k.org_id, name=k.name, key_prefix=k.key_prefix, permissions=k.permissions, is_active=k.is_active, last_used_at=k.last_used_at.isoformat() if k.last_used_at else None, expires_at=k.expires_at.isoformat() if k.expires_at else None, created_at=k.created_at.isoformat())


def _integration_to_response(i) -> IntegrationResponse:
    return IntegrationResponse(id=i.id, org_id=i.org_id, provider=i.provider, name=i.name, status=i.status, config_json=i.config_json, last_synced_at=i.last_synced_at.isoformat() if i.last_synced_at else None, created_at=i.created_at.isoformat(), updated_at=i.updated_at.isoformat())


@router.get("/settings", response_model=List[SettingResponse])
async def list_settings(
    org_id: uuid.UUID = Depends(get_current_org_id), db: AsyncSession = Depends(get_db_session),
    category: Optional[str] = Query(default=None),
) -> List[SettingResponse]:
    stmt = select(OrganizationSetting).where(OrganizationSetting.org_id == org_id)
    if category:
        stmt = stmt.where(OrganizationSetting.category == category)
    result = await db.execute(stmt)
    return [_setting_to_response(s) for s in result.scalars().all()]


@router.post("/settings", response_model=SettingResponse, status_code=status.HTTP_201_CREATED)
async def upsert_setting(
    data: SettingUpdateRequest, org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session), _=Depends(require_role("admin")),
) -> SettingResponse:
    now = datetime.datetime.now(datetime.timezone.utc)
    stmt = select(OrganizationSetting).where(
        OrganizationSetting.org_id == org_id, OrganizationSetting.setting_key == data.setting_key
    )
    result = await db.execute(stmt)
    setting = result.scalar_one_or_none()
    if setting:
        setting.setting_value = data.setting_value
        setting.setting_type = data.setting_type
        setting.category = data.category
        setting.updated_at = now
    else:
        setting = OrganizationSetting(
            id=uuid.uuid4(), org_id=org_id, setting_key=data.setting_key,
            setting_value=data.setting_value, setting_type=data.setting_type,
            category=data.category, created_at=now, updated_at=now,
        )
        db.add(setting)
    await db.commit()
    await db.refresh(setting)
    return _setting_to_response(setting)


@router.get("/api-keys", response_model=List[ApiKeyResponse])
async def list_api_keys(
    org_id: uuid.UUID = Depends(get_current_org_id), db: AsyncSession = Depends(get_db_session),
) -> List[ApiKeyResponse]:
    stmt = select(ApiKey).where(ApiKey.org_id == org_id, ApiKey.is_active == True).order_by(ApiKey.created_at.desc())
    result = await db.execute(stmt)
    return [_apikey_to_response(k) for k in result.scalars().all()]


@router.post("/api-keys", response_model=ApiKeyResponse, status_code=status.HTTP_201_CREATED)
async def create_api_key(
    data: ApiKeyCreateRequest, org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session), _=Depends(require_role("admin")),
) -> ApiKeyResponse:
    import secrets
    key = secrets.token_hex(32)
    key_hash = hashlib.sha256(key.encode()).hexdigest()
    key_prefix = key[:8]
    now = datetime.datetime.now(datetime.timezone.utc)
    api_key = ApiKey(
        id=uuid.uuid4(), org_id=org_id, name=data.name, key_hash=key_hash,
        key_prefix=key_prefix, permissions=data.permissions, is_active=True,
        expires_at=datetime.datetime.fromisoformat(data.expires_at) if data.expires_at else None,
        created_at=now,
    )
    db.add(api_key)
    await db.commit()
    await db.refresh(api_key)
    return _apikey_to_response(api_key)


@router.delete("/api-keys/{key_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_api_key(
    key_id: uuid.UUID, org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session), _=Depends(require_role("admin")),
) -> None:
    stmt = select(ApiKey).where(ApiKey.id == key_id, ApiKey.org_id == org_id)
    result = await db.execute(stmt)
    key = result.scalar_one_or_none()
    if not key:
        raise HTTPException(status_code=404, detail="API key not found.")
    key.is_active = False
    await db.commit()


@router.get("/integrations", response_model=List[IntegrationResponse])
async def list_integrations(
    org_id: uuid.UUID = Depends(get_current_org_id), db: AsyncSession = Depends(get_db_session),
) -> List[IntegrationResponse]:
    stmt = select(Integration).where(Integration.org_id == org_id).order_by(Integration.created_at.desc())
    result = await db.execute(stmt)
    return [_integration_to_response(i) for i in result.scalars().all()]


@router.patch("/integrations/{integration_id}", response_model=IntegrationResponse)
async def update_integration(
    integration_id: uuid.UUID, data: IntegrationUpdateRequest,
    org_id: uuid.UUID = Depends(get_current_org_id), db: AsyncSession = Depends(get_db_session),
) -> IntegrationResponse:
    stmt = select(Integration).where(Integration.id == integration_id, Integration.org_id == org_id)
    result = await db.execute(stmt)
    integration = result.scalar_one_or_none()
    if not integration:
        raise HTTPException(status_code=404, detail="Integration not found.")
    if data.name is not None:
        integration.name = data.name
    if data.status is not None:
        integration.status = data.status
    if data.config_json is not None:
        integration.config_json = data.config_json
    if data.credentials_json is not None:
        integration.credentials_json = data.credentials_json
    integration.updated_at = datetime.datetime.now(datetime.timezone.utc)
    await db.commit()
    await db.refresh(integration)
    return _integration_to_response(integration)
