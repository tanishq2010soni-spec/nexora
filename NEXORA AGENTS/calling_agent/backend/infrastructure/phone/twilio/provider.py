from __future__ import annotations

import base64
from typing import Any, Optional
from urllib.parse import urlencode

from twilio.base.exceptions import TwilioRestException
from twilio.rest import Client

from backend.infrastructure.phone.base import PhoneProvider


class TwilioProvider(PhoneProvider):
    def __init__(self, account_sid: str, auth_token: str, **kwargs: Any) -> None:
        self._client = Client(account_sid, auth_token)
        self._webhook_base = kwargs.get("webhook_base", "")
        self._recordings: dict[str, str] = {}

    async def make_call(self, from_number: str, to_number: str, **kwargs: Any) -> dict:
        webhook_url = f"{self._webhook_base}/webhooks/twilio/voice"
        status_callback = f"{self._webhook_base}/webhooks/twilio/status"

        call = self._client.calls.create(
            url=webhook_url,
            to=to_number,
            from_=from_number,
            status_callback=status_callback,
            status_callback_event=["initiated", "ringing", "answered", "completed"],
            timeout=kwargs.get("timeout", 60),
            record=kwargs.get("record", False),
        )
        return {
            "provider_call_id": call.sid,
            "status": call.status,
            "from_number": call.from_,
            "to_number": call.to,
            "direction": "outbound",
        }

    async def end_call(self, call_id: str) -> bool:
        try:
            call = self._client.calls(call_id).update(status="completed")
            return call.status == "completed"
        except TwilioRestException:
            return False

    async def hold_call(self, call_id: str) -> bool:
        try:
            twiml = '<Response><Hold></Hold></Response>'
            self._client.calls(call_id).update(twiml=twiml)
            return True
        except TwilioRestException:
            return False

    async def resume_call(self, call_id: str) -> bool:
        try:
            twiml = '<Response></Response>'
            self._client.calls(call_id).update(twiml=twiml)
            return True
        except TwilioRestException:
            return False

    async def transfer_call(self, call_id: str, to_number: str) -> bool:
        try:
            twiml = f'<Response><Dial>{to_number}</Dial></Response>'
            self._client.calls(call_id).update(twiml=twiml)
            return True
        except TwilioRestException:
            return False

    async def start_conference(self, call_id: str, numbers: list[str]) -> dict:
        conference_sid = None
        participants = []
        try:
            conf = self._client.conferences.create(
                friendly_name=f"conf-{call_id}",
                status_callback=f"{self._webhook_base}/webhooks/twilio/conference",
            )
            conference_sid = conf.sid

            for num in numbers:
                participant = self._client.conferences(conference_sid).participants.create(
                    from_=num,
                    to=num,
                    early_media=True,
                )
                participants.append({"call_sid": participant.call_sid, "number": num})

            return {
                "conference_sid": conference_sid,
                "participants": participants,
            }
        except TwilioRestException:
            return {"conference_sid": conference_sid or "", "participants": participants}

    async def get_call_status(self, call_id: str) -> str:
        try:
            call = self._client.calls(call_id).fetch()
            return call.status
        except TwilioRestException:
            return "unknown"

    async def send_digits(self, call_id: str, digits: str) -> bool:
        try:
            self._client.calls(call_id).update(twiml=f"<Response><Play digits=\"{digits}\"></Play></Response>")
            return True
        except TwilioRestException:
            return False

    async def start_recording(self, call_id: str) -> str:
        try:
            recording = self._client.calls(call_id).recordings.create()
            self._recordings[call_id] = recording.sid
            return recording.sid
        except TwilioRestException:
            return ""

    async def stop_recording(self, call_id: str) -> Optional[str]:
        recording_sid = self._recordings.pop(call_id, None)
        if not recording_sid:
            return None
        try:
            recording = self._client.recordings(recording_sid).fetch()
            url = f"https://api.twilio.com{recording.uri.replace('.json', '.wav')}"
            return url
        except TwilioRestException:
            return None

    async def stream_audio(self, call_id: str, audio_data: bytes) -> bool:
        try:
            encoded = base64.b64encode(audio_data).decode("utf-8")
            twiml = f"<Response><Play>{encoded}</Play></Response>"
            self._client.calls(call_id).update(twiml=twiml)
            return True
        except TwilioRestException:
            return False

    async def process_webhook(self, payload: dict) -> dict:
        call_sid = payload.get("CallSid", "")
        call_status = payload.get("CallStatus", "")
        direction = "inbound" if payload.get("Direction") == "inbound" else "outbound"
        from_number = payload.get("From", "")
        to_number = payload.get("To", "")

        result = {
            "provider_call_id": call_sid,
            "status": self._map_status(call_status),
            "direction": direction,
            "from_number": from_number,
            "to_number": to_number,
            "event": payload.get("StatusCallbackEvent", ""),
        }

        if "Digits" in payload:
            result["digits"] = payload["Digits"]

        if payload.get("RecordingUrl"):
            result["recording_url"] = payload["RecordingUrl"]
            result["recording_duration"] = payload.get("RecordingDuration", "")

        return result

    def _map_status(self, twilio_status: str) -> str:
        mapping = {
            "queued": "queued",
            "ringing": "ringing",
            "in-progress": "in_progress",
            "completed": "completed",
            "busy": "busy",
            "failed": "failed",
            "no-answer": "no_answer",
            "canceled": "cancelled",
        }
        return mapping.get(twilio_status, twilio_status)
