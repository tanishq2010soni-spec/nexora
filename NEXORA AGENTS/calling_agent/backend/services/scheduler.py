from __future__ import annotations

import asyncio
import logging
from datetime import datetime, timedelta, timezone
from typing import Any, Optional
from uuid import UUID

from sqlalchemy import select, and_
from sqlalchemy.ext.asyncio import AsyncSession

from backend.domain.entities import Call
from backend.infrastructure.database.models import CallModel, LeadModel, OrganizationModel, CampaignModel

logger = logging.getLogger(__name__)


class CallScheduler:
    def __init__(self) -> None:
        self._jobs: dict[str, asyncio.Task] = {}

    async def schedule_call(self, lead_id: str, scheduled_at: datetime, campaign_id: Optional[str] = None, session: Optional[AsyncSession] = None) -> None:
        if not session:
            return

        result = await session.execute(
            select(LeadModel).where(LeadModel.id == lead_id)
        )
        db_lead = result.scalar_one_or_none()
        if not db_lead:
            raise ValueError(f"Lead {lead_id} not found")

        db_lead.next_call_at = scheduled_at

        if campaign_id:
            db_lead.campaign_id = campaign_id

        await session.flush()

        delay = (scheduled_at - datetime.utcnow()).total_seconds()
        if delay > 0:
            task = asyncio.create_task(
                self._execute_scheduled_call(lead_id, campaign_id, delay, session)
            )
            self._jobs[lead_id] = task

    async def schedule_campaign(self, campaign_id: str, schedule_config: dict, session: Optional[AsyncSession] = None) -> None:
        if not session:
            return

        result = await session.execute(
            select(CampaignModel).where(CampaignModel.id == campaign_id)
        )
        db_campaign = result.scalar_one_or_none()
        if not db_campaign:
            raise ValueError(f"Campaign {campaign_id} not found")

        db_campaign.schedule = schedule_config

        interval_minutes = schedule_config.get("interval_minutes", 60)
        max_calls = schedule_config.get("max_calls_per_batch", 10)

        async def campaign_scheduler_loop():
            while True:
                try:
                    result = await session.execute(
                        select(LeadModel).where(
                            LeadModel.campaign_id == campaign_id,
                            LeadModel.do_not_call == False,
                            and_(
                                LeadModel.next_call_at.is_(None),
                                LeadModel.call_count < db_campaign.max_attempts,
                            ),
                        ).limit(max_calls)
                    )
                    leads = result.scalars().all()

                    now = datetime.utcnow()
                    for lead in leads:
                        if await self.is_within_business_hours(db_campaign.organization_id, db_campaign.timezone, session):
                            lead.next_call_at = now + timedelta(seconds=10)
                        else:
                            next_slot = await self.get_next_available_slot(
                                lead.timezone or db_campaign.timezone,
                                db_campaign.organization_id,
                                session,
                            )
                            lead.next_call_at = next_slot or (now + timedelta(hours=1))

                    await session.flush()
                except Exception as e:
                    logger.error(f"Campaign scheduler error: {e}")

                await asyncio.sleep(interval_minutes * 60)

        task = asyncio.create_task(campaign_scheduler_loop())
        self._jobs[f"campaign_{campaign_id}"] = task

    async def cancel_scheduled_call(self, call_id: str) -> None:
        task = self._jobs.pop(call_id, None)
        if task:
            task.cancel()

    async def get_due_calls(self, session: Optional[AsyncSession] = None) -> list[dict]:
        if not session:
            return []

        now = datetime.utcnow()
        result = await session.execute(
            select(LeadModel).where(
                LeadModel.do_not_call == False,
                LeadModel.next_call_at.isnot(None),
                LeadModel.next_call_at <= now,
            ).limit(100)
        )
        leads = result.scalars().all()

        return [
            {
                "lead_id": str(lead.id),
                "phone": lead.phone,
                "first_name": lead.first_name,
                "last_name": lead.last_name,
                "campaign_id": str(lead.campaign_id) if lead.campaign_id else None,
                "scheduled_at": lead.next_call_at.isoformat() if lead.next_call_at else None,
            }
            for lead in leads
        ]

    async def is_within_business_hours(self, org_id: str, timezone_str: str, session: Optional[AsyncSession] = None) -> bool:
        if not session:
            return True

        result = await session.execute(
            select(OrganizationModel).where(OrganizationModel.id == org_id)
        )
        db_org = result.scalar_one_or_none()
        if not db_org:
            return True

        import pytz
        try:
            tz = pytz.timezone(timezone_str)
        except Exception:
            tz = pytz.UTC

        now = datetime.now(tz)
        weekday = now.weekday()

        if weekday not in (db_org.working_days or [0, 1, 2, 3, 4, 5, 6]):
            return False

        start_parts = db_org.business_hours_start.split(":")
        end_parts = db_org.business_hours_end.split(":")
        start_hour = int(start_parts[0])
        start_min = int(start_parts[1]) if len(start_parts) > 1 else 0
        end_hour = int(end_parts[0])
        end_min = int(end_parts[1]) if len(end_parts) > 1 else 0

        current_minutes = now.hour * 60 + now.minute
        start_minutes = start_hour * 60 + start_min
        end_minutes = end_hour * 60 + end_min

        return start_minutes <= current_minutes <= end_minutes

    async def get_next_available_slot(self, lead_timezone: str, org_id: str, session: Optional[AsyncSession] = None) -> Optional[datetime]:
        if not session:
            return datetime.utcnow() + timedelta(hours=1)

        result = await session.execute(
            select(OrganizationModel).where(OrganizationModel.id == org_id)
        )
        db_org = result.scalar_one_or_none()
        if not db_org:
            return datetime.utcnow() + timedelta(hours=1)

        import pytz
        try:
            tz = pytz.timezone(lead_timezone)
        except Exception:
            tz = pytz.UTC

        now = datetime.now(tz)
        start_parts = db_org.business_hours_start.split(":")
        end_parts = db_org.business_hours_end.split(":")
        start_hour = int(start_parts[0])
        start_min = int(start_parts[1]) if len(start_parts) > 1 else 0
        end_hour = int(end_parts[0])
        end_min = int(end_parts[1]) if len(end_parts) > 1 else 0

        working_days = set(db_org.working_days or [0, 1, 2, 3, 4, 5, 6])

        current = now
        for _ in range(14):
            if current.weekday() in working_days:
                slot_start = current.replace(hour=start_hour, minute=start_min, second=0, microsecond=0)
                slot_end = current.replace(hour=end_hour, minute=end_min, second=0, microsecond=0)

                if current < slot_start:
                    return slot_start.astimezone(pytz.UTC).replace(tzinfo=None)
                if slot_start <= current <= slot_end:
                    return current.astimezone(pytz.UTC).replace(tzinfo=None) + timedelta(minutes=30)

            current = current + timedelta(days=1)
            current = current.replace(hour=0, minute=0, second=0, microsecond=0)

        return None

    async def _execute_scheduled_call(self, lead_id: str, campaign_id: Optional[str], delay: float, session: AsyncSession) -> None:
        try:
            await asyncio.sleep(delay)

            result = await session.execute(
                select(LeadModel).where(LeadModel.id == lead_id)
            )
            db_lead = result.scalar_one_or_none()
            if not db_lead or db_lead.do_not_call:
                return

            logger.info(f"Executing scheduled call for lead {lead_id}")
        except asyncio.CancelledError:
            logger.info(f"Scheduled call for lead {lead_id} was cancelled")
