from __future__ import annotations

import struct
from typing import AsyncIterator, Optional

import httpx

from backend.infrastructure.voice.stt.base import STTProvider


class DeepgramSTT(STTProvider):
    BASE_URL = "https://api.deepgram.com/v1"

    def __init__(self, api_key: str) -> None:
        self._api_key = api_key
        self._headers = {
            "Authorization": f"Token {api_key}",
            "Content-Type": "audio/wav",
        }

    async def transcribe(self, audio_data: bytes, language: Optional[str] = None) -> str:
        params: dict = {"model": "nova-2", "punctuate": "true"}
        if language:
            params["language"] = language

        async with httpx.AsyncClient(timeout=60.0) as client:
            resp = await client.post(
                f"{self.BASE_URL}/listen",
                headers=self._headers,
                content=audio_data,
                params=params,
            )
            resp.raise_for_status()
            data = resp.json()
            channel = data.get("results", {}).get("channels", [{}])[0]
            alternatives = channel.get("alternatives", [{}])
            return alternatives[0].get("transcript", "") if alternatives else ""

    async def transcribe_file(self, file_path: str, language: Optional[str] = None) -> str:
        params: dict = {"model": "nova-2", "punctuate": "true"}
        if language:
            params["language"] = language

        with open(file_path, "rb") as f:
            audio_data = f.read()

        async with httpx.AsyncClient(timeout=120.0) as client:
            resp = await client.post(
                f"{self.BASE_URL}/listen",
                headers=self._headers,
                content=audio_data,
                params=params,
            )
            resp.raise_for_status()
            data = resp.json()
            channel = data.get("results", {}).get("channels", [{}])[0]
            alternatives = channel.get("alternatives", [{}])
            return alternatives[0].get("transcript", "") if alternatives else ""

    async def streaming_transcribe(self, audio_stream: AsyncIterator[bytes]) -> AsyncIterator[str]:
        url = f"{self.BASE_URL}/listen"
        params = {"model": "nova-2", "punctuate": "true", "encoding": "linear16", "sample_rate": 16000}

        async with httpx.AsyncClient(timeout=None) as client:
            async with client.stream("POST", url, headers=self._headers, content=audio_stream, params=params) as resp:
                resp.raise_for_status()
                async for line in resp.aiter_lines():
                    if line.startswith("data:"):
                        import json
                        payload = json.loads(line[5:].strip())
                        channel = payload.get("channel", {})
                        alternatives = channel.get("alternatives", [{}])
                        transcript = alternatives[0].get("transcript", "") if alternatives else ""
                        if transcript.strip():
                            yield transcript.strip()

    async def get_available_models(self) -> list[str]:
        return ["nova-2", "nova-2-general", "whisper", "base", "enhanced"]
