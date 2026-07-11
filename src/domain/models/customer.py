import datetime
import uuid
from typing import Optional


class Customer:
    def __init__(
        self,
        org_id: uuid.UUID,
        phone: str,
        name: Optional[str] = None,
        preferences: Optional[str] = None,
        notes: Optional[str] = None,
        id: Optional[uuid.UUID] = None,
        created_at: Optional[datetime.datetime] = None,
        updated_at: Optional[datetime.datetime] = None,
    ):
        self.id = id or uuid.uuid4()
        self.org_id = org_id
        self.phone = phone
        self.name = name
        self.preferences = preferences
        self.notes = notes
        self.created_at = created_at or datetime.datetime.utcnow()
        self.updated_at = updated_at or datetime.datetime.utcnow()
