import time
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import JSONResponse
from fastapi import status

from src.infrastructure.cache.redis_cache import get_cache_client
from src.infrastructure.logging.logger import get_logger

logger = get_logger(__name__)

# Paths exempt from rate limiting
EXEMPT_PATHS = {"/health", "/docs", "/redoc", "/openapi.json"}
# Different rate limits per endpoint category
RATE_LIMITS = {
    "default": 120,      # 120 req/min for most endpoints
    "auth": 20,          # 20 req/min for auth (login, register)
    "chat": 60,          # 60 req/min for chat
    "analytics": 30,     # 30 req/min for analytics (expensive queries)
    "webhook": 300,      # 300 req/min for webhooks (high volume from Meta/Twilio/Stripe)
}


def _get_rate_limit(path: str) -> int:
    """Determine rate limit based on request path."""
    if path.startswith("/api/v1/auth"):
        return RATE_LIMITS["auth"]
    elif path.startswith("/api/v1/chat"):
        return RATE_LIMITS["chat"]
    elif path.startswith("/api/v1/analytics"):
        return RATE_LIMITS["analytics"]
    elif "/webhook" in path or path.startswith("/api/v1/inbox"):
        return RATE_LIMITS["webhook"]
    return RATE_LIMITS["default"]


class GlobalRateLimitMiddleware(BaseHTTPMiddleware):
    """
    Global Redis-backed rate limiting middleware.
    Uses sliding window counter with per-path limits.
    Fails open (allows request) if Redis is unavailable.
    """

    async def dispatch(self, request: Request, call_next):
        path = request.url.path

        # Skip health checks and docs
        if path in EXEMPT_PATHS or path.startswith("/docs") or path.startswith("/redoc"):
            return await call_next(request)

        client = await get_cache_client()
        if client is None:
            return await call_next(request)

        # Build rate limit key from org_id (if authenticated) + IP + path prefix
        org_id = "anon"
        auth_header = request.headers.get("Authorization", "")
        if auth_header.startswith("Bearer "):
            from src.application.services.auth_service import AuthService
            payload = AuthService.decode_access_token(auth_header.removeprefix("Bearer "))
            if payload:
                org_id = payload.get("org_id", "anon")

        ip = request.client.host if request.client else "unknown"
        path_prefix = "/".join(path.strip("/").split("/")[:3])  # e.g. "api/v1/leads"
        key = f"rl:{ip}:{org_id}:{path_prefix}"

        limit = _get_rate_limit(path)
        window = 60  # seconds

        try:
            # Atomic increment + TTL using pipeline
            async with client.pipeline(transaction=True) as pipe:
                await pipe.incr(key)
                await pipe.expire(key, window)
                results = await pipe.execute()

            current_count = results[0]
            if current_count > limit:
                retry_after = await client.ttl(key)
                logger.warning(
                    "Rate limit exceeded",
                    key=key,
                    current=current_count,
                    limit=limit,
                    path=path,
                )
                return JSONResponse(
                    status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                    content={
                        "detail": "Rate limit exceeded. Please slow down.",
                        "retry_after": max(retry_after, 1),
                        "limit": limit,
                        "window_seconds": window,
                    },
                    headers={"Retry-After": str(max(retry_after, 1))},
                )

            response = await call_next(request)
            # Add rate limit headers
            remaining = max(0, limit - current_count)
            response.headers["X-RateLimit-Limit"] = str(limit)
            response.headers["X-RateLimit-Remaining"] = str(remaining)
            response.headers["X-RateLimit-Reset"] = str(int(time.time()) + window)
            return response

        except Exception as e:
            logger.warning("Rate limiter error, failing open", error=str(e))
            return await call_next(request)
