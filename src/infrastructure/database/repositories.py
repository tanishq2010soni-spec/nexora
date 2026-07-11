import datetime
import uuid
from typing import List, Optional
from sqlalchemy import select, delete
from sqlalchemy.ext.asyncio import AsyncSession

from src.domain.models.business_profile import BusinessProfile
from src.domain.models.lead import Lead
from src.domain.models.customer import Customer
from src.application.interfaces.business_profile_repository import BusinessProfileRepository
from src.application.interfaces.lead_repository import LeadRepository
from src.application.interfaces.customer_repository import CustomerRepository
from src.infrastructure.database.models import (
    BusinessProfile as ORMProfile,
    Lead as ORMLead,
    Customer as ORMCustomer,
)


# ==================== Mappers ====================

def to_domain_profile(orm: ORMProfile) -> BusinessProfile:
    return BusinessProfile(
        id=orm.id,
        org_id=orm.org_id,
        name=orm.name,
        business_type=orm.business_type,
        address=orm.address,
        phone=orm.phone,
        email=orm.email,
        website=orm.website,
        working_hours=orm.working_hours,
        services=orm.services,
        policies=orm.policies,
        description=orm.description,
    )


def to_domain_lead(orm: ORMLead) -> Lead:
    return Lead(
        id=orm.id,
        org_id=orm.org_id,
        session_id=orm.session_id,
        name=orm.name,
        phone=orm.phone,
        email=orm.email,
        intent=orm.intent,
        product_interest=orm.product_interest,
        budget=orm.budget,
        created_at=orm.created_at,
    )


def to_domain_customer(orm: ORMCustomer) -> Customer:
    return Customer(
        id=orm.id,
        org_id=orm.org_id,
        phone=orm.phone,
        name=orm.name,
        preferences=orm.preferences,
        notes=orm.notes,
        created_at=orm.created_at,
        updated_at=orm.updated_at,
    )


# ==================== Repositories ====================

class SQLAlchemyBusinessProfileRepository(BusinessProfileRepository):
    def __init__(self, session: AsyncSession):
        self.session = session

    async def get_by_id(self, profile_id: uuid.UUID) -> Optional[BusinessProfile]:
        stmt = select(ORMProfile).where(ORMProfile.id == profile_id)
        result = await self.session.execute(stmt)
        orm = result.scalar_one_or_none()
        return to_domain_profile(orm) if orm else None

    async def get_by_org_id(self, org_id: uuid.UUID) -> Optional[BusinessProfile]:
        stmt = select(ORMProfile).where(ORMProfile.org_id == org_id)
        result = await self.session.execute(stmt)
        orm = result.scalar_one_or_none()
        return to_domain_profile(orm) if orm else None

    async def create(self, profile: BusinessProfile) -> BusinessProfile:
        orm = ORMProfile(
            id=profile.id,
            org_id=profile.org_id,
            name=profile.name,
            business_type=profile.business_type,
            address=profile.address,
            phone=profile.phone,
            email=profile.email,
            website=profile.website,
            working_hours=profile.working_hours,
            services=profile.services,
            policies=profile.policies,
            description=profile.description,
        )
        self.session.add(orm)
        await self.session.commit()
        await self.session.refresh(orm)
        return to_domain_profile(orm)

    async def update(self, profile: BusinessProfile) -> BusinessProfile:
        stmt = select(ORMProfile).where(ORMProfile.org_id == profile.org_id)
        result = await self.session.execute(stmt)
        orm = result.scalar_one_or_none()
        if not orm:
            raise ValueError("Business profile not found for organization")
        
        orm.name = profile.name
        orm.business_type = profile.business_type
        orm.address = profile.address
        orm.phone = profile.phone
        orm.email = profile.email
        orm.website = profile.website
        orm.working_hours = profile.working_hours
        orm.services = profile.services
        orm.policies = profile.policies
        orm.description = profile.description
        
        await self.session.commit()
        await self.session.refresh(orm)
        return to_domain_profile(orm)

    async def delete(self, org_id: uuid.UUID) -> bool:
        stmt = delete(ORMProfile).where(ORMProfile.org_id == org_id)
        result = await self.session.execute(stmt)
        await self.session.commit()
        return (result.rowcount or 0) > 0  # type: ignore[attr-defined]


