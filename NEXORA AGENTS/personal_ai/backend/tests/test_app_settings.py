from __future__ import annotations

import pytest

from backend.services.settings_manager import AppSettings


class TestAppSettingsUnit:
    def test_model_default(self):
        s = AppSettings()
        assert s.model == "gpt-4o"

    def test_temperature_range(self):
        s = AppSettings(temperature=0.0)
        assert s.temperature == 0.0
        s2 = AppSettings(temperature=2.0)
        assert s2.temperature == 2.0

    def test_memory_limit_positive(self):
        s = AppSettings(memory_limit=1)
        assert s.memory_limit == 1

    def test_tool_permissions_default(self):
        s = AppSettings()
        assert s.tool_permissions == {}

    def test_tool_permissions_custom(self):
        s = AppSettings(tool_permissions={"read": True, "write": False})
        assert s.tool_permissions["read"] is True
        assert s.tool_permissions["write"] is False

    def test_plugins_enabled_default(self):
        s = AppSettings()
        assert s.plugins_enabled == []

    def test_plugins_enabled_custom(self):
        s = AppSettings(plugins_enabled=["plugin1", "plugin2"])
        assert len(s.plugins_enabled) == 2

    def test_context_window_valid_sizes(self):
        for size in [2048, 4096, 8192, 16384, 32768, 65536, 131072]:
            s = AppSettings(context_window=size)
            assert s.context_window == size

    def test_to_dict_roundtrip(self):
        s = AppSettings(model="test", temperature=0.5, theme="light")
        data = s.to_dict()
        s2 = AppSettings.from_dict(data)
        assert s2.model == "test"
        assert s2.temperature == 0.5
        assert s2.theme == "light"

    def test_from_dict_ignores_unknown_keys(self):
        data = {"model": "test", "unknown_key": "value"}
        s = AppSettings.from_dict(data)
        assert s.model == "test"
        assert not hasattr(s, "unknown_key")
