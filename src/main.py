import asyncio
import time
import uuid as _uuid
from collections.abc import AsyncGenerator
from contextlib import asynccontextmanager
from typing import Any

import structlog
from fastapi import FastAPI, Request, Response, status
from fastapi.responses import JSONResponse, PlainTextResponse
from fastapi.middleware.cors import CORSMiddleware
from starlette.middleware.base import BaseHTTPMiddleware

from src.config import settings
from src.infrastructure.logging.logger import configure_logging, get_logger
from src.infrastructure.cache.redis_cache import get_cache_client, close_cache_client
from src.infrastructure.middleware.rate_limit import GlobalRateLimitMiddleware
from src.infrastructure.metrics.metrics import PrometheusMiddleware, generate_metrics_response
from src.infrastructure.metrics.metrics import cpu_usage_percent, memory_usage_bytes, memory_total_bytes
from src.infrastructure.metrics.metrics import disk_usage_bytes, disk_total_bytes, uptime_seconds
from src.infrastructure.metrics.metrics import leads_total, customers_total, revenue_cents
from src.infrastructure.metrics.metrics import active_conversations, active_subscriptions
from src.infrastructure.metrics.metrics import tenants_total, agents_total
from src.presentation.api.v1.health import router as health_router
from src.presentation.api.v1.auth import router as auth_router
from src.presentation.api.v1.business import router as business_router
from src.presentation.api.v1.documents import router as documents_router
from src.presentation.api.v1.chat import router as chat_router
from src.presentation.api.v1.leads import router as leads_router
from src.presentation.api.v1.customers import router as customers_router
from src.presentation.api.v1.monitoring import router as monitoring_router
from src.presentation.api.v1.dashboard import router as dashboard_router
from src.presentation.api.v1.knowledge_bases import router as knowledge_bases_router
from src.presentation.api.v1.agents import router as agents_router
from src.presentation.api.v1.conversations import router as conversations_router
from src.presentation.api.v1.inbox import router as inbox_router
from src.presentation.api.v1.inbox_ws import router as inbox_ws_router
from src.presentation.api.v1.calls import router as calls_router
from src.presentation.api.v1.memory import router as memory_router
from src.presentation.api.v1.workflows import router as workflows_router
from src.presentation.api.v1.tasks import router as tasks_router
from src.presentation.api.v1.team import router as team_router
from src.presentation.api.v1.billing import router as billing_router
from src.presentation.api.v1.notifications_api import router as notifications_router
from src.presentation.api.v1.settings import router as settings_router
from src.presentation.api.v1.analytics import router as analytics_router
from src.presentation.api.v1.audit_logs import router as audit_logs_router
from src.presentation.api.v1.copilot import router as copilot_router
from src.presentation.api.v1.metrics import router as metrics_router
from src.presentation.api.v1.agent_management import router as agent_management_router
from src.presentation.api.v1.providers import router as providers_router
from src.presentation.api.v1.model_registry import router as model_registry_router
from src.presentation.api.v1.tool_registry import router as tool_registry_router
from src.presentation.api.v1.knowledge_sources import router as knowledge_sources_router
from src.presentation.api.v1.workflow_engine import router as workflow_engine_router
from src.presentation.api.v1.licensing import router as licensing_router
from src.presentation.api.v1.plugins import router as plugins_router
from src.presentation.api.dependencies import ollama_client_singleton

# Initialize structured logging early
configure_logging()
logger = get_logger(__name__)


async def run_migrations() -> None:
    """Run database migrations or create tables for SQLite."""
    try:
        if settings.DATABASE_URL.startswith("sqlite"):
            from src.infrastructure.database.connection import engine
            from src.infrastructure.database.models import Base
            async with engine.begin() as conn:
                await conn.run_sync(Base.metadata.create_all)
            logger.info("SQLite tables created successfully (skipped Alembic)")
        else:
            from alembic.config import Config
            from alembic import command
            alembic_cfg = Config("alembic.ini")
            await asyncio.to_thread(command.upgrade, alembic_cfg, "head")
            logger.info("Alembic migrations completed successfully")
    except Exception as e:
        logger.error("Failed to run database migrations", error=str(e))
        raise


MAX_REQUEST_SIZE = 10 * 1024 * 1024  # 10 MB


class RequestSizeLimitMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next: Any) -> Response:
        content_length = request.headers.get("content-length")
        if content_length and int(content_length) > MAX_REQUEST_SIZE:
            return PlainTextResponse(
                "Request body too large",
                status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            )
        return await call_next(request)