class SQLAlchemyLeadRepository(LeadRepository):
    def __init__(self, session: AsyncSession):
        self.session = session

    async def get_by_id(self, lead_id: uuid.UUID) -> Optional[Lead]:
        stmt = select(ORMLead).where(ORMLead.id == lead_id)
        result = await self.session.execute(stmt)
        orm = result.scalar_one_or_none()
        return to_domain_lead(orm) if orm else None

    async def get_by_org_id(self, org_id: uuid.UUID, limit: int = 100, offset: int = 0) -> List[Lead]:
        stmt = select(ORMLead).where(ORMLead.org_id == org_id).order_by(ORMLead.created_at.desc()).limit(limit).offset(offset)
        result = await self.session.execute(stmt)
        orms = result.scalars().all()
        return [to_domain_lead(orm) for orm in orms]

    async def get_by_session_id(self, session_id: uuid.UUID) -> List[Lead]:
        stmt = select(ORMLead).where(ORMLead.session_id == session_id)
        result = await self.session.execute(stmt)
        orms = result.scalars().all()
        return [to_domain_lead(orm) for orm in orms]

    async def create(self, lead: Lead) -> Lead:
        orm = ORMLead(
            id=lead.id,
            org_id=lead.org_id,
            session_id=lead.session_id,
            name=lead.name,
            phone=lead.phone,
            email=lead.email,
            intent=lead.intent,
            product_interest=lead.product_interest,
            budget=lead.budget,
            created_at=lead.created_at,
        )
        self.session.add(orm)
        await self.session.commit()
        await self.session.refresh(orm)
        return to_domain_lead(orm)

    async def find_duplicate(self, org_id: uuid.UUID, email: Optional[str], phone: Optional[str]) -> Optional[Lead]:
        if not email and not phone:
            return None
        conditions = [ORMLead.org_id == org_id]
        if email:
            conditions.append(ORMLead.email == email)
        if phone:
            conditions.append(ORMLead.phone == phone)
        from sqlalchemy import or_
        stmt = select(ORMLead).where(or_(*conditions))
        result = await self.session.execute(stmt)
        orm = result.scalar_one_or_none()
        return to_domain_lead(orm) if orm else None

    async def get_scored_leads(self, org_id: uuid.UUID, limit: int = 50, offset: int = 0) -> List[Lead]:
        all_leads = await self.get_by_org_id(org_id, limit=1000, offset=0)
        scored = sorted(all_leads, key=lambda l: _compute_lead_score(l), reverse=True)
        return scored[offset:offset + limit]

    async def count_by_org_id(self, org_id: uuid.UUID) -> int:
        from sqlalchemy import func
        stmt = select(func.count()).select_from(ORMLead).where(ORMLead.org_id == org_id)
        result = await self.session.execute(stmt)
        return result.scalar_one() or 0


def _compute_lead_score(lead: Lead) -> float:
    """
    Compute a lead score from 0.0 to 1.0 based on completeness and value signals.
    """
    score = 0.0
    if lead.name:
        score += 0.2
    if lead.email:
        score += 0.2
    if lead.phone:
        score += 0.15
    if lead.intent:
        score += 0.15
    if lead.product_interest:
        score += 0.15
    if lead.budget is not None and lead.budget > 0:
        score += 0.15
    return min(score, 1.0)


class SQLAlchemyCustomerRepository(CustomerRepository):
    def __init__(self, session: AsyncSession):
        self.session = session

    async def get_by_phone(self, org_id: uuid.UUID, phone: str) -> Optional[Customer]:
        stmt = select(ORMCustomer).where(ORMCustomer.org_id == org_id, ORMCustomer.phone == phone)
        result = await self.session.execute(stmt)
        orm = result.scalar_one_or_none()
        return to_domain_customer(orm) if orm else None

    async def create(self, customer: Customer) -> Customer:
        orm = ORMCustomer(
            id=customer.id,
            org_id=customer.org_id,
            phone=customer.phone,
            name=customer.name,
            preferences=customer.preferences,
            notes=customer.notes,
            created_at=customer.created_at,
            updated_at=customer.updated_at,
        )
        self.session.add(orm)
        await self.session.commit()
        await self.session.refresh(orm)
        return to_domain_customer(orm)

    async def update(self, customer: Customer) -> Customer:
        stmt = select(ORMCustomer).where(ORMCustomer.id == customer.id)
        result = await self.session.execute(stmt)
        orm = result.scalar_one_or_none()
        if not orm:
            raise ValueError("Customer record not found")
        
        orm.name = customer.name
        orm.preferences = customer.preferences
        orm.notes = customer.notes
        orm.updated_at = datetime.datetime.now(datetime.timezone.utc)
        
        await self.session.commit()
        await self.session.refresh(orm)
        return to_domain_customer(orm)

    async def save_or_update(self, customer: Customer) -> Customer:
        existing = await self.get_by_phone(customer.org_id, customer.phone)
        if existing:
            existing.name = customer.name or existing.name
            existing.preferences = customer.preferences or existing.preferences
            existing.notes = customer.notes or existing.notes
            return await self.update(existing)
        else:
            return await self.create(customer)
