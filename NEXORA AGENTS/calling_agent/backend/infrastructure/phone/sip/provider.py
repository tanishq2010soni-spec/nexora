from __future__ import annotations

import asyncio
import base64
from typing import Any, Optional

import httpx

from backend.infrastructure.phone.base import PhoneProvider


class SIPProvider(PhoneProvider):
    def __init__(self, server: str, username: str, password: str, **kwargs: Any) -> None:
        self._server = server
        self._username = username
        self._password = password
        self._ws_url = kwargs.get("ws_url", f"wss://{server}:8089/ws")
        self._api_url = kwargs.get("api_url", f"http://{server}:8088/ari")
        self._recordings: dict[str, str] = {}

    async def _api_request(self, method: str, path: str, json_data: Optional[dict] = None) -> dict:
        url = f"{self._api_url}{path}"
        auth = (self._username, self._password)
        async with httpx.AsyncClient(timeout=15.0) as client:
            if method == "GET":
                resp = await client.get(url, auth=auth)
            elif method == "POST":
                resp = await client.post(url, auth=auth, json=json_data or {})
            elif method == "DELETE":
                resp = await client.delete(url, auth=auth)
            else:
                resp = await client.request(method, url, auth=auth, json=json_data or {})
            resp.raise_for_status()
            return resp.json() if resp.content else {}

    async def make_call(self, from_number: str, to_number: str, **kwargs: Any) -> dict:
        payload = {
            "endpoint": f"PJSIP/{to_number}",
            "caller_id": from_number,
            "timeout": kwargs.get("timeout", 60),
        }
        if "context" in kwargs:
            payload["context"] = kwargs["context"]
        if "extension" in kwargs:
            payload["extension"] = kwargs["extension"]

        try:
            data = await self._api_request("POST", "/channels", payload)
            return {
                "provider_call_id": data.get("id", ""),
                "status": "ringing",
                "from_number": from_number,
                "to_number": to_number,
                "direction": "outbound",
            }
        except Exception:
            return {
                "provider_call_id": "",
                "status": "failed",
                "from_number": from_number,
                "to_number": to_number,
                "direction": "outbound",
            }

    async def end_call(self, call_id: str) -> bool:
        try:
            await self._api_request("DELETE", f"/channels/{call_id}")
            return True
        except Exception:
            return False

    async def hold_call(self, call_id: str) -> bool:
        try:
            await self._api_request("POST", f"/channels/{call_id}/hold")
            return True
        except Exception:
            return False

    async def resume_call(self, call_id: str) -> bool:
        try:
            await self._api_request("DELETE", f"/channels/{call_id}/hold")
            return True
        except Exception:
            return False

    async def transfer_call(self, call_id: str, to_number: str) -> bool:
        try:
            payload = {"endpoint": f"PJSIP/{to_number}"}
            await self._api_request("POST", f"/channels/{call_id}/redirect", payload)
            return True
        except Exception:
            return False

    async def start_conference(self, call_id: str, numbers: list[str]) -> dict:
        conference_name = f"conf-{call_id}"
        participants = []

        try:
            await self._api_request("POST", f"/conferences/{conference_name}")
        except Exception:
            pass

        for num in numbers:
            try:
                payload = {
                    "endpoint": f"PJSIP/{num}",
                    "caller_id": num,
                    "app": "conference",
                    "app_args": conference_name,
                }
                data = await self._api_request("POST", "/channels", payload)
                participants.append({"call_sid": data.get("id", ""), "number": num})
            except Exception:
                participants.append({"call_sid": "", "number": num})

        return {"conference_sid": conference_name, "participants": participants}

    async def get_call_status(self, call_id: str) -> str:
        try:
            data = await self._api_request("GET", f"/channels/{call_id}")
            return self._map_status(data.get("state", "unknown"))
        except Exception:
            return "unknown"

    async def send_digits(self, call_id: str, digits: str) -> bool:
        try:
            payload = {"dtmf": digits}
            await self._api_request("POST", f"/channels/{call_id}/dtmf", payload)
            return True
        except Exception:
            return False

    async def start_recording(self, call_id: str) -> str:
        try:
            payload = {"name": f"rec-{call_id}", "format": "wav"}
            data = await self._api_request("POST", f"/channels/{call_id}/record", payload)
            recording_id = data.get("name", f"rec-{call_id}")
            self._recordings[call_id] = recording_id
            return recording_id
        except Exception:
            return ""

    async def stop_recording(self, call_id: str) -> Optional[str]:
        recording_id = self._recordings.pop(call_id, None)
        if not recording_id:
            return None
        try:
            await self._api_request("DELETE", f"/channels/{call_id}/record")
            return f"{self._api_url}/recordings/{recording_id}"
        except Exception:
            return recording_id

    async def stream_audio(self, call_id: str, audio_data: bytes) -> bool:
        try:
            encoded = base64.b64encode(audio_data).decode("utf-8")
            payload = {"media": f"data:audio/wav;base64,{encoded}"}
            await self._api_request("POST", f"/channels/{call_id}/play", payload)
            return True
        except Exception:
            return False

    async def process_webhook(self, payload: dict) -> dict:
        channel_id = payload.get("channel", {}).get("id", "") if isinstance(payload.get("channel"), dict) else payload.get("channel_id", "")
        event_type = payload.get("type", "")
        caller_id = payload.get("caller_id", {}).get("number", "") if isinstance(payload.get("caller_id"), dict) else payload.get("caller_id_num", "")

        status_map = {
            "ChannelCreated": "queued",
            "ChannelEnteredState": payload.get("state", "unknown"),
            "ChannelDestroyed": "completed",
            "ChannelHangupRequest": "completed",
        }
        status = status_map.get(event_type, "unknown")

        return {
            "provider_call_id": channel_id,
            "status": self._map_status(status),
            "direction": "inbound" if "incoming" in event_type.lower() else "outbound",
            "from_number": caller_id,
            "to_number": payload.get("caller_id", {}).get("number", "") if isinstance(payload.get("caller_id"), dict) else payload.get("extension", ""),
            "event": event_type,
        }

    def _map_status(self, sip_state: str) -> str:
        mapping = {
            "Ring": "ringing",
            "Up": "in_progress",
            "Hangup": "completed",
            "Destroyed": "completed",
            "held": "hold",
        }
        return mapping.get(sip_state, sip_state)
