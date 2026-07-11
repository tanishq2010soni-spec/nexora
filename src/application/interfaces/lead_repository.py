from abc import ABC, abstractmethod
import uuid
from typing import List, Optional
from src.domain.models.lead import Lead


class LeadRepository(ABC):
    @abstractmethod
    async def get_by_id(self, lead_id: uuid.UUID) -> Optional[Lead]:
        pass

    @abstractmethod
    async def get_by_org_id(self, org_id: uuid.UUID, limit: int = 100, offset: int = 0) -> List[Lead]:
        pass

    @abstractmethod
    async def get_by_session_id(self, session_id: uuid.UUID) -> List[Lead]:
        pass

    @abstractmethod
    async def create(self, lead: Lead) -> Lead:
        pass

    @abstractmethod
    async def find_duplicate(self, org_id: uuid.UUID, email: Optional[str], phone: Optional[str]) -> Optional[Lead]:
        """
        Find an existing lead by email or phone to avoid duplicates.
        """
        pass

    @abstractmethod
    async def get_scored_leads(self, org_id: uuid.UUID, limit: int = 50, offset: int = 0) -> List[Lead]:
        """
        Retrieve leads sorted by computed score (high-potential first).
        """
        pass

    @abstractmethod
    async def count_by_org_id(self, org_id: uuid.UUID) -> int:
        pass
