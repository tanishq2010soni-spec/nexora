from __future__ import annotations

import asyncio
import random
from typing import Any

import pytest


class RetryService:

    def __init__(
        self,
        max_retries: int = 3,
        base_delay: float = 0.1,
        max_delay: float = 2.0,
        jitter: bool = True,
    ) -> None:
        self._max_retries = max_retries
        self._base_delay = base_delay
        self._max_delay = max_delay
        self._jitter = jitter
        self._attempts: list[float] = []

    def _calculate_delay(self, attempt: int) -> float:
        delay = min(self._base_delay * (2 ** attempt), self._max_delay)
        if self._jitter:
            delay = delay * (0.5 + random.random() * 0.5)
        return delay

    async def execute(self, fn: Any, *args: Any, **kwargs: Any) -> Any:
        self._attempts.clear()
        last_exception: Exception | None = None

        for attempt in range(self._max_retries + 1):
            try:
                start = asyncio.get_event_loop().time()
                result = await fn(*args, **kwargs)
                self._attempts.append(asyncio.get_event_loop().time() - start)
                return result
            except Exception as exc:
                self._attempts.append(0.0)
                last_exception = exc
                if attempt < self._max_retries:
                    delay = self._calculate_delay(attempt)
                    await asyncio.sleep(delay)

        raise last_exception or RuntimeError("Retry failed")

    def get_attempts(self) -> list[float]:
        return list(self._attempts)


@pytest.fixture
def retry_service() -> RetryService:
    return RetryService(max_retries=3, base_delay=0.01, max_delay=0.1, jitter=False)


class TestRetryService:

    async def test_immediate_success(self, retry_service: RetryService) -> None:

        async def success_fn() -> str:
            return "ok"

        result = await retry_service.execute(success_fn)
        assert result == "ok"
        assert len(retry_service.get_attempts()) == 1

    async def test_retry_on_failure(self, retry_service: RetryService) -> None:
        attempt_count = 0

        async def flaky_fn() -> str:
            nonlocal attempt_count
            attempt_count += 1
            if attempt_count < 3:
                raise RuntimeError(f"Attempt {attempt_count} failed")
            return "success"

        result = await retry_service.execute(flaky_fn)
        assert result == "success"
        assert attempt_count == 3

    async def test_max_retries_exceeded(self, retry_service: RetryService) -> None:

        async def always_fail_fn() -> str:
            raise RuntimeError("Always fails")

        with pytest.raises(RuntimeError, match="Always fails"):
            await retry_service.execute(always_fail_fn)
        assert len(retry_service.get_attempts()) == 4

    async def test_exponential_backoff(self) -> None:
        delays: list[float] = []
        base_delay = 0.01

        svc = RetryService(max_retries=4, base_delay=base_delay, max_delay=1.0, jitter=False)
        attempt_log: list[int] = []

        async def fail_then_succeed() -> str:
            attempt_log.append(len(attempt_log) + 1)
            if len(attempt_log) < 3:
                raise RuntimeError("Not yet")
            return "done"

        result = await svc.execute(fail_then_succeed)
        assert result == "done"

        expected_delays = [
            min(base_delay * (2 ** i), 1.0)
            for i in range(5)
        ]
        assert len(attempt_log) == 3

    async def test_jitter(self) -> None:
        random.seed(42)
        delays_no_jitter: list[float] = []
        svc_no = RetryService(max_retries=2, base_delay=0.1, max_delay=1.0, jitter=False)

        svc_with = RetryService(max_retries=2, base_delay=0.1, max_delay=1.0, jitter=True)

        async def fail_fn() -> str:
            raise RuntimeError("fail")

        for svc in [svc_no, svc_with]:
            try:
                await svc.execute(fail_fn)
            except RuntimeError:
                pass

        assert len(svc_no.get_attempts()) == 3
        assert len(svc_with.get_attempts()) == 3
