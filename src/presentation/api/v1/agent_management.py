import uuid
import datetime
from typing import Any, Dict, List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel, Field
from sqlalchemy import select, func, delete as sa_delete
from sqlalchemy.ext.asyncio import AsyncSession

from src.infrastructure.database.connection import get_db_session
from src.infrastructure.database.models import (
    Agent,
    AgentVersion,
    AgentCapability,
    AgentHealth,
    AgentHeartbeat,
    AgentLog,
    AgentConfiguration,
)
from src.presentation.api.dependencies import get_current_org_id, require_role
from src.application.services.audit_service import AuditService

router = APIRouter()


# ─── Schemas ───────────────────────────────────────────────────────────────

class AgentVersionResponse(BaseModel):
    id: uuid.UUID
    agent_id: uuid.UUID
    version: str
    description: Optional[str] = None
    config_json: Optional[str] = None
    status: str
    created_at: str


class AgentVersionCreate(BaseModel):
    version: str = Field(..., min_length=1, max_length=50)
    description: Optional[str] = None
    config_json: Optional[str] = None
    status: str = Field(default="draft", pattern="^(draft|active|archived)$")


class AgentCapabilityResponse(BaseModel):
    id: uuid.UUID
    agent_id: uuid.UUID
    name: str
    description: Optional[str] = None
    enabled: bool
    config_json: Optional[str] = None
    created_at: str
    updated_at: str


class AgentCapabilityUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    description: Optional[str] = None
    enabled: Optional[bool] = None
    config_json: Optional[str] = None


class AgentHealthResponse(BaseModel):
    id: uuid.UUID
    agent_id: uuid.UUID
    status: str
    last_heartbeat_at: Optional[str] = None
    error_message: Optional[str] = None
    metrics_json: Optional[str] = None
    created_at: str
    updated_at: str


class AgentHeartbeatResponse(BaseModel):
    id: uuid.UUID
    agent_id: uuid.UUID
    status: str
    metrics_json: Optional[str] = None
    created_at: str


class AgentHeartbeatCreate(BaseModel):
    status: str = Field(default="healthy", pattern="^(healthy|degraded|down)$")
    metrics_json: Optional[str] = None


class AgentLogResponse(BaseModel):
    id: uuid.UUID
    agent_id: uuid.UUID
    level: str
    message: str
    source: Optional[str] = None
    created_at: str


class AgentConfigurationResponse(BaseModel):
    id: uuid.UUID
    agent_id: uuid.UUID
    config_key: str
    config_value: Optional[str] = None
    value_type: str
    created_at: str
    updated_at: str


class AgentConfigurationUpdate(BaseModel):
    config_value: Optional[str] = None
    value_type: Optional[str] = Field(None, pattern="^(string|boolean|json|integer|float)$")


# ─── Helpers ───────────────────────────────────────────────────────────────

async def _get_agent_or_404(db: AsyncSession, agent_id: uuid.UUID, org_id: uuid.UUID) -> Agent:
    stmt = select(Agent).where(Agent.id == agent_id, Agent.org_id == org_id)
    result = await db.execute(stmt)
    agent = result.scalar_one_or_none()
    if not agent:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Agent not found.")
    return agent


# ─── Agent Versions ────────────────────────────────────────────────────────

@router.get("/{agent_id}/versions", response_model=List[AgentVersionResponse])
async def list_agent_versions(
    agent_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
) -> List[AgentVersionResponse]:
    await _get_agent_or_404(db, agent_id, org_id)
    stmt = (
        select(AgentVersion)
        .where(AgentVersion.agent_id == agent_id)
        .order_by(AgentVersion.created_at.desc())
        .limit(limit)
        .offset(offset)
    )
    result = await db.execute(stmt)
    return [
        AgentVersionResponse(
            id=v.id, agent_id=v.agent_id, version=v.version,
            description=v.description, config_json=v.config_json,
            status=v.status, created_at=v.created_at.isoformat(),
        )
        for v in result.scalars().all()
    ]


@router.post("/{agent_id}/versions", response_model=AgentVersionResponse, status_code=status.HTTP_201_CREATED)
async def create_agent_version(
    agent_id: uuid.UUID,
    data: AgentVersionCreate,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin", "member")),
) -> AgentVersionResponse:
    agent = await _get_agent_or_404(db, agent_id, org_id)
    version = AgentVersion(
        id=uuid.uuid4(),
        agent_id=agent_id,
        version=data.version,
        description=data.description,
        config_json=data.config_json,
        status=data.status,
        created_at=datetime.datetime.now(datetime.timezone.utc),
    )
    db.add(version)
    await db.commit()
    await db.refresh(version)

    await AuditService.log(
        db=db, action="create", resource="agent_version",
        org_id=org_id, resource_id=str(version.id),
        detail=f"Version {data.version} created for agent: {agent.name}",
    )
    await db.commit()

    return AgentVersionResponse(
        id=version.id, agent_id=version.agent_id, version=version.version,
        description=version.description, config_json=version.config_json,
        status=version.status, created_at=version.created_at.isoformat(),
    )


