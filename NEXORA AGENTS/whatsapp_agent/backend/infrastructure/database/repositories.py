from __future__ import annotations

import logging
from typing import Any, Generic, Optional, Type, TypeVar
from uuid import uuid4

from sqlalchemy import func, select, update as sa_update
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.sql import and_

from backend.infrastructure.database.models import (AuditLogModel, CampaignModel, ConversationModel,
                                                     CustomerModel, DepartmentModel, KnowledgeDocumentModel,
                                                     LeadModel, MessageModel, OrganizationModel,
                                                     PromptTemplateModel, UserModel, WhatsAppAccountModel,
                                                     WorkflowModel)

logger = logging.getLogger(__name__)

ModelType = TypeVar("ModelType")


class Repository(Generic[ModelType]):
    def __init__(self, session: AsyncSession, model_class: Type[ModelType]) -> None:
        self.session = session
        self.model_class = model_class

    async def create(self, **kwargs: Any) -> ModelType:
        instance = self.model_class(**kwargs)
        self.session.add(instance)
        await self.session.flush()
        logger.debug("Created %s with id=%s", self.model_class.__name__, instance.id)
        return instance

    async def get(self, id: str) -> Optional[ModelType]:
        stmt = select(self.model_class).where(self.model_class.id == id)
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def get_by_org(self, org_id: str, id: str) -> Optional[ModelType]:
        stmt = select(self.model_class).where(
            and_(self.model_class.id == id, self.model_class.organization_id == org_id)
        )
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def list_by_org(
        self, org_id: str, page: int = 1, limit: int = 50, sort_by: str = "created_at", sort_desc: bool = True, **filters: Any
    ) -> tuple[list[ModelType], int]:
        conditions = [self.model_class.organization_id == org_id]
        for key, value in filters.items():
            if hasattr(self.model_class, key) and value is not None:
                column = getattr(self.model_class, key)
                if isinstance(value, list):
                    conditions.append(column.in_(value))
                else:
                    conditions.append(column == value)

        count_stmt = select(func.count()).select_from(self.model_class).where(and_(*conditions))
        count_result = await self.session.execute(count_stmt)
        total = count_result.scalar() or 0

        sort_column = getattr(self.model_class, sort_by, self.model_class.created_at)
        order = sort_column.desc() if sort_desc else sort_column.asc()

        stmt = (
            select(self.model_class)
            .where(and_(*conditions))
            .order_by(order)
            .offset((page - 1) * limit)
            .limit(limit)
        )
        result = await self.session.execute(stmt)
        items = list(result.scalars().all())
        return items, total

    async def update(self, id: str, **kwargs: Any) -> Optional[ModelType]:
        stmt = (
            sa_update(self.model_class)
            .where(self.model_class.id == id)
            .values(**kwargs)
            .execution_options(synchronize_session="fetch")
        )
        await self.session.execute(stmt)
        await self.session.flush()
        return await self.get(id)

    async def delete(self, id: str) -> bool:
        instance = await self.get(id)
        if instance is None:
            return False
        await self.session.delete(instance)
        await self.session.flush()
        logger.debug("Deleted %s with id=%s", self.model_class.__name__, id)
        return True

    async def count_by_org(self, org_id: str, **filters: Any) -> int:
        conditions = [self.model_class.organization_id == org_id]
        for key, value in filters.items():
            if hasattr(self.model_class, key) and value is not None:
                conditions.append(getattr(self.model_class, key) == value)
        stmt = select(func.count()).select_from(self.model_class).where(and_(*conditions))
        result = await self.session.execute(stmt)
        return result.scalar() or 0


class OrganizationRepository(Repository[OrganizationModel]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, OrganizationModel)

    async def find_by_slug(self, slug: str) -> Optional[OrganizationModel]:
        stmt = select(OrganizationModel).where(OrganizationModel.slug == slug)
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()


class WhatsAppAccountRepository(Repository[WhatsAppAccountModel]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, WhatsAppAccountModel)

    async def find_by_phone(self, org_id: str, phone_number: str) -> Optional[WhatsAppAccountModel]:
        stmt = select(WhatsAppAccountModel).where(
            and_(
                WhatsAppAccountModel.organization_id == org_id,
                WhatsAppAccountModel.phone_number == phone_number,
            )
        )
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def list_connected(self, org_id: str) -> list[WhatsAppAccountModel]:
        stmt = select(WhatsAppAccountModel).where(
            and_(
                WhatsAppAccountModel.organization_id == org_id,
                WhatsAppAccountModel.status == "connected",
                WhatsAppAccountModel.is_active == True,
            )
        )
        result = await self.session.execute(stmt)
        return list(result.scalars().all())


