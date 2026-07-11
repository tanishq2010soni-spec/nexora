from __future__ import annotations

from datetime import datetime, timedelta
from typing import Any, Optional
from uuid import UUID

from sqlalchemy import select, func, and_, cast, Date
from sqlalchemy.ext.asyncio import AsyncSession

from backend.infrastructure.database.models import (
    CallModel,
    CampaignModel,
    LeadModel,
    AnalyticsEventModel,
    RecordingModel,
)

from backend.domain.enums import AnalyticsMetric


class AnalyticsService:
    async def get_overview(self, org_id: str, session: AsyncSession) -> dict:
        now = datetime.utcnow()
        today_start = now.replace(hour=0, minute=0, second=0, microsecond=0)
        week_ago = now - timedelta(days=7)

        today_count = await self._count_calls(org_id, today_start, now, session)
        week_count = await self._count_calls(org_id, week_ago, now, session)

        total_count = await self._count_calls(org_id, None, None, session)

        active_campaigns = await self._count_active_campaigns(org_id, session)
        total_leads = await self._count_leads(org_id, session)
        total_recordings = await self._count_recordings(org_id, session)

        avg_duration = await self._avg_call_duration(org_id, week_ago, now, session)
        answer_rate = await self._answer_rate(org_id, week_ago, now, session)

        return {
            "calls_today": today_count,
            "calls_this_week": week_count,
            "total_calls": total_count,
            "active_campaigns": active_campaigns,
            "total_leads": total_leads,
            "total_recordings": total_recordings,
            "avg_duration_seconds": round(avg_duration or 0, 2),
            "answer_rate": round(answer_rate or 0, 4),
            "period_start": week_ago.isoformat(),
            "period_end": now.isoformat(),
        }

    async def get_call_metrics(self, org_id: str, days: int, session: AsyncSession) -> list[dict]:
        since = datetime.utcnow() - timedelta(days=days)
        result = await session.execute(
            select(
                cast(CallModel.created_at, Date).label("date"),
                func.count(CallModel.id).label("total"),
                func.sum(CallModel.duration_seconds).label("total_duration"),
                func.avg(CallModel.duration_seconds).label("avg_duration"),
                func.avg(CallModel.cost).label("avg_cost"),
            ).where(
                CallModel.organization_id == org_id,
                CallModel.created_at >= since,
            ).group_by(
                cast(CallModel.created_at, Date)
            ).order_by(
                cast(CallModel.created_at, Date)
            )
        )
        rows = result.all()
        return [
            {
                "date": str(row.date),
                "total_calls": row.total,
                "total_duration_seconds": row.total_duration or 0,
                "avg_duration_seconds": round(row.avg_duration or 0, 2),
                "avg_cost": round(row.avg_cost or 0, 4),
            }
            for row in rows
        ]

    async def get_campaign_metrics(self, org_id: str, campaign_id: Optional[str], days: int, session: AsyncSession) -> dict:
        since = datetime.utcnow() - timedelta(days=days)

        query = select(CampaignModel).where(CampaignModel.organization_id == org_id)
        if campaign_id:
            query = query.where(CampaignModel.id == campaign_id)
        result = await session.execute(query)
        campaigns = result.scalars().all()

        metrics = []
        for camp in campaigns:
            call_query = select(
                func.count(CallModel.id).label("total_calls"),
                func.sum(CallModel.duration_seconds).label("total_duration"),
                func.avg(CallModel.duration_seconds).label("avg_duration"),
                func.sum(CallModel.cost).label("total_cost"),
            ).where(
                CallModel.campaign_id == camp.id,
                CallModel.created_at >= since,
            )
            call_result = await session.execute(call_query)
            row = call_result.one()

            answered = await session.execute(
                select(func.count(CallModel.id)).where(
                    CallModel.campaign_id == camp.id,
                    CallModel.status == "completed",
                    CallModel.created_at >= since,
                )
            )
            answered_count = answered.scalar() or 0

            metrics.append({
                "campaign_id": camp.id,
                "campaign_name": camp.name,
                "status": camp.status,
                "total_calls": row.total_calls or 0,
                "answered_calls": answered_count,
                "total_duration_seconds": row.total_duration or 0,
                "avg_duration_seconds": round(row.avg_duration or 0, 2),
                "total_cost": round(row.total_cost or 0, 4),
            })

        return {
            "campaigns": metrics,
            "period_days": days,
        }

    async def get_agent_metrics(self, org_id: str, days: int, session: AsyncSession) -> list[dict]:
        since = datetime.utcnow() - timedelta(days=days)
        result = await session.execute(
            select(
                CallModel.user_id,
                func.count(CallModel.id).label("total_calls"),
                func.sum(CallModel.duration_seconds).label("total_duration"),
                func.avg(CallModel.duration_seconds).label("avg_duration"),
            ).where(
                CallModel.organization_id == org_id,
                CallModel.user_id.isnot(None),
                CallModel.created_at >= since,
            ).group_by(CallModel.user_id)
        )
        rows = result.all()
        return [
            {
                "user_id": row.user_id,
                "total_calls": row.total_calls,
                "total_duration_seconds": row.total_duration or 0,
                "avg_duration_seconds": round(row.avg_duration or 0, 2),
            }
            for row in rows
        ]

    async def get_sentiment_trends(self, org_id: str, days: int, session: AsyncSession) -> list[dict]:
        since = datetime.utcnow() - timedelta(days=days)
        result = await session.execute(
            select(
                cast(CallModel.created_at, Date).label("date"),
                CallModel.sentiment,
                func.count(CallModel.id).label("count"),
            ).where(
                CallModel.organization_id == org_id,
                CallModel.sentiment.isnot(None),
                CallModel.created_at >= since,
            ).group_by(
                cast(CallModel.created_at, Date),
                CallModel.sentiment,
            ).order_by(
                cast(CallModel.created_at, Date),
            )
        )
        rows = result.all()

        trends: dict[str, dict] = {}
        for row in rows:
            date_str = str(row.date)
            if date_str not in trends:
                trends[date_str] = {"date": date_str, "positive": 0, "neutral": 0, "negative": 0}
            sentiment_key = row.sentiment.lower()
            if "positive" in sentiment_key:
                trends[date_str]["positive"] += row.count
            elif "negative" in sentiment_key:
                trends[date_str]["negative"] += row.count
            else:
                trends[date_str]["neutral"] += row.count

        return list(trends.values())

    async def record_event(self, org_id: str, metric: str, value: float, tags: dict, session: AsyncSession) -> None:
        event = AnalyticsEventModel(
            organization_id=org_id,
            metric=metric,
            value=value,
            tags=tags,
        )
        session.add(event)
        await session.flush()

    async def _count_calls(self, org_id: str, since: Optional[datetime], until: Optional[datetime], session: AsyncSession) -> int:
        query = select(func.count(CallModel.id)).where(CallModel.organization_id == org_id)
        if since:
            query = query.where(CallModel.created_at >= since)
        if until:
            query = query.where(CallModel.created_at <= until)
        result = await session.execute(query)
        return result.scalar() or 0

    async def _count_active_campaigns(self, org_id: str, session: AsyncSession) -> int:
        result = await session.execute(
            select(func.count(CampaignModel.id)).where(
                CampaignModel.organization_id == org_id,
                CampaignModel.status == "active",
            )
        )
        return result.scalar() or 0

    async def _count_leads(self, org_id: str, session: AsyncSession) -> int:
        result = await session.execute(
            select(func.count(LeadModel.id)).where(LeadModel.organization_id == org_id)
        )
        return result.scalar() or 0

    async def _count_recordings(self, org_id: str, session: AsyncSession) -> int:
        result = await session.execute(
            select(func.count(RecordingModel.id)).where(RecordingModel.organization_id == org_id)
        )
        return result.scalar() or 0

    async def _avg_call_duration(self, org_id: str, since: datetime, until: datetime, session: AsyncSession) -> Optional[float]:
        result = await session.execute(
            select(func.avg(CallModel.duration_seconds)).where(
                CallModel.organization_id == org_id,
                CallModel.created_at >= since,
                CallModel.created_at <= until,
                CallModel.duration_seconds.isnot(None),
            )
        )
        return result.scalar()

    async def _answer_rate(self, org_id: str, since: datetime, until: datetime, session: AsyncSession) -> Optional[float]:
        total = await self._count_calls(org_id, since, until, session)
        if total == 0:
            return 0.0
        answered = await session.execute(
            select(func.count(CallModel.id)).where(
                CallModel.organization_id == org_id,
                CallModel.created_at >= since,
                CallModel.created_at <= until,
                CallModel.status == "completed",
            )
        )
        answered_count = answered.scalar() or 0
        return answered_count / total
