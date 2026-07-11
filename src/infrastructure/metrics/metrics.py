import time
from typing import Any
from prometheus_client import Counter, Histogram, Gauge, Summary, generate_latest, CONTENT_TYPE_LATEST
from prometheus_client import CollectorRegistry, multiprocess
from fastapi import Request, Response
from starlette.middleware.base import BaseHTTPMiddleware

from src.infrastructure.logging.logger import get_logger

logger = get_logger(__name__)

# ─── Registry ────────────────────────────────────────────────────────────
# Use default registry for single-process; multi-process in production
try:
    from prometheus_client import multiprocess
    _registry = CollectorRegistry()
    multiprocess.MultiProcessCollector(_registry)
except Exception:
    _registry = None

def _get_registry():
    return _registry


# ─── HTTP Metrics ────────────────────────────────────────────────────────

http_requests_total = Counter(
    "nexora_http_requests_total",
    "Total HTTP requests",
    ["method", "path", "status_code"],
)

http_request_duration_seconds = Histogram(
    "nexora_http_request_duration_seconds",
    "HTTP request duration in seconds",
    ["method", "path", "status_code"],
    buckets=(0.005, 0.01, 0.025, 0.05, 0.075, 0.1, 0.25, 0.5, 0.75, 1.0, 2.5, 5.0, 7.5, 10.0, 30.0, 60.0),
)

http_request_size_bytes = Summary(
    "nexora_http_request_size_bytes",
    "HTTP request size in bytes",
    ["method", "path"],
)

http_response_size_bytes = Summary(
    "nexora_http_response_size_bytes",
    "HTTP response size in bytes",
    ["method", "path"],
)

http_active_requests = Gauge(
    "nexora_http_active_requests",
    "Number of active HTTP requests",
    ["method"],
)


# ─── Database Metrics ────────────────────────────────────────────────────

db_query_duration_seconds = Histogram(
    "nexora_db_query_duration_seconds",
    "Database query duration in seconds",
    ["operation", "table"],
    buckets=(0.001, 0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0),
)

db_query_total = Counter(
    "nexora_db_query_total",
    "Total database queries",
    ["operation", "table", "status"],
)

db_connection_pool_size = Gauge(
    "nexora_db_connection_pool_size",
    "Database connection pool size",
    ["pool"],
)

db_connection_pool_available = Gauge(
    "nexora_db_connection_pool_available",
    "Available database connections",
    ["pool"],
)


# ─── Redis Metrics ────────────────────────────────────────────────────────

redis_operation_duration_seconds = Histogram(
    "nexora_redis_operation_duration_seconds",
    "Redis operation duration in seconds",
    ["operation"],
    buckets=(0.001, 0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5),
)

redis_operation_total = Counter(
    "nexora_redis_operation_total",
    "Total Redis operations",
    ["operation", "status"],
)


# ─── LLM Metrics ─────────────────────────────────────────────────────────

llm_requests_total = Counter(
    "nexora_llm_requests_total",
    "Total LLM requests",
    ["model", "operation", "status"],
)

llm_request_duration_seconds = Histogram(
    "nexora_llm_request_duration_seconds",
    "LLM request duration in seconds",
    ["model", "operation"],
    buckets=(0.1, 0.5, 1.0, 2.5, 5.0, 10.0, 30.0, 60.0, 120.0, 300.0),
)

llm_tokens_total = Counter(
    "nexora_llm_tokens_total",
    "Total LLM tokens used",
    ["model", "type"],
)

llm_health_status = Gauge(
    "nexora_ollama_health_status",
    "Ollama health check status (1=up, 0=down)",
)


# ─── Business Metrics ────────────────────────────────────────────────────

leads_total = Counter(
    "nexora_leads_total",
    "Total number of leads created",
)

customers_total = Counter(
    "nexora_customers_total",
    "Total number of customers converted",
)

