from __future__ import annotations

import asyncio
from datetime import datetime, timezone
from typing import Any

from nexora_ai.domain.enums.provider_enums import ProviderStatus


class MockRuntime:

    STATE_IDLE = "idle"
    STATE_RUNNING = "running"
    STATE_STOPPED = "stopped"
    STATE_ERROR = "error"

    def __init__(self, config: dict[str, Any] | None = None) -> None:
        self._config = config or {}
        self._state = self.STATE_IDLE
        self._tasks: dict[str, dict[str, Any]] = {}
        self._started_at: datetime | None = None
        self._error: str | None = None
        self._health_status: dict[str, Any] = {"status": ProviderStatus.ACTIVE.value, "checks": {}}
        self._task_results: dict[str, Any] = {}

    @property
    def state(self) -> str:
        return self._state

    @property
    def error(self) -> str | None:
        return self._error

    async def start(self) -> None:
        if self._state == self.STATE_RUNNING:
            raise RuntimeError("Runtime is already running")
        self._state = self.STATE_RUNNING
        self._started_at = datetime.now(timezone.utc)
        self._error = None

    async def shutdown(self) -> None:
        if self._state == self.STATE_STOPPED:
            raise RuntimeError("Runtime is not running")
        if self._state == self.STATE_IDLE:
            raise RuntimeError("Runtime is not running")
        self._state = self.STATE_STOPPED
        self._started_at = None

    async def hot_reload(self, new_config: dict[str, Any]) -> None:
        if self._state not in (self.STATE_RUNNING, self.STATE_IDLE):
            raise RuntimeError("Cannot reload in current state")
        self._config = {**self._config, **new_config}
        self._health_status["last_reload"] = datetime.now(timezone.utc).isoformat()

    async def execute_task(self, task_id: str, task_data: dict[str, Any]) -> Any:
        if self._state != self.STATE_RUNNING:
            raise RuntimeError("Runtime is not running")
        self._tasks[task_id] = {"data": task_data, "status": "running", "started_at": datetime.now(timezone.utc)}
        delay = task_data.get("delay", 0)
        if delay > 0:
            try:
                await asyncio.wait_for(asyncio.sleep(delay), timeout=delay + 1)
            except asyncio.TimeoutError:
                pass
        if self._tasks.get(task_id, {}).get("status") == "cancelled":
            raise asyncio.CancelledError("Task was cancelled")
        try:
            result = task_data.get("mock_result", f"Task {task_id} completed")
            self._tasks[task_id]["status"] = "completed"
            self._tasks[task_id]["completed_at"] = datetime.now(timezone.utc)
            self._task_results[task_id] = result
            return result
        except asyncio.CancelledError:
            self._tasks[task_id]["status"] = "cancelled"
            raise
        except Exception as exc:
            self._tasks[task_id]["status"] = "failed"
            self._tasks[task_id]["error"] = str(exc)
            raise

    async def cancel_task(self, task_id: str) -> bool:
        if task_id in self._tasks and self._tasks[task_id]["status"] == "running":
            self._tasks[task_id]["status"] = "cancelled"
            return True
        return False

    async def get_health(self) -> dict[str, Any]:
        if self._state == self.STATE_ERROR:
            self._health_status["status"] = ProviderStatus.ERROR.value
        elif self._state == self.STATE_RUNNING:
            self._health_status["status"] = ProviderStatus.ACTIVE.value
        else:
            self._health_status["status"] = ProviderStatus.INACTIVE.value
        self._health_status["state"] = self._state
        self._health_status["task_count"] = len(self._tasks)
        self._health_status["uptime"] = (
            (datetime.now(timezone.utc) - self._started_at).total_seconds()
            if self._started_at else 0.0
        )
        return dict(self._health_status)

    def get_task_status(self, task_id: str) -> dict[str, Any] | None:
        return self._tasks.get(task_id)

    def get_all_tasks(self) -> dict[str, dict[str, Any]]:
        return dict(self._tasks)

    async def close(self) -> None:
        if self._state == self.STATE_RUNNING:
            await self.shutdown()
