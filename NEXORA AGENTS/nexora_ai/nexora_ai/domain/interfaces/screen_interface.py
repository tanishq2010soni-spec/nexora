from __future__ import annotations

from abc import ABC, abstractmethod


class ScreenInterface(ABC):
    @abstractmethod
    async def capture(self) -> bytes: ...

    @abstractmethod
    async def get_element_at(self, x: int, y: int) -> dict | None: ...

    @abstractmethod
    async def get_elements_by_text(self, text: str) -> list[dict]: ...

    @abstractmethod
    async def get_window_info(self) -> dict: ...

    @abstractmethod
    async def get_mouse_position(self) -> tuple[int, int]: ...

    @abstractmethod
    async def get_monitor_layout(self) -> list[dict]: ...

    @abstractmethod
    async def ocr(self, region: tuple | None = None) -> str: ...

    @abstractmethod
    async def get_active_window(self) -> dict: ...

    @abstractmethod
    async def wait_for_element(self, condition: dict, timeout: int) -> dict | None: ...
