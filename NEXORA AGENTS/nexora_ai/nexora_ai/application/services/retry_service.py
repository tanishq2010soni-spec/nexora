from __future__ import annotations

import asyncio
import random
from collections.abc import Callable, Coroutine
from typing import Any, TypeVar

T = TypeVar("T")


class RetryPolicy:
    def __init__(
        self,
        max_retries: int = 3,
        base_delay: float = 1.0,
        max_delay: float = 60.0,
        exponential_base: float = 2.0,
        jitter: bool = True,
    ) -> None:
        self.max_retries = max_retries
        self.base_delay = base_delay
        self.max_delay = max_delay
        self.exponential_base = exponential_base
        self.jitter = jitter

    def copy(self) -> RetryPolicy:
        return RetryPolicy(
            max_retries=self.max_retries,
            base_delay=self.base_delay,
            max_delay=self.max_delay,
            exponential_base=self.exponential_base,
            jitter=self.jitter,
        )


class RetryService:

    def should_retry(self, attempt: int, error: Exception) -> bool:
        return attempt < 3

    def calculate_delay(self, attempt: int, policy: RetryPolicy) -> float:
        delay = policy.base_delay * (policy.exponential_base**attempt)
        delay = min(delay, policy.max_delay)
        if policy.jitter:
            delay += random.uniform(0, delay * 0.1)
        return delay

    async def execute_with_retry(
        self,
        coro: Callable[..., Coroutine[Any, Any, T]],
        policy: RetryPolicy | None = None,
    ) -> T:
        effective_policy = policy or RetryPolicy()
        last_exception: Exception | None = None
        for attempt in range(effective_policy.max_retries + 1):
            try:
                return await coro()
            except Exception as e:
                last_exception = e
                if not self.should_retry(attempt, e):
                    raise
                if attempt < effective_policy.max_retries:
                    delay = self.calculate_delay(attempt, effective_policy)
                    await asyncio.sleep(delay)
        raise last_exception  # type: ignore[misc]
