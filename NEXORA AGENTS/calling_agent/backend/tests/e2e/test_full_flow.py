from __future__ import annotations

import asyncio
from datetime import datetime
from decimal import Decimal
from typing import AsyncGenerator
from uuid import UUID, uuid4

import pytest
import pytest_asyncio
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from backend.domain.entities import Call, Campaign, Lead, Organization, Recording
from backend.domain.enums import CallDirection, CallDisposition, CallStatus, CampaignStatus, CampaignType, LeadStatus

pytestmark = pytest.mark.asyncio

TEST_DATABASE_URL = "sqlite+aiosqlite://"


@pytest_asyncio.fixture
async def db_session() -> AsyncGenerator[AsyncSession, None]:
    engine = create_async_engine(TEST_DATABASE_URL, echo=False)
    async with engine.begin() as conn:
        from backend.infrastructure.database import Base
        await conn.run_sync(Base.metadata.create_all)

    session_factory = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
    async with session_factory() as session:
        yield session

    await engine.dispose()


class FullFlowMock:
    def __init__(self):
        self.organizations: dict[str, Organization] = {}
        self.campaigns: dict[str, Campaign] = {}
        self.leads: dict[str, Lead] = {}
        self.calls: dict[str, Call] = {}
        self.recordings: dict[str, Recording] = {}
        self.analytics: dict = {
            "total_calls": 0,
            "total_duration": 0,
            "total_cost": Decimal("0.00"),
            "total_answered": 0,
            "total_converted": 0,
        }

    def create_organization(self, name: str, slug: str) -> Organization:
        org = Organization(name=name, slug=slug)
        self.organizations[str(org.id)] = org
        return org

    def create_campaign(self, org_id: UUID, name: str, type: str) -> Campaign:
        campaign = Campaign(
            organization_id=org_id,
            name=name,
            type=type,
        )
        self.campaigns[str(campaign.id)] = campaign
        return campaign

    def add_lead(self, org_id: UUID, campaign_id: UUID, phone: str, first_name: str | None = None) -> Lead:
        lead = Lead(
            organization_id=org_id,
            campaign_id=campaign_id,
            phone=phone,
            first_name=first_name,
            status=LeadStatus.new.value,
        )
        self.leads[str(lead.id)] = lead
        return lead

    def start_campaign(self, campaign_id: UUID) -> Campaign:
        campaign = self.campaigns[str(campaign_id)]
        campaign.status = CampaignStatus.active.value
        return campaign

    def simulate_call(self, lead_id: UUID, campaign_id: UUID, org_id: UUID) -> Call:
        lead = self.leads[str(lead_id)]
        call = Call(
            organization_id=org_id,
            campaign_id=campaign_id,
            lead_id=lead_id,
            direction=CallDirection.outbound.value,
            from_number="+15551234567",
            to_number=lead.phone,
            status=CallStatus.in_progress.value,
            started_at=datetime.utcnow(),
        )
        self.calls[str(call.id)] = call
        return call

    def complete_call(self, call_id: UUID, disposition: str, duration: int = 60) -> Call:
        call = self.calls[str(call_id)]
        call.status = CallStatus.completed.value
        call.disposition = disposition
        call.duration_seconds = duration
        call.ended_at = datetime.utcnow()

        lead = self.leads.get(str(call.lead_id))
        if lead:
            lead.last_called_at = call.ended_at
            lead.call_count += 1
            lead.last_disposition = disposition
            if disposition in (CallDisposition.interested.value,
                               CallDisposition.sale_made.value,
                               CallDisposition.appointment_set.value):
                lead.status = LeadStatus.qualified.value
            elif disposition == CallDisposition.not_interested.value:
                lead.status = LeadStatus.lost.value

        campaign = self.campaigns.get(str(call.campaign_id))
        if campaign:
            campaign.total_calls += 1
            if call.status == CallStatus.completed.value:
                campaign.total_answered += 1
            if disposition in (CallDisposition.interested.value, CallDisposition.sale_made.value, CallDisposition.appointment_set.value):
                campaign.total_converted += 1

        self.analytics["total_calls"] += 1
        self.analytics["total_duration"] += duration
        self.analytics["total_answered"] += 1
        if disposition in (CallDisposition.interested.value, CallDisposition.sale_made.value, CallDisposition.appointment_set.value):
            self.analytics["total_converted"] += 1

        return call

    def get_analytics(self) -> dict:
        return dict(self.analytics)


@pytest_asyncio.fixture
def flow():
    return FullFlowMock()


