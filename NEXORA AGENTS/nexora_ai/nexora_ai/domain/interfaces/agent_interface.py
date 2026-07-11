from __future__ import annotations

from abc import ABC, abstractmethod

from nexora_ai.domain.entities.agent import (
    AgentCapabilities,
    AgentHeartbeat,
    AgentMetrics,
    AgentRegistration,
    AgentStatusInfo,
    AgentVersion,
)


class AgentManagerInterface(ABC):
    @abstractmethod
    async def register(self, registration: AgentRegistration) -> bool: ...

    @abstractmethod
    async def unregister(self, agent_id: str) -> bool: ...

    @abstractmethod
    async def heartbeat(self, heartbeat: AgentHeartbeat) -> bool: ...

    @abstractmethod
    async def get_agent(self, agent_id: str) -> AgentRegistration | None: ...

    @abstractmethod
    async def list_agents(self) -> list[AgentRegistration]: ...

    @abstractmethod
    async def list_online_agents(self) -> list[AgentRegistration]: ...

    @abstractmethod
    async def get_agent_status(self, agent_id: str) -> AgentStatusInfo | None: ...

    @abstractmethod
    async def get_all_status(self) -> list[AgentStatusInfo]: ...

    @abstractmethod
    async def get_agent_metrics(self, agent_id: str) -> AgentMetrics | None: ...

    @abstractmethod
    async def get_agent_capabilities(self, agent_id: str) -> AgentCapabilities | None: ...

    @abstractmethod
    async def get_agent_version(self, agent_id: str) -> AgentVersion | None: ...

    @abstractmethod
    async def set_agent_status(self, agent_id: str, status: str) -> bool: ...

    @abstractmethod
    async def check_stale_agents(self, warning_seconds: int = 30, offline_seconds: int = 60) -> list[str]: ...

    @abstractmethod
    async def get_dashboard_summary(self) -> dict: ...
