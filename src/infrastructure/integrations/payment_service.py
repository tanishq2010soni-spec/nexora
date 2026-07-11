"""
Payment System Integration - Stripe and Razorpay.

Handles:
- Checkout sessions
- Subscription purchase/upgrade/downgrade/cancellation
- Webhook handling
- Invoice generation
- Payment history
"""

import datetime
import json
import uuid
from typing import Any, Dict, Optional

import httpx
import structlog
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from src.infrastructure.database.models import (
    Plan,
    Subscription,
    Invoice,
)

logger = structlog.get_logger(__name__)


class PaymentAPIError(Exception):
    """Raised when a payment API call fails."""
    def __init__(self, provider: str, status_code: int, detail: str):
        self.provider = provider
        self.status_code = status_code
        self.detail = detail
        super().__init__(f"{provider} API error {status_code}: {detail}")


class StripeService:
    """Stripe API integration service."""

    def __init__(self, secret_key: str):
        self.secret_key = secret_key
        self.base_url = "https://api.stripe.com/v1"
        self._client: Optional[httpx.AsyncClient] = None

    async def _get_client(self) -> httpx.AsyncClient:
        if self._client is None or self._client.is_closed:
            self._client = httpx.AsyncClient(timeout=30.0)
        return self._client

    def _headers(self) -> Dict[str, str]:
        return {"Authorization": f"Bearer {self.secret_key}"}

    async def close(self):
        if self._client and not self._client.is_closed:
            await self._client.aclose()

    async def create_checkout_session(
        self,
        price_id: str,
        customer_email: str,
        org_id: str,
        success_url: str,
        cancel_url: str,
        mode: str = "subscription",
    ) -> Dict[str, Any]:
        client = await self._get_client()
        response = await client.post(
            f"{self.base_url}/checkout/sessions",
            headers=self._headers(),
            data={
                "mode": mode,
                "line_items[0][price]": price_id,
                "line_items[0][quantity]": "1",
                "customer_email": customer_email,
                "success_url": success_url,
                "cancel_url": cancel_url,
                "metadata[org_id]": org_id,
            },
        )
        if response.status_code not in (200, 201):
            raise PaymentAPIError("stripe", response.status_code, response.text)
        return response.json()

    async def create_customer(self, email: str, name: Optional[str] = None) -> Dict[str, Any]:
        client = await self._get_client()
        data: Dict[str, Any] = {"email": email}
        if name:
            data["name"] = name
        response = await client.post(
            f"{self.base_url}/customers",
            headers=self._headers(),
            data=data,
        )
        if response.status_code not in (200, 201):
            raise PaymentAPIError("stripe", response.status_code, response.text)
        return response.json()

    async def create_subscription(
        self, customer_id: str, price_id: str
    ) -> Dict[str, Any]:
        client = await self._get_client()
        response = await client.post(
            f"{self.base_url}/subscriptions",
            headers=self._headers(),
            data={
                "customer": customer_id,
                "items[0][price]": price_id,
                "payment_behavior": "default_incomplete",
                "expand[]": "latest_invoice.payment_intent",
            },
        )
        if response.status_code not in (200, 201):
            raise PaymentAPIError("stripe", response.status_code, response.text)
        return response.json()

    async def cancel_subscription(self, subscription_id: str) -> Dict[str, Any]:
        client = await self._get_client()
        response = await client.delete(
            f"{self.base_url}/subscriptions/{subscription_id}",
            headers=self._headers(),
        )
        if response.status_code not in (200, 201):
            raise PaymentAPIError("stripe", response.status_code, response.text)
        return response.json()

    async def retrieve_subscription(self, subscription_id: str) -> Dict[str, Any]:
        client = await self._get_client()
        response = await client.get(
            f"{self.base_url}/subscriptions/{subscription_id}",
            headers=self._headers(),
        )
        if response.status_code != 200:
            raise PaymentAPIError("stripe", response.status_code, response.text)
        return response.json()

    async def list_invoices(self, customer_id: str, limit: int = 20) -> Dict[str, Any]:
        client = await self._get_client()
        response = await client.get(
            f"{self.base_url}/invoices",
            headers=self._headers(),
            params={"customer": customer_id, "limit": str(limit)},
        )
        if response.status_code != 200:
            raise PaymentAPIError("stripe", response.status_code, response.text)
        return response.json()

    async def create_invoice_item(
        self, customer_id: str, amount: int, currency: str, description: str
    ) -> Dict[str, Any]:
        client = await self._get_client()
        response = await client.post(
            f"{self.base_url}/invoiceitems",
            headers=self._headers(),
            data={
                "customer": customer_id,
                "amount": str(amount),
                "currency": currency,
                "description": description,
            },
        )
        if response.status_code not in (200, 201):
            raise PaymentAPIError("stripe", response.status_code, response.text)
        return response.json()

    def verify_webhook_signature(
        self, payload: bytes, sig_header: str, endpoint_secret: str
    ) -> bool:
        import hmac
        import hashlib
        import time
        try:
            items = {}
            for item in sig_header.split(","):
                key, value = item.split("=", 1)
                items[key.strip()] = value.strip()

            timestamp = items.get("t", "")
            expected_sig = items.get("v1", "")

            # Reject signatures older than 5 minutes
            if timestamp and abs(time.time() - int(timestamp)) > 300:
                logger.warning("Stripe webhook signature timestamp expired", timestamp=timestamp)
                return False

            signed_payload = f"{timestamp}.{payload.decode()}"
            computed = hmac.new(
                endpoint_secret.encode(),
                signed_payload.encode(),
                hashlib.sha256,
            ).hexdigest()
            return hmac.compare_digest(computed, expected_sig)
        except Exception as e:
            logger.error("Stripe webhook signature verification failed", error=str(e))
            return False


