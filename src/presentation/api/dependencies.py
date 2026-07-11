import uuid
from typing import Optional
from fastapi import Depends, HTTPException, status, Request
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.ext.asyncio import AsyncSession
import redis.asyncio as aioredis

from src.config import settings
from src.application.services.auth_service import AuthService
from src.application.services.document_service import DocumentService
from src.application.services.rag_service import RAGService
from src.infrastructure.database.connection import get_db_session
from src.infrastructure.database.repositories import (
    SQLAlchemyCustomerRepository,
    SQLAlchemyLeadRepository,
)
from src.infrastructure.embeddings.transformer_embeddings import SentenceTransformersEmbeddingService
from src.infrastructure.llm.ollama_client import OllamaClient
from src.infrastructure.llm.ollama_service import OllamaLLMService
from src.infrastructure.vector.qdrant_service import QdrantVectorRepository
from src.infrastructure.logging.logger import get_logger

logger = get_logger(__name__)

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")

# Shared singletons for AI dependencies to save memory and avoid multiple initializations
ollama_client_singleton = OllamaClient()
embedding_service_singleton = SentenceTransformersEmbeddingService()
vector_db_singleton = QdrantVectorRepository()
llm_service_singleton = OllamaLLMService(client=ollama_client_singleton)

# Setup Redis Client for Rate Limiting
try:
    redis_client = aioredis.from_url(settings.REDIS_URL, decode_responses=True)
except Exception as e:
    logger.warning("Could not establish initial Redis link for rate limiter", error=str(e))
    redis_client = None


async def get_current_org_id(token: str = Depends(oauth2_scheme)) -> uuid.UUID:
    """
    Dependency verifying bearer tokens and returning tenant identifier org_id.
    """
    payload = AuthService.decode_access_token(token)
    if not payload:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )

    org_id_str = payload.get("org_id")
    if not org_id_str:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Tenant credentials missing inside token claim",
        )

    try:
        return uuid.UUID(org_id_str)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid organization UUID format inside token claim",
        )


async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: AsyncSession = Depends(get_db_session),
) -> dict:
    """Returns JWT payload with verified claims."""
    payload = AuthService.decode_access_token(token)
    if not payload:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return payload


async def get_agent_org_id(
    x_agent_key: Optional[str] = None,
    token: Optional[str] = None,
    x_organization_id: Optional[str] = None,
) -> Optional[uuid.UUID]:
    """
    Temporary dependency for agent-to-brain communication.
    Accepts either:
      - X-Agent-Key header matching AGENT_REGISTRATION_KEY with X-Organization-Id header
      - Standard JWT Bearer token (for user-facing endpoints)
    Returns org_id from JWT or X-Organization-Id header, None only if agent key without org header.
    """
    # Try JWT first if token provided
    if token:
        payload = AuthService.decode_access_token(token)
        if payload:
            org_id_str = payload.get("org_id")
            if org_id_str:
                try:
                    return uuid.UUID(org_id_str)
                except ValueError:
                    pass
    # Try agent key — require X-Organization-Id header
    if x_agent_key and x_agent_key == settings.AGENT_REGISTRATION_KEY:
        if x_organization_id:
            try:
                return uuid.UUID(x_organization_id)
            except ValueError:
                pass
        return None
    raise HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Invalid authentication. Provide X-Agent-Key or Bearer token.",
        headers={"WWW-Authenticate": "Bearer"},
    )


def require_role(*roles: str):
    """Dependency factory that restricts access to specified roles."""
    async def role_checker(payload: dict = Depends(get_current_user)) -> dict:
        user_role = payload.get("role", "member")
        if user_role not in roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Insufficient permissions for this operation.",
            )
        return payload
    return role_checker


def get_document_service() -> DocumentService:
    return DocumentService(
        embedding_service=embedding_service_singleton,
        vector_db=vector_db_singleton
    )


def get_rag_service(db: AsyncSession = Depends(get_db_session)) -> RAGService:
    customer_repo = SQLAlchemyCustomerRepository(db)
    lead_repo = SQLAlchemyLeadRepository(db)
    return RAGService(
        embedding_service=embedding_service_singleton,
        vector_db=vector_db_singleton,
        llm_service=llm_service_singleton,
        customer_repo=customer_repo,
        lead_repo=lead_repo
    )


# Rate limiting is handled by GlobalRateLimitMiddleware in main.py
# This module-level redis_client is kept for potential future use.
# The per-dependency rate_limiter has been removed to avoid double rate-limiting.
