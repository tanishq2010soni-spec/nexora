from __future__ import annotations

from abc import ABC, abstractmethod
from typing import AsyncIterator, Optional


class STTProvider(ABC):
    @abstractmethod
    async def transcribe(self, audio_data: bytes, language: Optional[str] = None) -> str:
        ...

    @abstractmethod
    async def transcribe_file(self, file_path: str, language: Optional[str] = None) -> str:
        ...

    @abstractmethod
    async def streaming_transcribe(self, audio_stream: AsyncIterator[bytes]) -> AsyncIterator[str]:
        ...

    @abstractmethod
    async def get_available_models(self) -> list[str]:
        ...
