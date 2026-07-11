from __future__ import annotations

import logging
from datetime import datetime, timedelta
from typing import Any, Optional
from uuid import uuid4

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from backend.domain.enums import AnalyticsMetric
from backend.infrastructure.database.models import (AnalyticsEventModel, ConversationModel, LeadModel,
                                                     MessageModel)

logger = logging.getLogger(__name__)


class AnalyticsService:
    async def get_overview(self, org_id: str, session: AsyncSession) -> dict[str, Any]:
        now = datetime.utcnow()
        today_start = now.replace(hour=0, minute=0, second=0, microsecond=0)
        week_start = today_start - timedelta(days=7)
        month_start = today_start - timedelta(days=30)

        total_conversations = await self._count_model(session, ConversationModel, org_id)
        active_conversations = await self._count_model(session, ConversationModel, org_id, status="active")
        total_messages = await self._count_model(session, MessageModel, org_id)
        total_leads = await self._count_model(session, LeadModel, org_id)
        qualified_leads = await self._count_model(session, LeadModel, org_id, status="qualified")
        converted_leads = await self._count_model(session, LeadModel, org_id, status="converted")
        today_conversations = await self._count_created_after(session, ConversationModel, org_id, today_start)
        today_messages = await self._count_created_after(session, MessageModel, org_id, today_start)
        month_conversations = await self._count_created_after(session, ConversationModel, org_id, month_start)
        month_leads = await self._count_created_after(session, LeadModel, org_id, month_start)

        return {
            "total_conversations": total_conversations,
            "active_conversations": active_conversations,
            "total_messages": total_messages,
            "total_leads": total_leads,
            "qualified_leads": qualified_leads,
            "converted_leads": converted_leads,
            "today_conversations": today_conversations,
            "today_messages": today_messages,
            "month_conversations": month_conversations,
            "month_leads": month_leads,
            "conversion_rate": round((converted_leads / max(total_leads, 1)) * 100, 1),
            "qualified_rate": round((qualified_leads / max(total_leads, 1)) * 100, 1),
        }

    async def get_conversation_metrics(
        self, org_id: str, days: int, session: AsyncSession
    ) -> list[dict[str, Any]]:
        since = datetime.utcnow() - timedelta(days=days)
        stmt = (
            select(
                func.date(ConversationModel.created_at).label("date"),
                func.count().label("count"),
            )
            .where(
                ConversationModel.organization_id == org_id,
                ConversationModel.created_at >= since,
            )
            .group_by(func.date(ConversationModel.created_at))
            .order_by(func.date(ConversationModel.created_at))
        )
        result = await session.execute(stmt)
        rows = result.all()
        metrics: list[dict[str, Any]] = []
        for row in rows:
            metrics.append({
                "date": str(row.date),
                "count": row.count,
                "metric": AnalyticsMetric.total_conversations.value,
            })
        return metrics

    async def get_lead_metrics(
        self, org_id: str, days: int, session: AsyncSession
    ) -> dict[str, Any]:
        since = datetime.utcnow() - timedelta(days=days)

        stmt = (
            select(
                LeadModel.status,
                func.count().label("count"),
            )
            .where(
                LeadModel.organization_id == org_id,
                LeadModel.created_at >= since,
            )
            .group_by(LeadModel.status)
        )
        result = await session.execute(stmt)
        rows = result.all()
        by_status: dict[str, int] = {}
        for row in rows:
            by_status[row.status] = row.count

        source_stmt = (
            select(
                LeadModel.source,
                func.count().label("count"),
            )
            .where(
                LeadModel.organization_id == org_id,
                LeadModel.created_at >= since,
            )
            .group_by(LeadModel.source)
        )
        source_result = await session.execute(source_stmt)
        source_rows = source_result.all()
        by_source: dict[str, int] = {}
        for row in source_rows:
            by_source[row.source] = row.count

        avg_score_stmt = select(func.avg(LeadModel.score)).where(
            LeadModel.organization_id == org_id,
            LeadModel.created_at >= since,
        )
        avg_score_result = await session.execute(avg_score_stmt)
        avg_score = avg_score_result.scalar() or 0.0

        total = sum(by_status.values()) or 1
        return {
            "by_status": by_status,
            "by_source": by_source,
            "total": sum(by_status.values()),
            "average_score": round(float(avg_score), 1),
            "conversion_rate": round(
                (by_status.get("converted", 0) / total) * 100, 1
            ),
        }

    async def get_response_time(
        self, org_id: str, days: int, session: AsyncSession
    ) -> dict[str, Any]:
        since = datetime.utcnow() - timedelta(days=days)

        stmt = (
            select(MessageModel.conversation_id, MessageModel.direction, MessageModel.created_at)
            .where(
                MessageModel.organization_id == org_id,
                MessageModel.created_at >= since,
            )
            .order_by(MessageModel.conversation_id, MessageModel.created_at)
        )
        result = await session.execute(stmt)
        rows = result.all()

        response_times: list[float] = []
        conv_groups: dict[str, list[tuple[str, datetime]]] = {}
        for conv_id, direction, created_at in rows:
            if conv_id not in conv_groups:
                conv_groups[conv_id] = []
            conv_groups[conv_id].append((direction, created_at))

        for conv_id, msgs in conv_groups.items():
            last_inbound: Optional[datetime] = None
            for direction, created_at in msgs:
                if direction == "inbound":
                    last_inbound = created_at
                elif direction == "outbound" and last_inbound is not None:
                    diff = (created_at - last_inbound).total_seconds() / 60.0
                    if 0 < diff < 1440:
                        response_times.append(diff)
                    last_inbound = None

        if not response_times:
            return {
                "average_minutes": 0.0,
                "median_minutes": 0.0,
                "min_minutes": 0.0,
                "max_minutes": 0.0,
                "sample_size": 0,
            }

        response_times.sort()
        avg = sum(response_times) / len(response_times)
        median = response_times[len(response_times) // 2]
        return {
            "average_minutes": round(avg, 1),
            "median_minutes": round(median, 1),
            "min_minutes": round(response_times[0], 1),
            "max_minutes": round(response_times[-1], 1),
            "sample_size": len(response_times),
        }

    async def get_message_volume(
        self, org_id: str, days: int, session: AsyncSession
    ) -> list[dict[str, Any]]:
        since = datetime.utcnow() - timedelta(days=days)
        stmt = (
            select(
                func.date(MessageModel.created_at).label("date"),
                MessageModel.direction,
                func.count().label("count"),
            )
            .where(
                MessageModel.organization_id == org_id,
                MessageModel.created_at >= since,
            )
            .group_by(func.date(MessageModel.created_at), MessageModel.direction)
            .order_by(func.date(MessageModel.created_at))
        )
        result = await session.execute(stmt)
        rows = result.all()
        volume: list[dict[str, Any]] = []
        for row in rows:
            volume.append({
                "date": str(row.date),
                "direction": row.direction,
                "count": row.count,
            })
        return volume

    async def get_model_usage(
        self, org_id: str, days: int, session: AsyncSession
    ) -> list[dict[str, Any]]:
        since = datetime.utcnow() - timedelta(days=days)

        stmt = (
            select(
                func.date(MessageModel.created_at).label("date"),
                func.count().label("count"),
            )
            .where(
                MessageModel.organization_id == org_id,
                MessageModel.created_at >= since,
                MessageModel.is_ai_generated == True,
            )
            .group_by(func.date(MessageModel.created_at))
            .order_by(func.date(MessageModel.created_at))
        )
        result = await session.execute(stmt)
        rows = result.all()
        usage: list[dict[str, Any]] = []
        for row in rows:
            usage.append({
                "date": str(row.date),
                "ai_generated_messages": row.count,
                "metric": AnalyticsMetric.token_usage.value,
            })
        return usage

    async def record_event(
        self, org_id: str, metric: str, value: float, tags: dict[str, str], session: AsyncSession
        ) -> AnalyticsEventModel:
        event = AnalyticsEventModel(
            organization_id=str(org_id),
            metric=metric,
            value=value,
            tags=tags,
        )
        session.add(event)
        await session.flush()
        logger.info("Recorded analytics event: org=%s metric=%s value=%s", org_id, metric, value)
        return event

    async def _count_model(
        self, session: AsyncSession, model: Any, org_id: str, **filters: Any
    ) -> int:
        conditions = [model.organization_id == org_id]
        for key, value in filters.items():
            if hasattr(model, key) and value is not None:
                conditions.append(getattr(model, key) == value)
        stmt = select(func.count()).select_from(model).where(*conditions)
        result = await session.execute(stmt)
        return result.scalar() or 0

    async def _count_created_after(
        self, session: AsyncSession, model: Any, org_id: str, after: datetime
    ) -> int:
        stmt = select(func.count()).select_from(model).where(
            model.organization_id == org_id,
            model.created_at >= after,
        )
        result = await session.execute(stmt)
        return result.scalar() or 0
