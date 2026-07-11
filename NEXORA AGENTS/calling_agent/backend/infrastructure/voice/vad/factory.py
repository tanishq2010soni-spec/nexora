from __future__ import annotations

from backend.infrastructure.voice.vad.base import VADProvider


class VADFactory:
    @staticmethod
    def create(provider: str, config: dict) -> VADProvider:
        if provider == "webrtc":
            from backend.infrastructure.voice.vad.webrtc_vad import WebRTCVAD

            return WebRTCVAD(**config)
        if provider == "silero":
            from backend.infrastructure.voice.vad.silero_vad import SileroVAD

            return SileroVAD(**config)
        raise ValueError(f"Unknown VAD provider: {provider}")
