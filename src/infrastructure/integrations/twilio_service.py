"""
Twilio Voice AI Integration - Real calling capabilities.

Handles:
- Outbound calling
- Inbound call handling
- Call recording
- Call status tracking
- Transcription
- AI voice responses via TwiML
- Webhook signature verification
"""

import datetime
import hashlib
import hmac
import json
import uuid
from typing import Any, Dict, Optional
from urllib.parse import urlencode

import httpx
import structlog
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from src.infrastructure.database.models import Call, CallRecording

logger = structlog.get_logger(__name__)

TWILIO_API_URL = "https://api.twilio.com/2010-04-01"


class TwilioAPIError(Exception):
    """Raised when a Twilio API call fails."""
    def __init__(self, status_code: int, detail: str):
        self.status_code = status_code
        self.detail = detail
        super().__init__(f"Twilio API error {status_code}: {detail}")


class TwilioWebhookVerifier:
    """Verifies Twilio webhook request signatures."""

    @staticmethod
    def verify_signature(
        url: str,
        params: Dict[str, str],
        signature: str,
        auth_token: str,
    ) -> bool:
        """
        Verify Twilio request signature using HMAC-SHA1.
        Twilio signs by sorting all POST params alphabetically,
        concatenating key+value pairs, and signing the URL + data.
        """
        try:
            # Sort params and build data string
            data_str = url
            for key in sorted(params.keys()):
                data_str += key + str(params[key])

            # Compute HMAC-SHA1
            mac = hmac.new(
                auth_token.encode("utf-8"),
                data_str.encode("utf-8"),
                hashlib.sha1,
            )
            computed = __import__("base64").b64encode(mac.digest()).decode("utf-8")
            return hmac.compare_digest(computed, signature)
        except Exception as e:
            logger.error("Twilio webhook signature verification failed", error=str(e))
            return False


class TwilioVoiceService:
    """Twilio Voice API integration service."""

    def __init__(self, account_sid: str, auth_token: str):
        self.account_sid = account_sid
        self.auth_token = auth_token
        self.base_url = f"{TWILIO_API_URL}/Accounts/{account_sid}"
        self._client: Optional[httpx.AsyncClient] = None

    async def _get_client(self) -> httpx.AsyncClient:
        if self._client is None or self._client.is_closed:
            self._client = httpx.AsyncClient(timeout=30.0)
        return self._client

    def _auth(self) -> tuple[str, str]:
        return (self.account_sid, self.auth_token)

    async def close(self):
        if self._client and not self._client.is_closed:
            await self._client.aclose()

    async def initiate_outbound_call(
        self,
        to_number: str,
        from_number: str,
        webhook_url: str,
        status_callback_url: Optional[str] = None,
        record: bool = True,
    ) -> Dict[str, Any]:
        client = await self._get_client()
        url = f"{self.base_url}/Calls.json"
        data = {
            "To": to_number,
            "From": from_number,
            "Url": webhook_url,
            "Record": str(record).lower(),
            "StatusCallback": status_callback_url or "",
            "StatusCallbackEvent": "initiated ringing answered completed",
        }
        response = await client.post(url, data=data, auth=self._auth())
        if response.status_code not in (200, 201):
            raise TwilioAPIError(response.status_code, response.text)
        return response.json()

    async def get_call_status(self, call_sid: str) -> Dict[str, Any]:
        client = await self._get_client()
        url = f"{self.base_url}/Calls/{call_sid}.json"
        response = await client.get(url, auth=self._auth())
        if response.status_code != 200:
            raise TwilioAPIError(response.status_code, response.text)
        return response.json()

    async def get_call_recording(self, recording_sid: str) -> Dict[str, Any]:
        client = await self._get_client()
        url = f"{self.base_url}/Recordings/{recording_sid}.json"
        response = await client.get(url, auth=self._auth())
        if response.status_code != 200:
            raise TwilioAPIError(response.status_code, response.text)
        return response.json()

    async def list_recordings(self, call_sid: Optional[str] = None) -> Dict[str, Any]:
        client = await self._get_client()
        url = f"{self.base_url}/Recordings.json"
        params = {}
        if call_sid:
            params["CallSid"] = call_sid
        response = await client.get(url, params=params, auth=self._auth())
        if response.status_code != 200:
            raise TwilioAPIError(response.status_code, response.text)
        return response.json()

    def generate_twiml_response(
        self,
        message: str,
        voice: str = "Polly.Matthew",
        language: str = "en-US",
    ) -> str:
        return f"""<?xml version="1.0" encoding="UTF-8"?>
<Response>
    <Say voice="{voice}" language="{language}">{message}</Say>
    <Pause length="1"/>
    <Gather numDigits="1" action="/api/v1/calls/gather" method="POST">
        <Say voice="{voice}">Press 1 to continue, or press 2 to end the call.</Say>
    </Gather>
</Response>"""

    def generate_twiml_transfer(self, message: str, transfer_to: str, voice: str = "Polly.Matthew") -> str:
        return f"""<?xml version="1.0" encoding="UTF-8"?>
<Response>
    <Say voice="{voice}">{message}</Say>
    <Dial timeout="30">
        <Number>{transfer_to}</Number>
    </Dial>
</Response>"""

    def generate_twiml_recording(self, message: str, recording_callback: str, voice: str = "Polly.Matthew") -> str:
        return f"""<?xml version="1.0" encoding="UTF-8"?>
<Response>
    <Say voice="{voice}">{message}</Say>
    <Record maxLength="300" action="{recording_callback}" playBeep="true"/>
</Response>"""


