import time
import uuid
from fastapi import APIRouter, Depends

try:
    import psutil
    HAS_PSUTIL = True
except ImportError:
    HAS_PSUTIL = False
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from src.infrastructure.database.connection import get_db_session
from src.infrastructure.database.models import (
    Lead, Customer, InboxConversation, Invoice, Subscription,
)
from src.presentation.api.dependencies import get_current_org_id

router = APIRouter()


@router.get("/metrics")
async def prometheus_metrics(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
):
    """Prometheus-format metrics endpoint."""
    now = time.time()

    # Business metrics — scoped to authenticated organization
    total_leads = (await db.execute(select(func.count(Lead.id)).where(Lead.org_id == org_id))).scalar() or 0
    total_customers = (await db.execute(select(func.count(Customer.id)).where(Customer.org_id == org_id))).scalar() or 0
    active_conversations = (await db.execute(
        select(func.count(InboxConversation.id)).where(
            InboxConversation.org_id == org_id,
            InboxConversation.status.in_(["active", "open"]),
        )
    )).scalar() or 0
    total_revenue = (await db.execute(
        select(func.coalesce(func.sum(Invoice.amount), 0)).where(
            Invoice.org_id == org_id,
            Invoice.status == "paid",
        )
    )).scalar() or 0
    active_subscriptions = (await db.execute(
        select(func.count(Subscription.id)).where(
            Subscription.org_id == org_id,
            Subscription.status.in_(["active", "trialing"]),
        )
    )).scalar() or 0

    # System metrics
    if HAS_PSUTIL:
        cpu_percent = psutil.cpu_percent(interval=0.1)
        memory = psutil.virtual_memory()
        disk = psutil.disk_usage("/")
    else:
        cpu_percent = 0.0
        memory = type('obj', (object,), {'used': 0, 'total': 100})()
        disk = type('obj', (object,), {'used': 0, 'total': 100})()

    lines = [
        '# HELP nexora_leads_total Total number of leads',
        '# TYPE nexora_leads_total counter',
        f'nexora_leads_total {total_leads}',
        '',
        '# HELP nexora_customers_total Total number of customers',
        '# TYPE nexora_customers_total counter',
        f'nexora_customers_total {total_customers}',
        '',
        '# HELP nexora_active_conversations Currently active conversations',
        '# TYPE nexora_active_conversations gauge',
        f'nexora_active_conversations {active_conversations}',
        '',
        '# HELP nexora_revenue_cents Total revenue in cents',
        '# TYPE nexora_revenue_cents counter',
        f'nexora_revenue_cents {total_revenue}',
        '',
        '# HELP nexora_active_subscriptions Active subscriptions',
        '# TYPE nexora_active_subscriptions gauge',
        f'nexora_active_subscriptions {active_subscriptions}',
        '',
        '# HELP nexora_cpu_usage_percent CPU usage',
        '# TYPE nexora_cpu_usage_percent gauge',
        f'nexora_cpu_usage_percent {cpu_percent}',
        '',
        '# HELP nexora_memory_usage_bytes Memory used in bytes',
        '# TYPE nexora_memory_usage_bytes gauge',
        f'nexora_memory_usage_bytes {memory.used}',
        '',
        '# HELP nexora_memory_total_bytes Total memory in bytes',
        '# TYPE nexora_memory_total_bytes gauge',
        f'nexora_memory_total_bytes {memory.total}',
        '',
        '# HELP nexora_disk_usage_bytes Disk used in bytes',
        '# TYPE nexora_disk_usage_bytes gauge',
        f'nexora_disk_usage_bytes {disk.used}',
        '',
        '# HELP nexora_disk_total_bytes Total disk in bytes',
        '# TYPE nexora_disk_total_bytes gauge',
        f'nexora_disk_total_bytes {disk.total}',
        '',
        '# HELP nexora_uptime_seconds Process uptime in seconds',
        '# TYPE nexora_uptime_seconds gauge',
        f'nexora_uptime_seconds {time.time() - _start_time}',
    ]

    from fastapi.responses import PlainTextResponse
    return PlainTextResponse(content="\n".join(lines), media_type="text/plain")


_start_time = time.time()
