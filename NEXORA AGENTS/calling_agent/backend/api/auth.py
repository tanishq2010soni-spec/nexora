from __future__ import annotations

import time
from collections import defaultdict
from datetime import datetime, timedelta, timezone
from typing import Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Request, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError, jwt
from passlib.context import CryptContext
from pydantic import BaseModel, EmailStr
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ..config import settings
from ..domain.entities import User
from ..domain.enums import AgentRole
from ..infrastructure.database import UserModel, get_session

router = APIRouter(prefix="/api/v1/auth", tags=["auth"])
security = HTTPBearer()
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto", bcrypt__rounds=12)

_login_attempts: dict[str, list[float]] = defaultdict(list)
_MAX_LOGIN_ATTEMPTS = 5
_LOGIN_WINDOW_SECONDS = 300


class LoginRequest(BaseModel):
    email: str
    password: str


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int


class RefreshRequest(BaseModel):
    refresh_token: str


class CreateUserRequest(BaseModel):
    email: EmailStr
    name: str
    password: Optional[str] = None
    role: str = "agent"
    extension: Optional[str] = None
    sip_uri: Optional[str] = None


class UserResponse(BaseModel):
    id: UUID
    email: str
    name: str
    role: str
    extension: Optional[str] = None
    sip_uri: Optional[str] = None
    is_active: bool
    is_available: bool
    permissions: list[str]
    last_login_at: Optional[datetime] = None
    created_at: datetime

    @classmethod
    def from_entity(cls, u: User) -> UserResponse:
        return cls(
            id=u.id,
            email=str(u.email),
            name=u.name,
            role=u.role,
            extension=u.extension,
            sip_uri=u.sip_uri,
            is_active=u.is_active,
            is_available=u.is_available,
            permissions=u.permissions,
            last_login_at=u.last_login_at,
            created_at=u.created_at,
        )


def _serialize_uuids(data: dict) -> dict:
    return {k: str(v) if isinstance(v, UUID) else v for k, v in data.items()}


def create_access_token(data: dict) -> str:
    to_encode = _serialize_uuids(data.copy())
    expire = datetime.now(timezone.utc) + timedelta(minutes=settings.access_token_expire_minutes)
    to_encode.update({
        "exp": expire, "type": "access", "iss": "nexora",
        "tenant_id": to_encode.get("org_id", to_encode.get("org", "")),
    })
    return jwt.encode(to_encode, settings.secret_key, algorithm=settings.algorithm)


def create_refresh_token(data: dict) -> str:
    to_encode = _serialize_uuids(data.copy())
    expire = datetime.now(timezone.utc) + timedelta(days=settings.refresh_token_expire_days)
    to_encode.update({"exp": expire, "type": "refresh", "iss": "nexora"})
    return jwt.encode(to_encode, settings.secret_key, algorithm=settings.algorithm)


async def _decode_token_unified(token: str) -> dict:
    from nexora_ai.infrastructure.auth import AuthClient
    from nexora_ai.domain.entities.auth import AuthConfig

    client = AuthClient()
    client.configure(AuthConfig(
        jwt_secret=settings.secret_key,
        jwt_algorithm=settings.algorithm,
        issuer="nexora",
    ))
    claims = await client.validate_token(token)
    return {"sub": claims.sub, "org_id": claims.org_id, "tenant_id": claims.tenant_id,
            "role": claims.role, "permissions": claims.permissions, "type": claims.token_type}


async def _decode_token_legacy(token: str) -> dict:
    payload = jwt.decode(token, settings.secret_key, algorithms=[settings.algorithm])
    if payload.get("type") != "access":
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token type")
    return payload


async def _decode_token(token: str) -> dict:
    if settings.auth_mode == "unified":
        return await _decode_token_unified(token)
    return await _decode_token_legacy(token)


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    session: AsyncSession = Depends(get_session),
) -> User:
    token = credentials.credentials
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = await _decode_token(token)
        user_id: str = payload.get("sub")
        if user_id is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception

    result = await session.execute(select(UserModel).where(UserModel.id == user_id))
    model = result.scalar_one_or_none()
    if model is None or not model.is_active:
        raise credentials_exception

    return User.model_validate(model)


def require_permission(*permissions: str):
    async def checker(current_user: User = Depends(get_current_user)) -> User:
        if AgentRole.admin.value not in current_user.permissions and current_user.role != AgentRole.admin.value:
            for p in permissions:
                if p not in current_user.permissions:
                    raise HTTPException(
                        status_code=status.HTTP_403_FORBIDDEN,
                        detail=f"Missing required permission: {p}",
                    )
        return current_user
    return checker


@router.post("/login", response_model=TokenResponse)
async def login(
    req: LoginRequest,
    request: Request,
    session: AsyncSession = Depends(get_session),
):
    client_ip = request.client.host if request.client else "unknown"
    now = time.time()
    _login_attempts[client_ip] = [
        t for t in _login_attempts[client_ip] if now - t < _LOGIN_WINDOW_SECONDS
    ]
    if len(_login_attempts[client_ip]) >= _MAX_LOGIN_ATTEMPTS:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Too many login attempts. Try again later.",
        )
    result = await session.execute(select(UserModel).where(UserModel.email == req.email))
    model = result.scalar_one_or_none()
    if model is None or not pwd_context.verify(req.password, model.password_hash or ""):
        _login_attempts[client_ip].append(now)
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid email or password")
    if not model.is_active:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Account is disabled")

    _login_attempts[client_ip].clear()
    model.last_login_at = datetime.now(timezone.utc)
    session.add(model)

    access_token = create_access_token({"sub": str(model.id), "org_id": str(model.organization_id), "role": model.role})
    refresh_token = create_refresh_token({"sub": str(model.id)})
    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        expires_in=settings.access_token_expire_minutes * 60,
    )


@router.post("/refresh", response_model=TokenResponse)
async def refresh(req: RefreshRequest, session: AsyncSession = Depends(get_session)):
    try:
        payload = jwt.decode(req.refresh_token, settings.secret_key, algorithms=[settings.algorithm])
        user_id: str = payload.get("sub")
        if user_id is None or payload.get("type") != "refresh":
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid refresh token")
    except JWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid refresh token")

    result = await session.execute(select(UserModel).where(UserModel.id == user_id))
    model = result.scalar_one_or_none()
    if model is None or not model.is_active:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found or disabled")

    access_token = create_access_token({"sub": str(model.id), "org_id": str(model.organization_id), "role": model.role})
    new_refresh_token = create_refresh_token({"sub": str(model.id)})
    return TokenResponse(
        access_token=access_token,
        refresh_token=new_refresh_token,
        expires_in=settings.access_token_expire_minutes * 60,
    )


@router.get("/me", response_model=UserResponse)
async def me(current_user: User = Depends(get_current_user)):
    return UserResponse.from_entity(current_user)


@router.post("/users", response_model=UserResponse)
async def create_user(
    req: CreateUserRequest,
    session: AsyncSession = Depends(get_session),
    current_user: User = Depends(require_permission("manage_team")),
):
    existing = await session.execute(select(UserModel).where(UserModel.email == req.email))
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Email already exists")

    model = UserModel(
        organization_id=str(current_user.organization_id),
        email=str(req.email),
        password_hash=pwd_context.hash(req.password) if req.password else None,
        name=req.name,
        role=req.role,
        extension=req.extension,
        sip_uri=req.sip_uri,
    )
    session.add(model)
    await session.flush()
    await session.refresh(model)
    user = User.model_validate(model)
    return UserResponse.from_entity(user)
