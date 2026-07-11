from __future__ import annotations

import logging
from datetime import datetime
from typing import Any, Callable, Optional

from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.job import Job

logger = logging.getLogger(__name__)


class SchedulerService:
    def __init__(self) -> None:
        self._scheduler = AsyncIOScheduler()
        self._jobs: dict[str, Job] = {}

    async def start(self) -> None:
        if not self._scheduler.running:
            self._scheduler.start()
            logger.info("Scheduler started")

    async def stop(self) -> None:
        if self._scheduler.running:
            self._scheduler.shutdown(wait=False)
            self._jobs.clear()
            logger.info("Scheduler stopped")

    async def schedule_campaign(
        self, campaign_id: str, run_at: datetime, callback: Callable[..., Any], **kwargs: Any
    ) -> str:
        job_id = f"campaign_{campaign_id}"
        existing = self._scheduler.get_job(job_id)
        if existing:
            logger.warning("Campaign job %s already scheduled, rescheduling", job_id)
            existing.remove()

        job = self._scheduler.add_job(
            callback,
            trigger="date",
            run_date=run_at,
            id=job_id,
            replace_existing=True,
            kwargs={"campaign_id": campaign_id, **kwargs},
        )
        self._jobs[job_id] = job
        logger.info("Scheduled campaign %s at %s (job_id=%s)", campaign_id, run_at, job_id)
        return job_id

    async def schedule_workflow(
        self, workflow_id: str, delay_seconds: int, callback: Callable[..., Any], **kwargs: Any
    ) -> str:
        job_id = f"workflow_{workflow_id}"
        existing = self._scheduler.get_job(job_id)
        if existing:
            logger.warning("Workflow job %s already scheduled, rescheduling", job_id)
            existing.remove()

        job = self._scheduler.add_job(
            callback,
            trigger="date",
            run_date=datetime.utcnow(),
            id=job_id,
            replace_existing=True,
            kwargs={"workflow_id": workflow_id, **kwargs},
        )
        job.modify(next_run_time=datetime.utcnow())
        self._jobs[job_id] = job
        logger.info(
            "Scheduled workflow %s with %ds delay (job_id=%s)",
            workflow_id, delay_seconds, job_id
        )
        return job_id

    async def schedule_analytics_snapshot(
        self, organization_id: str, interval_hours: int = 24, callback: Callable[..., Any] = None, **kwargs: Any
    ) -> str:
        job_id = f"analytics_snapshot_{organization_id}"
        existing = self._scheduler.get_job(job_id)
        if existing:
            logger.warning("Analytics snapshot job %s already scheduled", job_id)
            return job_id

        job = self._scheduler.add_job(
            callback,
            trigger="interval",
            hours=interval_hours,
            id=job_id,
            replace_existing=True,
            kwargs={"organization_id": organization_id, **kwargs},
        )
        self._jobs[job_id] = job
        logger.info(
            "Scheduled analytics snapshot for org %s every %dh (job_id=%s)",
            organization_id, interval_hours, job_id
        )
        return job_id

    async def schedule_daily_maintenance(
        self, callback: Callable[..., Any], hour: int = 3, minute: int = 0, **kwargs: Any
    ) -> str:
        job_id = "daily_maintenance"
        existing = self._scheduler.get_job(job_id)
        if existing:
            return job_id

        job = self._scheduler.add_job(
            callback,
            trigger="cron",
            hour=hour,
            minute=minute,
            id=job_id,
            replace_existing=True,
            kwargs=kwargs,
        )
        self._jobs[job_id] = job
        logger.info("Scheduled daily maintenance at %02d:%02d (job_id=%s)", hour, minute, job_id)
        return job_id

    async def cancel_job(self, job_id: str) -> Optional[bool]:
        job = self._scheduler.get_job(job_id)
        if job:
            job.remove()
            self._jobs.pop(job_id, None)
            logger.info("Cancelled job %s", job_id)
            return True
        logger.warning("Job %s not found to cancel", job_id)
        return False

    def get_job(self, job_id: str) -> Optional[Job]:
        return self._scheduler.get_job(job_id)

    def is_running(self) -> bool:
        return self._scheduler.running

    def get_scheduled_jobs(self) -> list[dict[str, Any]]:
        jobs = self._scheduler.get_jobs()
        result: list[dict[str, Any]] = []
        for job in jobs:
            result.append({
                "id": job.id,
                "name": job.name,
                "next_run_time": job.next_run_time.isoformat() if job.next_run_time else None,
                "trigger": str(job.trigger),
            })
        return result