active_conversations = Gauge(
    "nexora_active_conversations",
    "Number of active conversations",
)

revenue_cents = Counter(
    "nexora_revenue_cents",
    "Total revenue in cents",
)

active_subscriptions = Gauge(
    "nexora_active_subscriptions",
    "Number of active subscriptions",
)

tenants_total = Gauge(
    "nexora_tenants_total",
    "Total number of tenant organizations",
)

agents_total = Gauge(
    "nexora_agents_total",
    "Total number of registered agents",
)


# ─── Queue / Worker Metrics ──────────────────────────────────────────────

queue_depth = Gauge(
    "nexora_queue_depth",
    "Background job queue depth",
    ["queue"],
)

worker_status = Gauge(
    "nexora_worker_status",
    "Worker status (1=active, 0=idle)",
    ["worker"],
)

job_duration_seconds = Histogram(
    "nexora_job_duration_seconds",
    "Background job duration in seconds",
    ["job_name", "status"],
    buckets=(0.1, 0.5, 1.0, 2.5, 5.0, 10.0, 30.0, 60.0, 120.0, 300.0),
)


# ─── System Metrics ──────────────────────────────────────────────────────

cpu_usage_percent = Gauge(
    "nexora_cpu_usage_percent",
    "Current CPU usage percentage",
)

memory_usage_bytes = Gauge(
    "nexora_memory_usage_bytes",
    "Current memory usage in bytes",
)

memory_total_bytes = Gauge(
    "nexora_memory_total_bytes",
    "Total memory in bytes",
)

disk_usage_bytes = Gauge(
    "nexora_disk_usage_bytes",
    "Current disk usage in bytes",
)

disk_total_bytes = Gauge(
    "nexora_disk_total_bytes",
    "Total disk in bytes",
)

uptime_seconds = Gauge(
    "nexora_uptime_seconds",
    "Application uptime in seconds",
)


# ─── Metrics Middleware ──────────────────────────────────────────────────

class PrometheusMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next: Any) -> Response:
        method = request.method
        path = _get_route_path(request)

        http_active_requests.labels(method=method).inc()

        # Request size
        content_length = request.headers.get("content-length", 0)
        try:
            http_request_size_bytes.labels(method=method, path=path).observe(int(content_length))
        except (ValueError, TypeError):
            pass

        start = time.perf_counter()
        try:
            response = await call_next(request)
            status_code = response.status_code
        except Exception as exc:
            status_code = 500
            raise
        finally:
            duration = time.perf_counter() - start
            status_group = f"{status_code // 100}xx"
            http_requests_total.labels(method=method, path=path, status_code=status_group).inc()
            http_request_duration_seconds.labels(method=method, path=path, status_code=status_group).observe(duration)

            response_size = response.headers.get("content-length", 0) if "response" in dir() else 0
            try:
                http_response_size_bytes.labels(method=method, path=path).observe(int(response_size))
            except (ValueError, TypeError):
                pass

            http_active_requests.labels(method=method).dec()

            logger.debug(
                "Request metrics recorded",
                method=method,
                path=path,
                status=status_code,
                duration_ms=round(duration * 1000, 2),
            )

        return response


def _get_route_path(request: Request) -> str:
    """Get a normalized route path for metrics labeling."""
    try:
        route = request.scope.get("route")
        if route and hasattr(route, "path"):
            return route.path
    except Exception:
        pass
    return request.url.path


def generate_metrics_response() -> Response:
    """Generate Prometheus metrics response."""
    from fastapi.responses import PlainTextResponse
    try:
        if _registry:
            data = generate_latest(_registry)
        else:
            data = generate_latest()
        return PlainTextResponse(content=data.decode(), media_type=CONTENT_TYPE_LATEST)
    except Exception as e:
        logger.error("Failed to generate metrics", error=str(e))
        return PlainTextResponse(
            content=f"# Error generating metrics: {e}",
            media_type="text/plain",
            status_code=500,
        )
