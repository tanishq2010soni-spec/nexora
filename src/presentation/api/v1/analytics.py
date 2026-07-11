import uuid
import datetime
from typing import Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy import select, func, case, and_, or_
from sqlalchemy.ext.asyncio import AsyncSession

from src.infrastructure.database.connection import get_db_session
from src.infrastructure.database.models import (
    Organization, User, Agent, Lead, Customer, InboxConversation,
    InboxMessage, Call, Task, Workflow, WorkflowExecution,
    ChatSession, Message, Subscription, Plan,
)
from src.presentation.api.dependencies import get_current_org_id

router = APIRouter()


@router.get("/executive")
async def executive_dashboard(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    days: int = Query(default=30, ge=1, le=365),
) -> dict:
    now = datetime.datetime.now(datetime.timezone.utc)
    month_start = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
    week_start = now - datetime.timedelta(days=now.weekday())
    week_start = week_start.replace(hour=0, minute=0, second=0, microsecond=0)
    period_start = now - datetime.timedelta(days=days)

    async def _count(stmt):
        return (await db.execute(stmt)).scalar() or 0

    total_leads = await _count(select(func.count()).select_from(Lead).where(Lead.org_id == org_id))
    leads_this_month = await _count(select(func.count()).select_from(Lead).where(Lead.org_id == org_id, Lead.created_at >= month_start))
    leads_converted = await _count(select(func.count()).select_from(Lead).where(Lead.org_id == org_id, Lead.status == "converted"))
    total_customers = await _count(select(func.count()).select_from(Customer).where(Customer.org_id == org_id))
    total_agents = await _count(select(func.count()).select_from(Agent).where(Agent.org_id == org_id))
    total_conversations = await _count(select(func.count()).select_from(InboxConversation).where(InboxConversation.org_id == org_id))
    open_conversations = await _count(select(func.count()).select_from(InboxConversation).where(InboxConversation.org_id == org_id, InboxConversation.status == "open"))
    messages_today = await _count(select(func.count()).select_from(InboxMessage).join(InboxConversation).where(InboxConversation.org_id == org_id, InboxMessage.created_at >= now.replace(hour=0, minute=0, second=0, microsecond=0)))
    total_calls = await _count(select(func.count()).select_from(Call).where(Call.org_id == org_id))
    calls_this_week = await _count(select(func.count()).select_from(Call).where(Call.org_id == org_id, Call.created_at >= week_start))
    total_tasks = await _count(select(func.count()).select_from(Task).where(Task.org_id == org_id))
    pending_tasks = await _count(select(func.count()).select_from(Task).where(Task.org_id == org_id, Task.status == "pending"))
    completed_tasks = await _count(select(func.count()).select_from(Task).where(Task.org_id == org_id, Task.status == "completed"))
    active_workflows = await _count(select(func.count()).select_from(Workflow).where(Workflow.org_id == org_id, Workflow.is_active == True))

    lead_conversion_rate = round((leads_converted / total_leads * 100), 1) if total_leads > 0 else 0.0

    msg_stmt = select(func.count()).select_from(InboxMessage).join(InboxConversation).where(
        InboxConversation.org_id == org_id,
        InboxMessage.sender_type == "user",
        InboxMessage.created_at >= period_start,
    )
    user_msg_count = (await db.execute(msg_stmt)).scalar() or 0

    agent_reply_stmt = select(func.count()).select_from(InboxMessage).join(InboxConversation).where(
        InboxConversation.org_id == org_id,
        InboxMessage.sender_type.in_(["agent", "bot"]),
        InboxMessage.created_at >= period_start,
    )
    agent_msg_count = (await db.execute(agent_reply_stmt)).scalar() or 0

    avg_response_time = 0
    if user_msg_count > 0 and agent_msg_count > 0:
        avg_response_time = round(user_msg_count / max(agent_msg_count, 1) * 30, 1)

    completed_calls = await _count(select(func.count()).select_from(Call).where(Call.org_id == org_id, Call.status == "completed"))
    agent_utilization = round((completed_calls / max(total_agents, 1)), 1) if total_agents > 0 else 0.0

    ai_resolved = await _count(
        select(func.count()).select_from(InboxConversation).where(
            InboxConversation.org_id == org_id,
            InboxConversation.takeover_mode == "ai",
            InboxConversation.status == "closed",
        )
    )
    ai_resolution_rate = round((ai_resolved / max(total_conversations, 1) * 100), 1) if total_conversations > 0 else 0.0

    return {
        "summary": {
            "total_leads": total_leads,
            "leads_this_month": leads_this_month,
            "leads_converted": leads_converted,
            "total_customers": total_customers,
            "total_agents": total_agents,
            "total_conversations": total_conversations,
            "open_conversations": open_conversations,
            "messages_today": messages_today,
            "total_calls": total_calls,
            "calls_this_week": calls_this_week,
            "total_tasks": total_tasks,
            "pending_tasks": pending_tasks,
            "completed_tasks": completed_tasks,
            "active_workflows": active_workflows,
        },
        "kpis": {
            "lead_conversion_rate": lead_conversion_rate,
            "avg_response_time_seconds": avg_response_time,
            "agent_utilization_rate": agent_utilization,
            "ai_resolution_rate": ai_resolution_rate,
        },
    }


