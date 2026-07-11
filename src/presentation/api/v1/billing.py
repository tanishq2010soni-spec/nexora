import uuid
import datetime
import json
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from pydantic import BaseModel, Field
from sqlalchemy import select, delete as sa_delete
from sqlalchemy.ext.asyncio import AsyncSession

from src.infrastructure.database.connection import get_db_session
from src.infrastructure.database.models import Plan, Subscription, Invoice
from src.presentation.api.dependencies import get_current_org_id, require_role

router = APIRouter()


class PlanResponse(BaseModel):
    id: uuid.UUID
    name: str
    slug: Optional[str] = None
    description: Optional[str] = None
    price_monthly: float
    price_yearly: float
    currency: str = "usd"
    trial_days: int = 0
    max_users: int = 1
    max_agents: int
    max_leads: int = 500
    max_conversations: int
    max_calls: int
    max_storage_mb: int
    features_json: Optional[str] = None
    is_active: bool
    created_at: str


class SubscriptionResponse(BaseModel):
    id: uuid.UUID
    org_id: uuid.UUID
    plan_id: Optional[uuid.UUID] = None
    billing_cycle: str
    status: str
    provider: str
    provider_subscription_id: Optional[str] = None
    started_at: str
    expires_at: Optional[str] = None
    trial_ends_at: Optional[str] = None
    created_at: str


class InvoiceResponse(BaseModel):
    id: uuid.UUID
    org_id: uuid.UUID
    subscription_id: Optional[uuid.UUID] = None
    amount: float
    currency: str
    status: str
    provider: str
    provider_invoice_id: Optional[str] = None
    pdf_url: Optional[str] = None
    created_at: str


class CreateSubscriptionRequest(BaseModel):
    plan_id: uuid.UUID
    billing_cycle: str = Field(default="monthly", pattern="^(monthly|yearly)$")
    provider: str = Field(..., pattern="^(stripe|razorpay)$")
    provider_subscription_id: Optional[str] = None


def _plan_to_response(p) -> PlanResponse:
    return PlanResponse(
        id=p.id, name=p.name, slug=getattr(p, 'slug', None), description=p.description,
        price_monthly=p.price_monthly, price_yearly=p.price_yearly,
        currency=getattr(p, 'currency', 'usd'), trial_days=getattr(p, 'trial_days', 0),
        max_users=getattr(p, 'max_users', 1), max_agents=p.max_agents,
        max_leads=getattr(p, 'max_leads', 500),
        max_conversations=p.max_conversations, max_calls=p.max_calls,
        max_storage_mb=p.max_storage_mb, features_json=p.features_json,
        is_active=p.is_active, created_at=p.created_at.isoformat(),
    )


def _sub_to_response(s) -> SubscriptionResponse:
    return SubscriptionResponse(
        id=s.id, org_id=s.org_id, plan_id=s.plan_id, billing_cycle=s.billing_cycle,
        status=s.status, provider=s.provider, provider_subscription_id=s.provider_subscription_id,
        started_at=s.started_at.isoformat(),
        expires_at=s.expires_at.isoformat() if s.expires_at else None,
        trial_ends_at=s.trial_ends_at.isoformat() if s.trial_ends_at else None,
        created_at=s.created_at.isoformat(),
    )


def _inv_to_response(i) -> InvoiceResponse:
    return InvoiceResponse(
        id=i.id, org_id=i.org_id, subscription_id=i.subscription_id,
        amount=i.amount, currency=i.currency, status=i.status, provider=i.provider,
        provider_invoice_id=i.provider_invoice_id, pdf_url=i.pdf_url,
        created_at=i.created_at.isoformat(),
    )


@router.get("/plans", response_model=List[PlanResponse])
async def list_plans(db: AsyncSession = Depends(get_db_session)) -> List[PlanResponse]:
    stmt = select(Plan).where(Plan.is_active == True).order_by(Plan.price_monthly.asc())
    result = await db.execute(stmt)
    return [_plan_to_response(p) for p in result.scalars().all()]


@router.get("/subscription", response_model=Optional[SubscriptionResponse])
async def get_subscription(
    org_id: uuid.UUID = Depends(get_current_org_id), db: AsyncSession = Depends(get_db_session),
) -> Optional[SubscriptionResponse]:
    stmt = select(Subscription).where(Subscription.org_id == org_id).order_by(Subscription.created_at.desc()).limit(1)
    result = await db.execute(stmt)
    sub = result.scalar_one_or_none()
    return _sub_to_response(sub) if sub else None


