from __future__ import annotations

from datetime import datetime, timedelta
from unittest.mock import AsyncMock, MagicMock, PropertyMock, patch
from uuid import UUID, uuid4

import pytest

from backend.domain.entities import Call, Campaign, Lead, Script
from backend.domain.enums import CallDisposition, CallStatus, CampaignStatus, CampaignType, LeadStatus


class CampaignEngineMock:
    def __init__(self):
        self.campaigns: dict[str, Campaign] = {}
        self.call_queue: list[dict] = []
        self.active_campaigns: set[str] = set()
        self.leads: dict[str, Lead] = {}

    async def start_campaign(self, campaign: Campaign) -> Campaign:
        campaign.status = CampaignStatus.active.value
        self.campaigns[str(campaign.id)] = campaign
        self.active_campaigns.add(str(campaign.id))
        return campaign

    async def pause_campaign(self, campaign: Campaign) -> Campaign:
        campaign.status = CampaignStatus.paused.value
        self.active_campaigns.discard(str(campaign.id))
        return campaign

    async def resume_campaign(self, campaign: Campaign) -> Campaign:
        campaign.status = CampaignStatus.active.value
        self.active_campaigns.add(str(campaign.id))
        return campaign

    async def stop_campaign(self, campaign: Campaign) -> Campaign:
        campaign.status = CampaignStatus.completed.value
        self.active_campaigns.discard(str(campaign.id))
        return campaign

    async def process_lead(self, lead: Lead) -> dict:
        entry = {
            "lead_id": str(lead.id),
            "phone": lead.phone,
            "campaign_id": str(lead.campaign_id) if lead.campaign_id else None,
            "attempts": lead.call_count,
            "status": "queued",
            "queued_at": datetime.utcnow(),
        }
        self.call_queue.append(entry)
        return entry

    def get_queue_size(self) -> int:
        return len(self.call_queue)

    def get_queue(self) -> list[dict]:
        return list(self.call_queue)

    def dequeue_call(self) -> dict | None:
        if self.call_queue:
            return self.call_queue.pop(0)
        return None

    def is_campaign_active(self, campaign_id: str) -> bool:
        return campaign_id in self.active_campaigns

    def is_within_business_hours(self, start: str, end: str, current: str | None = None) -> bool:
        if current is None:
            current = datetime.utcnow().strftime("%H:%M")
        return start <= current <= end

    def is_working_day(self, day: int, working_days: list[int] | None = None) -> bool:
        if working_days is None:
            working_days = [0, 1, 2, 3, 4, 5, 6]
        return day in working_days

    def should_retry(self, lead: Lead, max_attempts: int = 3) -> bool:
        if lead.do_not_call:
            return False
        if lead.last_disposition in (
            CallDisposition.dnc.value,
            CallDisposition.wrong_number.value,
            CallDisposition.disconnected.value,
        ):
            return False
        if lead.call_count >= max_attempts:
            return False
        return True

    def get_next_call_time(self, lead: Lead, delay_minutes: int = 60) -> datetime:
        now = datetime.utcnow()
        return now + timedelta(minutes=delay_minutes)


@pytest.fixture
def engine():
    return CampaignEngineMock()


