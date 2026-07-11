from __future__ import annotations

import io
import wave
from typing import AsyncIterator, Optional

from backend.infrastructure.voice.stt.base import STTProvider


class WhisperSTT(STTProvider):
    def __init__(self, model: str = "base", language: str = "en") -> None:
        self._model_name = model
        self._language = language
        self._model = None
        self._available = True

    async def _load_model(self) -> None:
        if self._model is not None:
            return
        try:
            import whisper

            self._model = await self._run_in_thread(whisper.load_model, self._model_name)
        except ImportError:
            self._available = False
            raise RuntimeError(
                "whisper is not installed. Install it with: pip install openai-whisper"
            )

    async def _run_in_thread(self, func, *args, **kwargs):
        import asyncio
        import functools

        loop = asyncio.get_event_loop()
        return await loop.run_in_executor(None, functools.partial(func, *args, **kwargs))

    async def transcribe(self, audio_data: bytes, language: Optional[str] = None) -> str:
        if not self._available:
            return "transcription unavailable: whisper not installed"
        await self._load_model()
        result = await self._run_in_thread(
            self._model.transcribe,
            audio_data,
            language=language or self._language,
        )
        return result.get("text", "").strip()

    async def transcribe_file(self, file_path: str, language: Optional[str] = None) -> str:
        if not self._available:
            return "transcription unavailable: whisper not installed"
        await self._load_model()
        result = await self._run_in_thread(
            self._model.transcribe,
            file_path,
            language=language or self._language,
        )
        return result.get("text", "").strip()

    async def streaming_transcribe(self, audio_stream: AsyncIterator[bytes]) -> AsyncIterator[str]:
        buffer = bytearray()
        async for chunk in audio_stream:
            buffer.extend(chunk)
            if len(buffer) >= 32000:
                text = await self.transcribe(bytes(buffer))
                if text:
                    yield text
                buffer.clear()
        if buffer:
            text = await self.transcribe(bytes(buffer))
            if text:
                yield text

    async def get_available_models(self) -> list[str]:
        return ["tiny", "base", "small", "medium", "large", "large-v2", "large-v3"]
