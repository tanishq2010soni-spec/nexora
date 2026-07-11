from typing import Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from ..api.auth import get_current_user, require_permission
from ..domain.entities import User
from ..domain.enums import AgentRole, Permission
from ..infrastructure.database import UserModel, get_session

router = APIRouter(prefix="/api/v1/permissions", tags=["permissions"])

ROLE_PERMISSIONS: dict[str, list[str]] = {
    AgentRole.admin.value: [p.value for p in Permission],
    AgentRole.supervisor.value: [
        Permission.view_dashboard.value,
        Permission.view_inbox.value,
        Permission.manage_inbox.value,
        Permission.view_crm.value,
        Permission.manage_crm.value,
        Permission.view_knowledge.value,
        Permission.manage_knowledge.value,
        Permission.view_workflows.value,
        Permission.manage_workflows.value,
        Permission.view_campaigns.value,
        Permission.manage_campaigns.value,
        Permission.view_analytics.value,
        Permission.view_settings.value,
        Permission.view_logs.value,
    ],
    AgentRole.agent.value: [
        Permission.view_dashboard.value,
        Permission.view_inbox.value,
        Permission.manage_inbox.value,
        Permission.view_crm.value,
        Permission.view_knowledge.value,
        Permission.view_analytics.value,
    ],
    AgentRole.viewer.value: [
        Permission.view_dashboard.value,
        Permission.view_inbox.value,
        Permission.view_crm.value,
        Permission.view_knowledge.value,
        Permission.view_analytics.value,
    ],
}


@router.get("/")
async def list_permissions(
    _: User = Depends(require_permission("manage_permissions")),
):
    return {
        "permissions": [p.value for p in Permission],
        "roles": {
            role: perms
            for role, perms in ROLE_PERMISSIONS.items()
        },
    }


@router.get("/users")
async def list_users_with_permissions(
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_permissions")),
    page: int = Query(1, ge=1),
    limit: int = Query(50, ge=1, le=100),
):
    org_id = str(current_user.organization_id)
    query = select(UserModel).where(UserModel.organization_id == org_id)
    total_result = await session.execute(select(func.count()).select_from(query.subquery()))
    total = total_result.scalar()
    offset = (page - 1) * limit
    result = await session.execute(query.offset(offset).limit(limit))
    models = result.scalars().all()
    return {
        "items": [
            {
                "id": m.id,
                "email": m.email,
                "name": m.name,
                "role": m.role,
                "permissions": m.permissions or [],
            }
            for m in models
        ],
        "total": total,
        "page": page,
        "limit": limit,
    }


@router.put("/users/{user_id}")
async def update_user_permissions(
    user_id: UUID,
    permissions: list[str],
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_permissions")),
):
    org_id = str(current_user.organization_id)
    result = await session.execute(
        select(UserModel).where(
            UserModel.id == str(user_id),
            UserModel.organization_id == org_id,
        )
    )
    model = result.scalar_one_or_none()
    if not model:
        raise HTTPException(status_code=404, detail="User not found")
    valid_perms = {p.value for p in Permission}
    for p in permissions:
        if p not in valid_perms:
            raise HTTPException(status_code=400, detail=f"Invalid permission: {p}")
    model.permissions = permissions
    session.add(model)
    await session.flush()
    return {
        "id": model.id,
        "email": model.email,
        "name": model.name,
        "role": model.role,
        "permissions": model.permissions,
    }


@router.get("/roles")
async def list_role_definitions(
    _: User = Depends(require_permission("manage_permissions")),
):
    return {
        "roles": [
            {
                "role": role,
                "permissions": perms,
                "description": _get_role_description(role),
            }
            for role, perms in ROLE_PERMISSIONS.items()
        ]
    }


@router.put("/roles/{role_name}")
async def update_role_permissions(
    role_name: str,
    permissions: list[str],
    _: User = Depends(require_permission("manage_permissions")),
):
    if role_name not in ROLE_PERMISSIONS:
        raise HTTPException(status_code=404, detail=f"Role '{role_name}' not found")
    valid_perms = {p.value for p in Permission}
    for p in permissions:
        if p not in valid_perms:
            raise HTTPException(status_code=400, detail=f"Invalid permission: {p}")
    ROLE_PERMISSIONS[role_name] = permissions
    return {
        "role": role_name,
        "permissions": permissions,
        "detail": "Role permissions updated (in-memory)",
    }


def _get_role_description(role: str) -> str:
    descriptions = {
        AgentRole.admin.value: "Full access to all features and settings",
        AgentRole.supervisor.value: "Access to most features except advanced settings and permissions",
        AgentRole.agent.value: "Access to inbox, CRM, and basic analytics",
        AgentRole.viewer.value: "Read-only access to dashboard, inbox, CRM, and analytics",
    }
    return descriptions.get(role, "")
