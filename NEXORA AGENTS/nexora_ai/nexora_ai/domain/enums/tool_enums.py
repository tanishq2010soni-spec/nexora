from enum import Enum


class ToolCategory(str, Enum):
    UTILITY = "utility"
    FILESYSTEM = "filesystem"
    TERMINAL = "terminal"
    PYTHON = "python"
    POWERSHELL = "powershell"
    BROWSER = "browser"
    CLIPBOARD = "clipboard"
    EMAIL = "email"
    CALENDAR = "calendar"
    VISION = "vision"
    OCR = "ocr"
    DESKTOP = "desktop"
    MOUSE = "mouse"
    KEYBOARD = "keyboard"
    CAMERA = "camera"
    MICROPHONE = "microphone"
    NETWORK_HTTP = "network_http"
    NETWORK_WS = "network_ws"
    CUSTOM = "custom"


class ToolExecutionMode(str, Enum):
    SYNC = "sync"
    ASYNC = "async"
    STREAMING = "streaming"


class ToolPermission(str, Enum):
    READ = "read"
    WRITE = "write"
    EXECUTE = "execute"
    ADMIN = "admin"
    NONE = "none"


class ToolStatus(str, Enum):
    INSTALLED = "installed"
    UNINSTALLED = "uninstalled"
    DISABLED = "disabled"
    ERROR = "error"
    UPDATING = "updating"
