from __future__ import annotations

import struct

from backend.infrastructure.voice.vad.base import VADProvider


class WebRTCVAD(VADProvider):
    def __init__(self, mode: int = 1, frame_ms: int = 30) -> None:
        import webrtcvad

        self._vad = webrtcvad.Vad(mode)
        self._frame_ms = frame_ms
        self._frame_size = int(16000 * frame_ms / 1000) * 2

    def is_speech(self, audio_frame: bytes, sample_rate: int = 16000) -> bool:
        if len(audio_frame) < self._frame_size:
            padded = audio_frame + b"\x00" * (self._frame_size - len(audio_frame))
            return self._vad.is_speech(padded, sample_rate)
        return self._vad.is_speech(audio_frame[:self._frame_size], sample_rate)

    def detect_silence(self, audio_frame: bytes, threshold: float = 0.01) -> bool:
        frame = audio_frame[:len(audio_frame) - len(audio_frame) % 2]
        if len(frame) < 2:
            return True
        samples = struct.unpack_from(f"<{len(frame) // 2}h", frame)
        rms = (sum(s * s for s in samples) / len(samples)) ** 0.5
        return rms < threshold

    def get_frame_size(self) -> int:
        return self._frame_size
