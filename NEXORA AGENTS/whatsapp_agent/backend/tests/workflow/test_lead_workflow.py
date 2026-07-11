from datetime import datetime, timezone
from uuid import uuid4

import pytest
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from backend.domain.entities import Lead, Message, Organization, WhatsAppAccount
from backend.domain.enums import LeadStatus, MessageDirection, PipelineStage


@pytest.fixture
def event_loop():
    import asyncio
    loop = asyncio.new_event_loop()
    yield loop
    loop.close()


@pytest.fixture
async def db_engine():
    from backend.infrastructure.database.models import Base
    engine = create_async_engine("sqlite+aiosqlite://", echo=False)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield engine
    await engine.dispose()


@pytest.fixture
async def db_session(db_engine):
    session_factory = async_sessionmaker(db_engine, class_=AsyncSession, expire_on_commit=False)
    async with session_factory() as session:
        yield session


@pytest.fixture
def sample_organization():
    return Organization(name="Test Org", slug="test-org")


@pytest.fixture
def sample_whatsapp_account(sample_organization):
    return WhatsAppAccount(organization_id=sample_organization.id, phone_number="+15551234567")


@pytest.fixture
def sample_messages(sample_organization, sample_whatsapp_account):
    conv_id = uuid4()
    now = datetime.now(timezone.utc)
    return [
        Message(
            organization_id=sample_organization.id,
            conversation_id=conv_id,
            direction=MessageDirection.inbound.value,
            from_phone="+15559876543",
            to_phone=sample_whatsapp_account.phone_number,
            content="Hi, I'm interested in your premium plan. What are the pricing options?",
            created_at=now,
        ),
        Message(
            organization_id=sample_organization.id,
            conversation_id=conv_id,
            direction=MessageDirection.outbound.value,
            from_phone=sample_whatsapp_account.phone_number,
            to_phone="+15559876543",
            content="Great! Our premium plan starts at $49/month. Would you like more details?",
            created_at=now,
        ),
        Message(
            organization_id=sample_organization.id,
            conversation_id=conv_id,
            direction=MessageDirection.inbound.value,
            from_phone="+15559876543",
            to_phone=sample_whatsapp_account.phone_number,
            content="Yes, please! I'd like to sign up. Can you help me with the process?",
            created_at=now,
        ),
    ]


