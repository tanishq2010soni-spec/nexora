import uuid
import datetime
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel, Field
from sqlalchemy import select, func, delete as sa_delete
from sqlalchemy.ext.asyncio import AsyncSession

from src.infrastructure.database.connection import get_db_session
from src.infrastructure.database.models import Department, Team, Role, User
from src.presentation.api.dependencies import get_current_org_id, require_role

router = APIRouter()


class DepartmentResponse(BaseModel):
    id: uuid.UUID
    org_id: uuid.UUID
    name: str
    description: Optional[str] = None
    created_at: str


class TeamResponse(BaseModel):
    id: uuid.UUID
    org_id: uuid.UUID
    department_id: Optional[uuid.UUID] = None
    name: str
    description: Optional[str] = None
    created_at: str


class RoleResponse(BaseModel):
    id: uuid.UUID
    org_id: uuid.UUID
    name: str
    permissions: str
    created_at: str


class UserResponse(BaseModel):
    id: uuid.UUID
    org_id: uuid.UUID
    email: str
    role: str
    created_at: str


class CreateDepartmentRequest(BaseModel):
    name: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None


class CreateTeamRequest(BaseModel):
    name: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    department_id: Optional[uuid.UUID] = None


class CreateRoleRequest(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    permissions: str = Field(default="[]")


def _dept_to_response(d) -> DepartmentResponse:
    return DepartmentResponse(id=d.id, org_id=d.org_id, name=d.name, description=d.description, created_at=d.created_at.isoformat())


def _team_to_response(t) -> TeamResponse:
    return TeamResponse(id=t.id, org_id=t.org_id, department_id=t.department_id, name=t.name, description=t.description, created_at=t.created_at.isoformat())


def _role_to_response(r) -> RoleResponse:
    return RoleResponse(id=r.id, org_id=r.org_id, name=r.name, permissions=r.permissions, created_at=r.created_at.isoformat())


def _user_to_response(u) -> UserResponse:
    return UserResponse(id=u.id, org_id=u.org_id, email=u.email, role=u.role, created_at=u.created_at.isoformat())


@router.get("/departments", response_model=List[DepartmentResponse])
async def list_departments(org_id: uuid.UUID = Depends(get_current_org_id), db: AsyncSession = Depends(get_db_session)) -> List[DepartmentResponse]:
    stmt = select(Department).where(Department.org_id == org_id).order_by(Department.created_at.desc())
    result = await db.execute(stmt)
    return [_dept_to_response(d) for d in result.scalars().all()]


@router.post("/departments", response_model=DepartmentResponse, status_code=status.HTTP_201_CREATED)
async def create_department(
    data: CreateDepartmentRequest, org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session), _=Depends(require_role("admin")),
) -> DepartmentResponse:
    dept = Department(id=uuid.uuid4(), org_id=org_id, name=data.name, description=data.description, created_at=datetime.datetime.now(datetime.timezone.utc))
    db.add(dept)
    await db.commit()
    await db.refresh(dept)
    return _dept_to_response(dept)


@router.get("/teams", response_model=List[TeamResponse])
async def list_teams(org_id: uuid.UUID = Depends(get_current_org_id), db: AsyncSession = Depends(get_db_session)) -> List[TeamResponse]:
    stmt = select(Team).where(Team.org_id == org_id).order_by(Team.created_at.desc())
    result = await db.execute(stmt)
    return [_team_to_response(t) for t in result.scalars().all()]


@router.post("/teams", response_model=TeamResponse, status_code=status.HTTP_201_CREATED)
async def create_team(
    data: CreateTeamRequest, org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session), _=Depends(require_role("admin")),
) -> TeamResponse:
    team = Team(id=uuid.uuid4(), org_id=org_id, department_id=data.department_id, name=data.name, description=data.description, created_at=datetime.datetime.now(datetime.timezone.utc))
    db.add(team)
    await db.commit()
    await db.refresh(team)
    return _team_to_response(team)


@router.get("/roles", response_model=List[RoleResponse])
async def list_roles(org_id: uuid.UUID = Depends(get_current_org_id), db: AsyncSession = Depends(get_db_session)) -> List[RoleResponse]:
    stmt = select(Role).where(Role.org_id == org_id).order_by(Role.created_at.desc())
    result = await db.execute(stmt)
    return [_role_to_response(r) for r in result.scalars().all()]


@router.post("/roles", response_model=RoleResponse, status_code=status.HTTP_201_CREATED)
async def create_role(
    data: CreateRoleRequest, org_id: uuid.UUID = Depends(get_current_org_id),
    db: AsyncSession = Depends(get_db_session), _=Depends(require_role("admin")),
) -> RoleResponse:
    role = Role(id=uuid.uuid4(), org_id=org_id, name=data.name, permissions=data.permissions, created_at=datetime.datetime.now(datetime.timezone.utc))
    db.add(role)
    await db.commit()
    await db.refresh(role)
    return _role_to_response(role)


@router.get("/members", response_model=List[UserResponse])
async def list_members(
    org_id: uuid.UUID = Depends(get_current_org_id), db: AsyncSession = Depends(get_db_session),
    limit: int = Query(default=50, ge=1, le=200), offset: int = Query(default=0, ge=0),
) -> List[UserResponse]:
    stmt = select(User).where(User.org_id == org_id).order_by(User.created_at.desc()).limit(limit).offset(offset)
    result = await db.execute(stmt)
    return [_user_to_response(u) for u in result.scalars().all()]


@router.get("/activity")
async def team_activity(
    org_id: uuid.UUID = Depends(get_current_org_id), db: AsyncSession = Depends(get_db_session),
) -> dict:
    from src.infrastructure.database.models import ActivityLog
    stmt = select(ActivityLog).where(ActivityLog.org_id == org_id).order_by(ActivityLog.created_at.desc()).limit(50)
    result = await db.execute(stmt)
    logs = result.scalars().all()
    return {
        "total_activities": len(logs),
        "activities": [
            {
                "id": str(l.id), "entity_type": l.entity_type, "entity_id": str(l.entity_id),
                "activity_type": l.activity_type, "description": l.description,
                "performed_by": l.performed_by, "created_at": l.created_at.isoformat(),
            }
            for l in logs
        ],
    }
