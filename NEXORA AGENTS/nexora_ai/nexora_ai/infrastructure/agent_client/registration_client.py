from __future__ import annotations

import asyncio
import logging
import platform
import socket
import sys
import time
from datetime import datetime, timezone
from typing import Any

try:
    import psutil
except ImportError:
    psutil = None

from nexora_ai.domain.entities.agent import (
    AgentCapabilities,
    AgentHeartbeat,
    AgentMetrics,
    AgentRegistration,
    AgentSystemInfo,
    AgentVersion,
)
from nexora_ai.domain.enums.agent_enums import AgentStatus, AgentType

logger = logging.getLogger(__name__)


def get_system_info() -> AgentSystemInfo:
    cpu_count = 0
    ram_total = 0.0
    if psutil:
        cpu_count = psutil.cpu_count() or 0
        mem = psutil.virtual_memory()
        ram_total = round(mem.total / (1024 * 1024), 1)
    else:
        cpu_count = 1
    return AgentSystemInfo(
        hostname=socket.gethostname(),
        os=f"{platform.system()} {platform.release()}",
        cpu_count=cpu_count,
        ram_total_mb=ram_total,
        python_version=sys.version.split()[0],
    )


def get_metrics(
    active_sessions: int = 0,
    active_conversations: int = 0,
    running_tasks: int = 0,
    queue_size: int = 0,
    total_requests: int = 0,
    total_errors: int = 0,
    uptime_seconds: float = 0.0,
) -> AgentMetrics:
    cpu_percent = 0.0
    ram_percent = 0.0
    ram_used = 0.0
    ram_total = 0.0
    if psutil:
        cpu_percent = psutil.cpu_percent(interval=0.1)
        mem = psutil.virtual_memory()
        ram_percent = mem.percent
        ram_used = round(mem.used / (1024 * 1024), 1)
        ram_total = round(mem.total / (1024 * 1024), 1)
    return AgentMetrics(
        cpu_percent=cpu_percent,
        ram_percent=ram_percent,
        ram_used_mb=ram_used,
        ram_total_mb=ram_total,
        active_sessions=active_sessions,
        active_conversations=active_conversations,
        running_tasks=running_tasks,
        queue_size=queue_size,
        total_requests=total_requests,
        total_errors=total_errors,
        uptime_seconds=uptime_seconds,
        timestamp=datetime.now(timezone.utc).isoformat(),
    )


