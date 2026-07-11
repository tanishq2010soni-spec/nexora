from __future__ import annotations

from abc import ABC, abstractmethod
from typing import AsyncIterator, Optional


class TTSProvider(ABC):
    @abstractmethod
    async def synthesize(self, text: str, voice: Optional[str] = None, speed: float = 1.0, pitch: float = 1.0) -> bytes:
        ...

    @abstractmethod
    async def synthesize_streaming(self, text: str) -> AsyncIterator[bytes]:
        ...

    @abstractmethod
    async def get_available_voices(self) -> list[dict]:
        ...

    @abstractmethod
    async def set_emotion(self, emotion: str) -> None:
        ...
