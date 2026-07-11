from __future__ import annotations

import asyncio
import os
import re
import subprocess
import time
from typing import Any

from nexora_ai.domain.entities.tool import ToolResult
from nexora_ai.domain.enums.tool_enums import ToolCategory, ToolPermission
from nexora_ai.domain.interfaces.logging_interface import LoggingInterface
from nexora_ai.infrastructure.tools.tool_registry import ToolRegistry

from backend.services.permissions_manager import PermissionsManager

_BLOCKED_COMMANDS = frozenset({
    "format", "del", "rmdir", "rd", "mklink", "icacls", "cacls",
    "reg", "regedit", "bcdboot", "diskpart", "shutdown", "taskkill",
})

_DANGEROUS_PATTERNS = re.compile(
    r"[;&|`$!(){}[\]<>]"
)


class DesktopController:
    category = ToolCategory.DESKTOP
    permissions = [ToolPermission.READ, ToolPermission.WRITE, ToolPermission.EXECUTE]
    description = "Windows desktop control tools"

    def __init__(
        self,
        tool_registry: ToolRegistry,
        permissions_manager: PermissionsManager,
        logger: LoggingInterface,
    ) -> None:
        self._tool_registry = tool_registry
        self._permissions = permissions_manager
        self._logger = logger

    async def register_tools(self) -> None:
        tools: list[tuple[str, Any]] = [
            ("open_app", self._make_handler(self._open_app, "open_app", "Open an application by path")),
            ("close_app", self._make_handler(self._close_app, "close_app", "Close an application by name")),
            ("focus_window", self._make_handler(self._focus_window, "focus_window", "Focus a window by title")),
            ("move_window", self._make_handler(self._move_window, "move_window", "Move and resize a window")),
            ("get_mouse_position", self._make_handler(self._get_mouse_position, "get_mouse_position", "Get current mouse cursor position")),
            ("move_mouse", self._make_handler(self._move_mouse, "move_mouse", "Move mouse to x,y coordinates")),
            ("click", self._make_handler(self._click, "click", "Perform a mouse click at current position")),
            ("double_click", self._make_handler(self._double_click, "double_click", "Perform a double click")),
            ("right_click", self._make_handler(self._right_click, "right_click", "Perform a right click")),
            ("type_text", self._make_handler(self._type_text, "type_text", "Type text at current focus")),
            ("press_key", self._make_handler(self._press_key, "press_key", "Press a keyboard key")),
            ("get_clipboard", self._make_handler(self._get_clipboard, "get_clipboard", "Get clipboard content")),
            ("set_clipboard", self._make_handler(self._set_clipboard, "set_clipboard", "Set clipboard content")),
            ("show_notification", self._make_handler(self._show_notification, "show_notification", "Show a desktop notification")),
            ("get_active_window", self._make_handler(self._get_active_window, "get_active_window", "Get info about the active window")),
            ("list_windows", self._make_handler(self._list_windows, "list_windows", "List all visible windows")),
            ("take_screenshot", self._make_handler(self._take_screenshot, "take_screenshot", "Take a screenshot to a file")),
            ("run_terminal", self._make_handler(self._run_terminal, "run_terminal", "Run a terminal command")),
            ("run_powershell", self._make_handler(self._run_powershell, "run_powershell", "Run a PowerShell script")),
            ("run_python", self._make_handler(self._run_python, "run_python", "Run Python code")),
            ("open_file_explorer", self._make_handler(self._open_file_explorer, "open_file_explorer", "Open File Explorer to a path")),
        ]
        for name, handler in tools:
            await self._tool_registry.register_tool(name, handler)

    def _make_handler(self, coro_func: Any, action: str, desc: str) -> Any:
        parameters = {}

        class ToolHandler:
            category = ToolCategory.DESKTOP
            description = desc
            permissions = [ToolPermission.READ, ToolPermission.WRITE, ToolPermission.EXECUTE]
            parameters = parameters

            def __init__(self, fn):
                self._fn = fn

            async def execute(self, params):
                return await self._fn(params)

        handler = ToolHandler(coro_func)
        return handler

    async def _open_app(self, parameters: dict[str, Any]) -> ToolResult:
        path = parameters.get("path", "")
        if not path:
            return ToolResult(success=False, error="path is required", tool_name="open_app")
        req = self._permissions.request_permission("open_app", {"resource": path})
        if req.status == "denied":
            return ToolResult(success=False, error="Permission denied", tool_name="open_app")
        try:
            if os.path.isfile(path):
                os.startfile(path)
            else:
                subprocess.Popen(["cmd.exe", "/c", "start", "", path])
            return ToolResult(success=True, output=f"Opened {path}", tool_name="open_app")
        except Exception as exc:
            return ToolResult(success=False, error=str(exc), tool_name="open_app")

    async def _close_app(self, parameters: dict[str, Any]) -> ToolResult:
        name = parameters.get("name", "")
        if not name:
            return ToolResult(success=False, error="name is required", tool_name="close_app")
        try:
            subprocess.run(["taskkill", "/f", "/im", name], capture_output=True, text=True)
            return ToolResult(success=True, output=f"Closed {name}", tool_name="close_app")
        except Exception as exc:
            return ToolResult(success=False, error=str(exc), tool_name="close_app")

    async def _focus_window(self, parameters: dict[str, Any]) -> ToolResult:
        title = parameters.get("title", "")
        if not title:
            return ToolResult(success=False, error="title is required", tool_name="focus_window")
        try:
            import win32gui
            hwnd = win32gui.FindWindow(None, title)
            if hwnd:
                win32gui.SetForegroundWindow(hwnd)
                return ToolResult(success=True, output=f"Focused window: {title}", tool_name="focus_window")
            return ToolResult(success=False, error=f"Window not found: {title}", tool_name="focus_window")
        except ImportError:
            return ToolResult(success=False, error="pywin32 not available", tool_name="focus_window")
        except Exception as exc:
            return ToolResult(success=False, error=str(exc), tool_name="focus_window")

    async def _move_window(self, parameters: dict[str, Any]) -> ToolResult:
        x = parameters.get("x", 0)
        y = parameters.get("y", 0)
        w = parameters.get("w", 800)
        h = parameters.get("h", 600)
        title = parameters.get("title", "")
        if not title:
            return ToolResult(success=False, error="title is required", tool_name="move_window")
        try:
            import win32gui
            hwnd = win32gui.FindWindow(None, title)
            if hwnd:
                win32gui.SetWindowPos(hwnd, 0, x, y, w, h, 0x0040)
                return ToolResult(success=True, output=f"Moved window {title} to ({x},{y}) size ({w}x{h})", tool_name="move_window")
            return ToolResult(success=False, error=f"Window not found: {title}", tool_name="move_window")
        except ImportError:
            return ToolResult(success=False, error="pywin32 not available", tool_name="move_window")
        except Exception as exc:
            return ToolResult(success=False, error=str(exc), tool_name="move_window")

    async def _get_mouse_position(self, parameters: dict[str, Any]) -> ToolResult:
        try:
            import win32api
            pos = win32api.GetCursorPos()
            return ToolResult(success=True, output={"x": pos[0], "y": pos[1]}, tool_name="get_mouse_position")
        except ImportError:
            return ToolResult(success=False, error="pywin32 not available", tool_name="get_mouse_position")
        except Exception as exc:
            return ToolResult(success=False, error=str(exc), tool_name="get_mouse_position")

    async def _move_mouse(self, parameters: dict[str, Any]) -> ToolResult:
        x = parameters.get("x", 0)
        y = parameters.get("y", 0)
        try:
            import win32api
            win32api.SetCursorPos((x, y))
            return ToolResult(success=True, output=f"Moved mouse to ({x},{y})", tool_name="move_mouse")
        except ImportError:
            return ToolResult(success=False, error="pywin32 not available", tool_name="move_mouse")
        except Exception as exc:
            return ToolResult(success=False, error=str(exc), tool_name="move_mouse")

    async def _click(self, parameters: dict[str, Any]) -> ToolResult:
        try:
            import win32api
            import win32con
            win32api.mouse_event(win32con.MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0)
            await asyncio.sleep(0.05)
            win32api.mouse_event(win32con.MOUSEEVENTF_LEFTUP, 0, 0, 0, 0)
            return ToolResult(success=True, output="Clicked", tool_name="click")
        except ImportError:
            return ToolResult(success=False, error="pywin32 not available", tool_name="click")
        except Exception as exc:
            return ToolResult(success=False, error=str(exc), tool_name="click")

    async def _double_click(self, parameters: dict[str, Any]) -> ToolResult:
        try:
            import win32api
            import win32con
            for _ in range(2):
                win32api.mouse_event(win32con.MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0)
                await asyncio.sleep(0.05)
                win32api.mouse_event(win32con.MOUSEEVENTF_LEFTUP, 0, 0, 0, 0)
                await asyncio.sleep(0.05)
            return ToolResult(success=True, output="Double clicked", tool_name="double_click")
        except ImportError:
            return ToolResult(success=False, error="pywin32 not available", tool_name="double_click")
        except Exception as exc:
            return ToolResult(success=False, error=str(exc), tool_name="double_click")

    async def _right_click(self, parameters: dict[str, Any]) -> ToolResult:
        try:
            import win32api
            import win32con
            win32api.mouse_event(win32con.MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0)
            await asyncio.sleep(0.05)
            win32api.mouse_event(win32con.MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0)
            return ToolResult(success=True, output="Right clicked", tool_name="right_click")
        except ImportError:
            return ToolResult(success=False, error="pywin32 not available", tool_name="right_click")
        except Exception as exc:
            return ToolResult(success=False, error=str(exc), tool_name="right_click")

    async def _type_text(self, parameters: dict[str, Any]) -> ToolResult:
        text = parameters.get("text", "")
        if not text:
            return ToolResult(success=False, error="text is required", tool_name="type_text")
        try:
            import win32clipboard
            import win32con
            win32clipboard.OpenClipboard()
            win32clipboard.EmptyClipboard()
            win32clipboard.SetClipboardText(text)
            win32clipboard.CloseClipboard()
            import win32api
            win32api.keybd_event(0x11, 0, 0, 0)
            win32api.keybd_event(0x56, 0, 0, 0)
            win32api.keybd_event(0x56, 0, win32con.KEYEVENTF_KEYUP, 0)
            win32api.keybd_event(0x11, 0, win32con.KEYEVENTF_KEYUP, 0)
            return ToolResult(success=True, output=f"Typed text ({len(text)} chars)", tool_name="type_text")
        except ImportError:
            return ToolResult(success=False, error="pywin32 not available", tool_name="type_text")
        except Exception as exc:
            return ToolResult(success=False, error=str(exc), tool_name="type_text")

    async def _press_key(self, parameters: dict[str, Any]) -> ToolResult:
        key = parameters.get("key", "")
        if not key:
            return ToolResult(success=False, error="key is required", tool_name="press_key")
        key_map = {
            "enter": 0x0D, "tab": 0x09, "escape": 0x1B, "backspace": 0x08,
            "space": 0x20, "delete": 0x2E, "up": 0x26, "down": 0x28,
            "left": 0x25, "right": 0x27, "home": 0x24, "end": 0x23,
            "pageup": 0x21, "pagedown": 0x22, "f1": 0x70, "f2": 0x71,
            "f3": 0x72, "f4": 0x73, "f5": 0x74, "f6": 0x75,
            "f7": 0x76, "f8": 0x77, "f9": 0x78, "f10": 0x79,
            "f11": 0x7A, "f12": 0x7B,
        }
        vk = key_map.get(key.lower())
        if vk is None:
            return ToolResult(success=False, error=f"Unknown key: {key}", tool_name="press_key")
        try:
            import win32api
            import win32con
            win32api.keybd_event(vk, 0, 0, 0)
            await asyncio.sleep(0.05)
            win32api.keybd_event(vk, 0, win32con.KEYEVENTF_KEYUP, 0)
            return ToolResult(success=True, output=f"Pressed key: {key}", tool_name="press_key")
        except ImportError:
            return ToolResult(success=False, error="pywin32 not available", tool_name="press_key")
        except Exception as exc:
            return ToolResult(success=False, error=str(exc), tool_name="press_key")

    async def _get_clipboard(self, parameters: dict[str, Any]) -> ToolResult:
        try:
            import win32clipboard
            win32clipboard.OpenClipboard()
            data = win32clipboard.GetClipboardData()
            win32clipboard.CloseClipboard()
            return ToolResult(success=True, output=data, tool_name="get_clipboard")
        except ImportError:
            return ToolResult(success=False, error="pywin32 not available", tool_name="get_clipboard")
        except Exception as exc:
            return ToolResult(success=False, error=str(exc), tool_name="get_clipboard")

    async def _set_clipboard(self, parameters: dict[str, Any]) -> ToolResult:
        text = parameters.get("text", "")
        try:
            import win32clipboard
            win32clipboard.OpenClipboard()
            win32clipboard.EmptyClipboard()
            win32clipboard.SetClipboardText(text)
            win32clipboard.CloseClipboard()
            return ToolResult(success=True, output="Clipboard set", tool_name="set_clipboard")
        except ImportError:
            return ToolResult(success=False, error="pywin32 not available", tool_name="set_clipboard")
        except Exception as exc:
            return ToolResult(success=False, error=str(exc), tool_name="set_clipboard")

    async def _show_notification(self, parameters: dict[str, Any]) -> ToolResult:
        title = parameters.get("title", "Personal AI")
        message = parameters.get("message", "")
        try:
            import win32api
            import win32con
            win32api.MessageBox(0, message, title, win32con.MB_OK | win32con.MB_TOPMOST)
            return ToolResult(success=True, output="Notification shown", tool_name="show_notification")
        except ImportError:
            subprocess.run(["cmd.exe", "/c", "msg", "*", f"{title}: {message}"])
            return ToolResult(success=True, output="Notification shown via msg", tool_name="show_notification")
        except Exception as exc:
            return ToolResult(success=False, error=str(exc), tool_name="show_notification")

    async def _get_active_window(self, parameters: dict[str, Any]) -> ToolResult:
        try:
            import win32gui
            hwnd = win32gui.GetForegroundWindow()
            title = win32gui.GetWindowText(hwnd)
            rect = win32gui.GetWindowRect(hwnd)
            return ToolResult(
                success=True,
                output={
                    "hwnd": hwnd,
                    "title": title,
                    "rect": {"left": rect[0], "top": rect[1], "right": rect[2], "bottom": rect[3]},
                },
                tool_name="get_active_window",
            )
        except ImportError:
            return ToolResult(success=False, error="pywin32 not available", tool_name="get_active_window")
        except Exception as exc:
            return ToolResult(success=False, error=str(exc), tool_name="get_active_window")

    async def _list_windows(self, parameters: dict[str, Any]) -> ToolResult:
        windows: list[dict[str, Any]] = []
        try:
            import win32gui

            def enum_callback(hwnd: int, _: Any) -> None:
                if win32gui.IsWindowVisible(hwnd):
                    title = win32gui.GetWindowText(hwnd)
                    if title:
                        rect = win32gui.GetWindowRect(hwnd)
                        windows.append({
                            "hwnd": hwnd,
                            "title": title,
                            "rect": {"left": rect[0], "top": rect[1], "right": rect[2], "bottom": rect[3]},
                        })

            win32gui.EnumWindows(enum_callback, None)
            return ToolResult(success=True, output=windows, tool_name="list_windows")
        except ImportError:
            return ToolResult(success=False, error="pywin32 not available", tool_name="list_windows")
        except Exception as exc:
            return ToolResult(success=False, error=str(exc), tool_name="list_windows")

    async def _take_screenshot(self, parameters: dict[str, Any]) -> ToolResult:
        path = parameters.get("path", "")
        if path:
            normalized = os.path.normpath(path)
            if ".." in normalized.split(os.sep):
                return ToolResult(success=False, error="Path traversal not allowed", tool_name="take_screenshot")
        try:
            import win32api
            import win32ui
            import win32gui
            import win32con
            from PIL import Image
            import io

            hdesktop = win32gui.GetDesktopWindow()
            dc = win32gui.GetWindowDC(hdesktop)
            mfc_dc = win32ui.CreateDCFromHandle(dc)
            save_dc = mfc_dc.CreateCompatibleDC()
            bitmap = win32ui.CreateBitmap()
            width = win32api.GetSystemMetrics(win32con.SM_CXVIRTUALSCREEN)
            height = win32api.GetSystemMetrics(win32con.SM_CYVIRTUALSCREEN)
            bitmap.CreateCompatibleBitmap(mfc_dc, width, height)
            save_dc.SelectObject(bitmap)
            save_dc.BitBlt((0, 0), (width, height), mfc_dc, (0, 0), win32con.SRCCOPY)
            bmp_info = bitmap.GetInfo()
            bmp_str = bitmap.GetBitmapBits(True)
            img = Image.frombuffer("RGB", (bmp_info["bmWidth"], bmp_info["bmHeight"]), bmp_str, "raw", "BGRX", 0, 1)
            mfc_dc.DeleteDC()
            save_dc.DeleteDC()
            win32gui.ReleaseDC(hdesktop, dc)
            win32gui.DeleteObject(bitmap.GetHandle())

            if path:
                img.save(path, "PNG")
                output = f"Screenshot saved to {path}"
            else:
                buf = io.BytesIO()
                img.save(buf, format="PNG")
                output = buf.getvalue()

            return ToolResult(success=True, output=output, tool_name="take_screenshot")
        except ImportError:
            return ToolResult(success=False, error="pywin32 or Pillow not available", tool_name="take_screenshot")
        except Exception as exc:
            return ToolResult(success=False, error=str(exc), tool_name="take_screenshot")

    async def _run_terminal(self, parameters: dict[str, Any]) -> ToolResult:
        command = parameters.get("command", "")
        if not command:
            return ToolResult(success=False, error="command is required", tool_name="run_terminal")
        if _DANGEROUS_PATTERNS.search(command):
            return ToolResult(success=False, error="Command contains forbidden characters", tool_name="run_terminal")
        first_word = command.split()[0].lower().rstrip(".exe")
        if first_word in _BLOCKED_COMMANDS:
            return ToolResult(success=False, error=f"Command '{first_word}' is blocked for safety", tool_name="run_terminal")
        req = self._permissions.request_permission("run_terminal", {"command": command[:100]})
        if req.status == "denied":
            return ToolResult(success=False, error="Permission denied", tool_name="run_terminal")
        try:
            result = subprocess.run(
                ["cmd.exe", "/c", command],
                capture_output=True, text=True, timeout=30,
            )
            return ToolResult(
                success=result.returncode == 0,
                output=result.stdout or result.stderr,
                tool_name="run_terminal",
            )
        except subprocess.TimeoutExpired:
            return ToolResult(success=False, error="Command timed out", tool_name="run_terminal")
        except Exception as exc:
            return ToolResult(success=False, error=str(exc), tool_name="run_terminal")

    async def _run_powershell(self, parameters: dict[str, Any]) -> ToolResult:
        script = parameters.get("script", "")
        if not script:
            return ToolResult(success=False, error="script is required", tool_name="run_powershell")
        req = self._permissions.request_permission("run_powershell", {"script": script[:100]})
        if req.status == "denied":
            return ToolResult(success=False, error="Permission denied", tool_name="run_powershell")
        try:
            result = subprocess.run(["powershell", "-Command", script], capture_output=True, text=True, timeout=30)
            return ToolResult(
                success=result.returncode == 0,
                output=result.stdout or result.stderr,
                tool_name="run_powershell",
            )
        except subprocess.TimeoutExpired:
            return ToolResult(success=False, error="Script timed out", tool_name="run_powershell")
        except Exception as exc:
            return ToolResult(success=False, error=str(exc), tool_name="run_powershell")

    async def _run_python(self, parameters: dict[str, Any]) -> ToolResult:
        code = parameters.get("code", "")
        if not code:
            return ToolResult(success=False, error="code is required", tool_name="run_python")
        req = self._permissions.request_permission("run_python", {"code": code[:100]})
        if req.status == "denied":
            return ToolResult(success=False, error="Permission denied", tool_name="run_python")
        try:
            result = subprocess.run(["python", "-c", code], capture_output=True, text=True, timeout=30)
            return ToolResult(
                success=result.returncode == 0,
                output=result.stdout or result.stderr,
                tool_name="run_python",
            )
        except subprocess.TimeoutExpired:
            return ToolResult(success=False, error="Code execution timed out", tool_name="run_python")
        except Exception as exc:
            return ToolResult(success=False, error=str(exc), tool_name="run_python")

    async def _open_file_explorer(self, parameters: dict[str, Any]) -> ToolResult:
        path = parameters.get("path", "")
        try:
            subprocess.Popen(["explorer.exe", path])
            return ToolResult(success=True, output=f"Opened explorer at {path}", tool_name="open_file_explorer")
        except Exception as exc:
            return ToolResult(success=False, error=str(exc), tool_name="open_file_explorer")
