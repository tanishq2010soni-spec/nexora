"""OpenTelemetry instrumentation for all libraries."""

import os
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from opentelemetry.instrumentation.sqlalchemy import SQLAlchemyInstrumentor
from opentelemetry.instrumentation.httpx import HTTPXClientInstrumentor
from opentelemetry.instrumentation.redis import RedisInstrumentor
from opentelemetry.instrumentation.logging import LoggingInstrumentor

from src.infrastructure.logging.logger import get_logger

logger = get_logger(__name__)


def instrument_app(app: Any) -> None:
    """Instrument all libraries for distributed tracing."""
    otlp_enabled = bool(os.environ.get("OTEL_EXPORTER_OTLP_ENDPOINT"))

    try:
        # FastAPI
        FastAPIInstrumentor.instrument_app(app, tracer_provider=trace.get_tracer_provider())
        logger.info("FastAPI instrumented for OpenTelemetry")
    except Exception as e:
        logger.warning("Failed to instrument FastAPI", error=str(e))

    try:
        # SQLAlchemy (instrumented at engine level)
        from src.infrastructure.database.connection import engine
        SQLAlchemyInstrumentor().instrument(
            engine=engine.sync_engine,
            tracer_provider=trace.get_tracer_provider(),
        )
        logger.info("SQLAlchemy instrumented for OpenTelemetry")
    except Exception as e:
        logger.warning("Failed to instrument SQLAlchemy", error=str(e))

    try:
        HTTPXClientInstrumentor().instrument(tracer_provider=trace.get_tracer_provider())
        logger.info("httpx instrumented for OpenTelemetry")
    except Exception as e:
        logger.warning("Failed to instrument httpx", error=str(e))

    try:
        RedisInstrumentor().instrument(tracer_provider=trace.get_tracer_provider())
        logger.info("Redis instrumented for OpenTelemetry")
    except Exception as e:
        logger.warning("Failed to instrument Redis", error=str(e))

    try:
        LoggingInstrumentor().instrument(set_logging_format=True)
        logger.info("Logging instrumented for OpenTelemetry")
    except Exception as e:
        logger.warning("Failed to instrument logging", error=str(e))

    logger.info("OpenTelemetry instrumentation complete", otlp_enabled=otlp_enabled)
