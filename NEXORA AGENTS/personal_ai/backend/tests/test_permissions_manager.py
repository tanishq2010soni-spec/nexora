from __future__ import annotations

import time
from uuid import uuid4

import pytest

from backend.services.permissions_manager import PermissionsManager, PermissionRequest


class TestPermissionRequest:
    def test_create_request(self):
        req = PermissionRequest(
            id=str(uuid4()),
            action="read_file",
            details={"resource": "/tmp/test.txt"},
        )
        assert req.action == "read_file"
        assert req.status == "pending"
        assert req.is_expired() is False

    def test_request_expiry(self):
        req = PermissionRequest(
            id=str(uuid4()),
            action="test",
            details={},
            expires_at=time.time() - 1,
        )
        assert req.is_expired() is True

    def test_request_to_json(self):
        req = PermissionRequest(
            id="test-id",
            action="write_file",
            details={"resource": "/tmp/test.txt"},
        )
        data = req.to_json()
        assert data["id"] == "test-id"
        assert data["action"] == "write_file"
        assert data["status"] == "pending"


class TestPermissionsManager:
    def setup_method(self):
        self.manager = PermissionsManager()

    def test_request_permission(self):
        req = self.manager.request_permission("read_file", {"resource": "/tmp/test.txt"})
        assert req.action == "read_file"
        assert req.status == "pending"
        assert len(self.manager.get_pending()) == 1

    def test_approve_permission(self):
        req = self.manager.request_permission("read_file")
        result = self.manager.approve(req.id)
        assert result is True
        assert len(self.manager.get_pending()) == 0
        assert self.manager.check_permission("read_file")

    def test_deny_permission(self):
        req = self.manager.request_permission("delete_file")
        result = self.manager.deny(req.id)
        assert result is True
        assert len(self.manager.get_pending()) == 0
        assert not self.manager.check_permission("delete_file")

    def test_approve_nonexistent(self):
        result = self.manager.approve("nonexistent-id")
        assert result is False

    def test_deny_nonexistent(self):
        result = self.manager.deny("nonexistent-id")
        assert result is False

    def test_approve_expired_request(self):
        req = PermissionRequest(
            id=str(uuid4()),
            action="test",
            details={},
            expires_at=time.time() - 1,
        )
        self.manager._pending[req.id] = req
        result = self.manager.approve(req.id)
        assert result is False

    def test_get_pending_cleans_expired(self):
        req1 = self.manager.request_permission("action1")
        req2 = PermissionRequest(
            id=str(uuid4()),
            action="action2",
            details={},
            expires_at=time.time() - 1,
        )
        self.manager._pending[req2.id] = req2
        pending = self.manager.get_pending()
        assert len(pending) == 1
        assert pending[0]["id"] == req1.id

    def test_get_history(self):
        self.manager.request_permission("action1")
        self.manager.request_permission("action2")
        history = self.manager.get_history()
        assert len(history) == 2

    def test_check_permission_with_resource(self):
        req = self.manager.request_permission("read_file", {"resource": "/tmp/test.txt"})
        self.manager.approve(req.id)
        assert self.manager.check_permission("read_file", "/tmp/test.txt")

    def test_check_permission_without_approval(self):
        assert not self.manager.check_permission("unknown_action")

    def test_set_auto_approve(self):
        self.manager.set_auto_approve("auto_action", True)
        assert self.manager.check_permission("auto_action")

    def test_set_auto_approve_disable(self):
        self.manager.set_auto_approve("auto_action", True)
        self.manager.set_auto_approve("auto_action", False)
        assert not self.manager.check_permission("auto_action")

    def test_request_with_approved_action(self):
        self.manager.set_auto_approve("fast_action", True)
        req = self.manager.request_permission("fast_action")
        assert req.status == "approved"
        assert len(self.manager.get_pending()) == 0

    def test_multiple_permissions(self):
        req1 = self.manager.request_permission("action1")
        req2 = self.manager.request_permission("action2")
        self.manager.approve(req1.id)
        assert self.manager.check_permission("action1")
        assert not self.manager.check_permission("action2")
        assert len(self.manager.get_pending()) == 1
