from __future__ import annotations

import asyncio
import os
from typing import Any

from nexora_ai.domain.enums.tool_enums import ToolCategory, ToolPermission


class TerminalTool:
    category = ToolCategory.TERMINAL
    permissions = [ToolPermission.EXECUTE]

    async def execute(self, parameters: dict[str, Any]) -> dict[str, Any]:
        command = parameters.get("command")
        if not command:
            return {"success": False, "error": "No command specified"}
        if isinstance(command, str):
            import shlex
            command_list = shlex.split(command)
        else:
            command_list = list(command)

        timeout = parameters.get("timeout", 30.0)
        working_dir = parameters.get("working_dir")
        env = parameters.get("env")

        resolved_env = dict(os.environ)
        if env:
            resolved_env.update(env)

        try:
            process = await asyncio.create_subprocess_exec(
                *command_list,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
                cwd=working_dir,
                env=resolved_env,
            )
            try:
                stdout, stderr = await asyncio.wait_for(
                    process.communicate(), timeout=timeout
                )
            except asyncio.TimeoutError:
                process.kill()
                await process.wait()
                return {
                    "success": False,
                    "error": f"Command timed out after {timeout}s",
                    "returncode": -1,
                    "stdout": "",
                    "stderr": "",
                }

            return {
                "success": process.returncode == 0,
                "returncode": process.returncode,
                "stdout": stdout.decode("utf-8", errors="replace") if stdout else "",
                "stderr": stderr.decode("utf-8", errors="replace") if stderr else "",
            }
        except FileNotFoundError:
            return {
                "success": False,
                "error": f"Command not found: {command_list[0] if command_list else ''}",
                "returncode": -1,
                "stdout": "",
                "stderr": "",
            }
        except Exception as exc:
            return {
                "success": False,
                "error": str(exc),
                "returncode": -1,
                "stdout": "",
                "stderr": "",
            }