@pytest.mark.asyncio
class TestLeadQualificationWorkflow:
    async def test_lead_creation_from_incoming_message(self, db_session, sample_messages):
        from backend.infrastructure.database.models import LeadModel

        incoming_msg = sample_messages[0]
        lead = LeadModel(
            id=str(uuid4()),
            organization_id=str(incoming_msg.organization_id),
            conversation_id=str(incoming_msg.conversation_id),
            customer_phone=incoming_msg.from_phone,
            status=LeadStatus.new.value,
            pipeline_stage=PipelineStage.new_lead.value,
            source="whatsapp",
        )
        db_session.add(lead)
        await db_session.commit()
        await db_session.refresh(lead)

        assert lead is not None
        assert lead.status == "new"
        assert lead.customer_phone == "+15559876543"
        assert lead.source == "whatsapp"
        assert lead.pipeline_stage == "new_lead"

    async def test_lead_creation_with_correct_status(self, db_session, sample_messages):
        from backend.infrastructure.database.models import LeadModel

        incoming_msg = sample_messages[0]
        lead = LeadModel(
            id=str(uuid4()),
            organization_id=str(incoming_msg.organization_id),
            conversation_id=str(incoming_msg.conversation_id),
            customer_phone=incoming_msg.from_phone,
            customer_name="Interested Customer",
            status=LeadStatus.new.value,
            pipeline_stage=PipelineStage.new_lead.value,
            source="whatsapp",
        )
        db_session.add(lead)
        await db_session.commit()

        assert lead.status == LeadStatus.new.value
        assert lead.customer_name == "Interested Customer"

    async def test_lead_qualification_workflow(self, db_session, sample_messages):
        from backend.infrastructure.database.models import LeadModel

        incoming_msg = sample_messages[0]
        lead = LeadModel(
            id=str(uuid4()),
            organization_id=str(incoming_msg.organization_id),
            conversation_id=str(incoming_msg.conversation_id),
            customer_phone=incoming_msg.from_phone,
            status=LeadStatus.new.value,
            pipeline_stage=PipelineStage.new_lead.value,
            score=0.0,
        )
        db_session.add(lead)
        await db_session.commit()

        lead.status = LeadStatus.qualified.value
        lead.pipeline_stage = PipelineStage.qualified.value
        lead.score = 75.0
        db_session.add(lead)
        await db_session.commit()
        await db_session.refresh(lead)

        assert lead.status == "qualified"
        assert lead.pipeline_stage == "qualified"
        assert lead.score == 75.0

    async def test_lead_qualification_workflow_full_pipeline(self, db_session, sample_messages):
        from backend.infrastructure.database.models import LeadModel

        incoming_msg = sample_messages[0]
        lead = LeadModel(
            id=str(uuid4()),
            organization_id=str(incoming_msg.organization_id),
            conversation_id=str(incoming_msg.conversation_id),
            customer_phone=incoming_msg.from_phone,
            status=LeadStatus.new.value,
            pipeline_stage=PipelineStage.new_lead.value,
        )
        db_session.add(lead)
        await db_session.commit()

        stages = [
            PipelineStage.contacted,
            PipelineStage.qualified,
            PipelineStage.proposal,
            PipelineStage.negotiation,
            PipelineStage.closed_won,
        ]
        for stage in stages:
            lead.pipeline_stage = stage.value
            lead.status = (
                LeadStatus.converted.value if stage == PipelineStage.closed_won
                else LeadStatus.qualified.value if stage == PipelineStage.qualified
                else LeadStatus.new.value
            )
            db_session.add(lead)
            await db_session.commit()
            await db_session.refresh(lead)

        assert lead.pipeline_stage == "closed_won"
        assert lead.status == "converted"

    async def test_assign_salesperson_step(self, db_session, sample_messages):
        from backend.infrastructure.database.models import LeadModel, UserModel

        org_id = str(sample_messages[0].organization_id)
        salesperson = UserModel(
            id=str(uuid4()),
            organization_id=org_id,
            email="sales@test.com",
            name="Sales Rep",
            role="agent",
        )
        db_session.add(salesperson)
        await db_session.commit()

        incoming_msg = sample_messages[0]
        lead = LeadModel(
            id=str(uuid4()),
            organization_id=org_id,
            conversation_id=str(incoming_msg.conversation_id),
            customer_phone=incoming_msg.from_phone,
            status=LeadStatus.qualified.value,
        )
        db_session.add(lead)
        await db_session.commit()

        lead.assigned_to = salesperson.id
        db_session.add(lead)
        await db_session.commit()
        await db_session.refresh(lead)

        assert str(lead.assigned_to) == salesperson.id

    async def test_disqualify_lead_workflow(self, db_session, sample_messages):
        from backend.infrastructure.database.models import LeadModel

        incoming_msg = sample_messages[0]
        lead = LeadModel(
            id=str(uuid4()),
            organization_id=str(incoming_msg.organization_id),
            conversation_id=str(incoming_msg.conversation_id),
            customer_phone=incoming_msg.from_phone,
            status=LeadStatus.new.value,
        )
        db_session.add(lead)
        await db_session.commit()

        lead.status = LeadStatus.disqualified.value
        lead.pipeline_stage = PipelineStage.closed_lost.value
        db_session.add(lead)
        await db_session.commit()
        await db_session.refresh(lead)

        assert lead.status == "disqualified"
        assert lead.pipeline_stage == "closed_lost"

    async def test_lead_with_multiple_messages_creates_lead(self, db_session, sample_messages):
        from backend.infrastructure.database.models import LeadModel

        incoming_msg = sample_messages[0]
        lead = LeadModel(
            id=str(uuid4()),
            organization_id=str(incoming_msg.organization_id),
            conversation_id=str(incoming_msg.conversation_id),
            customer_phone=incoming_msg.from_phone,
            status=LeadStatus.new.value,
        )
        db_session.add(lead)
        await db_session.commit()

        from sqlalchemy import select
        result = await db_session.execute(
            select(LeadModel).where(LeadModel.conversation_id == str(incoming_msg.conversation_id))
        )
        found = result.scalar_one_or_none()
        assert found is not None
        assert found.customer_phone == "+15559876543"
