from __future__ import annotations

from backend.infrastructure.voice.tts.base import TTSProvider


class TTSFactory:
    @staticmethod
    def create(provider: str, config: dict) -> TTSProvider:
        if provider == "pyttsx3":
            from backend.infrastructure.voice.tts.pyttsx3_tts import PyTTSx3TTS

            return PyTTSx3TTS(**config)
        if provider == "elevenlabs":
            from backend.infrastructure.voice.tts.elevenlabs import ElevenLabsTTS

            return ElevenLabsTTS(**config)
        raise ValueError(f"Unknown TTS provider: {provider}")
