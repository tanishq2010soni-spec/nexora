from datetime import datetime, timedelta
from typing import Optional
from uuid import UUID, uuid4

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from ..api.auth import get_current_user, require_permission
from ..domain.entities import AnalyticsEvent, User
from ..domain.enums import AnalyticsMetric
from ..infrastructure.database import (AnalyticsEventModel, ConversationModel,
                                       LeadModel, MessageModel, get_session)

router = APIRouter(prefix="/api/v1/analytics", tags=["analytics"])


@router.get("/overview")
async def analytics_overview(
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
    days: int = Query(30, ge=1, le=365),
):
    org_id = str(current_user.organization_id)
    since = datetime.utcnow() - timedelta(days=days)
    conv_count = await session.execute(
        select(func.count()).select_from(ConversationModel).where(
            ConversationModel.organization_id == org_id,
            ConversationModel.created_at >= since,
        )
    )
    msg_count = await session.execute(
        select(func.count()).select_from(MessageModel).where(
            MessageModel.organization_id == org_id,
            MessageModel.created_at >= since,
        )
    )
    lead_count = await session.execute(
        select(func.count()).select_from(LeadModel).where(
            LeadModel.organization_id == org_id,
            LeadModel.created_at >= since,
        )
    )
    qualified_count = await session.execute(
        select(func.count()).select_from(LeadModel).where(
            LeadModel.organization_id == org_id,
            LeadModel.status == "qualified",
            LeadModel.created_at >= since,
        )
    )
    converted_count = await session.execute(
        select(func.count()).select_from(LeadModel).where(
            LeadModel.organization_id == org_id,
            LeadModel.status == "converted",
            LeadModel.converted_at >= since if LeadModel.converted_at else True,
        )
    )
    total_conv = conv_count.scalar() or 0
    total_msg = msg_count.scalar() or 0
    total_leads = lead_count.scalar() or 0
    total_qualified = qualified_count.scalar() or 0
    total_converted = converted_count.scalar() or 0
    return {
        "period_days": days,
        "total_conversations": total_conv,
        "total_messages": total_msg,
        "total_leads": total_leads,
        "qualified_leads": total_qualified,
        "converted_leads": total_converted,
        "conversion_rate": round((total_converted / total_leads * 100), 2) if total_leads > 0 else 0,
        "qualification_rate": round((total_qualified / total_leads * 100), 2) if total_leads > 0 else 0,
    }


@router.get("/conversations")
async def conversation_metrics(
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
    days: int = Query(30, ge=1, le=365),
):
    org_id = str(current_user.organization_id)
    since = datetime.utcnow() - timedelta(days=days)
    results = await session.execute(
        select(
            func.date(ConversationModel.created_at).label("date"),
            func.count().label("count"),
        ).where(
            ConversationModel.organization_id == org_id,
            ConversationModel.created_at >= since,
        ).group_by(func.date(ConversationModel.created_at))
        .order_by(func.date(ConversationModel.created_at))
    )
    rows = results.all()
    return {
        "period_days": days,
        "metrics": [{"date": str(row.date), "count": row.count} for row in rows],
    }


@router.get("/leads")
async def lead_metrics(
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
    days: int = Query(30, ge=1, le=365),
):
    org_id = str(current_user.organization_id)
    since = datetime.utcnow() - timedelta(days=days)
    results = await session.execute(
        select(
            func.date(LeadModel.created_at).label("date"),
            func.count().label("count"),
        ).where(
            LeadModel.organization_id == org_id,
            LeadModel.created_at >= since,
        ).group_by(func.date(LeadModel.created_at))
        .order_by(func.date(LeadModel.created_at))
    )
    rows = results.all()
    status_counts = await session.execute(
        select(LeadModel.status, func.count().label("count")).where(
            LeadModel.organization_id == org_id,
        ).group_by(LeadModel.status)
    )
    status_rows = status_counts.all()
    return {
        "period_days": days,
        "daily": [{"date": str(row.date), "count": row.count} for row in rows],
        "by_status": {row.status: row.count for row in status_rows},
    }


