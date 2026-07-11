from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any

from nexora_ai.domain.enums.auth_enums import AuthMode, Permission, SystemRole


@dataclass
class UserContext:
    user_id: str
    email: str
    organization_id: str
    tenant_id: str
    role: SystemRole
    permissions: list[Permission] = field(default_factory=list)
    is_active: bool = True
    name: str = ""
    extra: dict[str, Any] = field(default_factory=dict)

    def has_permission(self, perm: Permission) -> bool:
        if self.role in (SystemRole.OWNER, SystemRole.ADMIN):
            return True
        return perm in self.permissions

    def has_any_permission(self, perms: list[Permission]) -> bool:
        if self.role in (SystemRole.OWNER, SystemRole.ADMIN):
            return True
        return any(p in self.permissions for p in perms)

    def has_all_permissions(self, perms: list[Permission]) -> bool:
        if self.role in (SystemRole.OWNER, SystemRole.ADMIN):
            return True
        return all(p in self.permissions for p in perms)


@dataclass
class OrganizationContext:
    organization_id: str
    tenant_id: str
    name: str
    slug: str
    status: str = "active"
    timezone: str = "UTC"
    settings: dict[str, Any] = field(default_factory=dict)
    is_active: bool = True

    def to_json(self) -> dict[str, Any]:
        return {
            "organization_id": self.organization_id,
            "tenant_id": self.tenant_id,
            "name": self.name,
            "slug": self.slug,
            "status": self.status,
            "timezone": self.timezone,
            "settings": self.settings,
            "is_active": self.is_active,
        }


@dataclass
class TokenClaims:
    sub: str
    org_id: str
    tenant_id: str
    role: str
    permissions: list[str]
    token_type: str
    iss: str = "nexora"
    exp: datetime | None = None
    iat: datetime | None = None
    jti: str | None = None
    extra: dict[str, Any] = field(default_factory=dict)

    def to_dict(self) -> dict[str, Any]:
        d: dict[str, Any] = {
            "sub": self.sub,
            "org_id": self.org_id,
            "tenant_id": self.tenant_id,
            "role": self.role,
            "permissions": self.permissions,
            "type": self.token_type,
            "iss": self.iss,
        }
        if self.exp:
            d["exp"] = self.exp
        if self.iat:
            d["iat"] = self.iat
        if self.jti:
            d["jti"] = self.jti
        d.update(self.extra)
        return d

    @classmethod
    def from_dict(cls, data: dict[str, Any]) -> TokenClaims:
        return cls(
            sub=data.get("sub", ""),
            org_id=data.get("org_id", data.get("org", "")),
            tenant_id=data.get("tenant_id", data.get("org_id", data.get("org", ""))),
            role=data.get("role", "employee"),
            permissions=data.get("permissions", []),
            token_type=data.get("type", data.get("token_type", "access")),
            iss=data.get("iss", "nexora"),
            exp=data.get("exp"),
            iat=data.get("iat"),
            jti=data.get("jti"),
            extra={k: v for k, v in data.items() if k not in {
                "sub", "org_id", "org", "tenant_id", "role", "permissions",
                "type", "token_type", "iss", "exp", "iat", "jti",
            }},
        )


@dataclass
class AuthConfig:
    mode: AuthMode = AuthMode.LEGACY
    jwt_secret: str = ""
    jwt_algorithm: str = "HS256"
    issuer: str = "nexora"
    access_token_expire_minutes: int = 60
    refresh_token_expire_days: int = 7
    control_plane_url: str = "http://localhost:8000"

    def to_json(self) -> dict[str, Any]:
        return {
            "mode": self.mode.value,
            "issuer": self.issuer,
            "jwt_algorithm": self.jwt_algorithm,
            "access_token_expire_minutes": self.access_token_expire_minutes,
            "refresh_token_expire_days": self.refresh_token_expire_days,
            "control_plane_url": self.control_plane_url,
        }
