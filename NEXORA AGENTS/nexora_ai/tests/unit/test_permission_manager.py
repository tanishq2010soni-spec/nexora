from __future__ import annotations

from datetime import datetime, timezone
from enum import Enum
from typing import Any

import pytest


class PermissionEffect(Enum):
    ALLOW = "allow"
    DENY = "deny"
    AUDIT_ONLY = "audit_only"


class ResourceType(Enum):
    TOOL = "tool"
    MEMORY = "memory"
    PROVIDER = "provider"
    FILE = "file"
    NETWORK = "network"


class AuditAction(Enum):
    READ = "read"
    WRITE = "write"
    EXECUTE = "execute"
    DELETE = "delete"


class PermissionRule:

    @staticmethod
    def _match_glob(pattern: str, value: str) -> bool:
        if "*" in pattern:
            parts = pattern.split("*")
            if value.startswith(parts[0]) and value.endswith(parts[-1]):
                return True
            return False
        return pattern == value

    def __init__(
        self,
        resource_type: ResourceType,
        resource_id: str,
        effect: PermissionEffect,
        actions: list[AuditAction] | None = None,
        constraints: dict[str, Any] | None = None,
    ) -> None:
        self.resource_type = resource_type
        self.resource_id = resource_id
        self.effect = effect
        self.actions = actions or [AuditAction.READ]
        self.constraints = constraints or {}
        self.created_at = datetime.now(timezone.utc)

    def matches(self, resource_type: ResourceType, resource_id: str, action: AuditAction) -> bool:
        if self.resource_type != resource_type:
            return False
        if self.resource_id != "*" and not self._match_glob(self.resource_id, resource_id):
            return False
        if action not in self.actions:
            return False
        return True


class PermissionManager:

    def __init__(self) -> None:
        self._rules: list[PermissionRule] = []
        self._audit_log: list[dict[str, Any]] = []
        self._default_effect = PermissionEffect.ALLOW

    def add_rule(self, rule: PermissionRule) -> None:
        self._rules.append(rule)

    def check_permission(
        self,
        resource_type: ResourceType,
        resource_id: str,
        action: AuditAction,
        context: dict[str, Any] | None = None,
    ) -> PermissionEffect:
        ctx = context or {}

        for rule in self._rules:
            if rule.matches(resource_type, resource_id, action):
                if rule.constraints:
                    if not self._evaluate_constraints(rule.constraints, ctx):
                        continue
                if rule.effect == PermissionEffect.AUDIT_ONLY:
                    self._audit(resource_type, resource_id, action, "audit_only", ctx)
                    return PermissionEffect.ALLOW
                return rule.effect
        return self._default_effect

    def _evaluate_constraints(self, constraints: dict[str, Any], context: dict[str, Any]) -> bool:
        for key, expected_value in constraints.items():
            actual = context.get(key)
            if isinstance(expected_value, dict) and "$gt" in expected_value:
                if not (actual is not None and actual > expected_value["$gt"]):
                    return False
            elif isinstance(expected_value, dict) and "$lt" in expected_value:
                if not (actual is not None and actual < expected_value["$lt"]):
                    return False
            elif actual != expected_value:
                return False
        return True

    def _audit(
        self,
        resource_type: ResourceType,
        resource_id: str,
        action: AuditAction,
        result: str,
        context: dict[str, Any],
    ) -> None:
        self._audit_log.append({
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "resource_type": resource_type.value,
            "resource_id": resource_id,
            "action": action.value,
            "result": result,
            "context": context,
        })

    def get_audit_log(self) -> list[dict[str, Any]]:
        return list(self._audit_log)

    def clear_audit_log(self) -> None:
        self._audit_log.clear()


@pytest.fixture
def pm() -> PermissionManager:
    return PermissionManager()


class TestPermissionManager:

    async def test_allow_permission(self, pm: PermissionManager) -> None:
        rule = PermissionRule(
            ResourceType.TOOL, "file_read", PermissionEffect.ALLOW,
            actions=[AuditAction.EXECUTE],
        )
        pm.add_rule(rule)
        result = pm.check_permission(ResourceType.TOOL, "file_read", AuditAction.EXECUTE)
        assert result == PermissionEffect.ALLOW

    async def test_deny_permission(self, pm: PermissionManager) -> None:
        rule = PermissionRule(
            ResourceType.TOOL, "dangerous_tool", PermissionEffect.DENY,
            actions=[AuditAction.EXECUTE],
        )
        pm.add_rule(rule)
        result = pm.check_permission(ResourceType.TOOL, "dangerous_tool", AuditAction.EXECUTE)
        assert result == PermissionEffect.DENY

    async def test_audit_only(self, pm: PermissionManager) -> None:
        rule = PermissionRule(
            ResourceType.MEMORY, "*", PermissionEffect.AUDIT_ONLY,
            actions=[AuditAction.READ],
        )
        pm.add_rule(rule)
        result = pm.check_permission(ResourceType.MEMORY, "user_data", AuditAction.READ)
        assert result == PermissionEffect.ALLOW
        assert len(pm.get_audit_log()) == 1
        assert pm.get_audit_log()[0]["resource_id"] == "user_data"

    async def test_constraint_evaluation(self, pm: PermissionManager) -> None:
        rule = PermissionRule(
            ResourceType.FILE, "/restricted/*", PermissionEffect.DENY,
            actions=[AuditAction.WRITE],
            constraints={"role": "guest"},
        )
        pm.add_rule(rule)

        result = pm.check_permission(ResourceType.FILE, "/restricted/data", AuditAction.WRITE, {"role": "guest"})
        assert result == PermissionEffect.DENY

        result = pm.check_permission(ResourceType.FILE, "/restricted/data", AuditAction.WRITE, {"role": "admin"})
        assert result != PermissionEffect.DENY

    async def test_audit_log_creation(self, pm: PermissionManager) -> None:
        rule = PermissionRule(
            ResourceType.NETWORK, "api.external.com", PermissionEffect.AUDIT_ONLY,
            actions=[AuditAction.READ],
        )
        pm.add_rule(rule)
        pm.check_permission(ResourceType.NETWORK, "api.external.com", AuditAction.READ, {"user": "test"})
        assert len(pm.get_audit_log()) == 1
        entry = pm.get_audit_log()[0]
        assert entry["resource_type"] == "network"
        assert entry["action"] == "read"
        assert entry["context"]["user"] == "test"

        pm.check_permission(ResourceType.NETWORK, "other.com", AuditAction.READ)
        assert len(pm.get_audit_log()) == 1