class ConversationRepository(Repository[ConversationModel]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, ConversationModel)

    async def find_by_phone(self, org_id: str, phone: str) -> Optional[ConversationModel]:
        stmt = select(ConversationModel).where(
            and_(
                ConversationModel.organization_id == org_id,
                ConversationModel.customer_phone == phone,
                ConversationModel.status.in_(["active", "paused"]),
            )
        ).order_by(ConversationModel.updated_at.desc()).limit(1)
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def find_by_phone_and_account(
        self, org_id: str, account_id: str, phone: str
    ) -> Optional[ConversationModel]:
        stmt = select(ConversationModel).where(
            and_(
                ConversationModel.organization_id == org_id,
                ConversationModel.whatsapp_account_id == account_id,
                ConversationModel.customer_phone == phone,
                ConversationModel.status.in_(["active", "paused"]),
            )
        ).order_by(ConversationModel.updated_at.desc()).limit(1)
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def list_active(self, org_id: str, page: int = 1, limit: int = 50) -> tuple[list[ConversationModel], int]:
        return await self.list_by_org(org_id, page=page, limit=limit, status="active", sort_by="last_message_at", sort_desc=True)

    async def mark_unread(self, conversation_id: str) -> None:
        await self.update(conversation_id, is_unread=True)


class MessageRepository(Repository[MessageModel]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, MessageModel)

    async def list_by_conversation(
        self, conversation_id: str, page: int = 1, limit: int = 50
    ) -> tuple[list[MessageModel], int]:
        conditions = [MessageModel.conversation_id == conversation_id]
        count_stmt = select(func.count()).select_from(MessageModel).where(and_(*conditions))
        count_result = await self.session.execute(count_stmt)
        total = count_result.scalar() or 0

        stmt = (
            select(MessageModel)
            .where(and_(*conditions))
            .order_by(MessageModel.created_at.asc())
            .offset((page - 1) * limit)
            .limit(limit)
        )
        result = await self.session.execute(stmt)
        items = list(result.scalars().all())
        return items, total

    async def count_by_conversation(self, conversation_id: str) -> int:
        stmt = select(func.count()).select_from(MessageModel).where(
            MessageModel.conversation_id == conversation_id
        )
        result = await self.session.execute(stmt)
        return result.scalar() or 0

    async def get_last_message(self, conversation_id: str) -> Optional[MessageModel]:
        stmt = (
            select(MessageModel)
            .where(MessageModel.conversation_id == conversation_id)
            .order_by(MessageModel.created_at.desc())
            .limit(1)
        )
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()


class LeadRepository(Repository[LeadModel]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, LeadModel)

    async def find_by_phone(self, org_id: str, phone: str) -> Optional[LeadModel]:
        stmt = select(LeadModel).where(
            and_(
                LeadModel.organization_id == org_id,
                LeadModel.customer_phone == phone,
            )
        ).order_by(LeadModel.updated_at.desc()).limit(1)
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def find_active_by_phone(self, org_id: str, phone: str) -> Optional[LeadModel]:
        stmt = select(LeadModel).where(
            and_(
                LeadModel.organization_id == org_id,
                LeadModel.customer_phone == phone,
                LeadModel.status.notin_(["converted", "lost", "disqualified"]),
            )
        ).order_by(LeadModel.updated_at.desc()).limit(1)
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def list_by_pipeline_stage(
        self, org_id: str, stage: str, page: int = 1, limit: int = 50
    ) -> tuple[list[LeadModel], int]:
        return await self.list_by_org(org_id, page=page, limit=limit, pipeline_stage=stage, sort_by="score", sort_desc=True)


class CustomerRepository(Repository[CustomerModel]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, CustomerModel)

    async def find_by_phone(self, org_id: str, phone: str) -> Optional[CustomerModel]:
        stmt = select(CustomerModel).where(
            and_(CustomerModel.organization_id == org_id, CustomerModel.phone == phone)
        )
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()