@router.post("/subscription", response_model=SubscriptionResponse, status_code=status.HTTP_201_CREATED)
async def create_subscription(
    data: CreateSubscriptionRequest, org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session), _=Depends(require_role("admin")),
) -> SubscriptionResponse:
    now = datetime.datetime.now(datetime.timezone.utc)
    sub = Subscription(
        id=uuid.uuid4(), org_id=org_id, plan_id=data.plan_id,
        billing_cycle=data.billing_cycle, status="active",
        provider=data.provider, provider_subscription_id=data.provider_subscription_id,
        started_at=now, created_at=now,
    )
    db.add(sub)
    await db.commit()
    await db.refresh(sub)
    return _sub_to_response(sub)


class StartTrialRequest(BaseModel):
    plan_id: uuid.UUID
    billing_cycle: str = Field(default="monthly", pattern="^(monthly|yearly)$")


@router.post("/trial", response_model=SubscriptionResponse, status_code=status.HTTP_201_CREATED)
async def start_trial(
    data: StartTrialRequest, org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session), _=Depends(require_role("admin")),
) -> SubscriptionResponse:
    now = datetime.datetime.now(datetime.timezone.utc)

    existing = await db.execute(
        select(Subscription).where(
            Subscription.org_id == org_id,
            Subscription.status.in_(["active", "trialing"]),
        )
    )
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="Organization already has an active subscription or trial")

    plan = await db.get(Plan, data.plan_id)
    if not plan:
        raise HTTPException(status_code=404, detail="Plan not found")

    trial_days = plan.trial_days or 14
    trial_ends = now + datetime.timedelta(days=trial_days)

    sub = Subscription(
        id=uuid.uuid4(), org_id=org_id, plan_id=data.plan_id,
        billing_cycle=data.billing_cycle, status="trialing",
        provider="internal", provider_subscription_id=None,
        started_at=now, trial_ends_at=trial_ends, expires_at=trial_ends,
        created_at=now,
    )
    db.add(sub)
    await db.commit()
    await db.refresh(sub)
    return _sub_to_response(sub)


@router.post("/subscription/{subscription_id}/cancel", response_model=SubscriptionResponse)
async def cancel_subscription(
    subscription_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin")),
) -> SubscriptionResponse:
    stmt = select(Subscription).where(
        Subscription.id == subscription_id, Subscription.org_id == org_id,
    )
    result = await db.execute(stmt)
    sub = result.scalar_one_or_none()
    if not sub:
        raise HTTPException(status_code=404, detail="Subscription not found")
    if sub.status in ("cancelled", "expired"):
        raise HTTPException(status_code=400, detail="Subscription already cancelled")

    sub.status = "cancelled"
    sub.expires_at = datetime.datetime.now(datetime.timezone.utc)
    await db.commit()
    await db.refresh(sub)
    return _sub_to_response(sub)


@router.get("/invoices", response_model=List[InvoiceResponse])
async def list_invoices(
    org_id: uuid.UUID = Depends(get_current_org_id), db: AsyncSession = Depends(get_db_session),
    limit: int = Query(default=50, ge=1, le=200), offset: int = Query(default=0, ge=0),
) -> List[InvoiceResponse]:
    stmt = select(Invoice).where(Invoice.org_id == org_id).order_by(Invoice.created_at.desc()).limit(limit).offset(offset)
    result = await db.execute(stmt)
    return [_inv_to_response(i) for i in result.scalars().all()]


@router.get("/usage")
async def usage_tracking(
    org_id: uuid.UUID = Depends(get_current_org_id), db: AsyncSession = Depends(get_db_session),
) -> dict:
    now = datetime.datetime.now(datetime.timezone.utc)
    month_start = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)

    from src.infrastructure.database.models import InboxConversation, Call
    from sqlalchemy import func

    conv_stmt = select(func.count()).select_from(InboxConversation).where(
        InboxConversation.org_id == org_id, InboxConversation.created_at >= month_start
    )
    conv_result = await db.execute(conv_stmt)
    conversations_used = conv_result.scalar() or 0

    call_stmt = select(func.count()).select_from(Call).where(
        Call.org_id == org_id, Call.created_at >= month_start
    )
    call_result = await db.execute(call_stmt)
    calls_used = call_result.scalar() or 0

    sub_stmt = select(Subscription).where(Subscription.org_id == org_id, Subscription.status == "active").limit(1)
    sub_result = await db.execute(sub_stmt)
    sub = sub_result.scalar_one_or_none()

    plan_limits = {"max_conversations": 1000, "max_calls": 100, "max_agents": 3}
    if sub:
        plan_stmt = select(Plan).where(Plan.id == sub.plan_id)
        plan_result = await db.execute(plan_stmt)
        plan = plan_result.scalar_one_or_none()
        if plan:
            plan_limits = {
                "max_conversations": plan.max_conversations,
                "max_calls": plan.max_calls,
                "max_agents": plan.max_agents,
            }

    return {
        "period": month_start.isoformat(),
        "conversations_used": conversations_used,
        "conversations_limit": plan_limits["max_conversations"],
        "calls_used": calls_used,
        "calls_limit": plan_limits["max_calls"],
        "agents_limit": plan_limits["max_agents"],
    }


