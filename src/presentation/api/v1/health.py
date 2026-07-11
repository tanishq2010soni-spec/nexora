from fastapi import APIRouter, Depends, status
from pydantic import BaseModel, Field
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from src.config import settings
from src.infrastructure.database.connection import get_db_session
from src.infrastructure.cache.redis_cache import cache_health_check
from src.infrastructure.logging.logger import get_logger

logger = get_logger(__name__)

router = APIRouter()


class HealthResponse(BaseModel):
    status: str = Field(..., description="Overall status of the application")
    database: str = Field(..., description="Connectivity status of the database")
    cache: str = Field(default="unknown", description="Redis cache status")
    environment: str = Field(..., description="Current deployment environment")


class DetailedHealthResponse(BaseModel):
    status: str
    database: dict
    cache: dict
    environment: str
    version: str
    uptime: str


@router.get("/health", response_model=HealthResponse, status_code=status.HTTP_200_OK)
async def health_check(db: AsyncSession = Depends(get_db_session)) -> HealthResponse:
    """
    Performs system health check, querying the database and Redis cache.
    """
    db_status = "healthy"
    try:
        await db.execute(text("SELECT 1"))
    except Exception as e:
        logger.error("Health check failed on database connection", error=str(e))
        db_status = "unhealthy"

    cache_result = await cache_health_check()
    cache_status = cache_result.get("status", "unknown")

    overall_status = "healthy"
    if db_status == "unhealthy":
        overall_status = "degraded"
    if cache_status == "unhealthy":
        overall_status = "degraded"

    return HealthResponse(
        status=overall_status,
        database=db_status,
        cache=cache_status,
        environment=settings.ENVIRONMENT,
    )


@router.get("/health/detailed", response_model=DetailedHealthResponse, status_code=status.HTTP_200_OK)
async def health_check_detailed(db: AsyncSession = Depends(get_db_session)) -> DetailedHealthResponse:
    """
    Detailed health check including all subsystem statuses.
    """
    # Database check
    db_info = {"status": "healthy", "latency_ms": 0}
    try:
        import time
        start = time.perf_counter()
        await db.execute(text("SELECT 1"))
        db_info["latency_ms"] = round((time.perf_counter() - start) * 1000, 2)
    except Exception as e:
        db_info = {"status": "unhealthy", "error": str(e)}

    # Cache check
    cache_info = await cache_health_check()

    # Overall status
    statuses = [db_info["status"], cache_info["status"]]
    if all(s == "healthy" for s in statuses):
        overall = "healthy"
    elif any(s == "unhealthy" for s in statuses):
        overall = "degraded"
    else:
        overall = "healthy"

    return DetailedHealthResponse(
        status=overall,
        database=db_info,
        cache=cache_info,
        environment=settings.ENVIRONMENT,
        version="1.0.0",
        uptime="running",
    )
