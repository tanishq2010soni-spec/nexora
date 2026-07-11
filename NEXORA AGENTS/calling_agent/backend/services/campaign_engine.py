from __future__ import annotations

import asyncio
import logging
from datetime import datetime, timedelta
from typing import Any, Optional
from uuid import UUID

from sqlalchemy import select, func, and_
from sqlalchemy.ext.asyncio import AsyncSession

from backend.domain.entities import Campaign, Call, Lead
from backend.infrastructure.database.models import CampaignModel, LeadModel, CallModel
from backend.services.call_engine import CallEngine

logger = logging.getLogger(__name__)


class CampaignEngine:
    def __init__(self, call_engine: CallEngine) -> None:
        self._call_engine = call_engine
        self._active_campaigns: dict[str, bool] = {}

    async def start_campaign(self, campaign_id: str, session: AsyncSession) -> None:
        result = await session.execute(
            select(CampaignModel).where(CampaignModel.id == campaign_id)
        )
        db_campaign = result.scalar_one_or_none()
        if not db_campaign:
            raise ValueError(f"Campaign {campaign_id} not found")

        db_campaign.status = "active"
        self._active_campaigns[campaign_id] = True
        await session.flush()

        asyncio.create_task(self._run_campaign_loop(campaign_id, session))

    async def pause_campaign(self, campaign_id: str) -> None:
        self._active_campaigns[campaign_id] = False

    async def _run_campaign_loop(self, campaign_id: str, session: AsyncSession) -> None:
        while self._active_campaigns.get(campaign_id, False):
            try:
                await self.process_call_queue(campaign_id, session)
                await asyncio.sleep(5)
            except Exception as e:
                logger.error(f"Campaign loop error for {campaign_id}: {e}")
                await asyncio.sleep(30)

        result = await session.execute(
            select(CampaignModel).where(CampaignModel.id == campaign_id)
        )
        db_campaign = result.scalar_one_or_none()
        if db_campaign:
            db_campaign.status = "paused"
            await session.flush()

    async def process_call_queue(self, campaign_id: Optional[str] = None, session: Optional[AsyncSession] = None) -> None:
        if not session:
            return

        query = select(LeadModel).where(
            LeadModel.do_not_call == False,
            LeadModel.next_call_at.is_(None),
        )
        if campaign_id:
            query = query.where(LeadModel.campaign_id == campaign_id)
        query = query.limit(10)

        result = await session.execute(query)
        leads = result.scalars().all()

        for lead in leads:
            if not self._active_campaigns.get(campaign_id or "", True):
                break
            await self.process_lead(str(lead.id), campaign_id or str(lead.campaign_id), session)

    async def schedule_calls(self, campaign_id: str, session: Optional[AsyncSession] = None) -> None:
        if not session:
            return

        result = await session.execute(
            select(CampaignModel).where(CampaignModel.id == campaign_id)
        )
        db_campaign = result.scalar_one_or_none()
        if not db_campaign:
            return

        now = datetime.utcnow()
        query = select(LeadModel).where(
            LeadModel.campaign_id == campaign_id,
            LeadModel.do_not_call == False,
            and_(
                LeadModel.next_call_at.is_(None),
                LeadModel.call_count < db_campaign.max_attempts,
            ),
        )
        result = await session.execute(query)
        leads = result.scalars().all()

        for lead in leads:
            delay_minutes = lead.call_count * db_campaign.retry_delay_minutes
            lead.next_call_at = now + timedelta(minutes=delay_minutes)

        await session.flush()

    async def process_lead(self, lead_id: str, campaign_id: str, session: AsyncSession) -> None:
        result = await session.execute(
            select(LeadModel).where(LeadModel.id == lead_id)
        )
        db_lead = result.scalar_one_or_none()
        if not db_lead:
            return

        result = await session.execute(
            select(CampaignModel).where(CampaignModel.id == campaign_id)
        )
        db_campaign = result.scalar_one_or_none()
        if not db_campaign:
            return

        limits = await self.check_campaign_limits(campaign_id, session)
        if limits.get("daily_limit_reached", False) or limits.get("max_concurrent_reached", False):
            return

        from backend.domain.entities import Call
        call = Call(
            organization_id=UUID(db_lead.organization_id),
            campaign_id=UUID(campaign_id),
            lead_id=UUID(lead_id),
            direction="outbound",
            from_number=db_campaign.caller_id or "",
            to_number=db_lead.phone,
            status="queued",
        )

        try:
            updated_call = await self._call_engine.initiate_call(call, session)
            db_lead.last_called_at = datetime.utcnow()
            db_lead.call_count = (db_lead.call_count or 0) + 1
            db_lead.status = "contacted"

            db_campaign.total_calls = (db_campaign.total_calls or 0) + 1
            await session.flush()
        except Exception as e:
            logger.error(f"Failed to process lead {lead_id}: {e}")
            db_lead.next_call_at = datetime.utcnow() + timedelta(minutes=db_campaign.retry_delay_minutes)
            await session.flush()

    async def check_campaign_limits(self, campaign_id: str, session: AsyncSession) -> dict:
        result = await session.execute(
            select(CampaignModel).where(CampaignModel.id == campaign_id)
        )
        db_campaign = result.scalar_one_or_none()
        if not db_campaign:
            return {"daily_limit_reached": True, "max_concurrent_reached": True}

        today_start = datetime.utcnow().replace(hour=0, minute=0, second=0, microsecond=0)
        count_result = await session.execute(
            select(func.count(CallModel.id)).where(
                CallModel.campaign_id == campaign_id,
                CallModel.created_at >= today_start,
            )
        )
        daily_count = count_result.scalar() or 0
        daily_limit_reached = daily_count >= db_campaign.max_calls_per_day

        active_count_result = await session.execute(
            select(func.count(CallModel.id)).where(
                CallModel.campaign_id == campaign_id,
                CallModel.status.in_(["queued", "ringing", "in_progress"]),
            )
        )
        active_count = active_count_result.scalar() or 0
        max_concurrent_reached = active_count >= 10

        return {
            "daily_limit_reached": daily_limit_reached,
            "max_concurrent_reached": max_concurrent_reached,
            "daily_count": daily_count,
            "max_calls_per_day": db_campaign.max_calls_per_day,
            "active_count": active_count,
        }
