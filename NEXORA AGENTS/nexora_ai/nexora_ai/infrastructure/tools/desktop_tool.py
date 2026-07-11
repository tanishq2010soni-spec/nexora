from __future__ import annotations

from typing import Any

from nexora_ai.domain.enums.tool_enums import ToolCategory, ToolPermission


class DesktopTool:
    category = ToolCategory.DESKTOP
    permissions = [ToolPermission.READ, ToolPermission.WRITE, ToolPermission.EXECUTE]

    async def execute(self, parameters: dict[str, Any]) -> dict[str, Any]:
        raise NotImplementedError("Production implementation requires pyautogui")
