import uuid
from typing import Optional
from pydantic import BaseModel, ConfigDict, EmailStr, Field


class BusinessProfileCreate(BaseModel):
    name: str = Field(..., min_length=2)
    business_type: str
    address: str
    phone: str
    email: EmailStr
    website: Optional[str] = None
    working_hours: Optional[str] = None
    services: Optional[str] = None
    policies: Optional[str] = None
    description: Optional[str] = None


class BusinessProfileUpdate(BaseModel):
    name: Optional[str] = None
    business_type: Optional[str] = None
    address: Optional[str] = None
    phone: Optional[str] = None
    email: Optional[EmailStr] = None
    website: Optional[str] = None
    working_hours: Optional[str] = None
    services: Optional[str] = None
    policies: Optional[str] = None
    description: Optional[str] = None


class BusinessProfileResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    org_id: uuid.UUID
    name: str
    business_type: str
    address: str
    phone: str
    email: str
    website: Optional[str]
    working_hours: Optional[str]
    services: Optional[str]
    policies: Optional[str]
    description: Optional[str]
