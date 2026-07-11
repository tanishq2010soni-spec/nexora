import datetime
import uuid
from typing import Optional


class Lead:
    def __init__(
        self,
        org_id: uuid.UUID,
        session_id: uuid.UUID,
        name: Optional[str] = None,
        phone: Optional[str] = None,
        email: Optional[str] = None,
        intent: Optional[str] = None,
        product_interest: Optional[str] = None,
        budget: Optional[float] = None,
        id: Optional[uuid.UUID] = None,
        created_at: Optional[datetime.datetime] = None,
    ):
        self.id = id or uuid.uuid4()
        self.org_id = org_id
        self.session_id = session_id
        self.name = name
        self.phone = phone
        self.email = email
        self.intent = intent
        self.product_interest = product_interest
        self.budget = budget
        self.created_at = created_at or datetime.datetime.utcnow()