class CheckoutRequest(BaseModel):
    plan_id: uuid.UUID
    billing_cycle: str = Field(default="monthly", pattern="^(monthly|yearly)$")
    provider: str = Field(..., pattern="^(stripe|razorpay)$")
    success_url: str = Field(..., min_length=1)
    cancel_url: str = Field(..., min_length=1)


@router.post("/checkout")
async def create_checkout_session(
    data: CheckoutRequest,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin")),
) -> dict:
    from src.config import settings

    plan_stmt = select(Plan).where(Plan.id == data.plan_id, Plan.is_active == True)
    plan_result = await db.execute(plan_stmt)
    plan = plan_result.scalar_one_or_none()
    if not plan:
        raise HTTPException(status_code=404, detail="Plan not found.")

    if data.provider == "stripe":
        stripe_key = getattr(settings, "STRIPE_SECRET_KEY", "")
        if not stripe_key:
            raise HTTPException(status_code=400, detail="Stripe not configured.")
        from src.infrastructure.integrations.payment_service import StripeService
        svc = StripeService(stripe_key)
        price_id = plan.features_json and plan.features_json.split("stripe_price_id:")[1].split(",")[0] if plan.features_json and "stripe_price_id:" in plan.features_json else ""
        if not price_id:
            raise HTTPException(status_code=400, detail="Stripe price ID not configured for this plan.")
        result = await svc.create_checkout_session(
            price_id=price_id,
            customer_email="",
            org_id=str(org_id),
            success_url=data.success_url,
            cancel_url=data.cancel_url,
        )
        return {"checkout_url": result.get("url"), "session_id": result.get("id")}

    elif data.provider == "razorpay":
        razorpay_key = getattr(settings, "RAZORPAY_KEY_ID", "")
        razorpay_secret = getattr(settings, "RAZORPAY_KEY_SECRET", "")
        if not razorpay_key or not razorpay_secret:
            raise HTTPException(status_code=400, detail="Razorpay not configured.")
        from src.infrastructure.integrations.payment_service import RazorpayService
        svc = RazorpayService(razorpay_key, razorpay_secret)
        amount = int(plan.price_monthly * 100 if data.billing_cycle == "monthly" else plan.price_yearly * 100)
        order = await svc.create_order(
            amount=amount,
            currency="INR",
            receipt=f"org_{org_id}_plan_{plan.id}",
            notes={"org_id": str(org_id), "plan_id": str(plan.id)},
        )
        return {"order_id": order.get("id"), "amount": amount, "currency": order.get("currency")}

    raise HTTPException(status_code=400, detail="Unsupported provider.")


@router.post("/webhook/stripe")
async def stripe_webhook(request: Request, db: AsyncSession = Depends(get_db_session)) -> dict:
    from src.config import settings
    from src.infrastructure.integrations.payment_service import PaymentService, StripeService

    payload = await request.body()
    sig_header = request.headers.get("stripe-signature", "")

    stripe_secret = getattr(settings, "STRIPE_WEBHOOK_SECRET", "")
    if not stripe_secret:
        raise HTTPException(
            status_code=503,
            detail="Stripe webhook secret not configured. Webhooks disabled.",
        )
    if not StripeService.verify_webhook_signature(payload, sig_header, stripe_secret):
        raise HTTPException(status_code=400, detail="Invalid signature")

    try:
        event = json.loads(payload)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid payload")

    service = PaymentService(db)
    result = await service.handle_stripe_webhook(event.get("type", ""), event.get("data", {}))
    await db.commit()
    return result


@router.post("/webhook/razorpay")
async def razorpay_webhook(request: Request, db: AsyncSession = Depends(get_db_session)) -> dict:
    from src.config import settings
    from src.infrastructure.integrations.payment_service import PaymentService, RazorpayService

    payload = await request.body()
    signature = request.headers.get("x-razorpay-signature", "")

    razorpay_secret = getattr(settings, "RAZORPAY_WEBHOOK_SECRET", "")
    if not razorpay_secret:
        raise HTTPException(
            status_code=503,
            detail="Razorpay webhook secret not configured. Webhooks disabled.",
        )
    if not RazorpayService.verify_webhook_signature(payload, signature, razorpay_secret):
        raise HTTPException(status_code=400, detail="Invalid signature")

    try:
        event = json.loads(payload)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid payload")

    service = PaymentService(db)
    result = await service.handle_razorpay_webhook(event.get("event", ""), event.get("payload", {}))
    await db.commit()
    return result
