import uuid
from fastapi import APIRouter, Depends, status
from pydantic import BaseModel
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from src.infrastructure.database.connection import get_db_session
from src.infrastructure.database.models import Agent, Lead, Customer, ChatSession, Message
from src.presentation.api.dependencies import get_current_org_id

router = APIRouter()


class DashboardStatsResponse(BaseModel):
    active_agents: int = 0
    messages_today: int = 0
    calls_today: int = 0
    leads_generated: int = 0
    customers_managed: int = 0
    system_health: str = "healthy"


@router.get("/stats", response_model=DashboardStatsResponse, status_code=status.HTTP_200_OK)
async def get_dashboard_stats(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> DashboardStatsResponse:
    """
    Aggregated dashboard statistics for the Control Center.
    Returns counts for active agents, messages today, calls today,
    leads generated, customers managed, and system health.
    """
    import datetime

    now = datetime.datetime.now(datetime.timezone.utc)
    today_start = now.replace(hour=0, minute=0, second=0, microsecond=0)

    # Active agents count
    agent_stmt = select(func.count()).select_from(Agent).where(Agent.org_id == org_id)
    agent_result = await db.execute(agent_stmt)
    active_agents = agent_result.scalar_one() or 0

    # Messages today count
    msg_stmt = (
        select(func.count())
        .select_from(Message)
        .join(ChatSession, Message.session_id == ChatSession.id)
        .join(Agent, ChatSession.agent_id == Agent.id)
        .where(Agent.org_id == org_id, Message.created_at >= today_start)
    )
    msg_result = await db.execute(msg_stmt)
    messages_today = msg_result.scalar_one() or 0

    # Calls today count (chat sessions created today)
    call_stmt = (
        select(func.count())
        .select_from(ChatSession)
        .join(Agent, ChatSession.agent_id == Agent.id)
        .where(Agent.org_id == org_id, ChatSession.created_at >= today_start)
    )
    call_result = await db.execute(call_stmt)
    calls_today = call_result.scalar_one() or 0

    # Leads generated count
    lead_stmt = select(func.count()).select_from(Lead).where(Lead.org_id == org_id)
    lead_result = await db.execute(lead_stmt)
    leads_generated = lead_result.scalar_one() or 0

    # Customers managed count
    cust_stmt = select(func.count()).select_from(Customer).where(Customer.org_id == org_id)
    cust_result = await db.execute(cust_stmt)
    customers_managed = cust_result.scalar_one() or 0

    return DashboardStatsResponse(
        active_agents=active_agents,
        messages_today=messages_today,
        calls_today=calls_today,
        leads_generated=leads_generated,
        customers_managed=customers_managed,
        system_health="healthy",
    )
