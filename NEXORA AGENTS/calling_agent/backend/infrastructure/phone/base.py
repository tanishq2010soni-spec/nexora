from __future__ import annotations

from abc import ABC, abstractmethod
from typing import Optional


class PhoneProvider(ABC):
    @abstractmethod
    async def make_call(self, from_number: str, to_number: str, **kwargs) -> dict:
        ...

    @abstractmethod
    async def end_call(self, call_id: str) -> bool:
        ...

    @abstractmethod
    async def hold_call(self, call_id: str) -> bool:
        ...

    @abstractmethod
    async def resume_call(self, call_id: str) -> bool:
        ...

    @abstractmethod
    async def transfer_call(self, call_id: str, to_number: str) -> bool:
        ...

    @abstractmethod
    async def start_conference(self, call_id: str, numbers: list[str]) -> dict:
        ...

    @abstractmethod
    async def get_call_status(self, call_id: str) -> str:
        ...

    @abstractmethod
    async def send_digits(self, call_id: str, digits: str) -> bool:
        ...

    @abstractmethod
    async def start_recording(self, call_id: str) -> str:
        ...

    @abstractmethod
    async def stop_recording(self, call_id: str) -> Optional[str]:
        ...

    @abstractmethod
    async def stream_audio(self, call_id: str, audio_data: bytes) -> bool:
        ...

    @abstractmethod
    async def process_webhook(self, payload: dict) -> dict:
        ...
