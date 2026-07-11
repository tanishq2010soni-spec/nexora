from __future__ import annotations

import numpy as np

from backend.infrastructure.voice.vad.base import VADProvider


class SileroVAD(VADProvider):
    def __init__(self, threshold: float = 0.5, frame_ms: int = 30) -> None:
        self._threshold = threshold
        self._frame_ms = frame_ms
        self._frame_size = int(16000 * frame_ms / 1000) * 2
        self._model = None
        self._get_model_ready = False
        self._h = None
        self._c = None

    def _ensure_model(self) -> None:
        if self._get_model_ready:
            return
        try:
            import torch
            torch.set_num_threads(1)

            model, utils = torch.hub.load(
                repo_or_dir="snakers4/silero-vad",
                model="silero_vad",
                force_reload=False,
                onnx=False,
            )
            self._model = model
            self._get_model_ready = True
        except (ImportError, Exception):
            self._get_model_ready = False

    def _audio_to_float(self, audio_frame: bytes) -> np.ndarray:
        import struct
        count = len(audio_frame) // 2
        samples = struct.unpack_from(f"<{count}h", audio_frame[:count * 2])
        return np.array(samples, dtype=np.float32) / 32768.0

    def is_speech(self, audio_frame: bytes, sample_rate: int = 16000) -> bool:
        self._ensure_model()
        if not self._get_model_ready:
            return False
        try:
            import torch
            audio_float = self._audio_to_float(audio_frame)
            audio_tensor = torch.tensor(audio_float, dtype=torch.float32).unsqueeze(0)

            with torch.no_grad():
                speech_prob, self._h, self._c = self._model(
                    audio_tensor,
                    h0=self._h,
                    c0=self._c,
                    sr=sample_rate,
                )
            return speech_prob.item() >= self._threshold
        except Exception:
            return False

    def detect_silence(self, audio_frame: bytes, threshold: float = 0.01) -> bool:
        audio_float = self._audio_to_float(audio_frame)
        rms = float(np.sqrt(np.mean(audio_float ** 2)))
        return rms < threshold

    def get_frame_size(self) -> int:
        return self._frame_size
