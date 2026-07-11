from __future__ import annotations

from typing import Any, Optional

import httpx

from backend.infrastructure.phone.base import PhoneProvider


class PlivoProvider(PhoneProvider):
    BASE_URL = "https://api.plivo.com/v1/Account"

    def __init__(self, auth_id: str, auth_token: str, **kwargs: Any) -> None:
        self._auth_id = auth_id
        self._auth = (auth_id, auth_token)
        self._base_url = f"{self.BASE_URL}/{auth_id}"
        self._webhook_base = kwargs.get("webhook_base", "")
        self._recordings: dict[str, str] = {}

    async def make_call(self, from_number: str, to_number: str, **kwargs: Any) -> dict:
        url = f"{self._base_url}/Call/"
        answer_url = kwargs.get("answer_url", f"{self._webhook_base}/webhooks/plivo/voice")

        payload = {
            "from": from_number,
            "to": to_number,
            "answer_url": answer_url,
            "answer_method": "POST",
        }

        if "caller_name" in kwargs:
            payload["caller_name"] = kwargs["caller_name"]

        async with httpx.AsyncClient(timeout=30.0) as client:
            resp = await client.post(url, auth=self._auth, json=payload)
            resp.raise_for_status()
            data = resp.json()
            return {
                "provider_call_id": data.get("request_uuid", ""),
                "status": "queued",
                "from_number": from_number,
                "to_number": to_number,
                "direction": "outbound",
            }

    async def end_call(self, call_id: str) -> bool:
        url = f"{self._base_url}/Call/{call_id}/"
        async with httpx.AsyncClient(timeout=15.0) as client:
            resp = await client.delete(url, auth=self._auth)
            return resp.status_code == 204

    async def hold_call(self, call_id: str) -> bool:
        url = f"{self._base_url}/Call/{call_id}/"
        payload = {"status": "on-hold"}
        async with httpx.AsyncClient(timeout=15.0) as client:
            resp = await client.patch(url, auth=self._auth, json=payload)
            return resp.status_code == 202

    async def resume_call(self, call_id: str) -> bool:
        url = f"{self._base_url}/Call/{call_id}/"
        payload = {"status": "active"}
        async with httpx.AsyncClient(timeout=15.0) as client:
            resp = await client.patch(url, auth=self._auth, json=payload)
            return resp.status_code == 202

    async def transfer_call(self, call_id: str, to_number: str) -> bool:
        url = f"{self._base_url}/Call/{call_id}/"
        payload = {
            "transfer_numbers": to_number,
            "transfer_answer_url": f"{self._webhook_base}/webhooks/plivo/transfer",
        }
        async with httpx.AsyncClient(timeout=15.0) as client:
            resp = await client.patch(url, auth=self._auth, json=payload)
            return resp.status_code == 202

    async def start_conference(self, call_id: str, numbers: list[str]) -> dict:
        conference_name = f"conf-{call_id}"
        participants = []

        for num in numbers:
            payload = {
                "from": num,
                "to": num,
                "answer_url": f"{self._webhook_base}/webhooks/plivo/conference?conf_name={conference_name}",
                "answer_method": "POST",
            }
            url = f"{self._base_url}/Call/"
            async with httpx.AsyncClient(timeout=30.0) as client:
                resp = await client.post(url, auth=self._auth, json=payload)
                if resp.status_code == 201:
                    data = resp.json()
                    participants.append({"call_uuid": data.get("request_uuid", ""), "number": num})

        return {"conference_sid": conference_name, "participants": participants}

    async def get_call_status(self, call_id: str) -> str:
        url = f"{self._base_url}/Call/{call_id}/"
        async with httpx.AsyncClient(timeout=15.0) as client:
            resp = await client.get(url, auth=self._auth)
            if resp.status_code == 200:
                data = resp.json()
                return self._map_status(data.get("call_status", "unknown"))
            return "unknown"

    async def send_digits(self, call_id: str, digits: str) -> bool:
        url = f"{self._base_url}/Call/{call_id}/"
        payload = {"digits": digits}
        async with httpx.AsyncClient(timeout=15.0) as client:
            resp = await client.patch(url, auth=self._auth, json=payload)
            return resp.status_code == 202

    async def start_recording(self, call_id: str) -> str:
        url = f"{self._base_url}/Call/{call_id}/Record/"
        async with httpx.AsyncClient(timeout=15.0) as client:
            resp = await client.post(url, auth=self._auth)
            if resp.status_code == 201:
                data = resp.json()
                recording_id = data.get("recording_id", "")
                self._recordings[call_id] = recording_id
                return recording_id
            return ""

    async def stop_recording(self, call_id: str) -> Optional[str]:
        recording_id = self._recordings.pop(call_id, None)
        if not recording_id:
            return None
        url = f"{self._base_url}/Recording/{recording_id}/"
        async with httpx.AsyncClient(timeout=15.0) as client:
            resp = await client.get(url, auth=self._auth)
            if resp.status_code == 200:
                data = resp.json()
                return data.get("url")
            return recording_id

    async def stream_audio(self, call_id: str, audio_data: bytes) -> bool:
        import base64
        encoded = base64.b64encode(audio_data).decode("utf-8")
        url = f"{self._base_url}/Call/{call_id}/"
        payload = {"media": f"data:audio/wav;base64,{encoded}"}
        async with httpx.AsyncClient(timeout=30.0) as client:
            resp = await client.patch(url, auth=self._auth, json=payload)
            return resp.status_code == 202

    async def process_webhook(self, payload: dict) -> dict:
        call_uuid = payload.get("CallUUID", "")
        status = payload.get("CallStatus", "")
        direction = payload.get("Direction", "inbound")
        from_number = payload.get("From", "")
        to_number = payload.get("To", "")

        result = {
            "provider_call_id": call_uuid,
            "status": self._map_status(status),
            "direction": direction,
            "from_number": from_number,
            "to_number": to_number,
            "event": payload.get("Event", ""),
        }

        if "Digits" in payload:
            result["digits"] = payload["Digits"]

        return result

    def _map_status(self, plivo_status: str) -> str:
        mapping = {
            "queued": "queued",
            "ringing": "ringing",
            "in-progress": "in_progress",
            "completed": "completed",
            "busy": "busy",
            "failed": "failed",
            "no-answer": "no_answer",
            "canceled": "cancelled",
            "on-hold": "hold",
        }
        return mapping.get(plivo_status, plivo_status)
