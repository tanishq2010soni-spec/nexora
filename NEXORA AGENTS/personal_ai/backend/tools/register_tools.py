from __future__ import annotations

from typing import Any

from nexora_ai.domain.entities.tool import ToolDefinition, ToolParameter
from nexora_ai.domain.enums.tool_enums import ToolCategory, ToolPermission, ToolStatus
from nexora_ai.infrastructure.tools.tool_registry import ToolRegistry


async def register_all_tools(
    tool_registry: ToolRegistry,
    services_dict: dict[str, Any],
) -> None:
    desktop = services_dict.get("desktop_controller")
    screen = services_dict.get("screen_capture")
    file_intel = services_dict.get("file_intelligence")
    browser = services_dict.get("browser_controller")

    desktop_tools: list[ToolDefinition] = [
        ToolDefinition(
            name="open_app",
            description="Open an application by executable path or name",
            category=ToolCategory.DESKTOP,
            permissions=[ToolPermission.EXECUTE],
            parameters=[
                ToolParameter(name="path", type="string", description="Path to the application", required=True),
            ],
        ),
        ToolDefinition(
            name="close_app",
            description="Close an application by process name",
            category=ToolCategory.DESKTOP,
            permissions=[ToolPermission.EXECUTE],
            parameters=[
                ToolParameter(name="name", type="string", description="Process name (e.g. notepad.exe)", required=True),
            ],
        ),
        ToolDefinition(
            name="focus_window",
            description="Bring a window to foreground by title",
            category=ToolCategory.DESKTOP,
            permissions=[ToolPermission.WRITE],
            parameters=[
                ToolParameter(name="title", type="string", description="Window title", required=True),
            ],
        ),
        ToolDefinition(
            name="move_window",
            description="Move and resize a window by title",
            category=ToolCategory.DESKTOP,
            permissions=[ToolPermission.WRITE],
            parameters=[
                ToolParameter(name="title", type="string", description="Window title", required=True),
                ToolParameter(name="x", type="integer", description="X position", required=False, default=0),
                ToolParameter(name="y", type="integer", description="Y position", required=False, default=0),
                ToolParameter(name="w", type="integer", description="Width", required=False, default=800),
                ToolParameter(name="h", type="integer", description="Height", required=False, default=600),
            ],
        ),
        ToolDefinition(
            name="get_mouse_position",
            description="Get current mouse cursor coordinates",
            category=ToolCategory.DESKTOP,
            permissions=[ToolPermission.READ],
        ),
        ToolDefinition(
            name="move_mouse",
            description="Move mouse cursor to specified coordinates",
            category=ToolCategory.DESKTOP,
            permissions=[ToolPermission.WRITE],
            parameters=[
                ToolParameter(name="x", type="integer", description="X coordinate", required=True),
                ToolParameter(name="y", type="integer", description="Y coordinate", required=True),
            ],
        ),
        ToolDefinition(
            name="click",
            description="Perform a left mouse click at current position",
            category=ToolCategory.DESKTOP,
            permissions=[ToolPermission.WRITE],
        ),
        ToolDefinition(
            name="double_click",
            description="Perform a double left click at current position",
            category=ToolCategory.DESKTOP,
            permissions=[ToolPermission.WRITE],
        ),
        ToolDefinition(
            name="right_click",
            description="Perform a right mouse click at current position",
            category=ToolCategory.DESKTOP,
            permissions=[ToolPermission.WRITE],
        ),
        ToolDefinition(
            name="type_text",
            description="Type text at the currently focused element",
            category=ToolCategory.DESKTOP,
            permissions=[ToolPermission.WRITE],
            parameters=[
                ToolParameter(name="text", type="string", description="Text to type", required=True),
            ],
        ),
        ToolDefinition(
            name="press_key",
            description="Press a keyboard key",
            category=ToolCategory.DESKTOP,
            permissions=[ToolPermission.WRITE],
            parameters=[
                ToolParameter(name="key", type="string", description="Key name (enter, tab, escape, etc.)", required=True),
            ],
        ),
        ToolDefinition(
            name="get_clipboard",
            description="Get current clipboard content",
            category=ToolCategory.DESKTOP,
            permissions=[ToolPermission.READ],
        ),
        ToolDefinition(
            name="set_clipboard",
            description="Set clipboard content",
            category=ToolCategory.DESKTOP,
            permissions=[ToolPermission.WRITE],
            parameters=[
                ToolParameter(name="text", type="string", description="Text to set", required=True),
            ],
        ),
        ToolDefinition(
            name="show_notification",
            description="Show a desktop notification",
            category=ToolCategory.DESKTOP,
            permissions=[ToolPermission.WRITE],
            parameters=[
                ToolParameter(name="title", type="string", description="Notification title", required=False, default="Personal AI"),
                ToolParameter(name="message", type="string", description="Notification message", required=True),
            ],
        ),
        ToolDefinition(
            name="get_active_window",
            description="Get information about the active foreground window",
            category=ToolCategory.DESKTOP,
            permissions=[ToolPermission.READ],
        ),
        ToolDefinition(
            name="list_windows",
            description="List all visible desktop windows",
            category=ToolCategory.DESKTOP,
            permissions=[ToolPermission.READ],
        ),
        ToolDefinition(
            name="take_screenshot",
            description="Take a screenshot of the entire screen",
            category=ToolCategory.DESKTOP,
            permissions=[ToolPermission.READ],
            parameters=[
                ToolParameter(name="path", type="string", description="Optional file path to save screenshot", required=False, default=""),
            ],
        ),
        ToolDefinition(
            name="run_terminal",
            description="Run a terminal/shell command",
            category=ToolCategory.DESKTOP,
            permissions=[ToolPermission.EXECUTE],
            parameters=[
                ToolParameter(name="command", type="string", description="Command to execute", required=True),
            ],
        ),
        ToolDefinition(
            name="run_powershell",
            description="Run a PowerShell script",
            category=ToolCategory.DESKTOP,
            permissions=[ToolPermission.EXECUTE],
            parameters=[
                ToolParameter(name="script", type="string", description="PowerShell script to execute", required=True),
            ],
        ),
        ToolDefinition(
            name="run_python",
            description="Run Python code",
            category=ToolCategory.DESKTOP,
            permissions=[ToolPermission.EXECUTE],
            parameters=[
                ToolParameter(name="code", type="string", description="Python code to execute", required=True),
            ],
        ),
        ToolDefinition(
            name="open_file_explorer",
            description="Open Windows File Explorer to a path",
            category=ToolCategory.DESKTOP,
            permissions=[ToolPermission.EXECUTE],
            parameters=[
                ToolParameter(name="path", type="string", description="Directory path to open", required=True),
            ],
        ),
    ]

    screen_tools: list[ToolDefinition] = [
        ToolDefinition(
            name="capture_screen",
            description="Capture the full screen as PNG image bytes",
            category=ToolCategory.DESKTOP,
            permissions=[ToolPermission.READ],
        ),
        ToolDefinition(
            name="ocr_region",
            description="Perform OCR on a screen region and return text",
            category=ToolCategory.DESKTOP,
            permissions=[ToolPermission.READ],
            parameters=[
                ToolParameter(name="x", type="integer", description="X coordinate", required=False, default=0),
                ToolParameter(name="y", type="integer", description="Y coordinate", required=False, default=0),
                ToolParameter(name="w", type="integer", description="Width", required=False, default=100),
                ToolParameter(name="h", type="integer", description="Height", required=False, default=100),
            ],
        ),
        ToolDefinition(
            name="detect_windows",
            description="Detect visible windows on the screen",
            category=ToolCategory.DESKTOP,
            permissions=[ToolPermission.READ],
        ),
        ToolDefinition(
            name="detect_buttons",
            description="Detect buttons in a screen region",
            category=ToolCategory.DESKTOP,
            permissions=[ToolPermission.READ],
        ),
        ToolDefinition(
            name="detect_text",
            description="Detect text in a screen region using OCR",
            category=ToolCategory.DESKTOP,
            permissions=[ToolPermission.READ],
            parameters=[
                ToolParameter(name="x", type="integer", description="X coordinate", required=False, default=0),
                ToolParameter(name="y", type="integer", description="Y coordinate", required=False, default=0),
                ToolParameter(name="w", type="integer", description="Width", required=False, default=800),
                ToolParameter(name="h", type="integer", description="Height", required=False, default=600),
            ],
        ),
        ToolDefinition(
            name="get_element_at",
            description="Get UI element information at screen coordinates",
            category=ToolCategory.DESKTOP,
            permissions=[ToolPermission.READ],
            parameters=[
                ToolParameter(name="x", type="integer", description="X coordinate", required=True),
                ToolParameter(name="y", type="integer", description="Y coordinate", required=True),
            ],
        ),
    ]

    file_tools: list[ToolDefinition] = [
        ToolDefinition(
            name="read_file",
            description="Read a text file's content",
            category=ToolCategory.FILESYSTEM,
            permissions=[ToolPermission.READ],
            parameters=[
                ToolParameter(name="path", type="string", description="File path", required=True),
            ],
        ),
        ToolDefinition(
            name="read_pdf",
            description="Read and extract text from a PDF file",
            category=ToolCategory.FILESYSTEM,
            permissions=[ToolPermission.READ],
            parameters=[
                ToolParameter(name="path", type="string", description="File path", required=True),
            ],
        ),
        ToolDefinition(
            name="read_docx",
            description="Read text from a DOCX file",
            category=ToolCategory.FILESYSTEM,
            permissions=[ToolPermission.READ],
            parameters=[
                ToolParameter(name="path", type="string", description="File path", required=True),
            ],
        ),
        ToolDefinition(
            name="read_excel",
            description="Read data from an Excel file",
            category=ToolCategory.FILESYSTEM,
            permissions=[ToolPermission.READ],
            parameters=[
                ToolParameter(name="path", type="string", description="File path", required=True),
            ],
        ),
        ToolDefinition(
            name="read_csv",
            description="Read data from a CSV file",
            category=ToolCategory.FILESYSTEM,
            permissions=[ToolPermission.READ],
            parameters=[
                ToolParameter(name="path", type="string", description="File path", required=True),
            ],
        ),
        ToolDefinition(
            name="read_markdown",
            description="Read a Markdown file's content",
            category=ToolCategory.FILESYSTEM,
            permissions=[ToolPermission.READ],
            parameters=[
                ToolParameter(name="path", type="string", description="File path", required=True),
            ],
        ),
        ToolDefinition(
            name="read_json",
            description="Read and parse a JSON file",
            category=ToolCategory.FILESYSTEM,
            permissions=[ToolPermission.READ],
            parameters=[
                ToolParameter(name="path", type="string", description="File path", required=True),
            ],
        ),
        ToolDefinition(
            name="list_directory",
            description="List contents of a directory",
            category=ToolCategory.FILESYSTEM,
            permissions=[ToolPermission.READ],
            parameters=[
                ToolParameter(name="path", type="string", description="Directory path", required=True),
            ],
        ),
        ToolDefinition(
            name="get_file_info",
            description="Get metadata and information about a file",
            category=ToolCategory.FILESYSTEM,
            permissions=[ToolPermission.READ],
            parameters=[
                ToolParameter(name="path", type="string", description="File path", required=True),
            ],
        ),
        ToolDefinition(
            name="search_files",
            description="Search for files by name pattern",
            category=ToolCategory.FILESYSTEM,
            permissions=[ToolPermission.READ],
            parameters=[
                ToolParameter(name="query", type="string", description="Search query (partial filename match)", required=True),
                ToolParameter(name="path", type="string", description="Root directory to search", required=False, default=""),
            ],
        ),
    ]

    browser_tools: list[ToolDefinition] = [
        ToolDefinition(
            name="browser_navigate",
            description="Navigate browser to a URL",
            category=ToolCategory.BROWSER,
            permissions=[ToolPermission.WRITE],
            parameters=[
                ToolParameter(name="url", type="string", description="URL to navigate to", required=True),
            ],
        ),
        ToolDefinition(
            name="browser_click",
            description="Click on a page element by CSS selector",
            category=ToolCategory.BROWSER,
            permissions=[ToolPermission.WRITE],
            parameters=[
                ToolParameter(name="selector", type="string", description="CSS selector", required=True),
            ],
        ),
        ToolDefinition(
            name="browser_type",
            description="Type text into an input element",
            category=ToolCategory.BROWSER,
            permissions=[ToolPermission.WRITE],
            parameters=[
                ToolParameter(name="selector", type="string", description="CSS selector", required=True),
                ToolParameter(name="text", type="string", description="Text to type", required=True),
            ],
        ),
        ToolDefinition(
            name="browser_get_text",
            description="Get text content of an element by CSS selector",
            category=ToolCategory.BROWSER,
            permissions=[ToolPermission.READ],
            parameters=[
                ToolParameter(name="selector", type="string", description="CSS selector", required=True),
            ],
        ),
        ToolDefinition(
            name="browser_get_html",
            description="Get full page HTML content",
            category=ToolCategory.BROWSER,
            permissions=[ToolPermission.READ],
        ),
        ToolDefinition(
            name="browser_screenshot",
            description="Take a screenshot of the current browser page",
            category=ToolCategory.BROWSER,
            permissions=[ToolPermission.READ],
        ),
        ToolDefinition(
            name="browser_get_title",
            description="Get the current page title",
            category=ToolCategory.BROWSER,
            permissions=[ToolPermission.READ],
        ),
        ToolDefinition(
            name="browser_get_url",
            description="Get the current page URL",
            category=ToolCategory.BROWSER,
            permissions=[ToolPermission.READ],
        ),
        ToolDefinition(
            name="browser_back",
            description="Navigate browser back",
            category=ToolCategory.BROWSER,
            permissions=[ToolPermission.WRITE],
        ),
        ToolDefinition(
            name="browser_forward",
            description="Navigate browser forward",
            category=ToolCategory.BROWSER,
            permissions=[ToolPermission.WRITE],
        ),
        ToolDefinition(
            name="browser_refresh",
            description="Refresh the current page",
            category=ToolCategory.BROWSER,
            permissions=[ToolPermission.WRITE],
        ),
        ToolDefinition(
            name="browser_download",
            description="Download a file from a URL to local path",
            category=ToolCategory.BROWSER,
            permissions=[ToolPermission.WRITE],
            parameters=[
                ToolParameter(name="url", type="string", description="Download URL", required=True),
                ToolParameter(name="path", type="string", description="Local file path to save", required=True),
            ],
        ),
        ToolDefinition(
            name="browser_upload",
            description="Upload a file to a form element",
            category=ToolCategory.BROWSER,
            permissions=[ToolPermission.WRITE],
            parameters=[
                ToolParameter(name="file_path", type="string", description="Local file path", required=True),
                ToolParameter(name="selector", type="string", description="CSS selector of file input", required=True),
            ],
        ),
        ToolDefinition(
            name="browser_wait",
            description="Wait for an element to appear on the page",
            category=ToolCategory.BROWSER,
            permissions=[ToolPermission.READ],
            parameters=[
                ToolParameter(name="selector", type="string", description="CSS selector", required=True),
                ToolParameter(name="timeout", type="integer", description="Timeout in seconds", required=False, default=10),
            ],
        ),
    ]

    for tool_def in desktop_tools:
        await tool_registry.register(tool_def)
    for tool_def in screen_tools:
        await tool_registry.register(tool_def)
    for tool_def in file_tools:
        await tool_registry.register(tool_def)
    for tool_def in browser_tools:
        await tool_registry.register(tool_def)