class TwilioCallManager:
    """Manages call lifecycle in the database with Twilio integration."""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def create_call(
        self,
        org_id: uuid.UUID,
        direction: str,
        caller_number: str,
        callee_number: str,
        agent_id: Optional[uuid.UUID] = None,
    ) -> Call:
        now = datetime.datetime.now(datetime.timezone.utc)
        call = Call(
            id=uuid.uuid4(),
            org_id=org_id,
            agent_id=agent_id,
            direction=direction,
            caller_number=caller_number,
            callee_number=callee_number,
            status="queued",
            created_at=now,
            updated_at=now,
        )
        self.db.add(call)
        await self.db.flush()
        return call

    async def update_call_from_twilio(
        self,
        call_id: uuid.UUID,
        twilio_status: str,
        duration: Optional[int] = None,
        recording_url: Optional[str] = None,
    ) -> Call:
        stmt = select(Call).where(Call.id == call_id)
        result = await self.db.execute(stmt)
        call = result.scalar_one_or_none()
        if not call:
            raise ValueError(f"Call {call_id} not found")

        status_map = {
            "queued": "queued",
            "initiated": "ringing",
            "ringing": "ringing",
            "in-progress": "in_progress",
            "completed": "completed",
            "busy": "failed",
            "no-answer": "missed",
            "failed": "failed",
            "canceled": "failed",
        }
        call.status = status_map.get(twilio_status, twilio_status)

        now = datetime.datetime.now(datetime.timezone.utc)
        if twilio_status == "initiated" and not call.started_at:
            call.started_at = now
        elif twilio_status == "in-progress" and not call.answered_at:
            call.answered_at = now
        elif twilio_status in ("completed", "busy", "no-answer", "failed", "canceled"):
            call.ended_at = now

        if duration is not None:
            call.duration_seconds = duration
        if recording_url:
            call.recording_url = recording_url

        call.updated_at = now
        await self.db.flush()
        return call

    async def store_recording(
        self,
        call_id: uuid.UUID,
        recording_url: str,
        duration_seconds: int,
        file_format: str = "wav",
    ) -> CallRecording:
        now = datetime.datetime.now(datetime.timezone.utc)
        recording = CallRecording(
            id=uuid.uuid4(),
            call_id=call_id,
            file_url=recording_url,
            duration_seconds=duration_seconds,
            created_at=now,
        )
        self.db.add(recording)
        await self.db.flush()
        return recording

    async def store_transcription(
        self,
        call_id: uuid.UUID,
        transcription_text: str,
    ) -> Call:
        stmt = select(Call).where(Call.id == call_id)
        result = await self.db.execute(stmt)
        call = result.scalar_one_or_none()
        if not call:
            raise ValueError(f"Call {call_id} not found for transcription")
        call.transcription = transcription_text
        call.updated_at = datetime.datetime.now(datetime.timezone.utc)
        await self.db.flush()
        return call