class RazorpayService:
    """Razorpay API integration service."""

    def __init__(self, key_id: str, key_secret: str):
        self.key_id = key_id
        self.key_secret = key_secret
        self.base_url = "https://api.razorpay.com/v1"
        self._client: Optional[httpx.AsyncClient] = None

    async def _get_client(self) -> httpx.AsyncClient:
        if self._client is None or self._client.is_closed:
            self._client = httpx.AsyncClient(timeout=30.0)
        return self._client

    def _auth(self) -> tuple[str, str]:
        return (self.key_id, self.key_secret)

    async def close(self):
        if self._client and not self._client.is_closed:
            await self._client.aclose()

    async def create_customer(self, name: str, email: str, contact: Optional[str] = None) -> Dict[str, Any]:
        client = await self._get_client()
        data: Dict[str, Any] = {"name": name, "email": email}
        if contact:
            data["contact"] = contact
        response = await client.post(
            f"{self.base_url}/customers",
            json=data,
            auth=self._auth(),
        )
        if response.status_code not in (200, 201):
            raise PaymentAPIError("razorpay", response.status_code, response.text)
        return response.json()

    async def create_order(
        self,
        amount: int,
        currency: str,
        receipt: str,
        notes: Optional[Dict[str, str]] = None,
    ) -> Dict[str, Any]:
        client = await self._get_client()
        data: Dict[str, Any] = {
            "amount": amount,
            "currency": currency,
            "receipt": receipt,
        }
        if notes:
            data["notes"] = notes
        response = await client.post(
            f"{self.base_url}/orders",
            json=data,
            auth=self._auth(),
        )
        if response.status_code not in (200, 201):
            raise PaymentAPIError("razorpay", response.status_code, response.text)
        return response.json()

    async def create_subscription(
        self, plan_id: str, customer_id: str, total_count: int = 12
    ) -> Dict[str, Any]:
        client = await self._get_client()
        response = await client.post(
            f"{self.base_url}/subscriptions",
            json={
                "plan_id": plan_id,
                "customer_id": customer_id,
                "total_count": total_count,
            },
            auth=self._auth(),
        )
        if response.status_code not in (200, 201):
            raise PaymentAPIError("razorpay", response.status_code, response.text)
        return response.json()

    async def cancel_subscription(self, subscription_id: str, cancel_at_cycle_end: bool = True) -> Dict[str, Any]:
        client = await self._get_client()
        response = await client.post(
            f"{self.base_url}/subscriptions/{subscription_id}/cancel",
            json={"cancel_at_cycle_end": str(cancel_at_cycle_end).lower()},
            auth=self._auth(),
        )
        if response.status_code not in (200, 201):
            raise PaymentAPIError("razorpay", response.status_code, response.text)
        return response.json()

    async def fetch_subscription(self, subscription_id: str) -> Dict[str, Any]:
        client = await self._get_client()
        response = await client.get(
            f"{self.base_url}/subscriptions/{subscription_id}",
            auth=self._auth(),
        )
        if response.status_code != 200:
            raise PaymentAPIError("razorpay", response.status_code, response.text)
        return response.json()

    async def list_payments(self, count: int = 20) -> Dict[str, Any]:
        client = await self._get_client()
        response = await client.get(
            f"{self.base_url}/payments",
            params={"count": str(count)},
            auth=self._auth(),
        )
        if response.status_code != 200:
            raise PaymentAPIError("razorpay", response.status_code, response.text)
        return response.json()

    def verify_webhook_signature(
        self, payload: bytes, signature: str, secret: str
    ) -> bool:
        import hmac
        import hashlib
        import base64
        try:
            expected = hmac.new(
                secret.encode(), payload, hashlib.sha256
            ).digest()
            expected_b64 = base64.b64encode(expected).decode()
            return hmac.compare_digest(expected_b64, signature)
        except Exception as e:
            logger.error("Razorpay webhook signature verification failed", error=str(e))
            return False


