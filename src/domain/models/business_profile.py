import uuid
from typing import Optional


class BusinessProfile:
    def __init__(
        self,
        org_id: uuid.UUID,
        name: str,
        business_type: str,
        address: str,
        phone: str,
        email: str,
        website: Optional[str] = None,
        working_hours: Optional[str] = None,
        services: Optional[str] = None,
        policies: Optional[str] = None,
        description: Optional[str] = None,
        id: Optional[uuid.UUID] = None,
    ):
        self.id = id or uuid.uuid4()
        self.org_id = org_id
        self.name = name
        self.business_type = business_type
        self.address = address
        self.phone = phone
        self.email = email
        self.website = website
        self.working_hours = working_hours
        self.services = services
        self.policies = policies
        self.description = description
