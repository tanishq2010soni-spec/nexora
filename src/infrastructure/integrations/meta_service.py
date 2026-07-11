"""
Meta Omnichannel Integration - WhatsApp Cloud API, Facebook Messenger, Instagram Messaging.

Handles:
- Receiving messages via webhooks
- Sending messages via Graph API
- Typing indicators
- Delivery/read status
- Media support
- Customer linking
"""

import datetime
import hashlib
import hmac
import json
import uuid
from typing import Any, Dict, List, Optional

import httpx
import structlog
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from src.infrastructure.database.models import (
    InboxConversation,
    InboxMessage,
    Customer,
)
from src.infrastructure.realtime.connection_manager import manager
from src.config import settings

logger = structlog.get_logger(__name__)

META_GRAPH_API_VERSION = "v19.0"
META_GRAPH_API_URL = f"https://graph.facebook.com/{META_GRAPH_API_VERSION}"


class MetaWebhookVerifier:
    """Verifies Meta webhook signatures."""

    @staticmethod
    def verify_signature(payload: bytes, signature: str, app_secret: str) -> bool:
        try:
            expected = hmac.new(
                app_secret.encode("utf-8"), payload, hashlib.sha256
            ).hexdigest()
            return hmac.compare_digest(f"sha256={expected}", signature)
        except Exception as e:
            logger.error("Meta webhook signature verification failed", error=str(e))
            return False


class WhatsAppCloudAPI:
    """WhatsApp Cloud API client."""

    def __init__(self, access_token: str, phone_number_id: str):
        self.access_token = access_token
        self.phone_number_id = phone_number_id
        self.base_url = f"{META_GRAPH_API_URL}/{phone_number_id}"
        self._client: Optional[httpx.AsyncClient] = None

    async def _get_client(self) -> httpx.AsyncClient:
        if self._client is None or self._client.is_closed:
            self._client = httpx.AsyncClient(timeout=30.0)
        return self._client

    async def close(self):
        if self._client and not self._client.is_closed:
            await self._client.aclose()

    def _headers(self) -> Dict[str, str]:
        return {
            "Authorization": f"Bearer {self.access_token}",
            "Content-Type": "application/json",
        }

    async def send_text_message(self, to: str, text: str) -> Dict[str, Any]:
        client = await self._get_client()
        url = f"{self.base_url}/messages"
        payload = {
            "messaging_product": "whatsapp",
            "to": to,
            "type": "text",
            "text": {"body": text},
        }
        response = await client.post(url, json=payload, headers=self._headers())
        if response.status_code != 200:
            logger.error("WhatsApp send failed", status=response.status_code, detail=response.text)
            raise Exception(f"WhatsApp API error {response.status_code}: {response.text}")
        return response.json()

    async def send_template_message(
        self, to: str, template_name: str, language_code: str = "en", components: Optional[List] = None
    ) -> Dict[str, Any]:
        client = await self._get_client()
        url = f"{self.base_url}/messages"
        template: Dict[str, Any] = {
            "name": template_name,
            "language": {"code": language_code},
        }
        if components:
            template["components"] = components

        payload = {
            "messaging_product": "whatsapp",
            "to": to,
            "type": "template",
            "template": template,
        }
        response = await client.post(url, json=payload, headers=self._headers())
        if response.status_code != 200:
            logger.error("WhatsApp template send failed", status=response.status_code, detail=response.text)
            raise Exception(f"WhatsApp API error {response.status_code}: {response.text}")
        return response.json()

    async def send_media_message(
        self, to: str, media_type: str, media_id: Optional[str] = None, media_url: Optional[str] = None, caption: Optional[str] = None
    ) -> Dict[str, Any]:
        client = await self._get_client()
        url = f"{self.base_url}/messages"
        media_obj: Dict[str, Any] = {}
        if media_id:
            media_obj["id"] = media_id
        elif media_url:
            media_obj["link"] = media_url
        if caption:
            media_obj["caption"] = caption

        payload: Dict[str, Any] = {
            "messaging_product": "whatsapp",
            "to": to,
            "type": media_type,
            media_type: media_obj,
        }
        response = await client.post(url, json=payload, headers=self._headers())
        if response.status_code != 200:
            logger.error("WhatsApp media send failed", status=response.status_code, detail=response.text)
            raise Exception(f"WhatsApp API error {response.status_code}: {response.text}")
        return response.json()

    async def send_typing_indicator(self, to: str) -> Dict[str, Any]:
        """
        Send typing indicator via WhatsApp Cloud API.
        Uses the presence API endpoint for typing indicators.
        """
        client = await self._get_client()
        url = f"{self.base_url}/messages"
        payload = {
            "messaging_product": "whatsapp",
            "to": to,
            "type": "text",
            "text": {"body": "\u200B"},  # Zero-width space as typing indicator
        }
        response = await client.post(url, json=payload, headers=self._headers())
        if response.status_code != 200:
            logger.warning("WhatsApp typing indicator failed", status=response.status_code, detail=response.text)
        return response.json() if response.status_code == 200 else {"error": response.text}

    async def mark_message_read(self, message_id: str) -> Dict[str, Any]:
        client = await self._get_client()
        url = f"{self.base_url}/messages"
        payload = {
            "messaging_product": "whatsapp",
            "status": "read",
            "message_id": message_id,
        }
        response = await client.post(url, json=payload, headers=self._headers())
        if response.status_code != 200:
            logger.warning("WhatsApp mark read failed", status=response.status_code, detail=response.text)
        return response.json() if response.status_code == 200 else {"error": response.text}