@router.get("/revenue")
async def revenue_analytics(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> dict:
    now = datetime.datetime.now(datetime.timezone.utc)
    month_start = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
    last_month_start = (month_start - datetime.timedelta(days=1)).replace(day=1)

    sub_stmt = select(Subscription).where(
        Subscription.org_id == org_id,
        Subscription.status == "active",
    )
    sub_result = await db.execute(sub_stmt)
    active_sub = sub_result.scalar_one_or_none()

    current_mrr = 0.0
    plan_name = "None"
    if active_sub:
        plan_stmt = select(Plan).where(Plan.id == active_sub.plan_id)
        plan_result = await db.execute(plan_stmt)
        plan = plan_result.scalar_one_or_none()
        if plan:
            current_mrr = plan.price_monthly if active_sub.billing_cycle == "monthly" else plan.price_yearly / 12
            plan_name = plan.name

    invoice_stmt = select(func.coalesce(func.sum(Invoice.amount), 0.0)).where(
        Invoice.org_id == org_id,
        Invoice.status == "paid",
        Invoice.created_at >= month_start,
    )
    monthly_revenue = (await db.execute(invoice_stmt)).scalar() or 0.0

    last_month_stmt = select(func.coalesce(func.sum(Invoice.amount), 0.0)).where(
        Invoice.org_id == org_id,
        Invoice.status == "paid",
        Invoice.created_at >= last_month_start,
        Invoice.created_at < month_start,
    )
    last_month_revenue = (await db.execute(last_month_stmt)).scalar() or 0.0

    total_revenue_stmt = select(func.coalesce(func.sum(Invoice.amount), 0.0)).where(
        Invoice.org_id == org_id,
        Invoice.status == "paid",
    )
    total_revenue = (await db.execute(total_revenue_stmt)).scalar() or 0.0

    revenue_growth = 0.0
    if last_month_revenue > 0:
        revenue_growth = round(((monthly_revenue - last_month_revenue) / last_month_revenue * 100), 1)

    return {
        "current_mrr": current_mrr,
        "monthly_revenue": monthly_revenue,
        "last_month_revenue": last_month_revenue,
        "total_revenue": total_revenue,
        "revenue_growth_pct": revenue_growth,
        "active_plan": plan_name,
        "has_subscription": active_sub is not None,
    }


@router.get("/leads/analytics")
async def lead_analytics(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    days: int = Query(default=30, ge=1, le=365),
) -> dict:
    now = datetime.datetime.now(datetime.timezone.utc)
    period_start = now - datetime.timedelta(days=days)

    total_stmt = select(func.count()).select_from(Lead).where(Lead.org_id == org_id)
    total_leads = (await db.execute(total_stmt)).scalar() or 0

    status_stmt = (
        select(Lead.status, func.count().label("cnt"))
        .where(Lead.org_id == org_id)
        .group_by(Lead.status)
    )
    status_rows = (await db.execute(status_stmt)).all()
    status_breakdown = {row.status: row.cnt for row in status_rows}

    assigned_count = (await db.execute(
        select(func.count()).select_from(Lead).where(Lead.org_id == org_id, Lead.assigned_to.isnot(None))
    )).scalar() or 0
    organic_count = total_leads - assigned_count
    source_breakdown = {"assigned": assigned_count, "organic": organic_count}

    avg_score_stmt = select(
        func.coalesce(func.avg(func.least(Lead.budget / 1000.0, 10.0)), 0.0)
    ).where(Lead.org_id == org_id, Lead.budget.isnot(None), Lead.budget > 0)
    avg_score = round((await db.execute(avg_score_stmt)).scalar() or 0.0, 1)

    converted_count = status_breakdown.get("converted", 0)
    conversion_rate = round(converted_count / total_leads * 100, 1) if total_leads > 0 else 0.0

    recent_stmt = select(func.count()).select_from(Lead).where(Lead.org_id == org_id, Lead.created_at >= period_start)
    recent_leads = (await db.execute(recent_stmt)).scalar() or 0

    daily_stmt = (
        select(
            func.date_trunc("day", Lead.created_at).label("day"),
            func.count().label("cnt"),
        )
        .where(Lead.org_id == org_id, Lead.created_at >= period_start)
        .group_by(func.date_trunc("day", Lead.created_at))
        .order_by(func.date_trunc("day", Lead.created_at))
    )
    daily_rows = (await db.execute(daily_stmt)).all()
    daily_trend = {row.day.strftime("%Y-%m-%d"): row.cnt for row in daily_rows if row.day}

    return {
        "total_leads": total_leads,
        "recent_leads": recent_leads,
        "converted_leads": converted_count,
        "conversion_rate": conversion_rate,
        "status_breakdown": status_breakdown,
        "source_breakdown": source_breakdown,
        "avg_score": avg_score,
        "daily_trend": daily_trend,
    }


@router.get("/customers/analytics")
async def customer_analytics(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    days: int = Query(default=30, ge=1, le=365),
) -> dict:
    now = datetime.datetime.now(datetime.timezone.utc)
    period_start = now - datetime.timedelta(days=days)
    six_months_ago = now - datetime.timedelta(days=180)

    total_stmt = select(func.count()).select_from(Customer).where(Customer.org_id == org_id)
    total_customers = (await db.execute(total_stmt)).scalar() or 0

    seg_stmt = (
        select(func.coalesce(Customer.segment, "unassigned").label("seg"), func.count().label("cnt"))
        .where(Customer.org_id == org_id)
        .group_by(func.coalesce(Customer.segment, "unassigned"))
    )
    seg_rows = (await db.execute(seg_stmt)).all()
    segment_breakdown = {row.seg: row.cnt for row in seg_rows}

    new_stmt = select(func.count()).select_from(Customer).where(
        Customer.org_id == org_id, Customer.created_at >= period_start
    )
    new_this_period = (await db.execute(new_stmt)).scalar() or 0

    active_stmt = select(func.count()).select_from(Customer).where(
        Customer.org_id == org_id, Customer.updated_at >= six_months_ago
    )
    active_customers = (await db.execute(active_stmt)).scalar() or 0

    retention_rate = round(active_customers / total_customers * 100, 1) if total_customers > 0 else 0.0

    conv_stmt = select(func.count()).select_from(InboxConversation).where(
        InboxConversation.org_id == org_id, InboxConversation.status == "closed",
    )
    total_conversations = (await db.execute(conv_stmt)).scalar() or 0
    avg_lifetime_value = round(total_conversations / total_customers, 1) if total_customers > 0 else 0.0

    daily_stmt = (
        select(
            func.date_trunc("day", Customer.created_at).label("day"),
            func.count().label("cnt"),
        )
        .where(Customer.org_id == org_id, Customer.created_at >= period_start)
        .group_by(func.date_trunc("day", Customer.created_at))
        .order_by(func.date_trunc("day", Customer.created_at))
    )
    daily_rows = (await db.execute(daily_stmt)).all()
    daily_trend = {row.day.strftime("%Y-%m-%d"): row.cnt for row in daily_rows if row.day}

    return {
        "total_customers": total_customers,
        "new_this_period": new_this_period,
        "active_customers": active_customers,
        "segment_breakdown": segment_breakdown,
        "retention_rate": retention_rate,
        "avg_lifetime_value": avg_lifetime_value,
        "daily_trend": daily_trend,
    }


@router.get("/conversations/analytics")
async def conversation_analytics(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    days: int = Query(default=30, ge=1, le=365),
) -> dict:
    now = datetime.datetime.now(datetime.timezone.utc)
    period_start = now - datetime.timedelta(days=days)

    total_convs_stmt = select(func.count()).select_from(InboxConversation).where(InboxConversation.org_id == org_id)
    total_convs = (await db.execute(total_convs_stmt)).scalar() or 0

    channel_stmt = (
        select(InboxConversation.channel, func.count().label("cnt"))
        .where(InboxConversation.org_id == org_id)
        .group_by(InboxConversation.channel)
    )
    channel_rows = (await db.execute(channel_stmt)).all()
    channel_breakdown = {row.channel: row.cnt for row in channel_rows}

    status_stmt = (
        select(InboxConversation.status, func.count().label("cnt"))
        .where(InboxConversation.org_id == org_id)
        .group_by(InboxConversation.status)
    )
    status_rows = (await db.execute(status_stmt)).all()
    status_breakdown = {row.status: row.cnt for row in status_rows}

    ai_stmt = select(func.count()).select_from(InboxConversation).where(
        InboxConversation.org_id == org_id, InboxConversation.takeover_mode == "ai",
    )
    ai_conversations = (await db.execute(ai_stmt)).scalar() or 0

    resolved_stmt = select(func.count()).select_from(InboxConversation).where(
        InboxConversation.org_id == org_id, InboxConversation.status == "closed",
    )
    resolved_conversations = (await db.execute(resolved_stmt)).scalar() or 0

    total_msg_stmt = select(func.count()).select_from(InboxMessage).join(InboxConversation).where(
        InboxConversation.org_id == org_id
    )
    total_messages = (await db.execute(total_msg_stmt)).scalar() or 0

    recent_msg_stmt = select(func.count()).select_from(InboxMessage).join(InboxConversation).where(
        InboxConversation.org_id == org_id, InboxMessage.created_at >= period_start,
    )
    recent_messages = (await db.execute(recent_msg_stmt)).scalar() or 0

    avg_messages = round(total_messages / total_convs, 1) if total_convs else 0.0
    ai_resolution_rate = round(ai_conversations / total_convs * 100, 1) if total_convs else 0.0
    resolution_rate = round(resolved_conversations / total_convs * 100, 1) if total_convs else 0.0

    first_response_stmt = select(
        func.avg(
            func.extract("epoch", InboxMessage.created_at) - func.extract("epoch", InboxConversation.created_at)
        )
    ).join(InboxConversation).where(
        InboxConversation.org_id == org_id,
        InboxMessage.sender_type.in_(["agent", "bot"]),
    )
    avg_first_response = (await db.execute(first_response_stmt)).scalar()
    avg_first_response_seconds = round(avg_first_response, 1) if avg_first_response else 0.0

    daily_stmt = (
        select(
            func.date_trunc("day", InboxConversation.created_at).label("day"),
            func.count().label("cnt"),
        )
        .where(InboxConversation.org_id == org_id, InboxConversation.created_at >= period_start)
        .group_by(func.date_trunc("day", InboxConversation.created_at))
        .order_by(func.date_trunc("day", InboxConversation.created_at))
    )
    daily_rows = (await db.execute(daily_stmt)).all()
    daily_trend = {row.day.strftime("%Y-%m-%d"): row.cnt for row in daily_rows if row.day}

    return {
        "total_conversations": total_convs,
        "total_messages": total_messages,
        "recent_messages": recent_messages,
        "channel_breakdown": channel_breakdown,
        "status_breakdown": status_breakdown,
        "avg_messages_per_conversation": avg_messages,
        "ai_resolution_rate": ai_resolution_rate,
        "resolution_rate": resolution_rate,
        "avg_first_response_seconds": avg_first_response_seconds,
        "daily_trend": daily_trend,
    }


@router.get("/calls/analytics")
async def calls_analytics(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    days: int = Query(default=30, ge=1, le=365),
) -> dict:
    now = datetime.datetime.now(datetime.timezone.utc)
    period_start = now - datetime.timedelta(days=days)

    total_stmt = select(func.count()).select_from(Call).where(Call.org_id == org_id)
    total = (await db.execute(total_stmt)).scalar() or 0

    direction_stmt = (
        select(Call.direction, func.count().label("cnt"))
        .where(Call.org_id == org_id)
        .group_by(Call.direction)
    )
    direction_rows = (await db.execute(direction_stmt)).all()
    direction_map = {row.direction: row.cnt for row in direction_rows}
    inbound = direction_map.get("inbound", 0)
    outbound = direction_map.get("outbound", 0)

    status_stmt = (
        select(Call.status, func.count().label("cnt"))
        .where(Call.org_id == org_id)
        .group_by(Call.status)
    )
    status_rows = (await db.execute(status_stmt)).all()
    status_map = {row.status: row.cnt for row in status_rows}
    completed = status_map.get("completed", 0)
    missed = status_map.get("missed", 0)
    failed = status_map.get("failed", 0)

    duration_stmt = select(func.coalesce(func.sum(Call.duration_seconds), 0)).where(
        Call.org_id == org_id, Call.status == "completed"
    )
    total_duration = (await db.execute(duration_stmt)).scalar() or 0
    avg_duration = round(total_duration / completed, 1) if completed else 0

    sentiment_stmt = (
        select(Call.sentiment, func.count().label("cnt"))
        .where(Call.org_id == org_id, Call.sentiment.isnot(None))
        .group_by(Call.sentiment)
    )
    sentiment_rows = (await db.execute(sentiment_stmt)).all()
    sentiment_breakdown = {row.sentiment: row.cnt for row in sentiment_rows}

    outcome_stmt = (
        select(Call.outcome, func.count().label("cnt"))
        .where(Call.org_id == org_id, Call.outcome.isnot(None))
        .group_by(Call.outcome)
    )
    outcome_rows = (await db.execute(outcome_stmt)).all()
    outcome_breakdown = {row.outcome: row.cnt for row in outcome_rows}

    recent_stmt = select(func.count()).select_from(Call).where(
        Call.org_id == org_id, Call.created_at >= period_start
    )
    recent_calls = (await db.execute(recent_stmt)).scalar() or 0

    daily_stmt = (
        select(
            func.date_trunc("day", Call.created_at).label("day"),
            func.count().label("cnt"),
        )
        .where(Call.org_id == org_id, Call.created_at >= period_start)
        .group_by(func.date_trunc("day", Call.created_at))
        .order_by(func.date_trunc("day", Call.created_at))
    )
    daily_rows = (await db.execute(daily_stmt)).all()
    daily_trend = {row.day.strftime("%Y-%m-%d"): row.cnt for row in daily_rows if row.day}

    return {
        "total_calls": total,
        "recent_calls": recent_calls,
        "inbound_calls": inbound,
        "outbound_calls": outbound,
        "completed_calls": completed,
        "missed_calls": missed,
        "failed_calls": failed,
        "total_duration_seconds": total_duration,
        "avg_duration_seconds": avg_duration,
        "answer_rate": round(completed / total * 100, 1) if total else 0.0,
        "miss_rate": round(missed / total * 100, 1) if total else 0.0,
        "sentiment_breakdown": sentiment_breakdown,
        "outcome_breakdown": outcome_breakdown,
        "daily_trend": daily_trend,
    }


@router.get("/agents/analytics")
async def agents_analytics(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> dict:
    agent_stmt = select(Agent).where(Agent.org_id == org_id)
    agents = (await db.execute(agent_stmt)).scalars().all()

    session_count_subq = (
        select(ChatSession.agent_id, func.count().label("session_count"))
        .group_by(ChatSession.agent_id)
        .subquery()
    )

    msg_count_subq = (
        select(
            ChatSession.agent_id,
            func.count().label("msg_count"),
        )
        .join(Message, Message.session_id == ChatSession.id)
        .where(Message.sender_type == "bot")
        .group_by(ChatSession.agent_id)
        .subquery()
    )

    agent_stats = []
    total_sessions = 0
    total_messages_handled = 0

    for agent in agents:
        sc = (await db.execute(
            select(session_count_subq.c.session_count).where(session_count_subq.c.agent_id == agent.id)
        )).scalar() or 0

        mc = (await db.execute(
            select(msg_count_subq.c.msg_count).where(msg_count_subq.c.agent_id == agent.id)
        )).scalar() or 0

        total_sessions += sc
        total_messages_handled += mc

        agent_stats.append({
            "agent_id": str(agent.id),
            "name": agent.name,
            "platform_type": agent.platform_type,
            "session_count": sc,
            "messages_handled": mc,
        })

    platform_stmt = (
        select(Agent.platform_type, func.count().label("cnt"))
        .where(Agent.org_id == org_id)
        .group_by(Agent.platform_type)
    )
    platform_rows = (await db.execute(platform_stmt)).all()
    platform_breakdown = {row.platform_type: row.cnt for row in platform_rows}

    return {
        "total_agents": len(agents),
        "total_sessions": total_sessions,
        "total_messages_handled": total_messages_handled,
        "avg_sessions_per_agent": round(total_sessions / len(agents), 1) if agents else 0,
        "platform_breakdown": platform_breakdown,
        "agent_stats": agent_stats,
    }


@router.get("/ai-performance")
async def ai_performance(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    days: int = Query(default=30, ge=1, le=365),
) -> dict:
    now = datetime.datetime.now(datetime.timezone.utc)
    period_start = now - datetime.timedelta(days=days)

    total_bot_msgs_stmt = select(func.count()).select_from(Message).join(ChatSession).join(Agent).where(
        Agent.org_id == org_id,
        Message.sender_type == "bot",
        Message.created_at >= period_start,
    )
    total_bot_messages = (await db.execute(total_bot_msgs_stmt)).scalar() or 0

    total_user_msgs_stmt = select(func.count()).select_from(Message).join(ChatSession).join(Agent).where(
        Agent.org_id == org_id,
        Message.sender_type == "user",
        Message.created_at >= period_start,
    )
    total_user_messages = (await db.execute(total_user_msgs_stmt)).scalar() or 0

    total_sessions_stmt = select(func.count()).select_from(ChatSession).join(Agent).where(
        Agent.org_id == org_id,
        ChatSession.created_at >= period_start,
    )
    total_sessions = (await db.execute(total_sessions_stmt)).scalar() or 0

    success_rate = round(total_bot_messages / max(total_user_messages, 1) * 100, 1) if total_user_messages > 0 else 0.0

    model_breakdown = {}
    agent_stmt = select(Agent).where(Agent.org_id == org_id)
    agent_result = await db.execute(agent_stmt)
    agents = agent_result.scalars().all()
    for agent in agents:
        model = agent.llm_model
        model_breakdown[model] = model_breakdown.get(model, 0) + 1

    avg_msg_length_stmt = select(func.avg(func.length(Message.content))).join(ChatSession).join(Agent).where(
        Agent.org_id == org_id,
        Message.sender_type == "bot",
        Message.created_at >= period_start,
    )
    avg_msg_length = (await db.execute(avg_msg_length_stmt)).scalar() or 0

    exec_stmt = select(func.count()).select_from(WorkflowExecution).join(Workflow).where(
        Workflow.org_id == org_id,
        WorkflowExecution.started_at >= period_start,
    )
    workflow_executions = (await db.execute(exec_stmt)).scalar() or 0

    exec_success_stmt = select(func.count()).select_from(WorkflowExecution).join(Workflow).where(
        Workflow.org_id == org_id,
        WorkflowExecution.status == "completed",
        WorkflowExecution.started_at >= period_start,
    )
    workflow_successes = (await db.execute(exec_success_stmt)).scalar() or 0

    return {
        "total_bot_messages": total_bot_messages,
        "total_user_messages": total_user_messages,
        "total_sessions": total_sessions,
        "success_rate": success_rate,
        "avg_response_length": round(avg_msg_length, 0),
        "model_breakdown": model_breakdown,
        "workflow_executions": workflow_executions,
        "workflow_success_rate": round(workflow_successes / max(workflow_executions, 1) * 100, 1),
        "period_days": days,
    }
