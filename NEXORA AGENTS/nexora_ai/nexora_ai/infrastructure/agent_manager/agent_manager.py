from __future__ import annotations

import time
from datetime import datetime, timezone
from typing import Any

from nexora_ai.domain.entities.agent import (
    AgentCapabilities,
    AgentHeartbeat,
    AgentMetrics,
    AgentRegistration,
    AgentStatusInfo,
    AgentSystemInfo,
    AgentVersion,
)
from nexora_ai.domain.enums.agent_enums import AgentStatus, HeartbeatState
from nexora_ai.domain.interfaces.agent_interface import AgentManagerInterface


class AgentManager(AgentManagerInterface):
    def __init__(self) -> None:
        self._agents: dict[str, AgentRegistration] = {}
        self._heartbeats: dict[str, AgentHeartbeat] = {}
        self._metrics: dict[str, AgentMetrics] = {}
        self._capabilities: dict[str, AgentCapabilities] = {}
        self._versions: dict[str, AgentVersion] = {}
        self._heartbeat_times: dict[str, float] = {}
        self._start_times: dict[str, float] = {}

    async def register(self, registration: AgentRegistration) -> bool:
        now = datetime.now(timezone.utc).isoformat()
        registration.registered_at = now
        registration.last_heartbeat = now
        self._agents[registration.agent_id] = registration
        self._heartbeat_times[registration.agent_id] = time.time()
        self._start_times[registration.agent_id] = time.time()
        return True

    async def unregister(self, agent_id: str) -> bool:
        removed = agent_id in self._agents
        self._agents.pop(agent_id, None)
        self._heartbeats.pop(agent_id, None)
        self._metrics.pop(agent_id, None)
        self._capabilities.pop(agent_id, None)
        self._versions.pop(agent_id, None)
        self._heartbeat_times.pop(agent_id, None)
        self._start_times.pop(agent_id, None)
        return removed

    async def heartbeat(self, heartbeat: AgentHeartbeat) -> bool:
        if heartbeat.agent_id not in self._agents:
            return False
        now = datetime.now(timezone.utc).isoformat()
        heartbeat.timestamp = now
        self._heartbeats[heartbeat.agent_id] = heartbeat
        self._heartbeat_times[heartbeat.agent_id] = time.time()
        agent = self._agents[heartbeat.agent_id]
        agent.status = heartbeat.status
        agent.last_heartbeat = now
        metrics = AgentMetrics(
            cpu_percent=heartbeat.cpu_percent,
            ram_percent=heartbeat.ram_percent,
            active_sessions=heartbeat.active_sessions,
            active_conversations=heartbeat.active_conversations,
            running_tasks=heartbeat.running_tasks,
            queue_size=heartbeat.queue_size,
            uptime_seconds=heartbeat.uptime_seconds,
            timestamp=now,
        )
        self._metrics[heartbeat.agent_id] = metrics
        return True

    async def get_agent(self, agent_id: str) -> AgentRegistration | None:
        return self._agents.get(agent_id)

    async def list_agents(self) -> list[AgentRegistration]:
        return list(self._agents.values())

    async def list_online_agents(self) -> list[AgentRegistration]:
        return [
            a for a in self._agents.values()
            if a.status in (AgentStatus.ONLINE, AgentStatus.DEGRADED)
        ]

    async def get_agent_status(self, agent_id: str) -> AgentStatusInfo | None:
        agent = self._agents.get(agent_id)
        if not agent:
            return None
        hb = self._heartbeats.get(agent_id)
        metrics = self._metrics.get(agent_id, AgentMetrics())
        uptime = time.time() - self._start_times.get(agent_id, time.time())
        health = self._compute_health(agent_id)
        return AgentStatusInfo(
            agent_id=agent.agent_id,
            agent_name=agent.agent_name,
            agent_type=agent.agent_type,
            status=agent.status,
            version=agent.version,
            uptime_seconds=uptime,
            last_heartbeat=agent.last_heartbeat,
            system_info=agent.system_info,
            metrics=metrics,
            health_status=health,
        )

    async def get_all_status(self) -> list[AgentStatusInfo]:
        result = []
        for agent_id in self._agents:
            status = await self.get_agent_status(agent_id)
            if status:
                result.append(status)
        return result

    async def get_agent_metrics(self, agent_id: str) -> AgentMetrics | None:
        return self._metrics.get(agent_id)

    async def get_agent_capabilities(self, agent_id: str) -> AgentCapabilities | None:
        return self._capabilities.get(agent_id)

    async def get_agent_version(self, agent_id: str) -> AgentVersion | None:
        return self._versions.get(agent_id)

    async def set_agent_status(self, agent_id: str, status: str) -> bool:
        agent = self._agents.get(agent_id)
        if not agent:
            return False
        try:
            agent.status = AgentStatus(status)
        except ValueError:
            return False
        return True

    async def check_stale_agents(
        self, warning_seconds: int = 30, offline_seconds: int = 60
    ) -> list[str]:
        now = time.time()
        stale: list[str] = []
        for agent_id, last_hb in list(self._heartbeat_times.items()):
            elapsed = now - last_hb
            agent = self._agents.get(agent_id)
            if not agent:
                continue
            if elapsed >= offline_seconds:
                agent.status = AgentStatus.OFFLINE
                stale.append(agent_id)
            elif elapsed >= warning_seconds:
                if agent.status == AgentStatus.ONLINE:
                    agent.status = AgentStatus.DEGRADED
                    stale.append(agent_id)
        return stale

    async def get_dashboard_summary(self) -> dict[str, Any]:
        agents = list(self._agents.values())
        online = sum(1 for a in agents if a.status == AgentStatus.ONLINE)
        degraded = sum(1 for a in agents if a.status == AgentStatus.DEGRADED)
        offline = sum(1 for a in agents if a.status == AgentStatus.OFFLINE)
        error = sum(1 for a in agents if a.status == AgentStatus.ERROR)
        total_cpu = sum(m.cpu_percent for m in self._metrics.values())
        total_ram = sum(m.ram_percent for m in self._metrics.values())
        total_tasks = sum(m.running_tasks for m in self._metrics.values())
        total_conversations = sum(m.active_conversations for m in self._metrics.values())
        return {
            "total_agents": len(agents),
            "online": online,
            "degraded": degraded,
            "offline": offline,
            "error": error,
            "total_cpu_percent": round(total_cpu, 1),
            "total_ram_percent": round(total_ram, 1),
            "total_running_tasks": total_tasks,
            "total_active_conversations": total_conversations,
            "agents": [a.to_json() for a in agents],
        }

    def set_capabilities(self, agent_id: str, capabilities: AgentCapabilities) -> None:
        self._capabilities[agent_id] = capabilities

    def set_version(self, agent_id: str, version: AgentVersion) -> None:
        self._versions[agent_id] = version

    def _compute_health(self, agent_id: str) -> str:
        last_hb = self._heartbeat_times.get(agent_id)
        if not last_hb:
            return "unknown"
        elapsed = time.time() - last_hb
        if elapsed < 30:
            return "healthy"
        if elapsed < 60:
            return "warning"
        return "critical"