class AgentRegistrationClient:
    def __init__(
        self,
        agent_id: str,
        agent_name: str,
        agent_type: AgentType,
        version: str,
        control_plane_url: str = "",
        heartbeat_interval: int = 30,
        organization_id: str = "",
        capabilities: list[str] | None = None,
        supported_models: list[str] | None = None,
        api_endpoint: str = "",
    ) -> None:
        self._agent_id = agent_id
        self._agent_name = agent_name
        self._agent_type = agent_type
        self._version = version
        self._control_plane_url = control_plane_url.rstrip("/")
        self._heartbeat_interval = heartbeat_interval
        self._organization_id = organization_id
        self._capabilities = capabilities or []
        self._supported_models = supported_models or []
        self._api_endpoint = api_endpoint
        self._running = False
        self._heartbeat_task: asyncio.Task | None = None
        self._start_time = time.time()
        self._status = AgentStatus.STARTING
        self._registered = False
        self._custom_metrics_callback: Any = None
        self._total_requests = 0
        self._total_errors = 0

    @property
    def agent_id(self) -> str:
        return self._agent_id

    @property
    def status(self) -> AgentStatus:
        return self._status

    def set_status(self, status: AgentStatus) -> None:
        self._status = status

    def set_metrics_callback(self, callback: Any) -> None:
        self._custom_metrics_callback = callback

    def increment_requests(self) -> None:
        self._total_requests += 1

    def increment_errors(self) -> None:
        self._total_errors += 1

    def build_registration(
        self,
        installed_plugins: list[str] | None = None,
    ) -> AgentRegistration:
        now = datetime.now(timezone.utc).isoformat()
        return AgentRegistration(
            agent_id=self._agent_id,
            agent_name=self._agent_name,
            agent_type=self._agent_type,
            version=self._version,
            build_number="",
            status=self._status,
            capabilities=self._capabilities,
            supported_models=self._supported_models,
            installed_plugins=installed_plugins or [],
            organization_id=self._organization_id,
            system_info=get_system_info(),
            startup_time=now,
            api_endpoint=self._api_endpoint,
            health_endpoint=f"{self._api_endpoint}/health",
            registered_at=now,
            last_heartbeat=now,
        )

    def build_heartbeat(
        self,
        active_sessions: int = 0,
        active_conversations: int = 0,
        running_tasks: int = 0,
        queue_size: int = 0,
    ) -> AgentHeartbeat:
        uptime = time.time() - self._start_time
        custom = {}
        if self._custom_metrics_callback:
            try:
                custom = self._custom_metrics_callback() or {}
            except Exception:
                pass
        return AgentHeartbeat(
            agent_id=self._agent_id,
            status=self._status,
            active_sessions=active_sessions,
            active_conversations=active_conversations,
            running_tasks=running_tasks,
            queue_size=queue_size,
            uptime_seconds=round(uptime, 1),
            timestamp=datetime.now(timezone.utc).isoformat(),
        )

    def build_version(self, build_date: str = "", commit_hash: str = "") -> AgentVersion:
        return AgentVersion(
            version=self._version,
            build_number="",
            commit_hash=commit_hash,
            build_date=build_date,
            python_version=sys.version.split()[0],
            framework_version="1.0.0",
        )

    def build_capabilities(
        self,
        supported_tools: list[str] | None = None,
        supported_protocols: list[str] | None = None,
        max_concurrent_sessions: int = 0,
        max_concurrent_conversations: int = 0,
        features: dict[str, Any] | None = None,
    ) -> AgentCapabilities:
        return AgentCapabilities(
            agent_id=self._agent_id,
            capabilities=self._capabilities,
            supported_models=self._supported_models,
            supported_tools=supported_tools or [],
            supported_protocols=supported_protocols or ["http", "websocket"],
            max_concurrent_sessions=max_concurrent_sessions,
            max_concurrent_conversations=max_concurrent_conversations,
            features=features or {},
        )

    async def register(self) -> bool:
        if not self._control_plane_url:
            logger.warning("No control plane URL configured, skipping registration")
            return False
        try:
            import httpx
        except ImportError:
            logger.warning("httpx not installed, skipping registration")
            return False
        registration = self.build_registration()
        url = f"{self._control_plane_url}/api/v1/agents/register"
        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                resp = await client.post(url, json=registration.to_json())
                if resp.status_code in (200, 201):
                    self._registered = True
                    self._status = AgentStatus.ONLINE
                    logger.info("Registered with control plane: %s", self._agent_id)
                    return True
                logger.warning("Registration failed: %s %s", resp.status_code, resp.text)
                return False
        except Exception as exc:
            logger.error("Registration error: %s", exc)
            return False

    async def send_heartbeat(
        self,
        active_sessions: int = 0,
        active_conversations: int = 0,
        running_tasks: int = 0,
        queue_size: int = 0,
    ) -> bool:
        if not self._control_plane_url or not self._registered:
            return False
        try:
            import httpx
        except ImportError:
            return False
        heartbeat = self.build_heartbeat(
            active_sessions=active_sessions,
            active_conversations=active_conversations,
            running_tasks=running_tasks,
            queue_size=queue_size,
        )
        url = f"{self._control_plane_url}/api/v1/agents/heartbeat"
        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                resp = await client.post(url, json=heartbeat.to_json())
                return resp.status_code == 200
        except Exception as exc:
            logger.debug("Heartbeat error: %s", exc)
            return False

    async def unregister(self) -> bool:
        if not self._control_plane_url or not self._registered:
            return False
        try:
            import httpx
        except ImportError:
            return False
        url = f"{self._control_plane_url}/api/v1/agents/{self._agent_id}"
        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                resp = await client.delete(url)
                return resp.status_code == 200
        except Exception:
            return False

    async def start_heartbeat_loop(
        self,
        active_sessions: int = 0,
        active_conversations: int = 0,
        running_tasks: int = 0,
        queue_size: int = 0,
    ) -> None:
        self._running = True
        while self._running:
            await asyncio.sleep(self._heartbeat_interval)
            if self._running:
                await self.send_heartbeat(
                    active_sessions=active_sessions,
                    active_conversations=active_conversations,
                    running_tasks=running_tasks,
                    queue_size=queue_size,
                )

    def start_heartbeat_background(self) -> None:
        self._heartbeat_task = asyncio.ensure_future(self.start_heartbeat_loop())

    async def stop(self) -> None:
        self._running = False
        if self._heartbeat_task:
            self._heartbeat_task.cancel()
            try:
                await self._heartbeat_task
            except asyncio.CancelledError:
                pass
        await self.unregister()
