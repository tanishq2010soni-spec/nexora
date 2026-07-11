import asyncio
import time
from abc import ABC
from collections.abc import AsyncIterator
from typing import Any

import httpx

from nexora_ai.domain.entities.conversation import StreamingChunk
from nexora_ai.domain.enums.provider_enums import ModelCapability, ProviderStatus
from nexora_ai.domain.interfaces.provider_interface import ProviderInterface


class RateLimitExceeded(Exception):
    ...


class ProviderAuthenticationError(Exception):
    ...


class ProviderRateLimitError(Exception):
    ...


class ProviderTimeoutError(Exception):
    ...


class ProviderServerError(Exception):
    ...


class BaseProviderAdapter(ProviderInterface, ABC):

    def __init__(self, config: dict[str, Any]) -> None:
        self._config = config
        self._provider_type: str = ""
        self._status: ProviderStatus = ProviderStatus.ACTIVE
        self._last_error: str | None = None
        self._rate_limit_queue: asyncio.Queue[float] = asyncio.Queue()
        self._rate_limit_max: int = config.get("rate_limit_max", 60)
        self._rate_limit_window: float = config.get("rate_limit_window", 60.0)
        self._retry_max_attempts: int = config.get("retry_max_attempts", 3)
        self._retry_base_delay: float = config.get("retry_base_delay", 1.0)
        self._retry_max_delay: float = config.get("retry_max_delay", 30.0)
        self._client: httpx.AsyncClient | None = None
        self._models: list[str] = []
        self._capabilities: list[ModelCapability] = []

    async def _get_client(self) -> httpx.AsyncClient:
        if self._client is None or self._client.is_closed:
            timeout = httpx.Timeout(
                self._config.get("timeout", 60.0),
                connect=self._config.get("connect_timeout", 10.0),
            )
            limits = httpx.Limits(
                max_keepalive_connections=self._config.get("max_connections", 10),
                max_connections=self._config.get("max_connections", 10),
            )
            self._client = httpx.AsyncClient(timeout=timeout, limits=limits)
        return self._client

    async def close(self) -> None:
        if self._client and not self._client.is_closed:
            await self._client.aclose()

    async def _rate_limit_acquire(self) -> None:
        now = time.monotonic()
        timestamps: list[float] = []
        while not self._rate_limit_queue.empty():
            ts = self._rate_limit_queue.get_nowait()
            if now - ts < self._rate_limit_window:
                timestamps.append(ts)
        for ts in timestamps:
            await self._rate_limit_queue.put(ts)
        count = len(timestamps)
        if count >= self._rate_limit_max:
            sleep_for = timestamps[0] + self._rate_limit_window - now
            if sleep_for > 0:
                await asyncio.sleep(sleep_for)
        await self._rate_limit_queue.put(now)

    def _classify_error(self, response: httpx.Response) -> Exception:
        status = response.status_code
        if status == 401:
            return ProviderAuthenticationError(
                f"Authentication failed for {self._provider_type}"
            )
        if status == 429:
            return ProviderRateLimitError(
                f"Rate limit exceeded for {self._provider_type}"
            )
        if 500 <= status < 600:
            return ProviderServerError(
                f"Server error {status} from {self._provider_type}"
            )
        return ProviderServerError(
            f"HTTP {status} from {self._provider_type}: {response.text}"
        )

    async def _make_request(
        self,
        method: str,
        url: str,
        **kwargs: Any,
    ) -> httpx.Response:
        client = await self._get_client()
        last_exception: Exception | None = None

        for attempt in range(self._retry_max_attempts):
            try:
                await self._rate_limit_acquire()
                response = await client.request(method, url, **kwargs)
                if response.is_success:
                    return response
                last_exception = self._classify_error(response)
                if isinstance(last_exception, ProviderAuthenticationError):
                    raise last_exception
                if isinstance(last_exception, ProviderRateLimitError):
                    if attempt < self._retry_max_attempts - 1:
                        delay = min(
                            self._retry_base_delay * (2**attempt),
                            self._retry_max_delay,
                        )
                        await asyncio.sleep(delay)
                        continue
                    raise last_exception
                if isinstance(last_exception, ProviderServerError):
                    if attempt < self._retry_max_attempts - 1:
                        delay = min(
                            self._retry_base_delay * (2**attempt),
                            self._retry_max_delay,
                        )
                        await asyncio.sleep(delay)
                        continue
                    raise last_exception
            except (httpx.TimeoutException, httpx.ConnectError) as exc:
                last_exception = ProviderTimeoutError(
                    f"Timeout connecting to {self._provider_type}: {exc}"
                )
                if attempt < self._retry_max_attempts - 1:
                    delay = min(
                        self._retry_base_delay * (2**attempt),
                        self._retry_max_delay,
                    )
                    await asyncio.sleep(delay)
                    continue
                raise last_exception from exc

        raise ProviderServerError(
            f"All {self._retry_max_attempts} retry attempts failed for {self._provider_type}"
        )

    def _count_tokens(self, text: str) -> int:
        return len(text) // 4 + 1

    async def get_models(self) -> list[str]:
        return self._models

    async def get_status(self) -> ProviderStatus:
        return self._status

    async def get_capabilities(self) -> list[ModelCapability]:
        return self._capabilities

    async def validate_config(self, config: dict) -> bool:
        return True