class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next: Any) -> Response:
        response = await call_next(request)
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["X-Frame-Options"] = "DENY"
        response.headers["X-XSS-Protection"] = "1; mode=block"
        response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
        response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
        return response


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncGenerator[None, None]:
    """
    Manages startup and shutdown events for the FastAPI application.
    """
    logger.info("Starting up Nexora Brain services", environment=settings.ENVIRONMENT)

    # Initialize OpenTelemetry (non-blocking, lazy imports)
    if not settings.is_test and settings.is_prod:
        try:
            from src.infrastructure.telemetry.tracing import setup_telemetry as _setup_otel
            from src.infrastructure.telemetry.instrumentation import instrument_app as _instrument_app
            _setup_otel()
            _instrument_app(app)
            logger.info("OpenTelemetry initialized")
        except ImportError as _otel_err:
            logger.warning("OpenTelemetry packages not installed, skipping instrumentation", error=str(_otel_err))
        except Exception as _otel_err:
            logger.warning("OpenTelemetry initialization failed (non-fatal)", error=str(_otel_err))

    # Initialize Redis cache
    await get_cache_client()
    if not settings.is_test:
        await run_migrations()
        try:
            from scripts.seed_plans import seed_plans
            await seed_plans()
        except Exception as e:
            logger.warning("Plan seeding skipped", error=str(e))

    # Background task for system metrics collection
    _update_interval = 15.0
    async def _collect_system_metrics() -> None:
        while True:
            try:
                import psutil as _psutil
                cpu_usage_percent.set(_psutil.cpu_percent(interval=0.1))
                mem = _psutil.virtual_memory()
                memory_usage_bytes.set(mem.used)
                memory_total_bytes.set(mem.total)
                disk = _psutil.disk_usage("/")
                disk_usage_bytes.set(disk.used)
                disk_total_bytes.set(disk.total)
                uptime_seconds.set(time.time() - _start_time)
            except Exception:
                pass
            await asyncio.sleep(_update_interval)

    if not settings.is_test:
        _metrics_task = asyncio.create_task(_collect_system_metrics())

    yield

    logger.info("Shutting down Nexora Brain services")
    await close_cache_client()
    try:
        from src.infrastructure.database.connection import engine
        await engine.dispose()
    except Exception as e:
        logger.warning("Error disposing database engine", error=str(e))
    await ollama_client_singleton.close()


app = FastAPI(
    title=settings.APP_NAME,
    description="Central intelligence layer for WhatsApp & Voice Calling Agents",
    version="1.0.0",
    lifespan=lifespan,
    docs_url="/docs" if not settings.is_prod else None,
    redoc_url="/redoc" if not settings.is_prod else None,
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allow_headers=["Authorization", "Content-Type", "X-Request-ID"],
)

# Security & Limits middleware
app.add_middleware(PrometheusMiddleware)
app.add_middleware(SecurityHeadersMiddleware)
app.add_middleware(RequestSizeLimitMiddleware)
app.add_middleware(GlobalRateLimitMiddleware)


@app.middleware("http")
async def request_logging_middleware(request: Request, call_next: Any) -> Response:
    """
    Logs metadata about incoming requests and their execution time.
    """
    structlog.contextvars.clear_contextvars()
    
    # Generate or propagate correlation identifier
    request_id = request.headers.get("X-Request-ID") or str(_uuid.uuid4())
    structlog.contextvars.bind_contextvars(request_id=request_id)

    start_time = time.perf_counter()
    response = None
    
    try:
        response = await call_next(request)
        process_time = time.perf_counter() - start_time
        logger.info(
            "HTTP Request Processed",
            method=request.method,
            path=request.url.path,
            status_code=response.status_code,
            duration_ms=round(process_time * 1000, 2),
        )
        return response
    except Exception as exc:
        process_time = time.perf_counter() - start_time
        logger.error(
            "HTTP Request Failed",
            method=request.method,
            path=request.url.path,
            error=str(exc),
            duration_ms=round(process_time * 1000, 2),
        )
        return JSONResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            content={"detail": "Internal server error occurred."},
        )

# Custom Global Exception Handlers
@app.exception_handler(Exception)
async def unhandled_exception_handler(request: Request, exc: Exception) -> JSONResponse:
    """
    Catch-all unhandled exceptions handler, preventing stack trace exposure.
    """
    logger.error("Unhandled system error occurred", path=request.url.path, error=str(exc))
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={"detail": "An unexpected error occurred. Please contact system administrators."},
    )


