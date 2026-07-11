from __future__ import annotations

from datetime import datetime, timedelta, timezone
from typing import Any, Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel
from sqlalchemy import select, func, cast, Date, case
from sqlalchemy.ext.asyncio import AsyncSession

from ..api.auth import get_current_user, require_permission
from ..domain.entities import AnalyticsEvent
from ..infrastructure.database import (AnalyticsEventModel, AppointmentModel, CallModel,
                                       CampaignModel, ContactModel, LeadModel, UserModel,
                                       get_session)

router = APIRouter(prefix="/api/v1/analytics", tags=["analytics"])


class OverviewResponse(BaseModel):
    total_calls: int
    active_calls: int
    total_campaigns: int
    active_campaigns: int
    total_leads: int
    total_contacts: int
    appointments_today: int
    answer_rate: float
    conversion_rate: float
    total_cost: float


class CallMetricsResponse(BaseModel):
    labels: list[str]
    total_calls: list[int]
    answered: list[int]
    avg_duration: list[float]


class CampaignPerformanceResponse(BaseModel):
    campaigns: list[dict[str, Any]]


class ConversionMetricsResponse(BaseModel):
    total_leads: int
    converted: int
    conversion_rate: float
    by_source: dict[str, int]


class SentimentTrendsResponse(BaseModel):
    labels: list[str]
    positive: list[int]
    neutral: list[int]
    negative: list[int]


class AgentPerformanceResponse(BaseModel):
    agents: list[dict[str, Any]]


class QualityScoresResponse(BaseModel):
    labels: list[str]
    avg_score: list[float]
    count: list[int]


class RevenueAttributionResponse(BaseModel):
    total_revenue: float
    by_campaign: list[dict[str, Any]]
    by_source: dict[str, float]


class ModelUsageResponse(BaseModel):
    total_calls: int
    ai_handled: int
    ai_handled_percentage: float
    human_handoff: int


class RecordEventRequest(BaseModel):
    metric: str
    value: float = 0.0
    tags: dict[str, Any] = {}


@router.get("/overview", response_model=OverviewResponse)
async def get_overview(
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("view_analytics")),
):
    org_id = str(current_user.organization_id)
    today_start = datetime.now(timezone.utc).replace(hour=0, minute=0, second=0, microsecond=0)

    total_calls = (await session.execute(select(func.count()).select_from(CallModel).where(CallModel.organization_id == org_id))).scalar() or 0
    active_calls = (await session.execute(select(func.count()).select_from(CallModel).where(CallModel.organization_id == org_id, CallModel.status.in_(["ringing", "in_progress", "hold"])))).scalar() or 0
    total_campaigns = (await session.execute(select(func.count()).select_from(CampaignModel).where(CampaignModel.organization_id == org_id))).scalar() or 0
    active_campaigns = (await session.execute(select(func.count()).select_from(CampaignModel).where(CampaignModel.organization_id == org_id, CampaignModel.status == "active"))).scalar() or 0
    total_leads = (await session.execute(select(func.count()).select_from(LeadModel).where(LeadModel.organization_id == org_id))).scalar() or 0
    total_contacts = (await session.execute(select(func.count()).select_from(ContactModel).where(ContactModel.organization_id == org_id))).scalar() or 0

    appointments_today = (await session.execute(
        select(func.count()).select_from(AppointmentModel)
        .where(AppointmentModel.organization_id == org_id)
        .where(cast(AppointmentModel.scheduled_at, Date) == today_start.date())
    )).scalar() or 0

    total_answered = (await session.execute(
        select(func.count()).select_from(CallModel)
        .where(CallModel.organization_id == org_id)
        .where(CallModel.status == "completed")
    )).scalar() or 0

    cost_result = await session.execute(
        select(func.sum(CallModel.cost)).select_from(CallModel).where(CallModel.organization_id == org_id)
    )
    total_cost = float(cost_result.scalar() or 0.0)

    answer_rate = (total_answered / total_calls * 100) if total_calls > 0 else 0.0

    return OverviewResponse(
        total_calls=total_calls,
        active_calls=active_calls,
        total_campaigns=total_campaigns,
        active_campaigns=active_campaigns,
        total_leads=total_leads,
        total_contacts=total_contacts,
        appointments_today=appointments_today,
        answer_rate=round(answer_rate, 2),
        conversion_rate=0.0,
        total_cost=round(total_cost, 2),
    )


