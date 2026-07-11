from __future__ import annotations

from typing import Any, Optional

import httpx

from backend.infrastructure.phone.base import PhoneProvider


class ExotelProvider(PhoneProvider):
    def __init__(self, api_key: str, api_token: str, sid: str) -> None:
        self._auth = (api_key, api_token)
        self._sid = sid
        self._base_url = f"https://api.exotel.com/v1/Accounts/{sid}"
        self._recordings: dict[str, str] = {}

    async def make_call(self, from_number: str, to_number: str, **kwargs: Any) -> dict:
        caller_id = kwargs.get("caller_id", from_number)
        url = f"{self._base_url}/Calls/connect.json"

        payload = {
            "From": to_number,
            "To": from_number,
            "CallerId": caller_id,
            "Url": kwargs.get("url", "http://exotel.com/"),
            "CallType": kwargs.get("call_type", "trans"),
        }

        async with httpx.AsyncClient(timeout=30.0) as client:
            resp = await client.post(url, auth=self._auth, json=payload)
            resp.raise_for_status()
            data = resp.json()
            call_data = data.get("Call", {})
            return {
                "provider_call_id": call_data.get("Sid", ""),
                "status": call_data.get("Status", "queued"),
                "from_number": from_number,
                "to_number": to_number,
                "direction": "outbound",
            }

    async def end_call(self, call_id: str) -> bool:
        url = f"{self._base_url}/Calls/{call_id}.json"
        async with httpx.AsyncClient(timeout=15.0) as client:
            resp = await client.delete(url, auth=self._auth)
            return resp.status_code == 200

    async def hold_call(self, call_id: str) -> bool:
        url = f"{self._base_url}/Calls/{call_id}/Hold.json"
        async with httpx.AsyncClient(timeout=15.0) as client:
            resp = await client.post(url, auth=self._auth)
            return resp.status_code == 200

    async def resume_call(self, call_id: str) -> bool:
        url = f"{self._base_url}/Calls/{call_id}/Unhold.json"
        async with httpx.AsyncClient(timeout=15.0) as client:
            resp = await client.post(url, auth=self._auth)
            return resp.status_code == 200

    async def transfer_call(self, call_id: str, to_number: str) -> bool:
        url = f"{self._base_url}/Calls/{call_id}/Transfer.json"
        payload = {"Url": f"http://exotel.com/transfer?to={to_number}"}
        async with httpx.AsyncClient(timeout=15.0) as client:
            resp = await client.post(url, auth=self._auth, json=payload)
            return resp.status_code == 200

    async def start_conference(self, call_id: str, numbers: list[str]) -> dict:
        url = f"{self._base_url}/Calls/connect.json"
        participants = []

        for num in numbers:
            payload = {
                "From": num,
                "To": call_id,
                "CallerId": num,
                "Url": "http://exotel.com/conference",
                "CallType": "conf",
            }
            async with httpx.AsyncClient(timeout=30.0) as client:
                resp = await client.post(url, auth=self._auth, json=payload)
                if resp.status_code == 200:
                    data = resp.json()
                    call_data = data.get("Call", {})
                    participants.append({"call_sid": call_data.get("Sid", ""), "number": num})

        return {"conference_sid": call_id, "participants": participants}

    async def get_call_status(self, call_id: str) -> str:
        url = f"{self._base_url}/Calls/{call_id}.json"
        async with httpx.AsyncClient(timeout=15.0) as client:
            resp = await client.get(url, auth=self._auth)
            if resp.status_code == 200:
                data = resp.json()
                call_data = data.get("Call", {})
                return call_data.get("Status", "unknown")
            return "unknown"

    async def send_digits(self, call_id: str, digits: str) -> bool:
        url = f"{self._base_url}/Calls/{call_id}/DTMF.json"
        payload = {"Digits": digits}
        async with httpx.AsyncClient(timeout=15.0) as client:
            resp = await client.post(url, auth=self._auth, json=payload)
            return resp.status_code == 200

    async def start_recording(self, call_id: str) -> str:
        url = f"{self._base_url}/Calls/{call_id}/Recordings.json"
        async with httpx.AsyncClient(timeout=15.0) as client:
            resp = await client.post(url, auth=self._auth)
            if resp.status_code == 201:
                data = resp.json()
                recording_sid = data.get("Recording", {}).get("Sid", "")
                self._recordings[call_id] = recording_sid
                return recording_sid
            return ""

    async def stop_recording(self, call_id: str) -> Optional[str]:
        recording_sid = self._recordings.pop(call_id, None)
        if not recording_sid:
            return None
        url = f"{self._base_url}/Recordings/{recording_sid}.json"
        async with httpx.AsyncClient(timeout=15.0) as client:
            resp = await client.get(url, auth=self._auth)
            if resp.status_code == 200:
                data = resp.json()
                recording = data.get("Recording", {})
                return recording.get("Url")
            return recording_sid

    async def stream_audio(self, call_id: str, audio_data: bytes) -> bool:
        url = f"{self._base_url}/Calls/{call_id}/Play.json"
        import base64
        encoded = base64.b64encode(audio_data).decode("utf-8")
        payload = {"Url": f"data:audio/wav;base64,{encoded}"}
        async with httpx.AsyncClient(timeout=30.0) as client:
            resp = await client.post(url, auth=self._auth, json=payload)
            return resp.status_code == 200

    async def process_webhook(self, payload: dict) -> dict:
        call_sid = payload.get("CallSid", "")
        status = payload.get("Status", "")
        from_number = payload.get("From", "")
        to_number = payload.get("To", "")
        direction = payload.get("Direction", "inbound")

        return {
            "provider_call_id": call_sid,
            "status": self._map_status(status),
            "direction": direction,
            "from_number": from_number,
            "to_number": to_number,
            "event": payload.get("Event", ""),
        }

    def _map_status(self, exotel_status: str) -> str:
        mapping = {
            "queued": "queued",
            "in-progress": "in_progress",
            "completed": "completed",
            "failed": "failed",
            "busy": "busy",
            "no-answer": "no_answer",
            "canceled": "cancelled",
        }
        return mapping.get(exotel_status, exotel_status)
