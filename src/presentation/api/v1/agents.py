import uuid
import datetime
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Header, Query, status
from pydantic import BaseModel, Field
from sqlalchemy import select, func, delete as sa_delete
from sqlalchemy.ext.asyncio import AsyncSession

from src.infrastructure.database.connection import get_db_session
from src.infrastructure.database.models import (
    Agent, AgentCapability, AgentHealth, AgentHeartbeat, ChatSession, Message,
)
from src.presentation.api.dependencies import get_current_org_id, get_agent_org_id, require_role
from src.application.services.audit_service import AuditService

router = APIRouter()


class AgentResponse(BaseModel):
    id: uuid.UUID
    org_id: uuid.UUID
    name: str
    platform_type: str
    system_prompt: str
    llm_model: str
    temperature: float
    created_at: str
    updated_at: str


class AgentCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=255)
    platform_type: str = Field(..., pattern="^(whatsapp|calling|web)$")
    system_prompt: str = Field(..., min_length=1)
    llm_model: str = Field(default="llama3")
    temperature: float = Field(default=0.7, ge=0.0, le=2.0)


class AgentUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    platform_type: Optional[str] = Field(None, pattern="^(whatsapp|calling|web)$")
    system_prompt: Optional[str] = Field(None, min_length=1)
    llm_model: Optional[str] = None
    temperature: Optional[float] = Field(None, ge=0.0, le=2.0)


@router.get("/", response_model=List[AgentResponse])
async def list_agents(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    platform_type: Optional[str] = Query(default=None),
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
) -> List[AgentResponse]:
    """List all agents for the organization, optionally filtered by platform type."""
    stmt = (
        select(Agent)
        .where(Agent.org_id == org_id)
        .order_by(Agent.created_at.desc())
        .limit(limit)
        .offset(offset)
    )
    if platform_type:
        stmt = stmt.where(Agent.platform_type == platform_type)

    result = await db.execute(stmt)
    agents = result.scalars().all()

    return [
        AgentResponse(
            id=a.id,
            org_id=a.org_id,
            name=a.name,
            platform_type=a.platform_type,
            system_prompt=a.system_prompt,
            llm_model=a.llm_model,
            temperature=a.temperature,
            created_at=a.created_at.isoformat(),
            updated_at=a.updated_at.isoformat(),
        )
        for a in agents
    ]


@router.post("/", response_model=AgentResponse, status_code=status.HTTP_201_CREATED)
async def create_agent(
    data: AgentCreate,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin", "member")),
) -> AgentResponse:
    """Create a new agent."""
    agent = Agent(
        id=uuid.uuid4(),
        org_id=org_id,
        name=data.name,
        platform_type=data.platform_type,
        system_prompt=data.system_prompt,
        llm_model=data.llm_model,
        temperature=data.temperature,
        created_at=datetime.datetime.now(datetime.timezone.utc),
        updated_at=datetime.datetime.now(datetime.timezone.utc),
    )
    db.add(agent)
    await db.commit()
    await db.refresh(agent)

    await AuditService.log(
        db=db,
        action="create",
        resource="agent",
        org_id=org_id,
        resource_id=str(agent.id),
        detail=f"Created {data.platform_type} agent: {agent.name}",
    )
    await db.commit()

    return AgentResponse(
        id=agent.id,
        org_id=agent.org_id,
        name=agent.name,
        platform_type=agent.platform_type,
        system_prompt=agent.system_prompt,
        llm_model=agent.llm_model,
        temperature=agent.temperature,
        created_at=agent.created_at.isoformat(),
        updated_at=agent.updated_at.isoformat(),
    )


