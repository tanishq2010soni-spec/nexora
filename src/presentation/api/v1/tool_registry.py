import uuid
import datetime
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel, Field
from sqlalchemy import select, func, distinct, delete as sa_delete
from sqlalchemy.ext.asyncio import AsyncSession

from src.infrastructure.database.connection import get_db_session
from src.infrastructure.database.models import ToolDefinition
from src.presentation.api.dependencies import get_current_org_id, require_role
from src.application.services.audit_service import AuditService

router = APIRouter()


# ─── Schemas ───────────────────────────────────────────────────────────────

class ToolRegistryResponse(BaseModel):
    id: uuid.UUID
    org_id: uuid.UUID
    name: str
    description: Optional[str] = None
    category: str
    endpoint_url: Optional[str] = None
    auth_config_json: Optional[str] = None
    input_schema_json: Optional[str] = None
    output_schema_json: Optional[str] = None
    is_active: bool
    metadata_json: Optional[str] = None
    created_at: str
    updated_at: str


class ToolRegistryCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    category: str = Field(..., min_length=1, max_length=100)
    endpoint_url: Optional[str] = None
    auth_config_json: Optional[str] = None
    input_schema_json: Optional[str] = None
    output_schema_json: Optional[str] = None
    is_active: bool = Field(default=True)
    metadata_json: Optional[str] = None


class ToolRegistryUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    description: Optional[str] = None
    category: Optional[str] = Field(None, min_length=1, max_length=100)
    endpoint_url: Optional[str] = None
    auth_config_json: Optional[str] = None
    input_schema_json: Optional[str] = None
    output_schema_json: Optional[str] = None
    is_active: Optional[bool] = None
    metadata_json: Optional[str] = None


class ToolToggleResponse(BaseModel):
    id: uuid.UUID
    is_active: bool


class ToolHealthResponse(BaseModel):
    tool_id: uuid.UUID
    status: str
    message: Optional[str] = None
    checked_at: str


class ToolCategoryResponse(BaseModel):
    category: str


# ─── Helpers ───────────────────────────────────────────────────────────────

async def _get_tool_or_404(db: AsyncSession, tool_id: uuid.UUID, org_id: uuid.UUID) -> ToolDefinition:
    stmt = select(ToolDefinition).where(ToolDefinition.id == tool_id, ToolDefinition.org_id == org_id)
    result = await db.execute(stmt)
    tool = result.scalar_one_or_none()
    if not tool:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Tool not found.")
    return tool


def _tool_to_response(t: ToolDefinition) -> ToolRegistryResponse:
    return ToolRegistryResponse(
        id=t.id, org_id=t.org_id, name=t.name,
        description=t.description, category=t.category,
        endpoint_url=t.endpoint_url, auth_config_json=t.auth_config_json,
        input_schema_json=t.input_schema_json, output_schema_json=t.output_schema_json,
        is_active=t.is_active, metadata_json=t.metadata_json,
        created_at=t.created_at.isoformat(),
        updated_at=t.updated_at.isoformat(),
    )


# ─── Endpoints ─────────────────────────────────────────────────────────────

@router.get("/", response_model=List[ToolRegistryResponse])
async def list_tools(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    category: Optional[str] = Query(default=None),
    search: Optional[str] = Query(default=None),
    is_active: Optional[bool] = Query(default=None),
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
) -> List[ToolRegistryResponse]:
    stmt = select(ToolDefinition).where(ToolDefinition.org_id == org_id)

    if category:
        stmt = stmt.where(ToolDefinition.category == category)
    if is_active is not None:
        stmt = stmt.where(ToolDefinition.is_active == is_active)
    if search:
        stmt = stmt.where(ToolDefinition.name.ilike(f"%{search}%"))

    stmt = stmt.order_by(ToolDefinition.name.asc()).limit(limit).offset(offset)
    result = await db.execute(stmt)
    return [_tool_to_response(t) for t in result.scalars().all()]


@router.post("/", response_model=ToolRegistryResponse, status_code=status.HTTP_201_CREATED)
async def register_tool(
    data: ToolRegistryCreate,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin", "member")),
) -> ToolRegistryResponse:
    now = datetime.datetime.now(datetime.timezone.utc)
    tool = ToolDefinition(
        id=uuid.uuid4(),
        org_id=org_id,
        name=data.name,
        description=data.description,
        category=data.category,
        endpoint_url=data.endpoint_url,
        auth_config_json=data.auth_config_json,
        input_schema_json=data.input_schema_json,
        output_schema_json=data.output_schema_json,
        is_active=data.is_active,
        metadata_json=data.metadata_json,
        created_at=now,
        updated_at=now,
    )
    db.add(tool)
    await db.commit()
    await db.refresh(tool)

    await AuditService.log(
        db=db, action="create", resource="tool_registry",
        org_id=org_id, resource_id=str(tool.id),
        detail=f"Registered tool: {tool.name} (category: {tool.category})",
    )
    await db.commit()

    return _tool_to_response(tool)


