from __future__ import annotations

from abc import ABC, abstractmethod
from typing import Any

from nexora_ai.domain.entities.auth import AuthConfig, OrganizationContext, TokenClaims, UserContext
from nexora_ai.domain.enums.auth_enums import Permission, SystemRole


class AuthClientInterface(ABC):
    @abstractmethod
    def configure(self, config: AuthConfig) -> None:
        pass

    @abstractmethod
    async def validate_token(self, token: str) -> TokenClaims:
        pass

    @abstractmethod
    async def get_user_context(self, token: str) -> UserContext:
        pass

    @abstractmethod
    async def get_organization_context(self, org_id: str) -> OrganizationContext:
        pass

    @abstractmethod
    def check_permission(self, user: UserContext, permission: Permission) -> bool:
        pass

    @abstractmethod
    def check_any_permission(self, user: UserContext, permissions: list[Permission]) -> bool:
        pass

    @abstractmethod
    def get_role_permissions(self, role: SystemRole) -> set[Permission]:
        pass

    @abstractmethod
    async def refresh_token(self, refresh_token: str) -> tuple[str, str]:
        pass

    @abstractmethod
    async def create_access_token(self, user_id: str, org_id: str, role: str, permissions: list[str] | None = None) -> str:
        pass

    @abstractmethod
    async def create_refresh_token(self, user_id: str) -> str:
        pass

    @abstractmethod
    def require_permission(self, *permissions: Permission):
        pass

    @abstractmethod
    def require_role(self, *roles: SystemRole):
        pass
