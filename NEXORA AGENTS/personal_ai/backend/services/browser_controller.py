from __future__ import annotations

import asyncio
from typing import Any

from nexora_ai.domain.entities.tool import ToolResult
from nexora_ai.domain.enums.tool_enums import ToolCategory, ToolPermission
from nexora_ai.domain.interfaces.logging_interface import LoggingInterface
from nexora_ai.infrastructure.tools.tool_registry import ToolRegistry

from backend.services.permissions_manager import PermissionsManager


class BrowserController:
    category = ToolCategory.BROWSER
    permissions = [ToolPermission.READ, ToolPermission.WRITE]
    description = "Browser automation and control tools"

    def __init__(
        self,
        tool_registry: ToolRegistry,
        permissions_manager: PermissionsManager,
        logger: LoggingInterface,
    ) -> None:
        self._tool_registry = tool_registry
        self._permissions = permissions_manager
        self._logger = logger
        self._playwright_available: bool | None = None
        self._browser: Any = None
        self._page: Any = None

    async def register_tools(self) -> None:
        self._check_playwright()
        tools: list[tuple[str, Any]] = [
            ("browser_navigate", self._make_handler(self._browser_navigate, "Navigate to a URL")),
            ("browser_click", self._make_handler(self._browser_click, "Click on an element by CSS selector")),
            ("browser_type", self._make_handler(self._browser_type, "Type text into an element")),
            ("browser_get_text", self._make_handler(self._browser_get_text, "Get text content of an element")),
            ("browser_get_html", self._make_handler(self._browser_get_html, "Get full page HTML")),
            ("browser_screenshot", self._make_handler(self._browser_screenshot, "Take a browser screenshot")),
            ("browser_get_title", self._make_handler(self._browser_get_title, "Get page title")),
            ("browser_get_url", self._make_handler(self._browser_get_url, "Get current URL")),
            ("browser_back", self._make_handler(self._browser_back, "Navigate back")),
            ("browser_forward", self._make_handler(self._browser_forward, "Navigate forward")),
            ("browser_refresh", self._make_handler(self._browser_refresh, "Refresh the page")),
            ("browser_download", self._make_handler(self._browser_download, "Download a file from URL")),
            ("browser_upload", self._make_handler(self._browser_upload, "Upload a file to a form element")),
            ("browser_wait", self._make_handler(self._browser_wait, "Wait for an element to appear")),
        ]
        for name, handler in tools:
            await self._tool_registry.register_tool(name, handler)

    def _check_playwright(self) -> None:
        try:
            import playwright
            self._playwright_available = True
        except ImportError:
            self._playwright_available = False

    def _make_handler(self, coro_func: Any, desc: str) -> Any:
        handler = type(
            f"Tool_{coro_func.__name__}",
            (),
            {
                "category": ToolCategory.BROWSER,
                "description": desc,
                "permissions": [ToolPermission.READ, ToolPermission.WRITE],
                "parameters": {},
                "execute": lambda params, cf=coro_func: cf(params),
            },
        )()
        return handler

    async def _ensure_browser(self) -> Any:
        if self._page is not None:
            return self._page
        if not self._playwright_available:
            raise NotImplementedError("Playwright is not installed. Run: pip install playwright && playwright install")
        from playwright.async_api import async_playwright
        self._playwright_instance = await async_playwright().start()
        self._browser = await self._playwright_instance.chromium.launch(headless=False)
        context = await self._browser.new_context()
        self._page = await context.new_page()
        return self._page

    async def _browser_navigate(self, parameters: dict[str, Any]) -> ToolResult:
        url = parameters.get("url", "")
        if not url:
            return ToolResult(success=False, error="url is required", tool_name="browser_navigate")
        try:
            page = await self._ensure_browser()
            await page.goto(url, timeout=30000)
            return ToolResult(success=True, output=f"Navigated to {url}", tool_name="browser_navigate")
        except NotImplementedError:
            raise
        except Exception as exc:
            return ToolResult(success=False, error=str(exc), tool_name="browser_navigate")

    async def _browser_click(self, parameters: dict[str, Any]) -> ToolResult:
        selector = parameters.get("selector", "")
        if not selector:
            return ToolResult(success=False, error="selector is required", tool_name="browser_click")
        try:
            page = await self._ensure_browser()
            await page.click(selector, timeout=5000)
            return ToolResult(success=True, output=f"Clicked {selector}", tool_name="browser_click")
        except NotImplementedError:
            raise
        except Exception as exc:
            return ToolResult(success=False, error=str(exc), tool_name="browser_click")

    async def _browser_type(self, parameters: dict[str, Any]) -> ToolResult:
        selector = parameters.get("selector", "")
        text = parameters.get("text", "")
        if not selector:
            return ToolResult(success=False, error="selector is required", tool_name="browser_type")
        try:
            page = await self._ensure_browser()
            await page.fill(selector, text)
            return ToolResult(success=True, output=f"Typed into {selector}", tool_name="browser_type")
        except NotImplementedError:
            raise
        except Exception as exc:
            return ToolResult(success=False, error=str(exc), tool_name="browser_type")

    async def _browser_get_text(self, parameters: dict[str, Any]) -> ToolResult:
        selector = parameters.get("selector", "")
        if not selector:
            return ToolResult(success=False, error="selector is required", tool_name="browser_get_text")
        try:
            page = await self._ensure_browser()
            text = await page.text_content(selector)
            return ToolResult(success=True, output=text or "", tool_name="browser_get_text")
        except NotImplementedError:
            raise
        except Exception as exc:
            return ToolResult(success=False, error=str(exc), tool_name="browser_get_text")

    async def _browser_get_html(self, parameters: dict[str, Any]) -> ToolResult:
        try:
            page = await self._ensure_browser()
            html = await page.content()
            return ToolResult(success=True, output=html, tool_name="browser_get_html")
        except NotImplementedError:
            raise
        except Exception as exc:
            return ToolResult(success=False, error=str(exc), tool_name="browser_get_html")

    async def _browser_screenshot(self, parameters: dict[str, Any]) -> ToolResult:
        try:
            page = await self._ensure_browser()
            screenshot = await page.screenshot()
            return ToolResult(success=True, output=screenshot, tool_name="browser_screenshot")
        except NotImplementedError:
            raise
        except Exception as exc:
            return ToolResult(success=False, error=str(exc), tool_name="browser_screenshot")

    async def _browser_get_title(self, parameters: dict[str, Any]) -> ToolResult:
        try:
            page = await self._ensure_browser()
            title = await page.title()
            return ToolResult(success=True, output=title, tool_name="browser_get_title")
        except NotImplementedError:
            raise
        except Exception as exc:
            return ToolResult(success=False, error=str(exc), tool_name="browser_get_title")

    async def _browser_get_url(self, parameters: dict[str, Any]) -> ToolResult:
        try:
            page = await self._ensure_browser()
            url = page.url
            return ToolResult(success=True, output=url, tool_name="browser_get_url")
        except NotImplementedError:
            raise
        except Exception as exc:
            return ToolResult(success=False, error=str(exc), tool_name="browser_get_url")

    async def _browser_back(self, parameters: dict[str, Any]) -> ToolResult:
        try:
            page = await self._ensure_browser()
            await page.go_back()
            return ToolResult(success=True, output="Navigated back", tool_name="browser_back")
        except NotImplementedError:
            raise
        except Exception as exc:
            return ToolResult(success=False, error=str(exc), tool_name="browser_back")

    async def _browser_forward(self, parameters: dict[str, Any]) -> ToolResult:
        try:
            page = await self._ensure_browser()
            await page.go_forward()
            return ToolResult(success=True, output="Navigated forward", tool_name="browser_forward")
        except NotImplementedError:
            raise
        except Exception as exc:
            return ToolResult(success=False, error=str(exc), tool_name="browser_forward")

    async def _browser_refresh(self, parameters: dict[str, Any]) -> ToolResult:
        try:
            page = await self._ensure_browser()
            await page.reload()
            return ToolResult(success=True, output="Page refreshed", tool_name="browser_refresh")
        except NotImplementedError:
            raise
        except Exception as exc:
            return ToolResult(success=False, error=str(exc), tool_name="browser_refresh")

    async def _browser_download(self, parameters: dict[str, Any]) -> ToolResult:
        url = parameters.get("url", "")
        path = parameters.get("path", "")
        if not url or not path:
            return ToolResult(success=False, error="url and path are required", tool_name="browser_download")
        import httpx
        try:
            async with httpx.AsyncClient() as client:
                response = await client.get(url, timeout=60)
                response.raise_for_status()
                with open(path, "wb") as f:
                    f.write(response.content)
            return ToolResult(success=True, output=f"Downloaded to {path}", tool_name="browser_download")
        except Exception as exc:
            return ToolResult(success=False, error=str(exc), tool_name="browser_download")

    async def _browser_upload(self, parameters: dict[str, Any]) -> ToolResult:
        file_path = parameters.get("file_path", "")
        selector = parameters.get("selector", "")
        if not file_path or not selector:
            return ToolResult(success=False, error="file_path and selector are required", tool_name="browser_upload")
        try:
            page = await self._ensure_browser()
            input_element = await page.query_selector(selector)
            if input_element is None:
                return ToolResult(success=False, error=f"Element {selector} not found", tool_name="browser_upload")
            await input_element.set_input_files(file_path)
            return ToolResult(success=True, output=f"Uploaded {file_path} to {selector}", tool_name="browser_upload")
        except NotImplementedError:
            raise
        except Exception as exc:
            return ToolResult(success=False, error=str(exc), tool_name="browser_upload")

    async def _browser_wait(self, parameters: dict[str, Any]) -> ToolResult:
        selector = parameters.get("selector", "")
        timeout = parameters.get("timeout", 10)
        if not selector:
            return ToolResult(success=False, error="selector is required", tool_name="browser_wait")
        try:
            page = await self._ensure_browser()
            await page.wait_for_selector(selector, timeout=timeout * 1000)
            return ToolResult(success=True, output=f"Element {selector} found", tool_name="browser_wait")
        except NotImplementedError:
            raise
        except Exception as exc:
            return ToolResult(success=False, error=str(exc), tool_name="browser_wait")