@router.get("/calls", response_model=CallMetricsResponse)
async def get_call_metrics(
    days: int = Query(30, ge=1, le=365),
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("view_analytics")),
):
    org_id = str(current_user.organization_id)
    since = datetime.now(timezone.utc) - timedelta(days=days)

    result = await session.execute(
        select(
            cast(CallModel.created_at, Date).label("date"),
            func.count().label("total"),
            func.sum(case((CallModel.status == "completed", 1), else_=0)).label("answered"),
            func.avg(CallModel.duration_seconds).label("avg_dur"),
        )
        .where(CallModel.organization_id == org_id)
        .where(CallModel.created_at >= since)
        .group_by(cast(CallModel.created_at, Date))
        .order_by(cast(CallModel.created_at, Date))
    )
    rows = result.all()

    return CallMetricsResponse(
        labels=[str(r.date) for r in rows],
        total_calls=[r.total for r in rows],
        answered=[r.answered or 0 for r in rows],
        avg_duration=[round(r.avg_dur or 0, 2) for r in rows],
    )


@router.get("/campaigns", response_model=CampaignPerformanceResponse)
async def get_campaign_performance(
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("view_analytics")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(CampaignModel).where(CampaignModel.organization_id == org_id)
    )
    models = result.scalars().all()

    campaigns = []
    for m in models:
        campaigns.append({
            "id": m.id,
            "name": m.name,
            "type": m.type,
            "status": m.status,
            "total_calls": m.total_calls,
            "total_answered": m.total_answered,
            "total_converted": m.total_converted,
            "total_cost": m.total_cost,
            "answer_rate": round(m.total_answered / m.total_calls * 100, 2) if m.total_calls > 0 else 0.0,
            "conversion_rate": round(m.total_converted / m.total_answered * 100, 2) if m.total_answered > 0 else 0.0,
        })

    return CampaignPerformanceResponse(campaigns=campaigns)


@router.get("/conversion", response_model=ConversionMetricsResponse)
async def get_conversion_metrics(
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("view_analytics")),
):
    org_id = str(current_user.organization_id)

    total_leads = (await session.execute(select(func.count()).select_from(LeadModel).where(LeadModel.organization_id == org_id))).scalar() or 0
    converted = (await session.execute(select(func.count()).select_from(LeadModel).where(LeadModel.organization_id == org_id, LeadModel.status == "converted"))).scalar() or 0

    source_result = await session.execute(
        select(LeadModel.source, func.count()).where(LeadModel.organization_id == org_id)
        .group_by(LeadModel.source)
    )
    by_source = dict(source_result.all())

    conversion_rate = (converted / total_leads * 100) if total_leads > 0 else 0.0
    return ConversionMetricsResponse(
        total_leads=total_leads,
        converted=converted,
        conversion_rate=round(conversion_rate, 2),
        by_source=by_source,
    )


@router.get("/sentiment", response_model=SentimentTrendsResponse)
async def get_sentiment_trends(
    days: int = Query(30, ge=1, le=365),
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("view_analytics")),
):
    org_id = str(current_user.organization_id)
    since = datetime.now(timezone.utc) - timedelta(days=days)

    result = await session.execute(
        select(
            cast(CallModel.created_at, Date).label("date"),
            CallModel.sentiment,
            func.count().label("cnt"),
        )
        .where(CallModel.organization_id == org_id)
        .where(CallModel.created_at >= since)
        .where(CallModel.sentiment.isnot(None))
        .group_by(cast(CallModel.created_at, Date), CallModel.sentiment)
        .order_by(cast(CallModel.created_at, Date))
    )
    rows = result.all()

    labels_set: set[str] = set()
    by_date: dict[str, dict[str, int]] = {}
    for r in rows:
        date_str = str(r.date)
        labels_set.add(date_str)
        if date_str not in by_date:
            by_date[date_str] = {"positive": 0, "neutral": 0, "negative": 0}
        sent = r.sentiment or "neutral"
        if sent in ("positive", "very_positive"):
            by_date[date_str]["positive"] += r.cnt
        elif sent in ("negative", "very_negative"):
            by_date[date_str]["negative"] += r.cnt
        else:
            by_date[date_str]["neutral"] += r.cnt

    labels = sorted(labels_set)
    return SentimentTrendsResponse(
        labels=labels,
        positive=[by_date[d]["positive"] for d in labels],
        neutral=[by_date[d]["neutral"] for d in labels],
        negative=[by_date[d]["negative"] for d in labels],
    )


