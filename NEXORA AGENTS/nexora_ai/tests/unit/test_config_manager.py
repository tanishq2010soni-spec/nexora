from __future__ import annotations

import pytest

from tests.mocks import MockConfigManager


class TestConfigManager:

    async def test_default_values(self) -> None:
        config = MockConfigManager({"host": "localhost", "port": 8080})
        assert config.get("host") == "localhost"
        assert config.get("port") == 8080
        assert config.get("nonexistent") is None
        assert config.get("nonexistent", "default") == "default"

    async def test_env_override(self) -> None:
        config = MockConfigManager({"host": "localhost"})
        assert config.get_with_override("host") == "localhost"
        config.set_env_override("host", "prod.example.com")
        assert config.get_with_override("host") == "prod.example.com"
        assert config.get("host") == "localhost"

    async def test_set_and_get(self) -> None:
        config = MockConfigManager()
        config.set("database.host", "db.local")
        config.set("database.port", 5432)
        assert config.get("database.host") == "db.local"
        assert config.get("database.port") == 5432
        assert config.get("database") == {"host": "db.local", "port": 5432}

    async def test_validation(self) -> None:
        config = MockConfigManager({"name": "test", "count": 42})
        errors = config.validate({"name": str, "count": int, "missing": str})
        assert len(errors) >= 1
        assert any("Missing required" in e for e in errors)

        errors = config.validate({"name": str, "count": int})
        assert len(errors) == 0

        errors = config.validate({"name": str, "count": str})
        assert len(errors) >= 1
        assert any("expected str" in e for e in errors)

    async def test_encrypted_values(self) -> None:
        config = MockConfigManager()
        config.set_encrypted("api_key", "sk-secret123")
        assert config.get("api_key") == "sk-secret123"
        assert config.is_encrypted("api_key") is True

        config.set("normal_key", "visible")
        assert config.is_encrypted("normal_key") is False

    async def test_export_import(self) -> None:
        config = MockConfigManager({"key": "value", "nested": {"a": 1}})
        exported = config.export_config()
        assert exported == {"key": "value", "nested": {"a": 1}}

        new_config = MockConfigManager()
        new_config.import_config(exported)
        assert new_config.get("key") == "value"
        assert new_config.get("nested.a") == 1
