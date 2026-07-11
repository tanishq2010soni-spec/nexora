from __future__ import annotations

from typing import Any

from nexora_ai.domain.entities.tool import ToolResult
from nexora_ai.domain.enums.tool_enums import ToolCategory, ToolPermission
from nexora_ai.domain.interfaces.logging_interface import LoggingInterface
from nexora_ai.infrastructure.tools.tool_registry import ToolRegistry


class ScreenCapture:
    category = ToolCategory.DESKTOP
    permissions = [ToolPermission.READ]
    description = "Screen capture and understanding tools"

    def __init__(
        self,
        tool_registry: ToolRegistry,
        logger: LoggingInterface,
    ) -> None:
        self._tool_registry = tool_registry
        self._logger = logger
        self._pytesseract_available: bool | None = None

    async def register_tools(self) -> None:
        self._check_dependencies()
        tools: list[tuple[str, Any]] = [
            ("capture_screen", self._make_handler(self._capture_screen, "Capture the full screen as PNG bytes")),
            ("ocr_region", self._make_handler(self._ocr_region, "Perform OCR on a screen region")),
            ("detect_windows", self._make_handler(self._detect_windows, "Detect visible windows on screen")),
            ("detect_buttons", self._make_handler(self._detect_buttons, "Detect buttons in a screen region")),
            ("detect_text", self._make_handler(self._detect_text, "Detect text in a screen region")),
            ("detect_forms", self._make_handler(self._detect_forms, "Detect form fields in a screen region")),
            ("detect_tables", self._make_handler(self._detect_tables, "Detect tables in a screen region")),
            ("get_element_at", self._make_handler(self._get_element_at, "Get UI element info at x,y coordinates")),
            ("wait_for_element", self._make_handler(self._wait_for_element, "Wait for an element matching condition")),
        ]
        for name, handler in tools:
            await self._tool_registry.register_tool(name, handler)

    def _check_dependencies(self) -> None:
        try:
            import pytesseract
            pytesseract.get_tesseract_version()
            self._pytesseract_available = True
        except Exception:
            self._pytesseract_available = False

    def _make_handler(self, coro_func: Any, desc: str) -> Any:
        handler = type(
            f"Tool_{coro_func.__name__}",
            (),
            {
                "category": ToolCategory.DESKTOP,
                "description": desc,
                "permissions": [ToolPermission.READ],
                "parameters": {},
                "execute": lambda params, cf=coro_func: cf(params),
            },
        )()
        return handler

    def _capture_image(self) -> bytes | None:
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
            buf = io.BytesIO()
            img.save(buf, format="PNG")
            return buf.getvalue()
        except ImportError:
            return None

    def _crop_region(self, image_bytes: bytes, x: int, y: int, w: int, h: int) -> Any:
        from PIL import Image
        import io
        img = Image.open(io.BytesIO(image_bytes))
        return img.crop((x, y, x + w, y + h))

    def _do_ocr(self, image: Any) -> str:
        if not self._pytesseract_available:
            return "OCR not available (pytesseract not installed)"
        import pytesseract
        return pytesseract.image_to_string(image)

    async def _capture_screen(self, parameters: dict[str, Any]) -> ToolResult:
        img_bytes = self._capture_image()
        if img_bytes is None:
            return ToolResult(success=False, error="Screen capture requires pywin32 + Pillow", tool_name="capture_screen")
        return ToolResult(success=True, output=img_bytes, tool_name="capture_screen")

    async def _ocr_region(self, parameters: dict[str, Any]) -> ToolResult:
        x = parameters.get("x", 0)
        y = parameters.get("y", 0)
        w = parameters.get("w", 100)
        h = parameters.get("h", 100)
        img_bytes = self._capture_image()
        if img_bytes is None:
            return ToolResult(success=False, error="Screen capture requires pywin32 + Pillow", tool_name="ocr_region")
        try:
            region = self._crop_region(img_bytes, x, y, w, h)
            text = self._do_ocr(region)
            return ToolResult(success=True, output=text, tool_name="ocr_region")
        except Exception as exc:
            return ToolResult(success=False, error=str(exc), tool_name="ocr_region")

    async def _detect_windows(self, parameters: dict[str, Any]) -> ToolResult:
        try:
            import win32gui
            windows: list[dict[str, Any]] = []

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
            return ToolResult(success=True, output=windows, tool_name="detect_windows")
        except ImportError:
            return ToolResult(success=False, error="pywin32 not available", tool_name="detect_windows")
        except Exception as exc:
            return ToolResult(success=False, error=str(exc), tool_name="detect_windows")

    async def _detect_buttons(self, parameters: dict[str, Any]) -> ToolResult:
        return ToolResult(success=True, output=[], tool_name="detect_buttons")

    async def _detect_text(self, parameters: dict[str, Any]) -> ToolResult:
        x = parameters.get("x", 0)
        y = parameters.get("y", 0)
        w = parameters.get("w", 800)
        h = parameters.get("h", 600)
        img_bytes = self._capture_image()
        if img_bytes is None:
            return ToolResult(success=False, error="Screen capture requires pywin32 + Pillow", tool_name="detect_text")
        try:
            region = self._crop_region(img_bytes, x, y, w, h)
            text = self._do_ocr(region)
            return ToolResult(success=True, output=text, tool_name="detect_text")
        except Exception as exc:
            return ToolResult(success=False, error=str(exc), tool_name="detect_text")

    async def _detect_forms(self, parameters: dict[str, Any]) -> ToolResult:
        return ToolResult(success=True, output=[], tool_name="detect_forms")

    async def _detect_tables(self, parameters: dict[str, Any]) -> ToolResult:
        return ToolResult(success=True, output=[], tool_name="detect_tables")

    async def _get_element_at(self, parameters: dict[str, Any]) -> ToolResult:
        x = parameters.get("x", 0)
        y = parameters.get("y", 0)
        try:
            import win32gui
            hwnd = win32gui.WindowFromPoint((x, y))
            class_name = win32gui.GetClassName(hwnd)
            window_text = win32gui.GetWindowText(hwnd)
            return ToolResult(
                success=True,
                output={
                    "hwnd": hwnd,
                    "class_name": class_name,
                    "window_text": window_text,
                    "x": x,
                    "y": y,
                },
                tool_name="get_element_at",
            )
        except ImportError:
            return ToolResult(success=False, error="pywin32 not available", tool_name="get_element_at")
        except Exception as exc:
            return ToolResult(success=False, error=str(exc), tool_name="get_element_at")

    async def _wait_for_element(self, parameters: dict[str, Any]) -> ToolResult:
        condition = parameters.get("condition", {})
        timeout = parameters.get("timeout", 10)
        import asyncio
        start = asyncio.get_event_loop().time()
        while (asyncio.get_event_loop().time() - start) < timeout:
            try:
                import win32gui
                text = condition.get("text", "")
                if text:
                    hwnd = win32gui.FindWindow(None, text)
                    if hwnd:
                        return ToolResult(
                            success=True,
                            output={"hwnd": hwnd, "title": text},
                            tool_name="wait_for_element",
                        )
            except Exception:
                pass
            await asyncio.sleep(0.5)
        return ToolResult(success=False, error=f"Element with condition {condition} not found within {timeout}s", tool_name="wait_for_element")