class TestFullFlow:
    async def test_full_campaign_flow(self, flow):
        org = flow.create_organization("Acme Corp", "acme-corp")
        assert org.name == "Acme Corp"
        assert org.status == "active"

        campaign = flow.create_campaign(org.id, "Q3 Outreach", CampaignType.cold_calling.value)
        assert campaign.status == CampaignStatus.draft.value

        lead = flow.add_lead(org.id, campaign.id, "+1234567890", "John Doe")
        assert lead.phone == "+1234567890"
        assert lead.status == LeadStatus.new.value

        flow.start_campaign(campaign.id)
        assert campaign.status == CampaignStatus.active.value

        call = flow.simulate_call(lead.id, campaign.id, org.id)
        assert call.status == CallStatus.in_progress.value
        assert call.direction == CallDirection.outbound.value
        assert call.lead_id == lead.id

        completed = flow.complete_call(call.id, CallDisposition.interested.value, duration=120)
        assert completed.status == CallStatus.completed.value
        assert completed.disposition == CallDisposition.interested.value
        assert completed.duration_seconds == 120

        assert lead.last_disposition == CallDisposition.interested.value
        assert lead.call_count == 1
        assert lead.status == LeadStatus.qualified.value

        analytics = flow.get_analytics()
        assert analytics["total_calls"] == 1
        assert analytics["total_duration"] == 120
        assert analytics["total_answered"] == 1
        assert analytics["total_converted"] == 1

    async def test_campaign_with_multiple_leads(self, flow):
        org = flow.create_organization("Test Corp", "test-corp")
        campaign = flow.create_campaign(org.id, "Campaign", CampaignType.follow_up.value)
        flow.start_campaign(campaign.id)

        leads = []
        for i in range(3):
            lead = flow.add_lead(org.id, campaign.id, f"+1{i:010d}", f"User {i}")
            leads.append(lead)
            call = flow.simulate_call(lead.id, campaign.id, org.id)
            dispositions = [CallDisposition.sale_made.value,
                            CallDisposition.not_interested.value,
                            CallDisposition.call_back.value]
            flow.complete_call(call.id, dispositions[i], duration=60 * (i + 1))

        analytics = flow.get_analytics()
        assert analytics["total_calls"] == 3
        assert analytics["total_duration"] == 360
        assert analytics["total_answered"] == 3
        assert analytics["total_converted"] == 1

        assert campaign.total_calls == 3
        assert campaign.total_answered == 3
        assert campaign.total_converted == 1

    async def test_lead_not_interested(self, flow):
        org = flow.create_organization("Org", "org")
        campaign = flow.create_campaign(org.id, "Campaign", CampaignType.cold_calling.value)
        flow.start_campaign(campaign.id)
        lead = flow.add_lead(org.id, campaign.id, "+1234567890", "John")
        call = flow.simulate_call(lead.id, campaign.id, org.id)
        flow.complete_call(call.id, CallDisposition.not_interested.value, duration=45)

        assert lead.status == LeadStatus.lost.value
        analytics = flow.get_analytics()
        assert analytics["total_converted"] == 0

    async def test_lead_appointment_set(self, flow):
        org = flow.create_organization("Org", "org")
        campaign = flow.create_campaign(org.id, "Campaign", CampaignType.appointment_reminder.value)
        flow.start_campaign(campaign.id)
        lead = flow.add_lead(org.id, campaign.id, "+1234567890", "Jane")
        call = flow.simulate_call(lead.id, campaign.id, org.id)
        flow.complete_call(call.id, CallDisposition.appointment_set.value, duration=180)

        assert lead.status == LeadStatus.qualified.value
        assert campaign.total_converted == 1

    async def test_campaign_with_no_answers(self, flow):
        org = flow.create_organization("Org", "org")
        campaign = flow.create_campaign(org.id, "Campaign", CampaignType.cold_calling.value)
        flow.start_campaign(campaign.id)
        lead = flow.add_lead(org.id, campaign.id, "+1234567890", "Bob")
        call = flow.simulate_call(lead.id, campaign.id, org.id)
        flow.complete_call(call.id, CallDisposition.no_answer.value, duration=0)

        assert campaign.total_answered == 1
        assert campaign.total_converted == 0
        assert lead.last_disposition == CallDisposition.no_answer.value

    async def test_sale_made_tracking(self, flow):
        org = flow.create_organization("Org", "org")
        campaign = flow.create_campaign(org.id, "Campaign", CampaignType.cold_calling.value)
        flow.start_campaign(campaign.id)
        lead = flow.add_lead(org.id, campaign.id, "+1234567890", "Alice")
        call = flow.simulate_call(lead.id, campaign.id, org.id)
        flow.complete_call(call.id, CallDisposition.sale_made.value, duration=300)

        assert campaign.total_converted == 1
        assert lead.status == LeadStatus.qualified.value

    async def test_analytics_accumulation(self, flow):
        org = flow.create_organization("Org", "org")
        campaign = flow.create_campaign(org.id, "Campaign", CampaignType.cold_calling.value)
        flow.start_campaign(campaign.id)

        for i in range(5):
            lead = flow.add_lead(org.id, campaign.id, f"+1{i:010d}", f"User {i}")
            call = flow.simulate_call(lead.id, campaign.id, org.id)
            flow.complete_call(call.id, CallDisposition.completed.value, duration=30)

        analytics = flow.get_analytics()
        assert analytics["total_calls"] == 5
        assert analytics["total_duration"] == 150

    async def test_campaign_metrics(self, flow):
        org = flow.create_organization("Org", "org")
        campaign = flow.create_campaign(org.id, "Campaign", CampaignType.cold_calling.value)
        flow.start_campaign(campaign.id)

        dispositions = [CallDisposition.sale_made.value,
                        CallDisposition.interested.value,
                        CallDisposition.no_answer.value,
                        CallDisposition.not_interested.value]

        for i, disp in enumerate(dispositions):
            lead = flow.add_lead(org.id, campaign.id, f"+1{i:010d}", f"User {i}")
            call = flow.simulate_call(lead.id, campaign.id, org.id)
            flow.complete_call(call.id, disp, duration=60)

        assert campaign.total_calls == 4
        assert campaign.total_answered == 4
        assert campaign.total_converted == 2

        analytics = flow.get_analytics()
        assert analytics["total_calls"] == 4
        assert analytics["total_converted"] == 2
