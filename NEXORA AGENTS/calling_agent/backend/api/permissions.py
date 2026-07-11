from __future__ import annotations

from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ..api.auth import get_current_user, require_permission
from ..domain.enums import AgentRole, Permission
from ..infrastructure.database import UserModel, get_session

router = APIRouter(prefix="/api/v1/permissions", tags=["permissions"])


class PermissionDefinition(BaseModel):
    key: str
    description: str


class UserPermissionsResponse(BaseModel):
    id: UUID
    name: str
    email: str
    role: str
    permissions: list[str]


class UpdateUserPermissionsRequest(BaseModel):
    permissions: list[str]


class RoleDefinition(BaseModel):
    role: str
    permissions: list[str]
    description: str


ROLE_PERMISSIONS: dict[str, dict[str, list[str]]] = {
    AgentRole.admin.value: {
        "permissions": [p.value for p in Permission],
        "description": "Full access to all features and settings",
    },
    AgentRole.supervisor.value: {
        "permissions": [
            Permission.view_dashboard.value,
            Permission.view_live_calls.value,
            Permission.manage_calls.value,
            Permission.view_call_queue.value,
            Permission.manage_call_queue.value,
            Permission.view_campaigns.value,
            Permission.view_leads.value,
            Permission.manage_leads.value,
            Permission.view_crm.value,
            Permission.manage_crm.value,
            Permission.view_knowledge.value,
            Permission.view_analytics.value,
            Permission.view_recordings.value,
            Permission.view_scripts.value,
            Permission.monitor_calls.value,
            Permission.barge_calls.value,
            Permission.whisper_calls.value,
            Permission.view_settings.value,
            Permission.view_logs.value,
            Permission.view_health.value,
        ],
        "description": "Can monitor and manage calls, campaigns, leads; view analytics and recordings",
    },
    AgentRole.agent.value: {
        "permissions": [
            Permission.view_dashboard.value,
            Permission.view_live_calls.value,
            Permission.manage_calls.value,
            Permission.view_call_queue.value,
            Permission.view_campaigns.value,
            Permission.view_leads.value,
            Permission.manage_leads.value,
            Permission.view_crm.value,
            Permission.manage_crm.value,
            Permission.view_knowledge.value,
            Permission.view_scripts.value,
            Permission.view_recordings.value,
        ],
        "description": "Can handle calls, manage leads and contacts, view scripts and recordings",
    },
    AgentRole.viewer.value: {
        "permissions": [
            Permission.view_dashboard.value,
            Permission.view_live_calls.value,
            Permission.view_call_queue.value,
            Permission.view_campaigns.value,
            Permission.view_leads.value,
            Permission.view_crm.value,
            Permission.view_analytics.value,
            Permission.view_recordings.value,
            Permission.view_scripts.value,
            Permission.view_knowledge.value,
            Permission.view_health.value,
        ],
        "description": "Read-only access to dashboards, calls, campaigns, and reports",
    },
}


@router.get("", response_model=list[PermissionDefinition])
async def list_permissions(
    current_user = Depends(require_permission("manage_permissions")),
):
    return [
        PermissionDefinition(key=p.value, description=p.name.replace("_", " ").title())
        for p in Permission
    ]


@router.get("/users", response_model=list[UserPermissionsResponse])
async def list_users_with_permissions(
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_permissions")),
):
    result = await session.execute(
        select(UserModel).where(UserModel.organization_id == str(current_user.organization_id))
        .order_by(UserModel.name)
    )
    models = result.scalars().all()
    return [
        UserPermissionsResponse(
            id=UUID(m.id),
            name=m.name,
            email=m.email,
            role=m.role,
            permissions=m.permissions or [],
        )
        for m in models
    ]


@router.put("/users/{user_id}", response_model=UserPermissionsResponse)
async def update_user_permissions(
    user_id: UUID,
    req: UpdateUserPermissionsRequest,
    session: AsyncSession = Depends(get_session),
    current_user = Depends(require_permission("manage_permissions")),
):
    result = await session.execute(
        select(UserModel).where(UserModel.id == str(user_id))
        .where(UserModel.organization_id == str(current_user.organization_id))
    )
    model = result.scalar_one_or_none()
    if model is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    valid_permissions = {p.value for p in Permission}
    for p in req.permissions:
        if p not in valid_permissions:
            raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail=f"Invalid permission: {p}")

    model.permissions = req.permissions
    session.add(model)
    await session.flush()
    await session.refresh(model)

    return UserPermissionsResponse(
        id=UUID(model.id),
        name=model.name,
        email=model.email,
        role=model.role,
        permissions=model.permissions or [],
    )


@router.get("/roles", response_model=list[RoleDefinition])
async def list_role_definitions(
    current_user = Depends(require_permission("manage_permissions")),
):
    return [
        RoleDefinition(
            role=role_key,
            permissions=role_data["permissions"],
            description=role_data["description"],
        )
        for role_key, role_data in ROLE_PERMISSIONS.items()
    ]