@router.get("/{agent_id}", response_model=AgentResponse)
async def get_agent(
    agent_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> AgentResponse:
    """Get an agent by ID."""
    stmt = select(Agent).where(Agent.id == agent_id, Agent.org_id == org_id)
    result = await db.execute(stmt)
    agent = result.scalar_one_or_none()
    if not agent:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Agent not found.")

    return AgentResponse(
        id=agent.id,
        org_id=agent.org_id,
        name=agent.name,
        platform_type=agent.platform_type,
        system_prompt=agent.system_prompt,
        llm_model=agent.llm_model,
        temperature=agent.temperature,
        created_at=agent.created_at.isoformat(),
        updated_at=agent.updated_at.isoformat(),
    )


@router.put("/{agent_id}", response_model=AgentResponse)
async def update_agent(
    agent_id: uuid.UUID,
    data: AgentUpdate,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin", "member")),
) -> AgentResponse:
    """Update an agent."""
    stmt = select(Agent).where(Agent.id == agent_id, Agent.org_id == org_id)
    result = await db.execute(stmt)
    agent = result.scalar_one_or_none()
    if not agent:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Agent not found.")

    if data.name is not None:
        agent.name = data.name
    if data.platform_type is not None:
        agent.platform_type = data.platform_type
    if data.system_prompt is not None:
        agent.system_prompt = data.system_prompt
    if data.llm_model is not None:
        agent.llm_model = data.llm_model
    if data.temperature is not None:
        agent.temperature = data.temperature
    agent.updated_at = datetime.datetime.now(datetime.timezone.utc)

    await db.commit()
    await db.refresh(agent)

    await AuditService.log(
        db=db,
        action="update",
        resource="agent",
        org_id=org_id,
        resource_id=str(agent.id),
        detail=f"Updated agent: {agent.name}",
    )
    await db.commit()

    return AgentResponse(
        id=agent.id,
        org_id=agent.org_id,
        name=agent.name,
        platform_type=agent.platform_type,
        system_prompt=agent.system_prompt,
        llm_model=agent.llm_model,
        temperature=agent.temperature,
        created_at=agent.created_at.isoformat(),
        updated_at=agent.updated_at.isoformat(),
    )


@router.delete("/{agent_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_agent(
    agent_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin")),
) -> None:
    """Delete an agent and all associated sessions."""
    stmt = select(Agent).where(Agent.id == agent_id, Agent.org_id == org_id)
    result = await db.execute(stmt)
    agent = result.scalar_one_or_none()
    if not agent:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Agent not found.")

    # Delete associated messages and sessions
    from src.infrastructure.database.models import ChatSession as ORMChatSession, Message as ORMMessage
    msg_del = sa_delete(ORMMessage).where(
        ORMMessage.session_id.in_(
            select(ORMChatSession.id).where(ORMChatSession.agent_id == agent_id)
        )
    )
    await db.execute(msg_del)

    session_del = sa_delete(ORMChatSession).where(ORMChatSession.agent_id == agent_id)
    await db.execute(session_del)

    agent_del = sa_delete(Agent).where(Agent.id == agent_id)
    await db.execute(agent_del)
    await db.commit()

    await AuditService.log(
        db=db,
        action="delete",
        resource="agent",
        org_id=org_id,
        resource_id=str(agent_id),
        detail=f"Deleted agent: {agent.name}",
    )
    await db.commit()


class AgentStatusToggle(BaseModel):
    enabled: bool


@router.patch("/{agent_id}/status", response_model=AgentResponse)
async def toggle_agent_status(
    agent_id: uuid.UUID,
    data: AgentStatusToggle,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin", "member")),
) -> AgentResponse:
    """Toggle agent active status."""
    stmt = select(Agent).where(Agent.id == agent_id, Agent.org_id == org_id)
    result = await db.execute(stmt)
    agent = result.scalar_one_or_none()
    if not agent:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Agent not found.")

    agent.is_active = data.enabled
    agent.updated_at = datetime.datetime.now(datetime.timezone.utc)

    await db.commit()
    await db.refresh(agent)

    await AuditService.log(
        db=db,
        action="update",
        resource="agent",
        org_id=org_id,
        resource_id=str(agent.id),
        detail=f"{'Enabled' if data.enabled else 'Disabled'} agent: {agent.name}",
    )
    await db.commit()

    return AgentResponse(
        id=agent.id,
        org_id=agent.org_id,
        name=agent.name,
        platform_type=agent.platform_type,
        system_prompt=agent.system_prompt,
        llm_model=agent.llm_model,
        temperature=agent.temperature,
        created_at=agent.created_at.isoformat(),
        updated_at=agent.updated_at.isoformat(),
    )


# ─── Agent Registration (internal, agent-to-brain) ───────────────────────

AGENT_TYPE_MAP = {
    "whatsapp": "whatsapp",
    "calling": "calling",
    "personal_ai": "web",
    "custom": "web",
}

HEARTBEAT_STATUS_MAP = {
    "online": "healthy",
    "starting": "healthy",
    "degraded": "degraded",
    "offline": "down",
    "error": "down",
    "maintenance": "degraded",
}


class AgentRegistrationRequest(BaseModel):
    agent_id: str
    agent_name: str
    agent_type: str
    version: str = ""
    build_number: str = ""
    status: str = "starting"
    capabilities: list[str] = []
    supported_models: list[str] = []
    installed_plugins: list[str] = []
    organization_id: str = ""
    system_info: Optional[dict] = None
    startup_time: str = ""
    api_endpoint: str = ""
    health_endpoint: str = ""
    registered_at: str = ""
    last_heartbeat: str = ""


class AgentRegistrationResponse(BaseModel):
    id: str
    status: str
    agent_id: str


@router.post("/register", response_model=AgentRegistrationResponse, status_code=status.HTTP_201_CREATED)
async def register_agent(
    payload: AgentRegistrationRequest,
    x_agent_key: Optional[str] = Header(None),
    token: Optional[str] = Header(None),
    x_organization_id: Optional[str] = Header(None),
    db: AsyncSession = Depends(get_db_session),
) -> AgentRegistrationResponse:
    """
    Agent self-registration endpoint. Idempotent — if agent already exists, updates it.
    Authenticated via X-Agent-Key header (internal) or JWT Bearer token.
    When using X-Agent-Key, also send X-Organization-Id header.
    """
    org_id = await get_agent_org_id(x_agent_key=x_agent_key, token=token, x_organization_id=x_organization_id)

    platform_type = AGENT_TYPE_MAP.get(payload.agent_type, "web")

    # Idempotent: check if agent already exists by name
    stmt = select(Agent).where(Agent.name == payload.agent_name)
    if org_id:
        stmt = stmt.where(Agent.org_id == org_id)
    result = await db.execute(stmt)
    agent = result.scalar_one_or_none()

    now = datetime.datetime.now(datetime.timezone.utc)

    if agent:
        # Update existing agent
        agent.platform_type = platform_type
        agent.updated_at = now
    else:
        # Create new agent
        if not org_id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="organization_id is required for agent registration without JWT.",
            )
        agent = Agent(
            id=uuid.uuid4(),
            org_id=org_id,
            name=payload.agent_name,
            platform_type=platform_type,
            system_prompt="",
            llm_model="llama3",
            created_at=now,
            updated_at=now,
        )
        db.add(agent)

    await db.flush()

    # Store capabilities (idempotent — clear and re-add)
    del_stmt = sa_delete(AgentCapability).where(AgentCapability.agent_id == agent.id)
    await db.execute(del_stmt)
    for cap_name in payload.capabilities:
        cap = AgentCapability(
            agent_id=agent.id,
            capability_name=cap_name,
            enabled=True,
            created_at=now,
        )
        db.add(cap)

    # Ensure health record exists
    health_stmt = select(AgentHealth).where(AgentHealth.agent_id == agent.id)
    health_result = await db.execute(health_stmt)
    health = health_result.scalar_one_or_none()
    if not health:
        health = AgentHealth(
            id=uuid.uuid4(),
            agent_id=agent.id,
            status=HEARTBEAT_STATUS_MAP.get(payload.status, "healthy"),
            created_at=now,
        )
        db.add(health)

    await db.commit()

    return AgentRegistrationResponse(
        id=str(agent.id),
        status="registered",
        agent_id=payload.agent_id,
    )


