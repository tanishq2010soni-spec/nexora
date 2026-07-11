from __future__ import annotations

from abc import ABC, abstractmethod

from nexora_ai.domain.entities.security import (
    AuditEntry,
    Permission,
    PermissionCheck,
    PermissionCheckResult,
    SandboxConfig,
)
from nexora_ai.domain.enums.security_enums import AuditAction, ResourceType
from nexora_ai.domain.interfaces.sandbox_interface import SandboxInterface


class SecurityInterface(ABC):
    @abstractmethod
    async def check_permission(self, check: PermissionCheck) -> PermissionCheckResult: ...

    @abstractmethod
    async def grant_permission(self, user_id: str, permission: Permission) -> bool: ...

    @abstractmethod
    async def revoke_permission(self, user_id: str, resource: ResourceType, action: str) -> bool: ...

    @abstractmethod
    async def get_permissions(self, user_id: str) -> list[Permission]: ...

    @abstractmethod
    async def audit_log(self, entry: AuditEntry) -> str: ...

    @abstractmethod
    async def query_audit_log(self, filter: dict) -> list[AuditEntry]: ...

    @abstractmethod
    async def encrypt(self, plaintext: str, key_id: str) -> str: ...

    @abstractmethod
    async def decrypt(self, ciphertext: str, key_id: str) -> str: ...

    @abstractmethod
    async def create_sandbox(self, config: SandboxConfig) -> SandboxInterface: ...
