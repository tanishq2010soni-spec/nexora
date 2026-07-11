import uuid
from typing import Optional
from sqlalchemy.ext.asyncio import AsyncSession

from src.infrastructure.database.models import AuditLog


class AuditService:
    @staticmethod
    async def log(
        db: AsyncSession,
        action: str,
        resource: str,
        org_id: Optional[uuid.UUID] = None,
        user_email: Optional[str] = None,
        resource_id: Optional[str] = None,
        detail: Optional[str] = None,
        ip_address: Optional[str] = None,
    ) -> None:
        entry = AuditLog(
            id=uuid.uuid4(),
            org_id=org_id,
            user_email=user_email,
            action=action,
            resource=resource,
            resource_id=resource_id,
            detail=detail,
            ip_address=ip_address,
        )
        db.add(entry)
        await db.flush()
