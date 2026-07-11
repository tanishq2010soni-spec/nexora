import uuid

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from src.application.services.audit_service import AuditService
from src.infrastructure.database.connection import get_db_session
from src.infrastructure.database.repositories import SQLAlchemyBusinessProfileRepository
from src.domain.models.business_profile import BusinessProfile
from src.presentation.api.dependencies import get_current_org_id
from src.presentation.schemas.business_profile import (
    BusinessProfileCreate,
    BusinessProfileUpdate,
    BusinessProfileResponse,
)

router = APIRouter()


def _profile_to_response(profile: BusinessProfile) -> BusinessProfileResponse:
    return BusinessProfileResponse(
        id=profile.id, org_id=profile.org_id, name=profile.name,
        business_type=profile.business_type, address=profile.address,
        phone=profile.phone, email=profile.email, website=profile.website,
        working_hours=profile.working_hours, services=profile.services,
        policies=profile.policies, description=profile.description,
    )


@router.get("/", response_model=BusinessProfileResponse)
async def get_profile(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> BusinessProfileResponse:
    repo = SQLAlchemyBusinessProfileRepository(db)
    profile = await repo.get_by_org_id(org_id)
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Business profile not found.",
        )
    return _profile_to_response(profile)


@router.post("/", response_model=BusinessProfileResponse, status_code=status.HTTP_201_CREATED)
async def create_profile(
    data: BusinessProfileCreate,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> BusinessProfileResponse:
    repo = SQLAlchemyBusinessProfileRepository(db)
    existing = await repo.get_by_org_id(org_id)
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Business profile already exists for this organization.",
        )

    profile = BusinessProfile(
        org_id=org_id, name=data.name, business_type=data.business_type,
        address=data.address, phone=data.phone, email=data.email,
        website=data.website, working_hours=data.working_hours,
        services=data.services, policies=data.policies, description=data.description,
    )

    created = await repo.create(profile)
    await AuditService.log(db=db, action="create", resource="business_profile", org_id=org_id, resource_id=str(created.id))
    return _profile_to_response(created)


@router.put("/{profile_id}", response_model=BusinessProfileResponse)
async def update_profile(
    profile_id: uuid.UUID,
    data: BusinessProfileUpdate,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> BusinessProfileResponse:
    repo = SQLAlchemyBusinessProfileRepository(db)
    profile = await repo.get_by_id(profile_id)
    if not profile or profile.org_id != org_id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Business profile not found.",
        )

    if data.name is not None:
        profile.name = data.name
    if data.business_type is not None:
        profile.business_type = data.business_type
    if data.address is not None:
        profile.address = data.address
    if data.phone is not None:
        profile.phone = data.phone
    if data.email is not None:
        profile.email = data.email
    if data.website is not None:
        profile.website = data.website
    if data.working_hours is not None:
        profile.working_hours = data.working_hours
    if data.services is not None:
        profile.services = data.services
    if data.policies is not None:
        profile.policies = data.policies
    if data.description is not None:
        profile.description = data.description

    updated = await repo.update(profile)
    await AuditService.log(db=db, action="update", resource="business_profile", org_id=org_id, resource_id=str(updated.id))
    return _profile_to_response(updated)


@router.delete("/{profile_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_profile(
    profile_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> None:
    repo = SQLAlchemyBusinessProfileRepository(db)
    profile = await repo.get_by_id(profile_id)
    if not profile or profile.org_id != org_id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Business profile not found.",
        )
    deleted = await repo.delete(org_id)
    if not deleted:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Business profile not found.",
        )