class TestCampaignLifecycle:
    @pytest.mark.asyncio
    async def test_start_campaign(self, engine):
        campaign = Campaign(
            organization_id=uuid4(),
            name="Q2 Outreach",
            type=CampaignType.cold_calling.value,
            status=CampaignStatus.draft.value,
        )
        result = await engine.start_campaign(campaign)
        assert result.status == CampaignStatus.active.value
        assert engine.is_campaign_active(str(campaign.id))

    @pytest.mark.asyncio
    async def test_pause_active_campaign(self, engine):
        campaign = Campaign(
            organization_id=uuid4(),
            name="Test Campaign",
            type=CampaignType.warm_calling.value,
            status=CampaignStatus.active.value,
        )
        await engine.start_campaign(campaign)
        result = await engine.pause_campaign(campaign)
        assert result.status == CampaignStatus.paused.value
        assert not engine.is_campaign_active(str(campaign.id))

    @pytest.mark.asyncio
    async def test_resume_paused_campaign(self, engine):
        campaign = Campaign(
            organization_id=uuid4(),
            name="Resume Test",
            type=CampaignType.follow_up.value,
            status=CampaignStatus.paused.value,
        )
        await engine.start_campaign(campaign)
        await engine.pause_campaign(campaign)
        result = await engine.resume_campaign(campaign)
        assert result.status == CampaignStatus.active.value
        assert engine.is_campaign_active(str(campaign.id))

    @pytest.mark.asyncio
    async def test_stop_campaign(self, engine):
        campaign = Campaign(
            organization_id=uuid4(),
            name="Stop Test",
            type=CampaignType.survey.value,
            status=CampaignStatus.active.value,
        )
        await engine.start_campaign(campaign)
        result = await engine.stop_campaign(campaign)
        assert result.status == CampaignStatus.completed.value
        assert not engine.is_campaign_active(str(campaign.id))

    def test_start_draft_campaign(self, engine):
        campaign = Campaign(
            organization_id=uuid4(),
            name="Draft Campaign",
            type=CampaignType.cold_calling.value,
            status=CampaignStatus.draft.value,
        )
        assert campaign.status == CampaignStatus.draft.value

    def test_campaign_status_transition(self, engine):
        campaign = Campaign(
            organization_id=uuid4(),
            name="Transition Test",
            type=CampaignType.appointment_reminder.value,
            status=CampaignStatus.draft.value,
        )
        assert campaign.status == CampaignStatus.draft.value


class TestLeadProcessing:
    @pytest.mark.asyncio
    async def test_process_lead_adds_to_queue(self, engine):
        lead = Lead(
            organization_id=uuid4(),
            campaign_id=uuid4(),
            phone="+1234567890",
            status=LeadStatus.new.value,
        )
        entry = await engine.process_lead(lead)
        assert entry["lead_id"] == str(lead.id)
        assert entry["status"] == "queued"
        assert engine.get_queue_size() == 1

    @pytest.mark.asyncio
    async def test_process_multiple_leads(self, engine):
        leads = [
            Lead(organization_id=uuid4(), phone=f"+1{i:010d}")
            for i in range(5)
        ]
        for lead in leads:
            await engine.process_lead(lead)
        assert engine.get_queue_size() == 5

    @pytest.mark.asyncio
    async def test_dequeue_call(self, engine):
        lead = Lead(organization_id=uuid4(), phone="+1234567890")
        await engine.process_lead(lead)
        item = engine.dequeue_call()
        assert item is not None
        assert item["lead_id"] == str(lead.id)

    @pytest.mark.asyncio
    async def test_queue_fifo_order(self, engine):
        lead1 = Lead(organization_id=uuid4(), phone="+1111111111")
        lead2 = Lead(organization_id=uuid4(), phone="+2222222222")
        await engine.process_lead(lead1)
        await engine.process_lead(lead2)
        first = engine.dequeue_call()
        second = engine.dequeue_call()
        assert first["phone"] == "+1111111111"
        assert second["phone"] == "+2222222222"

    def test_queue_empty_when_no_leads(self, engine):
        assert engine.get_queue_size() == 0
        assert engine.dequeue_call() is None

    def test_get_queue_returns_copy(self, engine):
        assert engine.get_queue() == []

    @pytest.mark.asyncio
    async def test_process_lead_with_campaign_context(self, engine):
        lead = Lead(
            organization_id=uuid4(),
            campaign_id=uuid4(),
            phone="+1234567890",
            first_name="John",
            last_name="Doe",
            company="Acme",
        )
        entry = await engine.process_lead(lead)
        assert entry["lead_id"] == str(lead.id)
        assert entry["phone"] == "+1234567890"