class FacebookMessengerAPI:
    """Facebook Messenger API client."""

    def __init__(self, page_access_token: str, page_id: str):
        self.page_access_token = page_access_token
        self.page_id = page_id
        self.base_url = f"{META_GRAPH_API_URL}/{page_id}"
        self._client: Optional[httpx.AsyncClient] = None

    async def _get_client(self) -> httpx.AsyncClient:
        if self._client is None or self._client.is_closed:
            self._client = httpx.AsyncClient(timeout=30.0)
        return self._client

    async def close(self):
        if self._client and not self._client.is_closed:
            await self._client.aclose()

    def _headers(self) -> Dict[str, str]:
        return {
            "Authorization": f"Bearer {self.page_access_token}",
            "Content-Type": "application/json",
        }

    async def send_text_message(self, recipient_id: str, text: str) -> Dict[str, Any]:
        client = await self._get_client()
        url = f"{self.base_url}/messages"
        payload = {
            "recipient": {"id": recipient_id},
            "message": {"text": text},
            "messaging_type": "RESPONSE",
        }
        response = await client.post(url, json=payload, headers=self._headers())
        if response.status_code != 200:
            logger.error("Facebook Messenger send failed", status=response.status_code, detail=response.text)
            raise Exception(f"Facebook API error {response.status_code}: {response.text}")
        return response.json()

    async def send_typing_on(self, recipient_id: str) -> Dict[str, Any]:
        client = await self._get_client()
        url = f"{self.base_url}/messages"
        payload = {
            "recipient": {"id": recipient_id},
            "sender_action": "typing_on",
        }
        response = await client.post(url, json=payload, headers=self._headers())
        if response.status_code != 200:
            logger.warning("Facebook typing indicator failed", status=response.status_code)
        return response.json() if response.status_code == 200 else {"error": response.text}

    async def mark_seen(self, recipient_id: str) -> Dict[str, Any]:
        client = await self._get_client()
        url = f"{self.base_url}/messages"
        payload = {
            "recipient": {"id": recipient_id},
            "sender_action": "mark_seen",
        }
        response = await client.post(url, json=payload, headers=self._headers())
        if response.status_code != 200:
            logger.warning("Facebook mark_seen failed", status=response.status_code)
        return response.json() if response.status_code == 200 else {"error": response.text}


class InstagramMessagingAPI:
    """Instagram Messaging API client (via Instagram Graph API)."""

    def __init__(self, access_token: str, instagram_account_id: str):
        self.access_token = access_token
        self.ig_account_id = instagram_account_id
        self.base_url = f"{META_GRAPH_API_URL}/{instagram_account_id}"
        self._client: Optional[httpx.AsyncClient] = None

    async def _get_client(self) -> httpx.AsyncClient:
        if self._client is None or self._client.is_closed:
            self._client = httpx.AsyncClient(timeout=30.0)
        return self._client

    async def close(self):
        if self._client and not self._client.is_closed:
            await self._client.aclose()

    def _headers(self) -> Dict[str, str]:
        return {
            "Authorization": f"Bearer {self.access_token}",
            "Content-Type": "application/json",
        }

    async def send_message(self, recipient_id: str, text: str) -> Dict[str, Any]:
        client = await self._get_client()
        url = f"{self.base_url}/messages"
        payload = {
            "recipient": {"id": recipient_id},
            "message": {"text": text},
        }
        response = await client.post(url, json=payload, headers=self._headers())
        if response.status_code != 200:
            logger.error("Instagram send failed", status=response.status_code, detail=response.text)
            raise Exception(f"Instagram API error {response.status_code}: {response.text}")
        return response.json()


