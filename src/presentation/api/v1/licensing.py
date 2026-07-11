import uuid
import datetime
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel, Field
from sqlalchemy import select, func, delete as sa_delete
from sqlalchemy.ext.asyncio import AsyncSession

from src.infrastructure.database.connection import get_db_session
from src.infrastructure.database.models import License
from src.presentation.api.dependencies import get_current_org_id, require_role
from src.application.services.audit_service import AuditService

router = APIRouter()


# ─── Schemas ───────────────────────────────────────────────────────────────

class LicenseResponse(BaseModel):
    id: uuid.UUID
    org_id: uuid.UUID
    license_key: str
    status: str
    activated_at: Optional[str] = None
    expires_at: Optional[str] = None
    features_json: Optional[str] = None
    max_users: int
    max_agents: int
    created_at: str
    updated_at: str


class LicenseActivateRequest(BaseModel):
    license_key: str = Field(..., min_length=1, max_length=255)


class LicenseUpdateRequest(BaseModel):
    features_json: Optional[str] = None
    max_users: Optional[int] = Field(None, ge=1)
    max_agents: Optional[int] = Field(None, ge=1)


class LicenseUsageResponse(BaseModel):
    id: uuid.UUID
    org_id: uuid.UUID
    license_id: uuid.UUID
    metric_name: str
    metric_value: int
    recorded_at: str


class LicenseValidateResponse(BaseModel):
    is_valid: bool
    status: str
    message: str
    expires_at: Optional[str] = None


# ─── Helpers ───────────────────────────────────────────────────────────────

async def _get_license_or_404(db: AsyncSession, org_id: uuid.UUID) -> License:
    stmt = select(License).where(License.org_id == org_id)
    result = await db.execute(stmt)
    lic = result.scalar_one_or_none()
    if not lic:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="License not found for this organization.")
    return lic


def _license_to_response(l: License) -> LicenseResponse:
    return LicenseResponse(
        id=l.id, org_id=l.org_id, license_key=l.license_key,
        status=l.status,
        activated_at=l.activated_at.isoformat() if l.activated_at else None,
        expires_at=l.expires_at.isoformat() if l.expires_at else None,
        features_json=l.features_json, max_users=l.max_users,
        max_agents=l.max_agents,
        created_at=l.created_at.isoformat(),
        updated_at=l.updated_at.isoformat(),
    )


# ─── Endpoints ─────────────────────────────────────────────────────────────

@router.get("/", response_model=LicenseResponse)
async def get_license(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin")),
) -> LicenseResponse:
    lic = await _get_license_or_404(db, org_id)
    return _license_to_response(lic)


@router.post("/activate", response_model=LicenseResponse)
async def activate_license(
    data: LicenseActivateRequest,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin")),
) -> LicenseResponse:
    existing = await db.execute(select(License).where(License.org_id == org_id))
    if existing.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="A license is already activated for this organization.",
        )

    now = datetime.datetime.now(datetime.timezone.utc)
    lic = License(
        id=uuid.uuid4(),
        org_id=org_id,
        license_key=data.license_key,
        status="active",
        activated_at=now,
        expires_at=now + datetime.timedelta(days=365),
        features_json='{"all": true}',
        max_users=10,
        max_agents=5,
        created_at=now,
        updated_at=now,
    )
    db.add(lic)
    await db.commit()
    await db.refresh(lic)

    await AuditService.log(
        db=db, action="activate", resource="license",
        org_id=org_id, resource_id=str(lic.id),
        detail=f"License activated: {data.license_key}",
    )
    await db.commit()

    return _license_to_response(lic)


@router.put("/", response_model=LicenseResponse)
async def update_license(
    data: LicenseUpdateRequest,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin")),
) -> LicenseResponse:
    lic = await _get_license_or_404(db, org_id)

    if data.features_json is not None:
        lic.features_json = data.features_json
    if data.max_users is not None:
        lic.max_users = data.max_users
    if data.max_agents is not None:
        lic.max_agents = data.max_agents
    lic.updated_at = datetime.datetime.now(datetime.timezone.utc)

    await db.commit()
    await db.refresh(lic)

    await AuditService.log(
        db=db, action="update", resource="license",
        org_id=org_id, resource_id=str(lic.id),
        detail="License settings updated",
    )
    await db.commit()

    return _license_to_response(lic)


@router.get("/usage", response_model=List[LicenseUsageResponse])
async def get_license_usage(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin")),
    metric_name: Optional[str] = Query(default=None),
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
) -> List[LicenseUsageResponse]:
    await _get_license_or_404(db, org_id)
    return []


@router.post("/validate", response_model=LicenseValidateResponse)
async def validate_license(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> LicenseValidateResponse:
    stmt = select(License).where(License.org_id == org_id)
    result = await db.execute(stmt)
    lic = result.scalar_one_or_none()

    if not lic:
        return LicenseValidateResponse(
            is_valid=False, status="not_found",
            message="No license found for this organization.",
            expires_at=None,
        )

    now = datetime.datetime.now(datetime.timezone.utc)
    if lic.status != "active":
        return LicenseValidateResponse(
            is_valid=False, status=lic.status,
            message=f"License status is '{lic.status}'.",
            expires_at=lic.expires_at.isoformat() if lic.expires_at else None,
        )

    if lic.expires_at and lic.expires_at < now:
        return LicenseValidateResponse(
            is_valid=False, status="expired",
            message="License has expired.",
            expires_at=lic.expires_at.isoformat(),
        )

    return LicenseValidateResponse(
        is_valid=True, status="active",
        message="License is valid and active.",
        expires_at=lic.expires_at.isoformat() if lic.expires_at else None,
    )