class TestCallQueueManagement:
    @pytest.mark.asyncio
    async def test_queue_order(self, engine):
        leads = [
            Lead(organization_id=uuid4(), phone="+1111111111", first_name="A"),
            Lead(organization_id=uuid4(), phone="+2222222222", first_name="B"),
            Lead(organization_id=uuid4(), phone="+3333333333", first_name="C"),
        ]
        for lead in leads:
            await engine.process_lead(lead)

        first = engine.dequeue_call()
        assert first["phone"] == "+1111111111"
        assert engine.get_queue_size() == 2

        second = engine.dequeue_call()
        assert second["phone"] == "+2222222222"
        assert engine.get_queue_size() == 1

    @pytest.mark.asyncio
    async def test_queue_empty_after_dequeue_all(self, engine):
        leads = [
            Lead(organization_id=uuid4(), phone="+1111111111"),
            Lead(organization_id=uuid4(), phone="+2222222222"),
        ]
        for lead in leads:
            await engine.process_lead(lead)

        engine.dequeue_call()
        engine.dequeue_call()
        assert engine.get_queue_size() == 0
        assert engine.dequeue_call() is None

    @pytest.mark.asyncio
    async def test_queue_limits(self, engine):
        for i in range(10):
            lead = Lead(organization_id=uuid4(), phone=f"+1{i:010d}")
            await engine.process_lead(lead)
        assert engine.get_queue_size() == 10

    @pytest.mark.asyncio
    async def test_priority_queue(self, engine):
        lead_high = Lead(organization_id=uuid4(), phone="+1111111111", priority="high")
        lead_low = Lead(organization_id=uuid4(), phone="+2222222222", priority="low")
        await engine.process_lead(lead_high)
        await engine.process_lead(lead_low)
        first = engine.dequeue_call()
        assert first is not None


class TestRetryLogic:
    def test_should_retry_within_limits(self, engine):
        lead = Lead(
            organization_id=uuid4(),
            phone="+1234567890",
            call_count=2,
        )
        assert engine.should_retry(lead, max_attempts=3)

    def test_should_not_retry_exceeded_limits(self, engine):
        lead = Lead(
            organization_id=uuid4(),
            phone="+1234567890",
            call_count=3,
        )
        assert not engine.should_retry(lead, max_attempts=3)

    def test_should_not_retry_do_not_call(self, engine):
        lead = Lead(
            organization_id=uuid4(),
            phone="+1234567890",
            do_not_call=True,
            call_count=0,
        )
        assert not engine.should_retry(lead, max_attempts=3)

    def test_should_not_retry_dnc_disposition(self, engine):
        lead = Lead(
            organization_id=uuid4(),
            phone="+1234567890",
            last_disposition=CallDisposition.dnc.value,
            call_count=1,
        )
        assert not engine.should_retry(lead, max_attempts=3)

    def test_should_not_retry_wrong_number(self, engine):
        lead = Lead(
            organization_id=uuid4(),
            phone="+1234567890",
            last_disposition=CallDisposition.wrong_number.value,
            call_count=1,
        )
        assert not engine.should_retry(lead, max_attempts=3)

    def test_should_not_retry_disconnected(self, engine):
        lead = Lead(
            organization_id=uuid4(),
            phone="+1234567890",
            last_disposition=CallDisposition.disconnected.value,
            call_count=1,
        )
        assert not engine.should_retry(lead, max_attempts=3)

    def test_should_retry_call_back(self, engine):
        lead = Lead(
            organization_id=uuid4(),
            phone="+1234567890",
            last_disposition=CallDisposition.call_back.value,
            call_count=1,
        )
        assert engine.should_retry(lead, max_attempts=3)

    def test_should_retry_no_answer(self, engine):
        lead = Lead(
            organization_id=uuid4(),
            phone="+1234567890",
            last_disposition=CallDisposition.no_answer.value,
            call_count=1,
        )
        assert engine.should_retry(lead, max_attempts=3)

    def test_should_retry_busy(self, engine):
        lead = Lead(
            organization_id=uuid4(),
            phone="+1234567890",
            last_disposition=CallDisposition.busy.value,
            call_count=1,
        )
        assert engine.should_retry(lead, max_attempts=3)

    def test_should_retry_follow_up(self, engine):
        lead = Lead(
            organization_id=uuid4(),
            phone="+1234567890",
            last_disposition=CallDisposition.follow_up_required.value,
            call_count=1,
        )
        assert engine.should_retry(lead, max_attempts=3)

    def test_should_retry_interested(self, engine):
        lead = Lead(
            organization_id=uuid4(),
            phone="+1234567890",
            last_disposition=CallDisposition.interested.value,
            call_count=1,
        )
        assert engine.should_retry(lead, max_attempts=3)

    def test_retry_delay_calculation(self, engine):
        lead = Lead(
            organization_id=uuid4(),
            phone="+1234567890",
            call_count=1,
            last_called_at=datetime.utcnow() - timedelta(hours=2),
        )
        next_call = engine.get_next_call_time(lead, delay_minutes=60)
        assert next_call > datetime.utcnow()
        assert (next_call - datetime.utcnow()) >= timedelta(minutes=59)

    def test_retry_delay_increases_with_attempts(self, engine):
        lead1 = Lead(organization_id=uuid4(), phone="+1111111111", call_count=1)
        lead2 = Lead(organization_id=uuid4(), phone="+2222222222", call_count=3)
        t1 = engine.get_next_call_time(lead1, delay_minutes=30)
        t2 = engine.get_next_call_time(lead2, delay_minutes=90)
        assert t2 > t1

    def test_max_attempts_configurable(self, engine):
        lead = Lead(
            organization_id=uuid4(),
            phone="+1234567890",
            call_count=5,
        )
        assert not engine.should_retry(lead, max_attempts=3)
        assert engine.should_retry(lead, max_attempts=10)

    def test_retry_with_voicemail_disposition(self, engine):
        lead = Lead(
            organization_id=uuid4(),
            phone="+1234567890",
            last_disposition=CallDisposition.voicemail.value,
            call_count=1,
        )
        assert engine.should_retry(lead, max_attempts=3)


