from collections.abc import AsyncGenerator
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from src.config import settings
from src.infrastructure.logging.logger import get_logger

logger = get_logger(__name__)

# Determine if using SQLite (no connection pooling options for SQLite)
_is_sqlite = settings.DATABASE_URL.startswith("sqlite")

_engine_kwargs: dict = {
    "echo": settings.is_dev,
}

if not _is_sqlite:
    # Connection pooling settings optimized for typical web servers (PostgreSQL)
    _engine_kwargs.update({
        "pool_size": 20,
        "max_overflow": 10,
        "pool_recycle": 1800,
        "pool_pre_ping": True,
    })

engine = create_async_engine(settings.DATABASE_URL, **_engine_kwargs)

# Async session factory
AsyncSessionLocal = async_sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autocommit=False,
    autoflush=False,
)


async def get_db_session() -> AsyncGenerator[AsyncSession, None]:
    """
    FastAPI dependency injection provider for AsyncSession.
    Ensures rollback on exceptions and automatic release of the connection pool.
    """
    session = AsyncSessionLocal()
    try:
        yield session
    except Exception as e:
        logger.error("Database session error occurred. Rolling back transaction.", error=str(e))
        await session.rollback()
        raise
    finally:
        await session.close()
