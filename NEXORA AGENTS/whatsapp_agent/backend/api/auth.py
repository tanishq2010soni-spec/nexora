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

from backend.config import settings
from backend.domain.entities import User
from backend.infrastructure.database import UserModel, get_session

router = APIRouter(prefix="/api/v1/auth", tags=["auth"])
security = HTTPBearer()
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto", bcrypt__rounds=12)

_login_attempts: dict[str, list[float]] = defaultdict(list)
_MAX_LOGIN_ATTEMPTS = 5
_LOGIN_WINDOW_SECONDS = 300


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int


class UserCreate(BaseModel):
    email: EmailStr
    password: str
    name: str
    organization_id: str


def create_access_token(user_id: str, organization_id: str) -> str:
    expire = datetime.now(timezone.utc) + timedelta(minutes=settings.access_token_expire_minutes)
    return jwt.encode(
        {"sub": str(user_id), "org_id": str(organization_id), "tenant_id": str(organization_id),
         "role": "employee", "permissions": [], "exp": expire, "type": "access", "iss": "nexora"},
        settings.secret_key,
        algorithm=settings.algorithm,
    )


def create_refresh_token(user_id: str) -> str:
    expire = datetime.now(timezone.utc) + timedelta(days=settings.refresh_token_expire_days)
    return jwt.encode(
        {"sub": str(user_id), "exp": expire, "type": "refresh", "iss": "nexora"},
        settings.secret_key,
        algorithm=settings.algorithm,
    )


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
    try:
        payload = await _decode_token(credentials.credentials)
        user_id = payload.get("sub")
        if not user_id:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")
    except JWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")

    result = await session.execute(select(UserModel).where(UserModel.id == user_id))
    user = result.scalar_one_or_none()
    if not user or not user.is_active:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found or inactive")

    return User(
        id=UUID(str(user.id)),
        organization_id=UUID(str(user.organization_id)),
        email=user.email,
        name=user.name,
        role=user.role,
        department_ids=[UUID(str(d)) for d in (user.department_ids or [])],
        is_active=user.is_active,
        is_available=user.is_available,
        max_concurrent_chats=user.max_concurrent_chats,
        permissions=user.permissions or [],
    )


def require_permission(*permissions: str):
    async def checker(current_user: User = Depends(get_current_user)) -> User:
        if current_user.role == "admin":
            return current_user
        for p in permissions:
            if p not in current_user.permissions:
                raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Insufficient permissions")
        return current_user
    return checker


@router.post("/login", response_model=TokenResponse)
async def login(
    request: LoginRequest,
    req: Request,
    session: AsyncSession = Depends(get_session),
):
    client_ip = req.client.host if req.client else "unknown"
    now = time.time()
    _login_attempts[client_ip] = [
        t for t in _login_attempts[client_ip] if now - t < _LOGIN_WINDOW_SECONDS
    ]
    if len(_login_attempts[client_ip]) >= _MAX_LOGIN_ATTEMPTS:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Too many login attempts. Try again later.",
        )
    result = await session.execute(select(UserModel).where(UserModel.email == request.email))
    user = result.scalar_one_or_none()
    if not user or not pwd_context.verify(request.password, user.password_hash or ""):
        _login_attempts[client_ip].append(now)
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")

    _login_attempts[client_ip].clear()
    user.last_login_at = datetime.utcnow()
    session.add(user)

    return TokenResponse(
        access_token=create_access_token(user.id, user.organization_id),
        refresh_token=create_refresh_token(user.id),
        expires_in=settings.access_token_expire_minutes * 60,
    )


@router.post("/refresh", response_model=TokenResponse)
async def refresh(credentials: HTTPAuthorizationCredentials = Depends(security)):
    try:
        payload = jwt.decode(credentials.credentials, settings.secret_key, algorithms=[settings.algorithm])
        if payload.get("type") != "refresh":
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token type")
        user_id = payload.get("sub")
        if not user_id:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")
    except JWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")

    return TokenResponse(
        access_token=create_access_token(user_id, payload.get("org_id", payload.get("org", ""))),
        refresh_token=create_refresh_token(user_id),
        expires_in=settings.access_token_expire_minutes * 60,
    )


@router.get("/me", response_model=User)
async def get_me(current_user: User = Depends(get_current_user)):
    return current_user


@router.post("/users", response_model=User)
async def create_user(
    request: UserCreate,
    session: AsyncSession = Depends(get_session),
    _: User = Depends(require_permission("manage_team")),
):
    model = UserModel(
        email=request.email,
        password_hash=pwd_context.hash(request.password),
        name=request.name,
        organization_id=request.organization_id,
    )
    session.add(model)
    await session.flush()
    return User(
        id=UUID(str(model.id)),
        organization_id=UUID(model.organization_id),
        email=model.email,
        name=model.name,
        role=model.role,
    )
