from __future__ import annotations

import base64
import hashlib
import json
import logging
import time
from datetime import datetime, timedelta
from typing import Any, Optional
from uuid import uuid4

logger = logging.getLogger(__name__)


class WhatsAppAdapter:
    def __init__(self) -> None:
        self._accounts: dict[str, dict[str, Any]] = {}

    async def connect(self, account_id: str, phone_number: str) -> dict[str, Any]:
        logger.info("Connecting WhatsApp account %s (%s)", account_id, phone_number)

        now = datetime.utcnow()
        qr_seed = f"{account_id}:{phone_number}:{int(time.time())}"
        qr_content = f"whatsapp://connect?account={account_id}&phone={phone_number}&token={hashlib.sha256(qr_seed.encode()).hexdigest()[:16]}"
        qr_base64 = base64.b64encode(qr_content.encode()).decode()

        qr_data = {
            "qr_code": qr_base64,
            "qr_content": qr_content,
            "expires_at": (now + timedelta(minutes=5)).isoformat(),
            "account_id": account_id,
            "phone_number": phone_number,
        }

        account_state: dict[str, Any] = {
            "account_id": account_id,
            "phone_number": phone_number,
            "status": "connecting",
            "connected_at": None,
            "disconnected_at": None,
            "qr_code": qr_base64,
            "qr_expires_at": now + timedelta(minutes=5),
            "session_data": {},
            "messages": [],
            "media_messages": [],
            "last_health_check": now,
            "health_status": "healthy",
            "error_message": None,
        }
        self._accounts[account_id] = account_state
        logger.info("Generated QR code for account %s", account_id)
        return qr_data

    async def disconnect(self, account_id: str) -> bool:
        account = self._accounts.get(account_id)
        if account is None:
            logger.warning("Account %s not found for disconnect", account_id)
            return False

        account["status"] = "disconnected"
        account["disconnected_at"] = datetime.utcnow()
        account["qr_code"] = None
        account["session_data"] = {}
        logger.info("Disconnected account %s", account_id)
        return True

    async def send_message(self, account_id: str, to: str, text: str) -> dict[str, Any]:
        account = self._accounts.get(account_id)
        if account is None:
            raise ValueError(f"WhatsApp account {account_id} not found")
        if account["status"] != "connected":
            raise ValueError(f"WhatsApp account {account_id} is not connected (status: {account['status']})")

        message_id = str(uuid4())
        message = {
            "id": message_id,
            "account_id": account_id,
            "from": account["phone_number"],
            "to": to,
            "text": text,
            "type": "text",
            "status": "sent",
            "timestamp": datetime.utcnow().isoformat(),
        }
        account["messages"].append(message)
        logger.info("Sent message %s to %s via account %s", message_id, to, account_id)
        return message

    async def send_media(self, account_id: str, to: str, media_url: str, caption: str = "") -> dict[str, Any]:
        account = self._accounts.get(account_id)
        if account is None:
            raise ValueError(f"WhatsApp account {account_id} not found")
        if account["status"] != "connected":
            raise ValueError(f"WhatsApp account {account_id} is not connected (status: {account['status']})")

        message_id = str(uuid4())
        message = {
            "id": message_id,
            "account_id": account_id,
            "from": account["phone_number"],
            "to": to,
            "media_url": media_url,
            "caption": caption,
            "type": "media",
            "status": "sent",
            "timestamp": datetime.utcnow().isoformat(),
        }
        account["media_messages"].append(message)
        account["messages"].append({**message, "text": caption or "[Media]"})
        logger.info("Sent media %s to %s via account %s", message_id, to, account_id)
        return message

    async def get_qr_code(self, account_id: str) -> Optional[dict[str, Any]]:
        account = self._accounts.get(account_id)
        if account is None:
            return None

        if account["status"] in ("connected", "disconnected", "expired", "banned"):
            return None

        qr = account.get("qr_code")
        expires = account.get("qr_expires_at")
        if not qr:
            return None

        if expires and datetime.utcnow() > expires:
            return None

        return {
            "qr_code": qr,
            "expires_at": expires.isoformat() if expires else None,
            "account_id": account_id,
        }

    async def check_health(self, account_id: str) -> dict[str, Any]:
        account = self._accounts.get(account_id)
        if account is None:
            return {
                "account_id": account_id,
                "status": "not_found",
                "healthy": False,
                "last_check": datetime.utcnow().isoformat(),
            }

        now = datetime.utcnow()
        connected = account["status"] == "connected"
        account["last_health_check"] = now

        if connected:
            account["health_status"] = "healthy"
            account["error_message"] = None
        else:
            account["health_status"] = "disconnected"

        return {
            "account_id": account_id,
            "phone_number": account["phone_number"],
            "status": account["status"],
            "healthy": connected,
            "health_status": account["health_status"],
            "message_count": len(account["messages"]),
            "last_check": now.isoformat(),
            "error_message": account.get("error_message"),
        }

    async def get_status(self, account_id: str) -> str:
        account = self._accounts.get(account_id)
        if account is None:
            return "not_found"
        return account["status"]

    async def simulate_connection(self, account_id: str) -> bool:
        account = self._accounts.get(account_id)
        if account is None:
            logger.warning("Cannot simulate connection: account %s not found", account_id)
            return False

        if account["status"] == "connected":
            return True

        account["status"] = "connected"
        account["connected_at"] = datetime.utcnow()
        account["session_data"] = {
            "session_id": str(uuid4()),
            "phone_number": account["phone_number"],
            "connected_at": account["connected_at"].isoformat(),
            "browser_session": f"simulated_{account_id[:8]}",
        }
        account["qr_code"] = None
        account["health_status"] = "healthy"
        logger.info("Simulated connection for account %s", account_id)
        return True

    async def simulate_disconnection(self, account_id: str) -> bool:
        account = self._accounts.get(account_id)
        if account is None:
            return False
        account["status"] = "disconnected"
        account["disconnected_at"] = datetime.utcnow()
        account["health_status"] = "disconnected"
        logger.info("Simulated disconnection for account %s", account_id)
        return True

    async def process_webhook(self, account_id: str, payload: dict[str, Any]) -> dict[str, Any]:
        account = self._accounts.get(account_id)
        if account is None:
            return {
                "success": False,
                "error": f"Account {account_id} not found",
                "event": "error",
            }

        event_type = payload.get("event", payload.get("type", "unknown"))
        logger.info("Processing webhook event '%s' for account %s", event_type, account_id)

        if event_type == "message":
            message_data = payload.get("message", payload)
            message = {
                "id": str(uuid4()),
                "account_id": account_id,
                "from": message_data.get("from", ""),
                "to": account["phone_number"],
                "text": message_data.get("text", ""),
                "type": "text",
                "status": "received",
                "timestamp": datetime.utcnow().isoformat(),
            }
            account["messages"].append(message)
            logger.info("Stored incoming message from %s", message["from"])
            return {"success": True, "event": "message_received", "message": message}

        elif event_type == "status":
            status_update = {
                "message_id": payload.get("message_id", ""),
                "status": payload.get("status", "unknown"),
                "timestamp": datetime.utcnow().isoformat(),
            }
            logger.info("Status update: %s", status_update)
            return {"success": True, "event": "status_updated", "status": status_update}

        elif event_type == "connected":
            await self.simulate_connection(account_id)
            return {"success": True, "event": "connected"}

        elif event_type == "disconnected":
            await self.simulate_disconnection(account_id)
            return {"success": True, "event": "disconnected"}

        else:
            logger.warning("Unknown webhook event type: %s", event_type)
            return {
                "success": True,
                "event": "unknown_event",
                "original_payload": payload,
            }

    async def get_account_state(self, account_id: str) -> Optional[dict[str, Any]]:
        return self._accounts.get(account_id)

    def _set_account_status(self, account_id: str, status: str) -> None:
        if account_id in self._accounts:
            self._accounts[account_id]["status"] = status
