from __future__ import annotations

import json
import tempfile
from pathlib import Path

import pytest

from backend.services.settings_manager import AppSettings, SettingsManager


class TestAppSettings:
    def test_defaults(self):
        settings = AppSettings()
        assert settings.model == "gpt-4o"
        assert settings.temperature == 0.7
        assert settings.memory_limit == 10000
        assert settings.theme == "dark"
        assert settings.voice_enabled is False
        assert settings.language == "en"
        assert settings.automation_enabled is True
        assert settings.context_window == 8192

    def test_to_dict(self):
        settings = AppSettings(model="claude-3", temperature=0.5)
        data = settings.to_dict()
        assert data["model"] == "claude-3"
        assert data["temperature"] == 0.5
        assert "memory_limit" in data
        assert "theme" in data

    def test_from_dict(self):
        data = {
            "model": "gpt-4o",
            "temperature": 0.3,
            "memory_limit": 5000,
            "theme": "light",
            "voice_enabled": True,
            "language": "es",
            "context_window": 4096,
        }
        settings = AppSettings.from_dict(data)
        assert settings.model == "gpt-4o"
        assert settings.temperature == 0.3
        assert settings.memory_limit == 5000
        assert settings.theme == "light"
        assert settings.voice_enabled is True
        assert settings.language == "es"
        assert settings.context_window == 4096

    def test_from_dict_defaults(self):
        settings = AppSettings.from_dict({})
        assert settings.model == "gpt-4o"
        assert settings.temperature == 0.7
        assert settings.context_window == 8192

    def test_from_dict_partial(self):
        settings = AppSettings.from_dict({"model": "claude-3"})
        assert settings.model == "claude-3"
        assert settings.temperature == 0.7


class TestSettingsManager:
    @pytest.fixture
    def temp_dir(self, tmp_path):
        return tmp_path / "settings.json"

    @pytest.fixture
    def mock_event_bus(self):
        from unittest.mock import AsyncMock
        bus = AsyncMock()
        bus.publish = AsyncMock()
        return bus

    @pytest.fixture
    def mock_logger(self):
        from unittest.mock import AsyncMock
        logger = AsyncMock()
        logger.info = AsyncMock()
        logger.error = AsyncMock()
        return logger

    @pytest.mark.asyncio
    async def test_load_creates_default(self, temp_dir, mock_event_bus, mock_logger):
        manager = SettingsManager(mock_event_bus, mock_logger, settings_path=temp_dir)
        settings = await manager.load()
        assert settings.model == "gpt-4o"
        assert temp_dir.exists()

    @pytest.mark.asyncio
    async def test_load_from_existing_file(self, temp_dir, mock_event_bus, mock_logger):
        temp_dir.write_text(json.dumps({"model": "claude-3", "temperature": 0.2}))
        manager = SettingsManager(mock_event_bus, mock_logger, settings_path=temp_dir)
        settings = await manager.load()
        assert settings.model == "claude-3"
        assert settings.temperature == 0.2

    @pytest.mark.asyncio
    async def test_get_all(self, temp_dir, mock_event_bus, mock_logger):
        manager = SettingsManager(mock_event_bus, mock_logger, settings_path=temp_dir)
        await manager.load()
        result = await manager.get_all()
        assert "model" in result
        assert "temperature" in result

    @pytest.mark.asyncio
    async def test_get_setting(self, temp_dir, mock_event_bus, mock_logger):
        manager = SettingsManager(mock_event_bus, mock_logger, settings_path=temp_dir)
        await manager.load()
        model = await manager.get("model")
        assert model == "gpt-4o"

    @pytest.mark.asyncio
    async def test_get_unknown_setting(self, temp_dir, mock_event_bus, mock_logger):
        manager = SettingsManager(mock_event_bus, mock_logger, settings_path=temp_dir)
        await manager.load()
        result = await manager.get("nonexistent")
        assert result is None

    @pytest.mark.asyncio
    async def test_set_setting(self, temp_dir, mock_event_bus, mock_logger):
        manager = SettingsManager(mock_event_bus, mock_logger, settings_path=temp_dir)
        await manager.load()
        result = await manager.set("model", "claude-3")
        assert result is True
        assert await manager.get("model") == "claude-3"

    @pytest.mark.asyncio
    async def test_set_unknown_setting(self, temp_dir, mock_event_bus, mock_logger):
        manager = SettingsManager(mock_event_bus, mock_logger, settings_path=temp_dir)
        await manager.load()
        result = await manager.set("nonexistent", "value")
        assert result is False

    @pytest.mark.asyncio
    async def test_set_temperature_valid(self, temp_dir, mock_event_bus, mock_logger):
        manager = SettingsManager(mock_event_bus, mock_logger, settings_path=temp_dir)
        await manager.load()
        result = await manager.set("temperature", 1.5)
        assert result is True

    @pytest.mark.asyncio
    async def test_set_temperature_invalid(self, temp_dir, mock_event_bus, mock_logger):
        manager = SettingsManager(mock_event_bus, mock_logger, settings_path=temp_dir)
        await manager.load()
        result = await manager.set("temperature", 5.0)
        assert result is False

    @pytest.mark.asyncio
    async def test_set_context_window_valid(self, temp_dir, mock_event_bus, mock_logger):
        manager = SettingsManager(mock_event_bus, mock_logger, settings_path=temp_dir)
        await manager.load()
        result = await manager.set("context_window", 4096)
        assert result is True

    @pytest.mark.asyncio
    async def test_set_context_window_invalid(self, temp_dir, mock_event_bus, mock_logger):
        manager = SettingsManager(mock_event_bus, mock_logger, settings_path=temp_dir)
        await manager.load()
        result = await manager.set("context_window", 3000)
        assert result is False

    @pytest.mark.asyncio
    async def test_update_settings(self, temp_dir, mock_event_bus, mock_logger):
        manager = SettingsManager(mock_event_bus, mock_logger, settings_path=temp_dir)
        await manager.load()
        results = await manager.update({"model": "gpt-4o", "temperature": 0.9})
        assert results["model"] is True
        assert results["temperature"] is True

    @pytest.mark.asyncio
    async def test_persistence(self, temp_dir, mock_event_bus, mock_logger):
        manager1 = SettingsManager(mock_event_bus, mock_logger, settings_path=temp_dir)
        await manager1.load()
        await manager1.set("model", "claude-3")

        manager2 = SettingsManager(mock_event_bus, mock_logger, settings_path=temp_dir)
        await manager2.load()
        assert await manager2.get("model") == "claude-3"

    def test_on_change_listener(self, temp_dir, mock_event_bus, mock_logger):
        manager = SettingsManager(mock_event_bus, mock_logger, settings_path=temp_dir)
        called = []
        manager.on_change(lambda k, v: called.append((k, v)))
        assert len(manager._listeners) == 1
