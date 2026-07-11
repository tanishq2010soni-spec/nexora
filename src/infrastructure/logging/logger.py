import logging
import sys
from typing import Any
import structlog
from structlog.types import Processor

from src.config import settings


def configure_logging() -> None:
    """
    Configures structlog to output structured JSON logs in production,
    and human-readable colorized logs in development environments.
    """
    log_level = logging.INFO
    if settings.LOG_LEVEL.lower() == "debug":
        log_level = logging.DEBUG
    elif settings.LOG_LEVEL.lower() == "warning":
        log_level = logging.WARNING
    elif settings.LOG_LEVEL.lower() == "error":
        log_level = logging.ERROR

    # Common processors for both JSON and Console logs
    shared_processors: list[Processor] = [
        structlog.contextvars.merge_contextvars,
        structlog.processors.add_log_level,
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.StackInfoRenderer(),
        structlog.processors.format_exc_info,
    ]

    if settings.is_prod:
        # Production output format: Structured JSON
        processors = shared_processors + [
            structlog.processors.JSONRenderer()
        ]
    else:
        # Development output format: Pretty-printed console logs
        processors = shared_processors + [
            structlog.dev.ConsoleRenderer(colors=True)
        ]

    structlog.configure(
        processors=processors,
        logger_factory=structlog.PrintLoggerFactory(),
        wrapper_class=structlog.make_filtering_bound_logger(log_level),
        cache_logger_on_first_use=True,
    )

    # Re-direct standard library logging to structlog
    logging.basicConfig(
        format="%(message)s",
        stream=sys.stdout,
        level=log_level,
    )


def get_logger(name: str) -> Any:
    """
    Returns a configured structlog logger.
    """
    return structlog.get_logger(name)
