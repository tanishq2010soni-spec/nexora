from abc import ABC, abstractmethod
import uuid
from typing import Optional
from src.domain.models.business_profile import BusinessProfile


class BusinessProfileRepository(ABC):
    @abstractmethod
    async def get_by_id(self, profile_id: uuid.UUID) -> Optional[BusinessProfile]:
        pass

    @abstractmethod
    async def get_by_org_id(self, org_id: uuid.UUID) -> Optional[BusinessProfile]:
        pass

    @abstractmethod
    async def create(self, profile: BusinessProfile) -> BusinessProfile:
        pass

    @abstractmethod
    async def update(self, profile: BusinessProfile) -> BusinessProfile:
        pass

    @abstractmethod
    async def delete(self, org_id: uuid.UUID) -> bool:
        pass
