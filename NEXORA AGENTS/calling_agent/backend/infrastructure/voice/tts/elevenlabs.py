from __future__ import annotations

from typing import AsyncIterator, Optional

import httpx

from backend.infrastructure.voice.tts.base import TTSProvider


class ElevenLabsTTS(TTSProvider):
    BASE_URL = "https://api.elevenlabs.io/v1"

    def __init__(self, api_key: str, voice_id: str = "default") -> None:
        self._api_key = api_key
        self._voice_id = voice_id
        self._headers = {
            "xi-api-key": api_key,
            "Content-Type": "application/json",
        }

    async def synthesize(self, text: str, voice: Optional[str] = None, speed: float = 1.0, pitch: float = 1.0) -> bytes:
        voice_id = voice or self._voice_id
        if voice_id == "default":
            voice_id = "21m00Tcm4TlvDq8ikWAM"

        payload = {
            "text": text,
            "model_id": "eleven_monolingual_v1",
            "voice_settings": {
                "stability": 0.5,
                "similarity_boost": 0.75,
                "speed": speed,
                "pitch": pitch,
            },
        }

        async with httpx.AsyncClient(timeout=30.0) as client:
            resp = await client.post(
                f"{self.BASE_URL}/text-to-speech/{voice_id}",
                headers=self._headers,
                json=payload,
            )
            resp.raise_for_status()
            return resp.content

    async def synthesize_streaming(self, text: str) -> AsyncIterator[bytes]:
        voice_id = self._voice_id
        if voice_id == "default":
            voice_id = "21m00Tcm4TlvDq8ikWAM"

        payload = {
            "text": text,
            "model_id": "eleven_monolingual_v1",
            "voice_settings": {
                "stability": 0.5,
                "similarity_boost": 0.75,
            },
        }

        async with httpx.AsyncClient(timeout=60.0) as client:
            async with client.stream(
                "POST",
                f"{self.BASE_URL}/text-to-speech/{voice_id}/stream",
                headers=self._headers,
                json=payload,
            ) as resp:
                resp.raise_for_status()
                async for chunk in resp.aiter_bytes():
                    yield chunk

    async def get_available_voices(self) -> list[dict]:
        async with httpx.AsyncClient(timeout=15.0) as client:
            resp = await client.get(
                f"{self.BASE_URL}/voices",
                headers={"xi-api-key": self._api_key},
            )
            resp.raise_for_status()
            data = resp.json()
            return [
                {"id": v["voice_id"], "name": v["name"], "category": v.get("category", "")}
                for v in data.get("voices", [])
            ]

    async def set_emotion(self, emotion: str) -> None:
        stability_map = {
            "neutral": 0.5,
            "happy": 0.3,
            "serious": 0.7,
            "sympathetic": 0.6,
            "urgent": 0.2,
            "energetic": 0.25,
        }
        stability = stability_map.get(emotion, 0.5)
        self._current_stability = stability
