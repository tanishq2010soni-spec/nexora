from __future__ import annotations

import asyncio
import os
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from nexora_ai.domain.interfaces.sandbox_interface import SandboxInterface


class Sandbox(SandboxInterface):
    def __init__(
        self,
        allowed_paths: list[str | Path] | None = None,
        allowed_commands: list[str] | None = None,
        network_disabled: bool = True,
        read_only: bool = False,
    ) -> None:
        self._allowed_paths = [Path(p).resolve() for p in (allowed_paths or [])]
        self._allowed_commands = set(allowed_commands or [])
        self._network_disabled = network_disabled
        self._read_only = read_only
        self._total_commands: int = 0
        self._failed_commands: int = 0
        self._start_time: float = time.monotonic()

    async def execute(
        self,
        command: str | list[str],
        timeout: int | float = 30,
        working_dir: str | None = None,
        env: dict[str, str] | None = None,
    ) -> dict[str, Any]:
        if isinstance(command, str):
            command_list = command.split()
        else:
            command_list = command

        self._total_commands += 1
        if self._allowed_commands:
            cmd_name = Path(command_list[0]).name if command_list else ""
            if cmd_name not in self._allowed_commands:
                self._failed_commands += 1
                return {
                    "success": False,
                    "error": f"Command '{cmd_name}' is not in the allowed list",
                    "returncode": -1,
                    "stdout": "",
                    "stderr": "",
                }

        resolved_cwd: str | None = None
        if working_dir:
            resolved = Path(working_dir).resolve()
            if self._allowed_paths and not any(
                self._is_subpath(resolved, allowed) for allowed in self._allowed_paths
            ):
                self._failed_commands += 1
                return {
                    "success": False,
                    "error": f"Working directory '{working_dir}' is not in allowed paths",
                    "returncode": -1,
                    "stdout": "",
                    "stderr": "",
                }
            resolved_cwd = str(resolved)

        sandbox_env = dict(os.environ)
        if env:
            sandbox_env.update(env)
        if self._network_disabled:
            sandbox_env["NO_NETWORK"] = "1"
            sandbox_env["HTTP_PROXY"] = ""
            sandbox_env["HTTPS_PROXY"] = ""
            sandbox_env["ALL_PROXY"] = ""

        try:
            process = await asyncio.create_subprocess_exec(
                *command_list,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
                cwd=resolved_cwd,
                env=sandbox_env,
            )
            try:
                stdout, stderr = await asyncio.wait_for(
                    process.communicate(), timeout=timeout
                )
            except asyncio.TimeoutError:
                process.kill()
                await process.wait()
                self._failed_commands += 1
                return {
                    "success": False,
                    "error": f"Command timed out after {timeout}s",
                    "returncode": -1,
                    "stdout": "",
                    "stderr": "",
                }

            success = process.returncode == 0
            if not success:
                self._failed_commands += 1
            return {
                "success": success,
                "returncode": process.returncode,
                "stdout": stdout.decode("utf-8", errors="replace") if stdout else "",
                "stderr": stderr.decode("utf-8", errors="replace") if stderr else "",
            }
        except FileNotFoundError:
            self._failed_commands += 1
            return {
                "success": False,
                "error": f"Command not found: {command_list[0] if command_list else ''}",
                "returncode": -1,
                "stdout": "",
                "stderr": "",
            }
        except Exception as exc:
            self._failed_commands += 1
            return {
                "success": False,
                "error": str(exc),
                "returncode": -1,
                "stdout": "",
                "stderr": "",
            }

    async def read_file(self, path: str) -> str:
        file_path = Path(path).resolve()
        if self._allowed_paths and not any(
            self._is_subpath(file_path, allowed) for allowed in self._allowed_paths
        ):
            raise PermissionError(f"Path '{path}' is not in allowed paths")
        if not file_path.exists():
            raise FileNotFoundError(f"File not found: {path}")
        return file_path.read_text(encoding="utf-8")

    async def write_file(self, path: str, content: str) -> bool:
        if self._read_only:
            raise PermissionError("Sandbox is read-only")
        file_path = Path(path).resolve()
        if self._allowed_paths and not any(
            self._is_subpath(file_path, allowed) for allowed in self._allowed_paths
        ):
            raise PermissionError(f"Path '{path}' is not in allowed paths")
        file_path.parent.mkdir(parents=True, exist_ok=True)
        file_path.write_text(content, encoding="utf-8")
        return True

    async def get_usage(self) -> dict[str, Any]:
        return self.get_usage_stats()

    async def destroy(self) -> None:
        self._total_commands = 0
        self._failed_commands = 0

    def get_usage_stats(self) -> dict[str, Any]:
        uptime = time.monotonic() - self._start_time
        return {
            "total_commands": self._total_commands,
            "failed_commands": self._failed_commands,
            "uptime_seconds": uptime,
        }

    def _is_subpath(self, child: Path, parent: Path) -> bool:
        try:
            child.relative_to(parent)
            return True
        except ValueError:
            return False