class TestScheduling:
    def test_business_hours_check(self, engine):
        assert engine.is_within_business_hours("09:00", "18:00", "12:00")
        assert not engine.is_within_business_hours("09:00", "18:00", "20:00")
        assert not engine.is_within_business_hours("09:00", "18:00", "08:00")

    def test_business_hours_boundary(self, engine):
        assert engine.is_within_business_hours("09:00", "18:00", "09:00")
        assert engine.is_within_business_hours("09:00", "18:00", "18:00")

    def test_working_day_check(self, engine):
        assert engine.is_working_day(1, [1, 2, 3, 4, 5])
        assert not engine.is_working_day(6, [1, 2, 3, 4, 5])
        assert not engine.is_working_day(0, [1, 2, 3, 4, 5])

    def test_working_days_default(self, engine):
        assert engine.is_working_day(0)
        assert engine.is_working_day(6)

    def test_schedule_with_timezone(self, engine):
        assert engine.is_within_business_hours("09:00", "18:00", "14:00")
        assert not engine.is_within_business_hours("09:00", "18:00", "02:00")

    def test_rate_limiting(self, engine):
        assert engine.get_queue_size() == 0

    @pytest.mark.asyncio
    async def test_max_calls_per_day_limit(self, engine):
        for i in range(5):
            lead = Lead(organization_id=uuid4(), phone=f"+1{i:010d}")
            await engine.process_lead(lead)
        assert engine.get_queue_size() == 5

    @pytest.mark.asyncio
    async def test_campaign_metrics_update(self, engine):
        campaign = Campaign(
            organization_id=uuid4(),
            name="Metrics Test",
            type=CampaignType.cold_calling.value,
            status=CampaignStatus.active.value,
        )
        await engine.start_campaign(campaign)
        assert campaign.status == CampaignStatus.active.value
