from __future__ import annotations

import io
from typing import Any

from nexora_ai.domain.interfaces.screen_interface import ScreenInterface


class WindowsScreenCapture(ScreenInterface):
    async def capture(self) -> bytes:
        try:
            import win32api
            import win32ui
            import win32gui
            import win32con
            from PIL import Image

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

            buf = io.BytesIO()
            img.save(buf, format="PNG")
            return buf.getvalue()
        except ImportError:
            raise NotImplementedError("Production implementation requires pywin32")

    async def get_element_at(self, x: int, y: int) -> dict[str, Any]:
        try:
            import win32gui
            hwnd = win32gui.WindowFromPoint((x, y))
            class_name = win32gui.GetClassName(hwnd)
            window_text = win32gui.GetWindowText(hwnd)
            return {
                "hwnd": hwnd,
                "class_name": class_name,
                "window_text": window_text,
                "x": x,
                "y": y,
            }
        except ImportError:
            raise NotImplementedError("Production implementation requires pywin32")

    async def get_window_info(self) -> dict[str, Any]:
        try:
            import win32gui
            hwnd = win32gui.GetForegroundWindow()
            rect = win32gui.GetWindowRect(hwnd)
            text = win32gui.GetWindowText(hwnd)
            return {
                "hwnd": hwnd,
                "rect": {"left": rect[0], "top": rect[1], "right": rect[2], "bottom": rect[3]},
                "title": text,
            }
        except ImportError:
            raise NotImplementedError("Production implementation requires pywin32")

    async def get_mouse_position(self) -> tuple[int, int]:
        try:
            import win32api
            pos = win32api.GetCursorPos()
            return (pos[0], pos[1])
        except ImportError:
            raise NotImplementedError("Production implementation requires pywin32")

    async def get_monitor_layout(self) -> list[dict[str, Any]]:
        try:
            import win32api
            monitors: list[dict[str, Any]] = []
            for hmonitor, hdc, rect in win32api.EnumDisplayMonitors():
                monitors.append({
                    "handle": hmonitor,
                    "rect": {"left": rect[0], "top": rect[1], "right": rect[2], "bottom": rect[3]},
                })
            return monitors
        except ImportError:
            raise NotImplementedError("Production implementation requires pywin32")

    async def ocr(self, image: bytes) -> str:
        raise NotImplementedError("Production implementation requires pytesseract")