class KnowledgeDocumentRepository(Repository[KnowledgeDocumentModel]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, KnowledgeDocumentModel)

    async def search_by_tags(self, org_id: str, tags: list[str], page: int = 1, limit: int = 50) -> tuple[list[KnowledgeDocumentModel], int]:
        conditions = [KnowledgeDocumentModel.organization_id == org_id]
        stmt = select(KnowledgeDocumentModel).where(and_(*conditions))
        result = await self.session.execute(stmt)
        all_docs = list(result.scalars().all())
        filtered = [d for d in all_docs if any(t in (d.tags or []) for t in tags)]
        total = len(filtered)
        start = (page - 1) * limit
        items = filtered[start:start + limit]
        return items, total


class WorkflowRepository(Repository[WorkflowModel]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, WorkflowModel)

    async def list_active_by_trigger(self, org_id: str, trigger_type: str) -> list[WorkflowModel]:
        stmt = select(WorkflowModel).where(
            and_(
                WorkflowModel.organization_id == org_id,
                WorkflowModel.status == "active",
                WorkflowModel.trigger_type == trigger_type,
            )
        )
        result = await self.session.execute(stmt)
        return list(result.scalars().all())

    async def increment_execution_count(self, workflow_id: str) -> None:
        await self.update(workflow_id, execution_count=WorkflowModel.execution_count + 1)


class CampaignRepository(Repository[CampaignModel]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, CampaignModel)

    async def list_scheduled(self) -> list[CampaignModel]:
        stmt = select(CampaignModel).where(
            and_(
                CampaignModel.status == "scheduled",
                CampaignModel.scheduled_at.isnot(None),
            )
        )
        result = await self.session.execute(stmt)
        return list(result.scalars().all())

    async def increment_sent(self, campaign_id: str) -> None:
        await self.update(campaign_id, sent_count=CampaignModel.sent_count + 1)

    async def increment_delivered(self, campaign_id: str) -> None:
        await self.update(campaign_id, delivered_count=CampaignModel.delivered_count + 1)


class AuditLogRepository(Repository[AuditLogModel]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, AuditLogModel)

    async def list_by_user(self, user_id: str, page: int = 1, limit: int = 50) -> tuple[list[AuditLogModel], int]:
        conditions = [AuditLogModel.user_id == user_id]
        count_stmt = select(func.count()).select_from(AuditLogModel).where(and_(*conditions))
        count_result = await self.session.execute(count_stmt)
        total = count_result.scalar() or 0
        stmt = (
            select(AuditLogModel)
            .where(and_(*conditions))
            .order_by(AuditLogModel.created_at.desc())
            .offset((page - 1) * limit)
            .limit(limit)
        )
        result = await self.session.execute(stmt)
        items = list(result.scalars().all())
        return items, total


class UserRepository(Repository[UserModel]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, UserModel)

    async def find_by_email(self, org_id: str, email: str) -> Optional[UserModel]:
        stmt = select(UserModel).where(
            and_(UserModel.organization_id == org_id, UserModel.email == email)
        )
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def list_available_agents(self, org_id: str) -> list[UserModel]:
        stmt = select(UserModel).where(
            and_(
                UserModel.organization_id == org_id,
                UserModel.is_active == True,
                UserModel.is_available == True,
                UserModel.role.in_(["agent", "supervisor"]),
            )
        )
        result = await self.session.execute(stmt)
        return list(result.scalars().all())


class DepartmentRepository(Repository[DepartmentModel]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, DepartmentModel)

    async def find_by_name(self, org_id: str, name: str) -> Optional[DepartmentModel]:
        stmt = select(DepartmentModel).where(
            and_(DepartmentModel.organization_id == org_id, DepartmentModel.name == name)
        )
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()


class PromptTemplateRepository(Repository[PromptTemplateModel]):
    def __init__(self, session: AsyncSession) -> None:
        super().__init__(session, PromptTemplateModel)

    async def find_active_by_name(self, org_id: str, name: str) -> Optional[PromptTemplateModel]:
        stmt = select(PromptTemplateModel).where(
            and_(
                PromptTemplateModel.organization_id == org_id,
                PromptTemplateModel.name == name,
                PromptTemplateModel.is_active == True,
            )
        )
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()
