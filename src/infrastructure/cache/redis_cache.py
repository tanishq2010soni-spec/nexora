import json
import hashlib
from typing import Any, Optional
import redis.asyncio as aioredis

from src.config import settings
from src.infrastructure.logging.logger import get_logger

logger = get_logger(__name__)

_cache_client: Optional[aioredis.Redis] = None


async def get_cache_client() -> Optional[aioredis.Redis]:
    """Get or initialize the Redis cache client."""
    global _cache_client
    if _cache_client is None:
        try:
            _cache_client = aioredis.from_url(
                settings.REDIS_URL,
                decode_responses=True,
                max_connections=20,
            )
            await _cache_client.ping()
            logger.info("Redis cache client connected")
        except Exception as e:
            logger.warning("Redis cache unavailable, caching disabled", error=str(e))
            _cache_client = None
    return _cache_client


async def close_cache_client() -> None:
    """Close the Redis cache client on shutdown."""
    global _cache_client
    if _cache_client is not None:
        await _cache_client.close()
        _cache_client = None


def _make_cache_key(prefix: str, *args: Any, **kwargs: Any) -> str:
    """Generate a deterministic cache key from prefix and arguments."""
    raw = json.dumps({"args": [str(a) for a in args], "kwargs": {k: str(v) for k, v in kwargs.items()}}, sort_keys=True)
    h = hashlib.sha256(raw.encode()).hexdigest()[:16]
    return f"cache:{prefix}:{h}"


async def cache_get(key: str) -> Optional[Any]:
    """Get a value from cache. Returns None on miss or if Redis is unavailable."""
    client = await get_cache_client()
    if client is None:
        return None
    try:
        raw = await client.get(key)
        if raw is None:
            return None
        return json.loads(raw)
    except Exception as e:
        logger.warning("Cache get error", key=key, error=str(e))
        return None


async def cache_set(key: str, value: Any, ttl_seconds: int = 300) -> bool:
    """Set a value in cache with TTL. Returns True on success."""
    client = await get_cache_client()
    if client is None:
        return False
    try:
        serialized = json.dumps(value, default=str)
        await client.setex(key, ttl_seconds, serialized)
        return True
    except Exception as e:
        logger.warning("Cache set error", key=key, error=str(e))
        return False


async def cache_delete(key: str) -> bool:
    """Delete a key from cache."""
    client = await get_cache_client()
    if client is None:
        return False
    try:
        await client.delete(key)
        return True
    except Exception as e:
        logger.warning("Cache delete error", key=key, error=str(e))
        return False


async def cache_delete_pattern(pattern: str) -> int:
    """Delete all keys matching a pattern. Returns count of deleted keys."""
    client = await get_cache_client()
    if client is None:
        return 0
    try:
        cursor = 0
        deleted = 0
        while True:
            cursor, keys = await client.scan(cursor=cursor, match=pattern, count=100)
            if keys:
                deleted += await client.delete(*keys)
            if cursor == 0:
                break
        return deleted
    except Exception as e:
        logger.warning("Cache delete pattern error", pattern=pattern, error=str(e))
        return 0


async def cache_health_check() -> dict:
    """Check Redis cache health status."""
    client = await get_cache_client()
    if client is None:
        return {"status": "disconnected", "message": "Redis cache not initialized"}
    try:
        pong = await client.ping()
        info = await client.info("memory")
        return {
            "status": "healthy",
            "ping": pong,
            "used_memory_human": info.get("used_memory_human", "unknown"),
            "connected_clients": info.get("connected_clients", 0),
        }
    except Exception as e:
        return {"status": "unhealthy", "error": str(e)}


class CachedQuery:
    """Decorator for caching async query results."""

    def __init__(self, prefix: str, ttl: int = 300):
        self.prefix = prefix
        self.ttl = ttl

    def __call__(self, func):
        async def wrapper(*args, **kwargs):
            key = _make_cache_key(self.prefix, *args, **kwargs)
            cached = await cache_get(key)
            if cached is not None:
                return cached
            result = await func(*args, **kwargs)
            if result is not None:
                await cache_set(key, result, self.ttl)
            return result
        wrapper.__name__ = func.__name__
        wrapper.__doc__ = func.__doc__
        return wrapper
