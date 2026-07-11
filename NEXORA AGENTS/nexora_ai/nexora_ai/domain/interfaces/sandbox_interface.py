from __future__ import annotations

from abc import ABC, abstractmethod


class SandboxInterface(ABC):
    @abstractmethod
    async def execute(self, command: str, timeout: int) -> dict: ...

    @abstractmethod
    async def read_file(self, path: str) -> str: ...

    @abstractmethod
    async def write_file(self, path: str, content: str) -> bool: ...

    @abstractmethod
    async def get_usage(self) -> dict: ...

    @abstractmethod
    async def destroy(self) -> None: ...