# ─── Agent Capabilities ────────────────────────────────────────────────────

@router.get("/{agent_id}/capabilities", response_model=List[AgentCapabilityResponse])
async def list_agent_capabilities(
    agent_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
) -> List[AgentCapabilityResponse]:
    await _get_agent_or_404(db, agent_id, org_id)
    stmt = (
        select(AgentCapability)
        .where(AgentCapability.agent_id == agent_id)
        .order_by(AgentCapability.capability_name.asc())
        .limit(limit)
        .offset(offset)
    )
    result = await db.execute(stmt)
    return [
        AgentCapabilityResponse(
            id=c.id, agent_id=c.agent_id, name=c.capability_name,
            description=c.description, enabled=c.enabled,
            config_json=c.config_json,
            created_at=c.created_at.isoformat(),
            updated_at=c.updated_at.isoformat(),
        )
        for c in result.scalars().all()
    ]


@router.put("/{agent_id}/capabilities/{cap_id}", response_model=AgentCapabilityResponse)
async def update_agent_capability(
    agent_id: uuid.UUID,
    cap_id: uuid.UUID,
    data: AgentCapabilityUpdate,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin", "member")),
) -> AgentCapabilityResponse:
    await _get_agent_or_404(db, agent_id, org_id)
    stmt = select(AgentCapability).where(AgentCapability.id == cap_id, AgentCapability.agent_id == agent_id)
    result = await db.execute(stmt)
    cap = result.scalar_one_or_none()
    if not cap:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Capability not found.")

    if data.name is not None:
        cap.capability_name = data.name
    if data.description is not None:
        cap.description = data.description
    if data.enabled is not None:
        cap.enabled = data.enabled
    if data.config_json is not None:
        cap.config_json = data.config_json
    cap.updated_at = datetime.datetime.now(datetime.timezone.utc)

    await db.commit()
    await db.refresh(cap)

    await AuditService.log(
        db=db, action="update", resource="agent_capability",
        org_id=org_id, resource_id=str(cap.id),
        detail=f"Updated capability: {cap.capability_name}",
    )
    await db.commit()

    return AgentCapabilityResponse(
        id=cap.id, agent_id=cap.agent_id, name=cap.capability_name,
        description=cap.description, enabled=cap.enabled,
        config_json=cap.config_json,
        created_at=cap.created_at.isoformat(),
        updated_at=cap.updated_at.isoformat(),
    )


# ─── Agent Health ──────────────────────────────────────────────────────────

@router.get("/{agent_id}/health", response_model=AgentHealthResponse)
async def get_agent_health(
    agent_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> AgentHealthResponse:
    await _get_agent_or_404(db, agent_id, org_id)
    stmt = (
        select(AgentHealth)
        .where(AgentHealth.agent_id == agent_id)
        .order_by(AgentHealth.created_at.desc())
        .limit(1)
    )
    result = await db.execute(stmt)
    health = result.scalar_one_or_none()
    if not health:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="No health record found for agent.")

    return AgentHealthResponse(
        id=health.id, agent_id=health.agent_id,
        status=health.status,
        last_heartbeat_at=health.last_heartbeat_at.isoformat() if health.last_heartbeat_at else None,
        error_message=health.error_message,
        metrics_json=health.metrics_json if hasattr(health, 'metrics_json') else None,
        created_at=health.created_at.isoformat(),
        updated_at=health.updated_at.isoformat() if hasattr(health, 'updated_at') else health.created_at.isoformat(),
    )


# ─── Agent Heartbeat ──────────────────────────────────────────────────────

