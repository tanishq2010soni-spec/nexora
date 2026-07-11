import uuid
import re
from typing import Optional
from pydantic import BaseModel, EmailStr, Field, field_validator
from src.config import settings


class UserRegister(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=8, max_length=128)
    organization_name: str = Field(..., min_length=2, max_length=255)

    @field_validator("password")
    @classmethod
    def validate_password_policy(cls, v: str) -> str:
        errors: list[str] = []
        if len(v) < settings.MIN_PASSWORD_LENGTH:
            errors.append(f"Password must be at least {settings.MIN_PASSWORD_LENGTH} characters long")
        if settings.PASSWORD_REQUIRE_UPPERCASE and not re.search(r"[A-Z]", v):
            errors.append("Password must contain at least one uppercase letter")
        if settings.PASSWORD_REQUIRE_LOWERCASE and not re.search(r"[a-z]", v):
            errors.append("Password must contain at least one lowercase letter")
        if settings.PASSWORD_REQUIRE_DIGIT and not re.search(r"\d", v):
            errors.append("Password must contain at least one digit")
        if settings.PASSWORD_REQUIRE_SPECIAL and not re.search(r"[!@#$%^&*(),.?\":{}|<>_\-+]", v):
            errors.append("Password must contain at least one special character")
        if errors:
            raise ValueError("; ".join(errors))
        return v


class UserLogin(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=1, max_length=128)


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    org_id: uuid.UUID
    email: str
    role: str


class RefreshTokenRequest(BaseModel):
    refresh_token: str
