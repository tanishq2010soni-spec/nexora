from __future__ import annotations

import asyncio

import pytest

from tests.mocks import MockRuntime
from nexora_ai.domain.enums.provider_enums import ProviderStatus


@pytest.fixture
async def runtime() -> MockRuntime:
    rt = MockRuntime({"name": "integration-test"})
    return rt


class TestRuntimeLifecycleIntegration:

    async def test_start_and_shutdown(self, runtime: MockRuntime) -> None:
        assert runtime.state == MockRuntime.STATE_IDLE

        await runtime.start()
        assert runtime.state == MockRuntime.STATE_RUNNING

        health = await runtime.get_health()
        assert health["status"] == ProviderStatus.ACTIVE.value
        assert health["state"] == MockRuntime.STATE_RUNNING

        await runtime.shutdown()
        assert runtime.state == MockRuntime.STATE_STOPPED

        with pytest.raises(RuntimeError, match="not running"):
            await runtime.shutdown()

    async def test_hot_reload(self, runtime: MockRuntime) -> None:
        await runtime.start()
        old_config = dict(runtime._config)
        await runtime.hot_reload({"new_key": "new_value"})
        assert runtime._config.get("new_key") == "new_value"

        await runtime.shutdown()

        with pytest.raises(RuntimeError, match="Cannot reload"):
            await runtime.hot_reload({"x": "y"})

    async def test_task_execution(self, runtime: MockRuntime) -> None:
        await runtime.start()
        result = await runtime.execute_task("task-1", {"mock_result": "completed"})
        assert result == "completed"

        task_status = runtime.get_task_status("task-1")
        assert task_status is not None
        assert task_status["status"] == "completed"

        all_tasks = runtime.get_all_tasks()
        assert "task-1" in all_tasks

        await runtime.shutdown()

    async def test_cancellation(self, runtime: MockRuntime) -> None:
        await runtime.start()

        task = asyncio.create_task(runtime.execute_task("cancel-me", {"delay": 0.5, "mock_result": "will cancel"}))

        await asyncio.sleep(0.05)

        cancelled = await runtime.cancel_task("cancel-me")
        assert cancelled is True

        try:
            await task
        except (asyncio.CancelledError, Exception):
            pass

        task_status = runtime.get_task_status("cancel-me")
        assert task_status is not None
        assert task_status["status"] in ("cancelled", "completed")

        cancelled = await runtime.cancel_task("nonexistent")
        assert cancelled is False

        await runtime.shutdown()

    async def test_health_reporting(self, runtime: MockRuntime) -> None:
        health = await runtime.get_health()
        assert "status" in health
        assert "state" in health
        assert "uptime" in health

        await runtime.start()
        runtime._state = MockRuntime.STATE_RUNNING
        health = await runtime.get_health()
        assert health["status"] == ProviderStatus.ACTIVE.value

        await runtime.shutdown()
        health = await runtime.get_health()
        assert health["status"] == ProviderStatus.INACTIVE.value