@router.post("/{agent_id}/heartbeat", response_model=AgentHeartbeatResponse, status_code=status.HTTP_201_CREATED)
async def record_heartbeat(
    agent_id: uuid.UUID,
    data: AgentHeartbeatCreate,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> AgentHeartbeatResponse:
    agent = await _get_agent_or_404(db, agent_id, org_id)

    now = datetime.datetime.now(datetime.timezone.utc)
    heartbeat = AgentHeartbeat(
        id=uuid.uuid4(),
        agent_id=agent_id,
        status=data.status,
        timestamp=now,
    )
    db.add(heartbeat)

    health_stmt = (
        select(AgentHealth)
        .where(AgentHealth.agent_id == agent_id)
        .order_by(AgentHealth.created_at.desc())
        .limit(1)
    )
    health_result = await db.execute(health_stmt)
    health = health_result.scalar_one_or_none()

    if health:
        health.status = data.status
        health.last_heartbeat_at = now
    else:
        health = AgentHealth(
            id=uuid.uuid4(),
            agent_id=agent_id,
            status=data.status,
            last_heartbeat_at=now,
            created_at=now,
        )
        db.add(health)

    await db.commit()
    await db.refresh(heartbeat)

    await AuditService.log(
        db=db, action="heartbeat", resource="agent",
        org_id=org_id, resource_id=str(agent_id),
        detail=f"Heartbeat received for agent: {agent.name} (status: {data.status})",
    )
    await db.commit()

    return AgentHeartbeatResponse(
        id=heartbeat.id, agent_id=heartbeat.agent_id,
        status=heartbeat.status, metrics_json=None,
        created_at=heartbeat.timestamp.isoformat(),
    )


# ─── Agent Logs ────────────────────────────────────────────────────────────

@router.get("/{agent_id}/logs", response_model=List[AgentLogResponse])
async def list_agent_logs(
    agent_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    level: Optional[str] = Query(default=None, pattern="^(debug|info|warning|error|critical)$"),
    limit: int = Query(default=50, ge=1, le=500),
    offset: int = Query(default=0, ge=0),
) -> List[AgentLogResponse]:
    await _get_agent_or_404(db, agent_id, org_id)
    stmt = select(AgentLog).where(AgentLog.agent_id == agent_id)
    if level:
        stmt = stmt.where(AgentLog.level == level)
    stmt = stmt.order_by(AgentLog.created_at.desc()).limit(limit).offset(offset)
    result = await db.execute(stmt)
    return [
        AgentLogResponse(
            id=l.id, agent_id=l.agent_id, level=l.level,
            message=l.message, source=l.metadata_json,
            created_at=l.created_at.isoformat(),
        )
        for l in result.scalars().all()
    ]


# ─── Agent Configuration ──────────────────────────────────────────────────

@router.get("/{agent_id}/config", response_model=List[AgentConfigurationResponse])
async def list_agent_config(
    agent_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
) -> List[AgentConfigurationResponse]:
    await _get_agent_or_404(db, agent_id, org_id)
    stmt = (
        select(AgentConfiguration)
        .where(AgentConfiguration.agent_id == agent_id)
        .order_by(AgentConfiguration.config_key.asc())
        .limit(limit)
        .offset(offset)
    )
    result = await db.execute(stmt)
    return [
        AgentConfigurationResponse(
            id=c.id, agent_id=c.agent_id, config_key=c.config_key,
            config_value=c.config_value, value_type=c.config_type,
            created_at=c.created_at.isoformat(),
            updated_at=c.updated_at.isoformat(),
        )
        for c in result.scalars().all()
    ]


@router.put("/{agent_id}/config/{config_key}", response_model=AgentConfigurationResponse)
async def update_agent_config(
    agent_id: uuid.UUID,
    config_key: str,
    data: AgentConfigurationUpdate,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin", "member")),
) -> AgentConfigurationResponse:
    agent = await _get_agent_or_404(db, agent_id, org_id)

    stmt = select(AgentConfiguration).where(
        AgentConfiguration.agent_id == agent_id,
        AgentConfiguration.config_key == config_key,
    )
    result = await db.execute(stmt)
    config = result.scalar_one_or_none()

    now = datetime.datetime.now(datetime.timezone.utc)
    if config:
        if data.config_value is not None:
            config.config_value = data.config_value
        if data.value_type is not None:
            config.config_type = data.value_type
        config.updated_at = now
    else:
        config = AgentConfiguration(
            id=uuid.uuid4(),
            agent_id=agent_id,
            config_key=config_key,
            config_value=data.config_value,
            config_type=data.value_type or "string",
            created_at=now,
            updated_at=now,
        )
        db.add(config)

    await db.commit()
    await db.refresh(config)

    await AuditService.log(
        db=db, action="update", resource="agent_configuration",
        org_id=org_id, resource_id=str(config.id),
        detail=f"Config '{config_key}' updated for agent: {agent.name}",
    )
    await db.commit()

    return AgentConfigurationResponse(
        id=config.id, agent_id=config.agent_id, config_key=config.config_key,
        config_value=config.config_value, value_type=config.config_type,
        created_at=config.created_at.isoformat(),
        updated_at=config.updated_at.isoformat(),
    )
