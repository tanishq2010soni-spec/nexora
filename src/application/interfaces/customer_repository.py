from abc import ABC, abstractmethod
import uuid
from typing import Optional
from src.domain.models.customer import Customer


class CustomerRepository(ABC):
    @abstractmethod
    async def get_by_phone(self, org_id: uuid.UUID, phone: str) -> Optional[Customer]:
        pass

    @abstractmethod
    async def create(self, customer: Customer) -> Customer:
        pass

    @abstractmethod
    async def update(self, customer: Customer) -> Customer:
        pass

    @abstractmethod
    async def save_or_update(self, customer: Customer) -> Customer:
        pass
