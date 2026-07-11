from __future__ import annotations

from backend.infrastructure.voice.stt.base import STTProvider


class STTFactory:
    @staticmethod
    def create(provider: str, config: dict) -> STTProvider:
        if provider == "whisper":
            from backend.infrastructure.voice.stt.whisper import WhisperSTT

            return WhisperSTT(**config)
        if provider == "deepgram":
            from backend.infrastructure.voice.stt.deepgram import DeepgramSTT

            return DeepgramSTT(**config)
        raise ValueError(f"Unknown STT provider: {provider}")
