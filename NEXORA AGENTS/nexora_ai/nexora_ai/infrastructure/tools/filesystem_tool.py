from __future__ import annotations

import shutil
from pathlib import Path
from typing import Any

from nexora_ai.domain.enums.tool_enums import ToolCategory, ToolPermission


class FilesystemTool:
    category = ToolCategory.FILESYSTEM
    permissions = [ToolPermission.READ, ToolPermission.WRITE]

    def __init__(self, allowed_paths: list[str | Path] | None = None) -> None:
        self._allowed_paths = [Path(p).resolve() for p in (allowed_paths or [])] if allowed_paths else []

    def _resolve_path(self, path: str | Path) -> Path:
        resolved = Path(path).resolve()
        if self._allowed_paths:
            if not any(self._is_subpath(resolved, allowed) for allowed in self._allowed_paths):
                msg = f"Path '{path}' is outside allowed directories"
                raise PermissionError(msg)
        return resolved

    async def execute(self, parameters: dict[str, Any]) -> dict[str, Any]:
        action = parameters.get("action", "read")
        path = str(parameters.get("path", ""))
        try:
            if action == "read":
                return await self._read(path)
            elif action == "write":
                content = parameters.get("content", "")
                return await self._write(path, content)
            elif action == "list":
                return await self._list(path)
            elif action == "move":
                dest = str(parameters.get("destination", ""))
                return await self._move(path, dest)
            elif action == "copy":
                dest = str(parameters.get("destination", ""))
                return await self._copy(path, dest)
            elif action == "delete":
                return await self._delete(path)
            elif action == "info":
                return await self._info(path)
            else:
                return {"success": False, "error": f"Unknown action: {action}"}
        except PermissionError as exc:
            return {"success": False, "error": str(exc)}
        except Exception as exc:
            return {"success": False, "error": str(exc)}

    async def _read(self, path: str) -> dict[str, Any]:
        resolved = self._resolve_path(path)
        if not resolved.exists():
            return {"success": False, "error": f"File not found: {path}"}
        if not resolved.is_file():
            return {"success": False, "error": f"Not a file: {path}"}
        content = resolved.read_text(encoding="utf-8")
        return {"success": True, "content": content, "path": str(resolved)}

    async def _write(self, path: str, content: str) -> dict[str, Any]:
        resolved = self._resolve_path(path)
        resolved.parent.mkdir(parents=True, exist_ok=True)
        resolved.write_text(content, encoding="utf-8")
        return {"success": True, "path": str(resolved)}

    async def _list(self, path: str) -> dict[str, Any]:
        resolved = self._resolve_path(path)
        if not resolved.exists():
            return {"success": False, "error": f"Directory not found: {path}"}
        if not resolved.is_dir():
            return {"success": False, "error": f"Not a directory: {path}"}
        entries = []
        for entry in resolved.iterdir():
            entries.append({
                "name": entry.name,
                "path": str(entry),
                "type": "directory" if entry.is_dir() else "file",
                "size": entry.stat().st_size if entry.is_file() else 0,
            })
        return {"success": True, "entries": entries, "path": str(resolved)}

    async def _move(self, source: str, destination: str) -> dict[str, Any]:
        src = self._resolve_path(source)
        dst = self._resolve_path(destination)
        if not src.exists():
            return {"success": False, "error": f"Source not found: {source}"}
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.move(str(src), str(dst))
        return {"success": True, "source": str(src), "destination": str(dst)}

    async def _copy(self, source: str, destination: str) -> dict[str, Any]:
        src = self._resolve_path(source)
        dst = self._resolve_path(destination)
        if not src.exists():
            return {"success": False, "error": f"Source not found: {source}"}
        dst.parent.mkdir(parents=True, exist_ok=True)
        if src.is_dir():
            shutil.copytree(str(src), str(dst))
        else:
            shutil.copy2(str(src), str(dst))
        return {"success": True, "source": str(src), "destination": str(dst)}

    async def _delete(self, path: str) -> dict[str, Any]:
        resolved = self._resolve_path(path)
        if not resolved.exists():
            return {"success": False, "error": f"Path not found: {path}"}
        if resolved.is_dir():
            shutil.rmtree(str(resolved))
        else:
            resolved.unlink()
        return {"success": True, "path": str(resolved)}

    async def _info(self, path: str) -> dict[str, Any]:
        resolved = self._resolve_path(path)
        if not resolved.exists():
            return {"success": False, "error": f"Path not found: {path}"}
        stat = resolved.stat()
        return {
            "success": True,
            "path": str(resolved),
            "exists": True,
            "type": "directory" if resolved.is_dir() else "file",
            "size": stat.st_size,
            "created": stat.st_ctime,
            "modified": stat.st_mtime,
            "permissions": oct(stat.st_mode),
        }

    def _is_subpath(self, child: Path, parent: Path) -> bool:
        try:
            child.relative_to(parent)
            return True
        except ValueError:
            return False