@router.get("/{tool_id}", response_model=ToolRegistryResponse)
async def get_tool(
    tool_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> ToolRegistryResponse:
    tool = await _get_tool_or_404(db, tool_id, org_id)
    return _tool_to_response(tool)


@router.put("/{tool_id}", response_model=ToolRegistryResponse)
async def update_tool(
    tool_id: uuid.UUID,
    data: ToolRegistryUpdate,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin", "member")),
) -> ToolRegistryResponse:
    tool = await _get_tool_or_404(db, tool_id, org_id)

    if data.name is not None:
        tool.name = data.name
    if data.description is not None:
        tool.description = data.description
    if data.category is not None:
        tool.category = data.category
    if data.endpoint_url is not None:
        tool.endpoint_url = data.endpoint_url
    if data.auth_config_json is not None:
        tool.auth_config_json = data.auth_config_json
    if data.input_schema_json is not None:
        tool.input_schema_json = data.input_schema_json
    if data.output_schema_json is not None:
        tool.output_schema_json = data.output_schema_json
    if data.is_active is not None:
        tool.is_active = data.is_active
    if data.metadata_json is not None:
        tool.metadata_json = data.metadata_json
    tool.updated_at = datetime.datetime.now(datetime.timezone.utc)

    await db.commit()
    await db.refresh(tool)

    await AuditService.log(
        db=db, action="update", resource="tool_registry",
        org_id=org_id, resource_id=str(tool.id),
        detail=f"Updated tool: {tool.name}",
    )
    await db.commit()

    return _tool_to_response(tool)


@router.delete("/{tool_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_tool(
    tool_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin")),
) -> None:
    tool = await _get_tool_or_404(db, tool_id, org_id)

    await db.execute(sa_delete(ToolDefinition).where(ToolDefinition.id == tool_id))
    await db.commit()

    await AuditService.log(
        db=db, action="delete", resource="tool_registry",
        org_id=org_id, resource_id=str(tool_id),
        detail=f"Unregistered tool: {tool.name}",
    )
    await db.commit()


@router.post("/{tool_id}/toggle", response_model=ToolToggleResponse)
async def toggle_tool(
    tool_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
    _=Depends(require_role("admin", "member")),
) -> ToolToggleResponse:
    tool = await _get_tool_or_404(db, tool_id, org_id)

    tool.is_active = not tool.is_active
    tool.updated_at = datetime.datetime.now(datetime.timezone.utc)
    await db.commit()
    await db.refresh(tool)

    action = "Enabled" if tool.is_active else "Disabled"
    await AuditService.log(
        db=db, action="update", resource="tool_registry",
        org_id=org_id, resource_id=str(tool.id),
        detail=f"{action} tool: {tool.name}",
    )
    await db.commit()

    return ToolToggleResponse(id=tool.id, is_active=tool.is_active)


@router.get("/{tool_id}/health", response_model=ToolHealthResponse)
async def check_tool_health(
    tool_id: uuid.UUID,
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> ToolHealthResponse:
    tool = await _get_tool_or_404(db, tool_id, org_id)

    now = datetime.datetime.now(datetime.timezone.utc)
    status_val = "unknown"
    message = None

    if tool.endpoint_url:
        try:
            import httpx
            async with httpx.AsyncClient(timeout=5.0) as client:
                resp = await client.get(tool.endpoint_url)
                status_val = "healthy" if resp.is_success else "degraded"
                message = f"HTTP {resp.status_code}"
        except Exception as e:
            status_val = "unreachable"
            message = str(e)
    else:
        message = "No endpoint configured"

    return ToolHealthResponse(
        tool_id=tool_id,
        status=status_val,
        message=message,
        checked_at=now.isoformat(),
    )


@router.get("/categories", response_model=List[ToolCategoryResponse])
async def list_tool_categories(
    org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session),
) -> List[ToolCategoryResponse]:
    stmt = select(distinct(ToolDefinition.category)).where(ToolDefinition.org_id == org_id)
    result = await db.execute(stmt)
    return [ToolCategoryResponse(category=row[0]) for row in result.all()]
