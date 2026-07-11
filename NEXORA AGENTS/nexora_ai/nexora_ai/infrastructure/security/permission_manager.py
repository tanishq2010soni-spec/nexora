from __future__ import annotations

import time
from datetime import datetime, timezone
from typing import Any

from nexora_ai.domain.enums.security_enums import AuditAction, PermissionEffect, ResourceType
from nexora_ai.domain.interfaces.logging_interface import LoggingInterface
from nexora_ai.domain.interfaces.security_interface import SecurityInterface
from nexora_ai.domain.interfaces.sandbox_interface import SandboxInterface
from nexora_ai.domain.entities.security import AuditEntry, Permission, SandboxConfig


class PermissionRule:
    def __init__(
        self,
        role: str,
        resource: str,
        action: str,
        effect: PermissionEffect = PermissionEffect.ALLOW,
        constraints: dict[str, Any] | None = None,
        priority: int = 0,
    ) -> None:
        self.role = role
        self.resource = resource
        self.action = action
        self.effect = effect
        self.constraints = constraints or {}
        self.priority = priority


class PermissionManager(SecurityInterface):
    def __init__(self, logger: LoggingInterface | None = None) -> None:
        self._roles: dict[str, set[str]] = {}
        self._rules: list[PermissionRule] = []
        self._logger = logger

    def add_role(self, role: str, permissions: set[str]) -> None:
        self._roles[role] = permissions

    def add_rule(self, rule: PermissionRule) -> None:
        self._rules.append(rule)
        self._rules.sort(key=lambda r: r.priority, reverse=True)

    async def check_permission(
        self,
        check_or_user_id: Any = None,
        resource: str | ResourceType | None = None,
        action: str | None = None,
        context: dict[str, Any] | None = None,
    ) -> PermissionEffect | PermissionCheckResult:
        from nexora_ai.domain.entities.security import PermissionCheck, PermissionCheckResult
        from nexora_ai.domain.enums.security_enums import PermissionEffect

        if isinstance(check_or_user_id, PermissionCheck):
            check = check_or_user_id
            user_id = check.user_id or ""
            resource_str = check.resource.value if hasattr(check.resource, "value") else str(check.resource)
            action_str = check.action
            ctx = check.context
        else:
            user_id = str(check_or_user_id or "")
            resource_str = resource.value if hasattr(resource, "value") else str(resource) if resource else ""
            action_str = action or ""
            ctx = context or {}

        user_roles = self._roles.get(user_id, set())
        effect = PermissionEffect.DENY

        for rule in self._rules:
            if user_id != rule.role and rule.role not in user_roles:
                continue
            if rule.resource != "*" and rule.resource != resource_str:
                continue
            if rule.action != "*" and rule.action != action_str:
                continue
            if rule.constraints:
                if not self._evaluate_constraints(rule.constraints, ctx):
                    continue
            effect = rule.effect
            break

        if isinstance(check_or_user_id, PermissionCheck):
            return PermissionCheckResult(
                allowed=effect == PermissionEffect.ALLOW,
                reason=f"Rule matched: {effect.value}",
                audit_required=effect == PermissionEffect.AUDIT,
            )
        return effect

    async def grant_permission(self, user_id: str, permission: Permission) -> bool:
        role = f"user_{user_id}"
        if role not in self._roles:
            self._roles[role] = set()
        resource_str = permission.resource.value if hasattr(permission.resource, "value") else str(permission.resource)
        self._roles[role].add(f"{resource_str}:*")
        return True

    async def revoke_permission(self, user_id: str, resource: ResourceType, action: str) -> bool:
        role = f"user_{user_id}"
        if role in self._roles:
            resource_str = resource.value if hasattr(resource, "value") else str(resource)
            self._roles[role].discard(f"{resource_str}:{action}")
            return True
        return False

    async def get_permissions(self, user_id: str) -> list[Permission]:
        from nexora_ai.domain.enums.security_enums import PermissionEffect, ResourceType

        role_perms = self._roles.get(user_id, set())
        result: list[Permission] = []
        for perm_str in role_perms:
            parts = perm_str.split(":", 1)
            if len(parts) == 2:
                try:
                    resource = ResourceType(parts[0])
                    result.append(Permission(resource=resource, effect=PermissionEffect.ALLOW))
                except (ValueError, KeyError):
                    pass
        return result

    async def audit_log(self, entry: AuditEntry) -> str:
        if self._logger is not None:
            action_str = entry.action.value if hasattr(entry.action, "value") else str(entry.action)
            resource_str = entry.resource.value if hasattr(entry.resource, "value") else str(entry.resource)
            await self._logger.info(
                f"Audit: {action_str} on {resource_str}:{entry.resource_id}",
                category="security",
                user_id=entry.user_id,
                org_id=entry.org_id,
                details=entry.details,
            )
        return entry.id

    async def query_audit_log(self, filter: dict) -> list[AuditEntry]:
        return []

    async def encrypt(self, plaintext: str, key_id: str) -> str:
        return plaintext

    async def decrypt(self, ciphertext: str, key_id: str) -> str:
        return ciphertext

    async def create_sandbox(self, config: SandboxConfig) -> SandboxInterface:
        from nexora_ai.infrastructure.security.sandbox import Sandbox

        return Sandbox(
            allowed_paths=config.allowed_paths,
            allowed_commands=config.allowed_commands,
            network_disabled=config.disable_network,
            read_only=config.read_only,
        )

    def _evaluate_constraints(self, constraints: dict[str, Any], context: dict[str, Any]) -> bool:
        for key, expected in constraints.items():
            actual = context.get(key)
            if key == "time_before" and isinstance(expected, str):
                cutoff = datetime.fromisoformat(expected).time()
                now = datetime.now(timezone.utc).time()
                if now >= cutoff:
                    return False
            elif key == "time_after" and isinstance(expected, str):
                cutoff = datetime.fromisoformat(expected).time()
                now = datetime.now(timezone.utc).time()
                if now <= cutoff:
                    return False
            elif key == "resource_prefix" and isinstance(expected, str):
                if not actual or not str(actual).startswith(expected):
                    return False
            elif actual != expected:
                return False
        return True

    async def _audit(
        self,
        user_id: str,
        resource: str,
        action: str,
        result: str,
        context: dict[str, Any] | None = None,
    ) -> None:
        if self._logger is None:
            return
        await self._logger.info(
            f"Permission check: {result}",
            category="security",
            user_id=user_id,
            resource=resource,
            action=action,
            result=result,
            context=context,
        )
