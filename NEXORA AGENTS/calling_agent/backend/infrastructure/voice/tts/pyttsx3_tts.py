from __future__ import annotations

import asyncio
import functools
import io
import tempfile
import wave
from pathlib import Path
from typing import AsyncIterator, Optional

from backend.infrastructure.voice.tts.base import TTSProvider


def _get_engine():
    import pyttsx3
    return pyttsx3.init()


class PyTTSx3TTS(TTSProvider):
    def __init__(self, voice: str = "default", speed: float = 1.0, pitch: float = 1.0) -> None:
        self._engine = _get_engine()
        self._voice_name = voice
        self._speed = speed
        self._pitch = pitch
        self._current_emotion = "neutral"
        self._configure_engine()

    def _configure_engine(self) -> None:
        rate = int(self._engine.getProperty("rate") * self._speed)
        self._engine.setProperty("rate", rate)
        voices = self._engine.getProperty("voices")
        for v in voices:
            if self._voice_name == "default" or self._voice_name.lower() in v.name.lower():
                self._engine.setProperty("voice", v.id)
                break

    async def _run_in_thread(self, func, *args, **kwargs):
        loop = asyncio.get_event_loop()
        return await loop.run_in_executor(None, functools.partial(func, *args, **kwargs))

    async def synthesize(self, text: str, voice: Optional[str] = None, speed: float = 1.0, pitch: float = 1.0) -> bytes:
        if voice:
            voices = self._engine.getProperty("voices")
            for v in voices:
                if voice.lower() in v.name.lower():
                    self._engine.setProperty("voice", v.id)
                    break

        rate = int(self._engine.getProperty("rate") * speed)
        self._engine.setProperty("rate", rate)

        with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp:
            tmp_path = Path(tmp.name)

        def _save():
            self._engine.save_to_file(text, str(tmp_path))
            self._engine.runAndWait()

        await self._run_in_thread(_save)

        audio_bytes = tmp_path.read_bytes()
        tmp_path.unlink(missing_ok=True)
        return audio_bytes

    async def synthesize_streaming(self, text: str) -> AsyncIterator[bytes]:
        audio_bytes = await self.synthesize(text)
        chunk_size = 4096
        for i in range(0, len(audio_bytes), chunk_size):
            yield audio_bytes[i:i + chunk_size]

    async def get_available_voices(self) -> list[dict]:
        result = []
        for v in self._engine.getProperty("voices"):
            result.append({
                "id": v.id,
                "name": v.name,
                "languages": v.languages,
            })
        return result

    async def set_emotion(self, emotion: str) -> None:
        self._current_emotion = emotion
        rate_map = {
            "neutral": 1.0,
            "happy": 1.2,
            "serious": 0.85,
            "sympathetic": 0.9,
            "urgent": 1.3,
            "energetic": 1.15,
        }
        speed_factor = rate_map.get(emotion, 1.0)
        rate = int(self._engine.getProperty("rate") * speed_factor)
        self._engine.setProperty("rate", rate)
