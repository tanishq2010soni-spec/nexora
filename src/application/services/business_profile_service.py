import uuid
from typing import Optional

from sqlalchemy.ext.asyncio import AsyncSession

from src.domain.models.business_profile import BusinessProfile
from src.application.interfaces.business_profile_repository import BusinessProfileRepository
from src.infrastructure.database.repositories import SQLAlchemyBusinessProfileRepository
from src.infrastructure.logging.logger import get_logger

logger = get_logger(__name__)


class BusinessProfileService:
    def __init__(self, db: AsyncSession):
        self.db = db
        self._repo: BusinessProfileRepository = SQLAlchemyBusinessProfileRepository(db)

    async def get_by_org_id(self, org_id: uuid.UUID) -> Optional[BusinessProfile]:
        return await self._repo.get_by_org_id(org_id)

    async def get_by_id(self, profile_id: uuid.UUID, org_id: uuid.UUID) -> Optional[BusinessProfile]:
        profile = await self._repo.get_by_id(profile_id)
        if profile and profile.org_id != org_id:
            return None
        return profile

    async def create(self, org_id: uuid.UUID, **kwargs) -> BusinessProfile:
        existing = await self._repo.get_by_org_id(org_id)
        if existing:
            raise ValueError("Business profile already exists for this organization")

        profile = BusinessProfile(org_id=org_id, **kwargs)
        created = await self._repo.create(profile)
        logger.info("Business profile created", org_id=str(org_id), profile_id=str(created.id))
        return created

    async def update(
        self, profile_id: uuid.UUID, org_id: uuid.UUID, **kwargs
    ) -> BusinessProfile:
        profile = await self._repo.get_by_id(profile_id)
        if not profile or profile.org_id != org_id:
            raise ValueError("Business profile not found")

        for field, value in kwargs.items():
            if value is not None and hasattr(profile, field):
                setattr(profile, field, value)

        updated = await self._repo.update(profile)
        logger.info("Business profile updated", profile_id=str(profile_id))
        return updated

    async def delete(self, profile_id: uuid.UUID, org_id: uuid.UUID) -> bool:
        profile = await self._repo.get_by_id(profile_id)
        if not profile or profile.org_id != org_id:
            return False
        result = await self._repo.delete(org_id)
        if result:
            logger.info("Business profile deleted", profile_id=str(profile_id))
        return result