class PaymentService:
    """Unified payment service for managing subscriptions and invoices."""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def _resolve_plan_id_from_stripe_price(
        self, stripe_price_id: str
    ) -> Optional[uuid.UUID]:
        """Look up the internal Plan UUID from a Stripe price ID."""
        stmt = select(Plan).where(Plan.stripe_price_id == stripe_price_id)
        result = await self.db.execute(stmt)
        plan = result.scalar_one_or_none()
        return plan.id if plan else None

    async def _resolve_plan_id_from_razorpay_plan(
        self, razorpay_plan_id: str
    ) -> Optional[uuid.UUID]:
        """Look up the internal Plan UUID from a Razorpay plan ID."""
        stmt = select(Plan).where(Plan.razorpay_plan_id == razorpay_plan_id)
        result = await self.db.execute(stmt)
        plan = result.scalar_one_or_none()
        return plan.id if plan else None

    async def activate_subscription(
        self,
        org_id: uuid.UUID,
        plan_id: uuid.UUID,
        provider: str,
        provider_subscription_id: str,
        billing_cycle: str = "monthly",
    ) -> Subscription:
        now = datetime.datetime.now(datetime.timezone.utc)
        expires = now + datetime.timedelta(days=365 if billing_cycle == "yearly" else 30)

        sub_stmt = select(Subscription).where(
            Subscription.org_id == org_id,
            Subscription.status == "active",
        )
        existing = (await self.db.execute(sub_stmt)).scalar_one_or_none()
        if existing:
            existing.status = "cancelled"
            existing.expires_at = now

        sub = Subscription(
            id=uuid.uuid4(),
            org_id=org_id,
            plan_id=plan_id,
            billing_cycle=billing_cycle,
            status="active",
            provider=provider,
            provider_subscription_id=provider_subscription_id,
            started_at=now,
            expires_at=expires,
            created_at=now,
        )
        self.db.add(sub)
        await self.db.flush()
        return sub

    async def create_invoice(
        self,
        org_id: uuid.UUID,
        amount: float,
        currency: str,
        status: str,
        provider: str,
        provider_invoice_id: Optional[str] = None,
        subscription_id: Optional[uuid.UUID] = None,
        pdf_url: Optional[str] = None,
    ) -> Invoice:
        now = datetime.datetime.now(datetime.timezone.utc)
        invoice = Invoice(
            id=uuid.uuid4(),
            org_id=org_id,
            subscription_id=subscription_id,
            amount=amount,
            currency=currency,
            status=status,
            provider=provider,
            provider_invoice_id=provider_invoice_id,
            pdf_url=pdf_url,
            created_at=now,
        )
        self.db.add(invoice)
        await self.db.flush()
        return invoice

    async def handle_stripe_webhook(self, event_type: str, data: Dict[str, Any]) -> Dict[str, Any]:
        try:
            if event_type == "checkout.session.completed":
                session = data.get("object", {})
                org_id = session.get("metadata", {}).get("org_id")
                subscription_id = session.get("subscription")
                price_id = session.get("metadata", {}).get("price_id")

                if not price_id:
                    # Try to extract from line_items if metadata missing
                    line_items = session.get("line_items", {})
                    if line_items and line_items.get("data"):
                        price_id = line_items["data"][0].get("price", {}).get("id")

                if org_id and subscription_id:
                    plan_uuid = None
                    if price_id:
                        plan_uuid = await self._resolve_plan_id_from_stripe_price(price_id)
                    if not plan_uuid:
                        logger.warning(
                            "Could not resolve plan from Stripe price_id",
                            price_id=price_id,
                            org_id=org_id,
                        )
                        # Use the org's default plan
                        plan_uuid = await self._get_default_plan_id(org_id)

                    await self.activate_subscription(
                        org_id=uuid.UUID(org_id),
                        plan_id=plan_uuid or uuid.uuid4(),
                        provider="stripe",
                        provider_subscription_id=subscription_id,
                    )
                    return {"status": "activated"}

            elif event_type == "invoice.paid":
                invoice = data.get("object", {})
                org_id = invoice.get("metadata", {}).get("org_id")
                if org_id:
                    await self.create_invoice(
                        org_id=uuid.UUID(org_id),
                        amount=invoice.get("amount_paid", 0) / 100,
                        currency=invoice.get("currency", "usd"),
                        status="paid",
                        provider="stripe",
                        provider_invoice_id=invoice.get("id"),
                    )
                    return {"status": "invoice_created"}

            elif event_type == "customer.subscription.deleted":
                subscription = data.get("object", {})
                provider_sub_id = subscription.get("id")
                if provider_sub_id:
                    stmt = select(Subscription).where(
                        Subscription.provider_subscription_id == provider_sub_id,
                        Subscription.provider == "stripe",
                    )
                    result = await self.db.execute(stmt)
                    sub = result.scalar_one_or_none()
                    if sub:
                        sub.status = "cancelled"
                        sub.expires_at = datetime.datetime.now(datetime.timezone.utc)
                        await self.db.flush()
                    return {"status": "cancelled"}

            return {"status": "unhandled"}

        except Exception as e:
            logger.error("Stripe webhook handling failed", event_type=event_type, error=str(e))
            raise

    async def handle_razorpay_webhook(self, event_type: str, data: Dict[str, Any]) -> Dict[str, Any]:
        try:
            if event_type == "subscription.activated":
                subscription = data.get("subscription", {})
                entity = data.get("entity", {})
                org_id = entity.get("notes", {}).get("org_id")
                razorpay_plan_id = subscription.get("plan_id")

                if org_id and subscription.get("id"):
                    plan_uuid = None
                    if razorpay_plan_id:
                        plan_uuid = await self._resolve_plan_id_from_razorpay_plan(razorpay_plan_id)
                    if not plan_uuid:
                        plan_uuid = await self._get_default_plan_id(org_id)

                    await self.activate_subscription(
                        org_id=uuid.UUID(org_id),
                        plan_id=plan_uuid or uuid.uuid4(),
                        provider="razorpay",
                        provider_subscription_id=subscription["id"],
                    )
                    return {"status": "activated"}

            elif event_type == "payment.captured":
                payment = data.get("entity", {})
                org_id = payment.get("notes", {}).get("org_id")
                if org_id:
                    await self.create_invoice(
                        org_id=uuid.UUID(org_id),
                        amount=payment.get("amount", 0) / 100,
                        currency=payment.get("currency", "inr"),
                        status="paid",
                        provider="razorpay",
                        provider_invoice_id=payment.get("id"),
                    )
                    return {"status": "invoice_created"}

            elif event_type == "subscription.cancelled":
                subscription = data.get("subscription", {})
                provider_sub_id = subscription.get("id")
                if provider_sub_id:
                    stmt = select(Subscription).where(
                        Subscription.provider_subscription_id == provider_sub_id,
                        Subscription.provider == "razorpay",
                    )
                    result = await self.db.execute(stmt)
                    sub = result.scalar_one_or_none()
                    if sub:
                        sub.status = "cancelled"
                        sub.expires_at = datetime.datetime.now(datetime.timezone.utc)
                        await self.db.flush()
                    return {"status": "cancelled"}

            return {"status": "unhandled"}

        except Exception as e:
            logger.error("Razorpay webhook handling failed", event_type=event_type, error=str(e))
            raise

    async def _get_default_plan_id(self, org_id: str) -> Optional[uuid.UUID]:
        """Get the first active plan as fallback."""
        stmt = select(Plan).where(Plan.is_active == True).limit(1)
        result = await self.db.execute(stmt)
        plan = result.scalar_one_or_none()
        return plan.id if plan else None
