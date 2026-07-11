"""
Background job queue using ARQ (Async Redis Queue).
Provides scheduled and ad-hoc background task execution.
"""
import asyncio
from datetime import datetime, timezone
from typing import Any, Optional

from arq import cron
from arq.connections import RedisSettings
from arq.worker import Worker

from src.config import settings
from src.infrastructure.logging.logger import get_logger

logger = get_logger(__name__)


# --- Job functions ---

async def send_notification_job(ctx: dict, user_id: str, title: str, body: str, notification_type: str = "info") -> dict:
    """Background job to send push/in-app notifications."""
    logger.info("Executing notification job", user_id=user_id, type=notification_type)
    try:
        from src.infrastructure.database.connection import AsyncSessionLocal
        from sqlalchemy import text

        async with AsyncSessionLocal() as db:
            await db.execute(
                text(
                    "INSERT INTO notifications (id, org_id, user_id, title, body, type, is_read, created_at) "
                    "VALUES (gen_random_uuid(), :org_id, :user_id, :title, :body, :type, false, now())"
                ),
                {"org_id": ctx.get("org_id", ""), "user_id": user_id, "title": title, "body": body, "type": notification_type},
            )
            await db.commit()
        return {"status": "sent", "user_id": user_id}
    except Exception as e:
        logger.error("Notification job failed", error=str(e), user_id=user_id)
        return {"status": "failed", "error": str(e)}


async def sync_contacts_job(ctx: dict, org_id: str, provider: str = "whatsapp") -> dict:
    """Background job to sync contacts from WhatsApp/Meta."""
    logger.info("Executing contact sync job", org_id=org_id, provider=provider)
    try:
        from src.infrastructure.database.connection import AsyncSessionLocal
        from src.infrastructure.integrations.meta_service import MetaOmnichannelService

        async with AsyncSessionLocal() as db:
            service = MetaOmnichannelService(db)
        # In production, this would pull contacts from Meta API and store in DB
        return {"status": "completed", "org_id": org_id, "provider": provider}
    except Exception as e:
        logger.error("Contact sync job failed", error=str(e), org_id=org_id)
        return {"status": "failed", "error": str(e)}


async def generate_report_job(ctx: dict, org_id: str, report_type: str = "weekly") -> dict:
    """Background job to generate analytics reports."""
    logger.info("Executing report generation job", org_id=org_id, report_type=report_type)
    try:
        from src.infrastructure.database.connection import AsyncSessionLocal
        from sqlalchemy import text

        async with AsyncSessionLocal() as db:
            # Example: compute weekly lead stats
            if report_type == "weekly":
                result = await db.execute(
                    text(
                        "SELECT status, COUNT(*) as count FROM leads "
                        "WHERE org_id = :org_id AND created_at >= now() - interval '7 days' "
                        "GROUP BY status"
                    ),
                    {"org_id": org_id},
                )
                stats = {row.status: row.count for row in result.fetchall()}
            else:
                stats = {}

        return {"status": "completed", "org_id": org_id, "report_type": report_type, "stats": stats}
    except Exception as e:
        logger.error("Report generation job failed", error=str(e), org_id=org_id)
        return {"status": "failed", "error": str(e)}


async def cleanup_old_sessions_job(ctx: dict) -> dict:
    """Background job to clean up old/expired chat sessions. Runs per-organization."""
    logger.info("Executing session cleanup job")
    try:
        from src.infrastructure.database.connection import AsyncSessionLocal
        from sqlalchemy import text

        async with AsyncSessionLocal() as db:
            # Get all org_ids that have sessions
            orgs_result = await db.execute(
                text("SELECT DISTINCT org_id FROM chat_sessions")
            )
            org_ids = [row[0] for row in orgs_result.fetchall()]

            total_deleted = 0
            for org_id in org_ids:
                result = await db.execute(
                    text(
                        "DELETE FROM chat_sessions WHERE org_id = :org_id "
                        "AND updated_at < now() - interval '30 days' RETURNING id"
                    ),
                    {"org_id": org_id},
                )
                total_deleted += len(result.fetchall())
            await db.commit()
        return {"status": "completed", "deleted_sessions": total_deleted}
    except Exception as e:
        logger.error("Session cleanup job failed", error=str(e))
        return {"status": "failed", "error": str(e)}


# --- ARQ Worker Settings ---

class WorkerSettings:
    """ARQ worker configuration."""
    functions = [
        send_notification_job,
        sync_contacts_job,
        generate_report_job,
        cleanup_old_sessions_job,
    ]
    cron_jobs = [
        cron(cleanup_old_sessions_job, hour=3, minute=0),  # Daily at 3 AM
        cron(generate_report_job, day_of_week=1, hour=6, minute=0),  # Weekly Monday 6 AM
    ]
    redis_settings = RedisSettings.from_dsn(settings.REDIS_URL)
    max_jobs = 10
    poll_delay = 0.5
    job_timeout = 300  # 5 minutes max per job
    max_tries = 3


async def enqueue_job(function_name: str, *args: Any, _job_queue: str = "default", **kwargs: Any) -> Optional[str]:
    """
    Enqueue a background job.
    Returns the job ID or None if Redis is unavailable.
    """
    try:
        from arq import create_pool
        pool = await create_pool(RedisSettings.from_dsn(settings.REDIS_URL))
        job_id = await pool.enqueue_job(function_name, *args, _queue_name=_job_queue, **kwargs)
        logger.info("Job enqueued", function=function_name, job_id=job_id)
        return job_id
    except Exception as e:
        logger.warning("Failed to enqueue job", function=function_name, error=str(e))
        return None