@router.get("/agents", response_model=AgentPerformanceResponse)
async def get_agent_performance(
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("view_analytics")),
):
    org_id = str(current_user.organization_id)

    users_result = await session.execute(
        select(UserModel).where(UserModel.organization_id == org_id)
    )
    users = users_result.scalars().all()

    agents = []
    for u in users:
        calls_result = await session.execute(
            select(
                func.count().label("total"),
                func.sum(CallModel.duration_seconds).label("total_duration"),
                func.avg(CallModel.quality_score).label("avg_quality"),
            ).select_from(CallModel)
            .where(CallModel.organization_id == org_id)
            .where(CallModel.user_id == u.id)
        )
        row = calls_result.one()
        agents.append({
            "user_id": u.id,
            "name": u.name,
            "email": u.email,
            "total_calls": row.total or 0,
            "total_duration": row.total_duration or 0,
            "avg_quality": round(row.avg_quality or 0.0, 2),
            "is_available": u.is_available,
        })

    return AgentPerformanceResponse(agents=agents)


@router.get("/quality", response_model=QualityScoresResponse)
async def get_quality_scores(
    days: int = Query(30, ge=1, le=365),
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("view_analytics")),
):
    org_id = str(current_user.organization_id)
    since = datetime.now(timezone.utc) - timedelta(days=days)

    result = await session.execute(
        select(
            cast(CallModel.created_at, Date).label("date"),
            func.avg(CallModel.quality_score).label("avg_score"),
            func.count().label("cnt"),
        )
        .where(CallModel.organization_id == org_id)
        .where(CallModel.created_at >= since)
        .where(CallModel.quality_score.isnot(None))
        .group_by(cast(CallModel.created_at, Date))
        .order_by(cast(CallModel.created_at, Date))
    )
    rows = result.all()

    return QualityScoresResponse(
        labels=[str(r.date) for r in rows],
        avg_score=[round(r.avg_score or 0, 2) for r in rows],
        count=[r.cnt for r in rows],
    )


@router.get("/revenue", response_model=RevenueAttributionResponse)
async def get_revenue_attribution(
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("view_analytics")),
):
    org_id = str(current_user.organization_id)

    cost_result = await session.execute(
        select(func.sum(CallModel.cost)).select_from(CallModel).where(CallModel.organization_id == org_id)
    )
    total_revenue = float(cost_result.scalar() or 0.0)

    campaign_costs = await session.execute(
        select(CampaignModel.name, func.sum(CallModel.cost))
        .select_from(CallModel)
        .join(CampaignModel, CallModel.campaign_id == CampaignModel.id)
        .where(CallModel.organization_id == org_id)
        .where(CallModel.campaign_id.isnot(None))
        .group_by(CampaignModel.name)
    )
    by_campaign = [{"name": name, "cost": round(float(cost or 0), 2)} for name, cost in campaign_costs.all()]

    source_costs = await session.execute(
        select(CallModel.direction, func.sum(CallModel.cost))
        .where(CallModel.organization_id == org_id)
        .group_by(CallModel.direction)
    )
    by_source = {direction: round(float(cost or 0), 2) for direction, cost in source_costs.all()}

    return RevenueAttributionResponse(
        total_revenue=round(total_revenue, 2),
        by_campaign=by_campaign,
        by_source=by_source,
    )


@router.get("/model-usage", response_model=ModelUsageResponse)
async def get_model_usage(
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("view_analytics")),
):
    org_id = str(current_user.organization_id)

    total_calls = (await session.execute(select(func.count()).select_from(CallModel).where(CallModel.organization_id == org_id))).scalar() or 0
    ai_handled = (await session.execute(select(func.count()).select_from(CallModel).where(CallModel.organization_id == org_id, CallModel.ai_handled == True))).scalar() or 0
    human_handoff = (await session.execute(select(func.count()).select_from(CallModel).where(CallModel.organization_id == org_id, CallModel.ai_handled == False))).scalar() or 0

    ai_pct = (ai_handled / total_calls * 100) if total_calls > 0 else 0.0

    return ModelUsageResponse(
        total_calls=total_calls,
        ai_handled=ai_handled,
        ai_handled_percentage=round(ai_pct, 2),
        human_handoff=human_handoff,
    )


@router.post("/events", response_model=AnalyticsEvent)
async def record_event(
    req: RecordEventRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("view_analytics")),
):
    model = AnalyticsEventModel(
        organization_id=str(current_user.organization_id),
        metric=req.metric,
        value=req.value,
        tags=req.tags,
    )
    session.add(model)
    await session.flush()
    await session.refresh(model)
    return AnalyticsEvent.model_validate(model)