class MetaOmnichannelService:
    """Unified Meta omnichannel service for processing webhooks and sending messages."""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def process_webhook_message(
        self,
        channel: str,
        platform_user_id: str,
        message_content: str,
        org_id: uuid.UUID,
        platform_message_id: Optional[str] = None,
        customer_name: Optional[str] = None,
        customer_phone: Optional[str] = None,
        customer_email: Optional[str] = None,
        attachment_url: Optional[str] = None,
        attachment_type: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Process an incoming webhook message from any Meta platform."""
        now = datetime.datetime.now(datetime.timezone.utc)

        try:
            conv_stmt = select(InboxConversation).where(
                InboxConversation.channel == channel,
                InboxConversation.platform_user_id == platform_user_id,
                InboxConversation.org_id == org_id,
            )
            conv_result = await self.db.execute(conv_stmt)
            conv = conv_result.scalar_one_or_none()

            if not conv:
                customer = await self._link_or_create_customer(
                    org_id, platform_user_id, customer_phone, customer_name, customer_email
                )
                conv = InboxConversation(
                    id=uuid.uuid4(),
                    org_id=org_id,
                    customer_id=customer.id if customer else None,
                    channel=channel,
                    platform_user_id=platform_user_id,
                    customer_name=customer_name,
                    customer_phone=customer_phone,
                    customer_email=customer_email,
                    last_message=message_content[:200],
                    unread_count=1,
                    status="open",
                    takeover_mode="ai",
                    created_at=now,
                    updated_at=now,
                )
                self.db.add(conv)
            else:
                conv.last_message = message_content[:200]
                conv.unread_count += 1
                conv.updated_at = now
                if customer_name and not conv.customer_name:
                    conv.customer_name = customer_name

            msg = InboxMessage(
                id=uuid.uuid4(),
                conversation_id=conv.id,
                sender_type="user",
                content=message_content,
                channel=channel,
                attachment_url=attachment_url,
                attachment_type=attachment_type,
                is_read=False,
                platform_message_id=platform_message_id,
                created_at=now,
            )
            self.db.add(msg)
            await self.db.flush()

            await manager.broadcast_new_message(
                conv.id,
                {
                    "id": str(msg.id),
                    "conversation_id": str(conv.id),
                    "sender_type": "user",
                    "content": message_content,
                    "channel": channel,
                    "created_at": now.isoformat(),
                },
            )

            await manager.broadcast_to_org(
                org_id,
                {
                    "type": "conversation_update",
                    "conversation": {
                        "id": str(conv.id),
                        "channel": channel,
                        "last_message": message_content[:200],
                        "unread_count": conv.unread_count,
                    },
                },
            )

            return {
                "status": "ok",
                "conversation_id": str(conv.id),
                "message_id": str(msg.id),
            }

        except Exception as e:
            logger.error("Failed to process webhook message", channel=channel, error=str(e))
            await self.db.rollback()
            raise

    async def send_message_to_conversation(
        self,
        conversation_id: uuid.UUID,
        org_id: uuid.UUID,
        content: str,
        sender_type: str = "agent",
    ) -> Dict[str, Any]:
        """Send a message to a conversation and persist it."""
        now = datetime.datetime.now(datetime.timezone.utc)

        conv_stmt = select(InboxConversation).where(
            InboxConversation.id == conversation_id,
            InboxConversation.org_id == org_id,
        )
        conv_result = await self.db.execute(conv_stmt)
        conv = conv_result.scalar_one_or_none()

        if not conv:
            return {"status": "error", "message": "Conversation not found"}

        msg = InboxMessage(
            id=uuid.uuid4(),
            conversation_id=conv.id,
            sender_type=sender_type,
            content=content,
            channel=conv.channel,
            is_read=True,
            created_at=now,
        )
        self.db.add(msg)
        conv.last_message = content[:200]
        conv.updated_at = now
        await self.db.flush()

        await manager.broadcast_new_message(
            conv.id,
            {
                "id": str(msg.id),
                "conversation_id": str(conv.id),
                "sender_type": sender_type,
                "content": content,
                "channel": conv.channel,
                "created_at": now.isoformat(),
            },
        )

        return {
            "status": "sent",
            "message_id": str(msg.id),
            "conversation_id": str(conv.id),
        }

    async def _link_or_create_customer(
        self,
        org_id: uuid.UUID,
        platform_user_id: str,
        phone: Optional[str],
        name: Optional[str],
        email: Optional[str],
    ) -> Optional[Customer]:
        """Link or create a customer from platform user data."""
        if phone:
            cust_stmt = select(Customer).where(
                Customer.org_id == org_id, Customer.phone == phone
            )
            cust_result = await self.db.execute(cust_stmt)
            customer = cust_result.scalar_one_or_none()
            if customer:
                if name and not customer.name:
                    customer.name = name
                if email:
                    customer.updated_at = datetime.datetime.now(datetime.timezone.utc)
                await self.db.flush()
                return customer

        if phone or name:
            now = datetime.datetime.now(datetime.timezone.utc)
            customer = Customer(
                id=uuid.uuid4(),
                org_id=org_id,
                phone=phone or f"unknown_{platform_user_id}",
                name=name,
                segment="new",
                created_at=now,
                updated_at=now,
            )
            self.db.add(customer)
            await self.db.flush()
            return customer

        return None