# ─── Flat Heartbeat (agent-to-brain, no path param) ──────────────────────

class FlatHeartbeatRequest(BaseModel):
    agent_id: str
    status: str = "online"
    cpu_percent: float = 0.0
    ram_percent: float = 0.0
    active_sessions: int = 0
    active_conversations: int = 0
    running_tasks: int = 0
    queue_size: int = 0
    uptime_seconds: float = 0.0
    timestamp: str = ""


class FlatHeartbeatResponse(BaseModel):
    status: str


@router.post("/heartbeat", response_model=FlatHeartbeatResponse, status_code=status.HTTP_201_CREATED)
async def record_flat_heartbeat(
    payload: FlatHeartbeatRequest,
    x_agent_key: Optional[str] = Header(None),
    token: Optional[str] = Header(None),
    x_organization_id: Optional[str] = Header(None),
    db: AsyncSession = Depends(get_db_session),
) -> FlatHeartbeatResponse:
    """
    Agent heartbeat endpoint (flat — agent_id in body, not path).
    Authenticated via X-Agent-Key header (internal) or JWT Bearer token.
    When using X-Agent-Key, also send X-Organization-Id header.
    """
    org_id = await get_agent_org_id(x_agent_key=x_agent_key, token=token, x_organization_id=x_organization_id)

    # Find agent by name
    stmt = select(Agent).where(Agent.name == payload.agent_id)
    if org_id:
        stmt = stmt.where(Agent.org_id == org_id)
    result = await db.execute(stmt)
    agent = result.scalar_one_or_none()
    if not agent:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Agent not found.")

    mapped_status = HEARTBEAT_STATUS_MAP.get(payload.status, payload.status)

    now = datetime.datetime.now(datetime.timezone.utc)

    # Store heartbeat with correct DB columns
    heartbeat = AgentHeartbeat(
        id=uuid.uuid4(),
        agent_id=agent.id,
        status=mapped_status,
        cpu_usage=payload.cpu_percent,
        memory_usage=payload.ram_percent,
        active_tasks=payload.running_tasks,
        timestamp=now,
        created_at=now,
    )
    db.add(heartbeat)

    # Update or create health record
    health_stmt = select(AgentHealth).where(AgentHealth.agent_id == agent.id)
    health_result = await db.execute(health_stmt)
    health = health_result.scalar_one_or_none()
    if health:
        health.status = mapped_status
        health.last_heartbeat_at = now
    else:
        health = AgentHealth(
            id=uuid.uuid4(),
            agent_id=agent.id,
            status=mapped_status,
            last_heartbeat_at=now,
            created_at=now,
        )
        db.add(health)

    await db.commit()

    return FlatHeartbeatResponse(status="ok")