# Route aggregate inclusions
@app.get("/health", tags=["system"])
async def root_health() -> Response:
    """
    Health check endpoint that verifies critical dependencies.
    Returns 200 when healthy, 503 when degraded.
    """
    checks = {}
    overall_status = "healthy"
    status_code = status.HTTP_200_OK

    # Database check
    try:
        from src.infrastructure.database.connection import get_db_session
        from sqlalchemy import text
        async with get_db_session() as session:
            await session.execute(text("SELECT 1"))
        checks["database"] = "healthy"
    except Exception as e:
        checks["database"] = f"unhealthy: {str(e)[:100]}"
        overall_status = "degraded"
        status_code = status.HTTP_503_SERVICE_UNAVAILABLE

    # Redis check
    try:
        cache = await get_cache_client()
        if cache:
            await cache.ping()
            checks["cache"] = "healthy"
        else:
            checks["cache"] = "not_configured"
    except Exception as e:
        checks["cache"] = f"unhealthy: {str(e)[:100]}"
        overall_status = "degraded"
        status_code = status.HTTP_503_SERVICE_UNAVAILABLE

    return JSONResponse(
        status_code=status_code,
        content={"status": overall_status, "checks": checks},
    )


@app.get("/metrics", tags=["monitoring"])
async def prometheus_metrics() -> Response:
    """Prometheus metrics endpoint (unauthenticated for scraping)."""
    return generate_metrics_response()


# Register API v1 endpoint groups
app.include_router(health_router, prefix="/api/v1", tags=["system"])
app.include_router(auth_router, prefix="/api/v1/auth", tags=["authentication"])
app.include_router(business_router, prefix="/api/v1/business", tags=["business"])
app.include_router(documents_router, prefix="/api/v1/documents", tags=["document management"])
app.include_router(chat_router, prefix="/api/v1/chat", tags=["chat engine"])
app.include_router(leads_router, prefix="/api/v1/leads", tags=["leads"])
app.include_router(customers_router, prefix="/api/v1/customers", tags=["customers"])
app.include_router(monitoring_router, prefix="/api/v1/monitoring", tags=["monitoring"])
app.include_router(dashboard_router, prefix="/api/v1/dashboard", tags=["dashboard"])
app.include_router(knowledge_bases_router, prefix="/api/v1/knowledge-bases", tags=["knowledge bases"])
app.include_router(agents_router, prefix="/api/v1/agents", tags=["agents"])
app.include_router(conversations_router, prefix="/api/v1/conversations", tags=["conversations"])
app.include_router(inbox_router, prefix="/api/v1/inbox", tags=["omnichannel inbox"])
app.include_router(inbox_ws_router, prefix="/api/v1/inbox", tags=["omnichannel inbox ws"])
app.include_router(calls_router, prefix="/api/v1/calls", tags=["voice ai"])
app.include_router(memory_router, prefix="/api/v1/memory", tags=["ai memory engine"])
app.include_router(workflows_router, prefix="/api/v1/workflows", tags=["workflow automation"])
app.include_router(tasks_router, prefix="/api/v1/tasks", tags=["task management"])
app.include_router(team_router, prefix="/api/v1/team", tags=["team management"])
app.include_router(billing_router, prefix="/api/v1/billing", tags=["billing & subscriptions"])
app.include_router(notifications_router, prefix="/api/v1/notifications", tags=["notification center"])
app.include_router(settings_router, prefix="/api/v1/settings", tags=["settings center"])
app.include_router(analytics_router, prefix="/api/v1/analytics", tags=["analytics center"])
app.include_router(audit_logs_router, prefix="/api/v1", tags=["audit logs"])
app.include_router(copilot_router, prefix="/api/v1/copilot", tags=["ai copilot"])
app.include_router(metrics_router, prefix="/api/v1", tags=["metrics"])
app.include_router(agent_management_router, prefix="/api/v1/agents", tags=["agent management"])
app.include_router(providers_router, prefix="/api/v1/providers", tags=["provider management"])
app.include_router(model_registry_router, prefix="/api/v1/models", tags=["model registry"])
app.include_router(tool_registry_router, prefix="/api/v1/tools", tags=["tool registry"])
app.include_router(knowledge_sources_router, prefix="/api/v1/knowledge-sources", tags=["knowledge sources"])
app.include_router(workflow_engine_router, prefix="/api/v1/workflow-engine", tags=["workflow engine"])
app.include_router(licensing_router, prefix="/api/v1/license", tags=["licensing"])
app.include_router(plugins_router, prefix="/api/v1/plugins", tags=["plugin sdk"])
