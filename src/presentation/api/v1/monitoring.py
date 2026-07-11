from fastapi import APIRouter, Depends, status
from pydantic import BaseModel
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from src.config import settings
from src.infrastructure.database.connection import get_db_session
from src.infrastructure.llm.ollama_client import OllamaClient
from src.infrastructure.logging.logger import get_logger

logger = get_logger(__name__)

router = APIRouter()

_ollama_health_client: OllamaClient | None = None


def _get_ollama_health_client() -> OllamaClient:
    global _ollama_health_client
    if _ollama_health_client is None:
        _ollama_health_client = OllamaClient(timeout=3, max_retries=0)
    return _ollama_health_client


class SystemHealthDetail(BaseModel):
    database: str
    ollama: str
    qdrant: str
    overall: str


@router.get("/health/details", response_model=SystemHealthDetail, status_code=status.HTTP_200_OK)
async def check_full_health(db: AsyncSession = Depends(get_db_session)) -> SystemHealthDetail:
    """
    Detailed health check probing Postgres connection status, Qdrant API availability,
    and the local Ollama LLM cluster responsive state.
    """
    # 1. Probe PostgreSQL
    db_status = "healthy"
    try:
        await db.execute(text("SELECT 1"))
    except Exception as e:
        logger.error("Health probe failed on Postgres query execution", error=str(e))
        db_status = "unhealthy"

    # 2. Probe Ollama
    ollama_status = "healthy"
    try:
        client = _get_ollama_health_client()
        is_healthy = await client.health_check()
        if not is_healthy:
            ollama_status = "unhealthy"
    except Exception as e:
        logger.error("Health probe failed on Ollama connection", error=str(e))
        ollama_status = "unhealthy"

    # 3. Probe Qdrant
    qdrant_status = "healthy"
    try:
        import httpx
        async with httpx.AsyncClient(timeout=3.0) as client:
            resp = await client.get(settings.QDRANT_URL)
            if resp.status_code != 200:
                qdrant_status = "unhealthy"
    except Exception as e:
        logger.error("Health probe failed on Qdrant socket link", error=str(e))
        qdrant_status = "unhealthy"

    # Evaluate overall status
    overall_status = "healthy"
    if db_status == "unhealthy" or ollama_status == "unhealthy" or qdrant_status == "unhealthy":
        overall_status = "degraded"

    return SystemHealthDetail(
        database=db_status,
        ollama=ollama_status,
        qdrant=qdrant_status,
        overall=overall_status
    )
