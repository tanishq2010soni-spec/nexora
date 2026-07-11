from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone
from typing import Any

try:
    from jose import JWTError, jwt
except ImportError:
    jwt = None  # type: ignore
    JWTError = Exception  # type: ignore

from fastapi import Depends, HTTPException, Request, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from nexora_ai.domain.entities.auth import AuthConfig, OrganizationContext, TokenClaims, UserContext
from nexora_ai.domain.enums.auth_enums import (
    AuthMode,
    Permission,
    ROLE_PERMISSIONS,
    SystemRole,
)
from nexora_ai.domain.interfaces.auth_interface import AuthClientInterface

security = HTTPBearer(auto_error=False)


class AuthClient(AuthClientInterface):
    def __init__(self) -> None:
        self._config = AuthConfig()
        self._organizations: dict[str, OrganizationContext] = {}

    def configure(self, config: AuthConfig) -> None:
        self._config = config

    def register_organization(self, org: OrganizationContext) -> None:
        self._organizations[org.organization_id] = org

    async def validate_token(self, token: str) -> TokenClaims:
        if jwt is None:
            raise HTTPException(status_code=500, detail="python-jose not installed")
        try:
            payload = jwt.decode(
                token,
                self._config.jwt_secret,
                algorithms=[self._config.jwt_algorithm],
            )
        except JWTError as e:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail=f"Invalid token: {e}",
                headers={"WWW-Authenticate": "Bearer"},
            )
        token_type = payload.get("type", payload.get("token_type", "access"))
        if token_type != "access":
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token type",
            )
        claims = TokenClaims.from_dict(payload)
        if claims.iss and claims.iss != self._config.issuer:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token issuer",
            )
        return claims

    async def get_user_context(self, token: str) -> UserContext:
        claims = await self.validate_token(token)
        role = SystemRole(claims.role) if claims.role in [r.value for r in SystemRole] else SystemRole.EMPLOYEE
        perms = []
        for p_str in claims.permissions:
            try:
                perms.append(Permission(p_str))
            except ValueError:
                continue
        if not perms:
            perms = list(ROLE_PERMISSIONS.get(role, set()))
        return UserContext(
            user_id=claims.sub,
            email=claims.extra.get("email", ""),
            organization_id=claims.org_id,
            tenant_id=claims.tenant_id,
            role=role,
            permissions=perms,
            is_active=True,
            name=claims.extra.get("name", ""),
            extra=claims.extra,
        )

    async def get_organization_context(self, org_id: str) -> OrganizationContext:
        if org_id in self._organizations:
            return self._organizations[org_id]
        return OrganizationContext(
            organization_id=org_id,
            tenant_id=org_id,
            name="Unknown",
            slug="unknown",
            status="active",
        )

    def check_permission(self, user: UserContext, permission: Permission) -> bool:
        return user.has_permission(permission)

    def check_any_permission(self, user: UserContext, permissions: list[Permission]) -> bool:
        return user.has_any_permission(permissions)

    def get_role_permissions(self, role: SystemRole) -> set[Permission]:
        return ROLE_PERMISSIONS.get(role, set())

    async def refresh_token(self, refresh_token: str) -> tuple[str, str]:
        if jwt is None:
            raise HTTPException(status_code=500, detail="python-jose not installed")
        try:
            payload = jwt.decode(
                refresh_token,
                self._config.jwt_secret,
                algorithms=[self._config.jwt_algorithm],
            )
        except JWTError:
            raise HTTPException(status_code=401, detail="Invalid refresh token")
        token_type = payload.get("type", payload.get("token_type", ""))
        if token_type != "refresh":
            raise HTTPException(status_code=401, detail="Invalid token type")
        user_id = payload.get("sub", "")
        org_id = payload.get("org_id", payload.get("org", ""))
        role = payload.get("role", "employee")
        permissions = payload.get("permissions", [])
        new_access = await self.create_access_token(user_id, org_id, role, permissions)
        new_refresh = await self.create_refresh_token(user_id)
        return new_access, new_refresh

    async def create_access_token(
        self,
        user_id: str,
        org_id: str,
        role: str,
        permissions: list[str] | None = None,
    ) -> str:
        if jwt is None:
            raise HTTPException(status_code=500, detail="python-jose not installed")
        now = datetime.now(timezone.utc)
        expire = now + timedelta(minutes=self._config.access_token_expire_minutes)
        claims = {
            "sub": user_id,
            "org_id": org_id,
            "tenant_id": org_id,
            "role": role,
            "permissions": permissions or [],
            "type": "access",
            "iss": self._config.issuer,
            "exp": expire,
            "iat": now,
            "jti": str(uuid.uuid4()),
        }
        return jwt.encode(claims, self._config.jwt_secret, algorithm=self._config.jwt_algorithm)

    async def create_refresh_token(self, user_id: str) -> str:
        if jwt is None:
            raise HTTPException(status_code=500, detail="python-jose not installed")
        now = datetime.now(timezone.utc)
        expire = now + timedelta(days=self._config.refresh_token_expire_days)
        claims = {
            "sub": user_id,
            "type": "refresh",
            "iss": self._config.issuer,
            "exp": expire,
            "iat": now,
            "jti": str(uuid.uuid4()),
        }
        return jwt.encode(claims, self._config.jwt_secret, algorithm=self._config.jwt_algorithm)

    def require_permission(self, *permissions: Permission):
        async def checker(request: Request) -> UserContext:
            credentials: HTTPAuthorizationCredentials | None = await security(request)
            if not credentials:
                raise HTTPException(status_code=401, detail="Not authenticated")
            user = await self.get_user_context(credentials.credentials)
            if not user.is_active:
                raise HTTPException(status_code=401, detail="User inactive")
            if not user.has_any_permission(list(permissions)):
                raise HTTPException(status_code=403, detail="Insufficient permissions")
            return user
        return checker

    def require_role(self, *roles: SystemRole):
        async def checker(request: Request) -> UserContext:
            credentials: HTTPAuthorizationCredentials | None = await security(request)
            if not credentials:
                raise HTTPException(status_code=401, detail="Not authenticated")
            user = await self.get_user_context(credentials.credentials)
            if not user.is_active:
                raise HTTPException(status_code=401, detail="User inactive")
            if user.role not in roles:
                raise HTTPException(status_code=403, detail="Insufficient role")
            return user
        return checker
