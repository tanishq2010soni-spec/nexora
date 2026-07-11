from __future__ import annotations

from abc import ABC, abstractmethod


class VADProvider(ABC):
    @abstractmethod
    def is_speech(self, audio_frame: bytes, sample_rate: int = 16000) -> bool:
        ...

    @abstractmethod
    def detect_silence(self, audio_frame: bytes, threshold: float = 0.01) -> bool:
        ...

    @abstractmethod
    def get_frame_size(self) -> int:
        ...