@router.get("/response-time")
async def response_time_metrics(
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
    days: int = Query(30, ge=1, le=365),
):
    org_id = str(current_user.organization_id)
    since = datetime.utcnow() - timedelta(days=days)
    subquery = select(
        MessageModel.conversation_id,
        func.min(MessageModel.created_at).label("first_inbound"),
    ).where(
        MessageModel.organization_id == org_id,
        MessageModel.direction == "inbound",
        MessageModel.created_at >= since,
    ).group_by(MessageModel.conversation_id).subquery()
    response_query = select(
        MessageModel.conversation_id,
        func.min(MessageModel.created_at).label("first_response"),
    ).where(
        MessageModel.organization_id == org_id,
        MessageModel.direction == "outbound",
        MessageModel.is_ai_generated == False,
        MessageModel.created_at >= since,
    ).group_by(MessageModel.conversation_id).subquery()
    join_query = select(
        func.avg(
            func.julianday(response_query.c.first_response) - func.julianday(subquery.c.first_inbound)
        ).label("avg_days")
    ).select_from(
        subquery.join(response_query, subquery.c.conversation_id == response_query.c.conversation_id)
    )
    result = await session.execute(join_query)
    avg_days = result.scalar()
    avg_hours = round((avg_days or 0) * 24, 2)
    return {
        "period_days": days,
        "average_response_time_hours": avg_hours,
        "average_response_time_minutes": round(avg_hours * 60, 2),
    }


@router.get("/revenue")
async def revenue_metrics(
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
    days: int = Query(30, ge=1, le=365),
):
    org_id = str(current_user.organization_id)
    since = datetime.utcnow() - timedelta(days=days)
    events = await session.execute(
        select(AnalyticsEventModel).where(
            AnalyticsEventModel.organization_id == org_id,
            AnalyticsEventModel.metric == AnalyticsMetric.revenue_attributed.value,
            AnalyticsEventModel.recorded_at >= since,
        )
    )
    event_list = events.scalars().all()
    total_revenue = sum(e.value for e in event_list) if event_list else 0
    return {
        "period_days": days,
        "total_revenue": round(total_revenue, 2),
        "event_count": len(event_list),
    }


@router.get("/satisfaction")
async def satisfaction_metrics(
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
    days: int = Query(30, ge=1, le=365),
):
    org_id = str(current_user.organization_id)
    since = datetime.utcnow() - timedelta(days=days)
    events = await session.execute(
        select(AnalyticsEventModel).where(
            AnalyticsEventModel.organization_id == org_id,
            AnalyticsEventModel.metric == AnalyticsMetric.customer_satisfaction.value,
            AnalyticsEventModel.recorded_at >= since,
        )
    )
    event_list = events.scalars().all()
    avg_satisfaction = round(sum(e.value for e in event_list) / len(event_list), 2) if event_list else 0
    return {
        "period_days": days,
        "average_satisfaction": avg_satisfaction,
        "total_responses": len(event_list),
    }


@router.get("/model-usage")
async def model_usage_metrics(
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
    days: int = Query(30, ge=1, le=365),
):
    org_id = str(current_user.organization_id)
    since = datetime.utcnow() - timedelta(days=days)
    token_events = await session.execute(
        select(AnalyticsEventModel).where(
            AnalyticsEventModel.organization_id == org_id,
            AnalyticsEventModel.metric == AnalyticsMetric.token_usage.value,
            AnalyticsEventModel.recorded_at >= since,
        )
    )
    cost_events = await session.execute(
        select(AnalyticsEventModel).where(
            AnalyticsEventModel.organization_id == org_id,
            AnalyticsEventModel.metric == AnalyticsMetric.model_cost.value,
            AnalyticsEventModel.recorded_at >= since,
        )
    )
    total_tokens = sum(e.value for e in token_events.scalars().all())
    total_cost = sum(e.value for e in cost_events.scalars().all())
    return {
        "period_days": days,
        "total_tokens": int(total_tokens),
        "total_cost": round(total_cost, 4),
    }


@router.post("/events", status_code=201)
async def record_analytics_event(
    metric: str,
    value: float,
    tags: Optional[dict[str, str]] = None,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(get_current_user),
):
    org_id = str(current_user.organization_id)
    model = AnalyticsEventModel(
        id=str(uuid4()),
        organization_id=org_id,
        metric=metric,
        value=value,
        tags=tags or {},
    )
    session.add(model)
    await session.flush()
    return AnalyticsEvent.model_validate(model)
