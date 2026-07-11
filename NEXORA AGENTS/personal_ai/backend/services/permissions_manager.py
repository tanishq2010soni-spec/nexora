from __future__ import annotations

import time
from typing import Any
from uuid import uuid4


class PermissionRequest:
    def __init__(
        self,
        id: str,
        action: str,
        details: dict[str, Any],
        status: str = "pending",
        expires_at: float | None = None,
    ) -> None:
        self.id = id
        self.action = action
        self.details = details
        self.status = status
        self.expires_at = expires_at or (time.time() + 60)

    def is_expired(self) -> bool:
        return time.time() > self.expires_at

    def to_json(self) -> dict[str, Any]:
        return {
            "id": self.id,
            "action": self.action,
            "details": self.details,
            "status": self.status,
            "expires_at": self.expires_at,
        }


_APPROVED_ACTIONS: set[str] = set()


class PermissionsManager:
    def __init__(self) -> None:
        self._pending: dict[str, PermissionRequest] = {}
        self._history: list[PermissionRequest] = []
        self._auto_approve_patterns: dict[str, bool] = {}

    def request_permission(self, action: str, details: dict[str, Any] | None = None) -> PermissionRequest:
        action_key = f"{action}:{details.get('resource', '')}" if details else action
        if action_key in _APPROVED_ACTIONS:
            req = PermissionRequest(
                id=str(uuid4()),
                action=action,
                details=details or {},
                status="approved",
                expires_at=time.time() + 3600,
            )
            self._history.append(req)
            return req

        req = PermissionRequest(
            id=str(uuid4()),
            action=action,
            details=details or {},
            expires_at=time.time() + 60,
        )
        self._pending[req.id] = req
        self._history.append(req)
        return req

    def approve(self, permission_id: str) -> bool:
        req = self._pending.pop(permission_id, None)
        if req is None or req.is_expired():
            return False
        req.status = "approved"
        action_key = f"{req.action}:{req.details.get('resource', '')}" if req.details else req.action
        _APPROVED_ACTIONS.add(action_key)
        return True

    def deny(self, permission_id: str) -> bool:
        req = self._pending.pop(permission_id, None)
        if req is None:
            return False
        req.status = "denied"
        return True

    def get_pending(self) -> list[dict[str, Any]]:
        now = time.time()
        active: list[dict[str, Any]] = []
        expired_ids: list[str] = []
        for pid, req in self._pending.items():
            if req.is_expired():
                expired_ids.append(pid)
            else:
                active.append(req.to_json())
        for pid in expired_ids:
            self._pending.pop(pid, None)
        return active

    def get_history(self) -> list[dict[str, Any]]:
        return [r.to_json() for r in self._history]

    def check_permission(self, action: str, resource: str | None = None) -> bool:
        action_key = f"{action}:{resource}" if resource else action
        return action_key in _APPROVED_ACTIONS

    def set_auto_approve(self, action: str, enabled: bool) -> None:
        self._auto_approve_patterns[action] = enabled
        if enabled:
            _APPROVED_ACTIONS.add(action)
        else:
            _APPROVED_ACTIONS.discard(action)
