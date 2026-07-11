import datetime
import re
from typing import Optional, Any
from jose import jwt, JWTError
from passlib.context import CryptContext
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from src.config import settings
from src.infrastructure.database.models import User
from src.infrastructure.logging.logger import get_logger

logger = get_logger(__name__)

# Configure bcrypt context for secure password hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


class PasswordPolicy:
    @staticmethod
    def validate(password: str) -> list[str]:
        errors: list[str] = []
        if len(password) < settings.MIN_PASSWORD_LENGTH:
            errors.append(f"Password must be at least {settings.MIN_PASSWORD_LENGTH} characters long")
        if settings.PASSWORD_REQUIRE_UPPERCASE and not re.search(r"[A-Z]", password):
            errors.append("Password must contain at least one uppercase letter")
        if settings.PASSWORD_REQUIRE_LOWERCASE and not re.search(r"[a-z]", password):
            errors.append("Password must contain at least one lowercase letter")
        if settings.PASSWORD_REQUIRE_DIGIT and not re.search(r"\d", password):
            errors.append("Password must contain at least one digit")
        if settings.PASSWORD_REQUIRE_SPECIAL and not re.search(r"[!@#$%^&*(),.?\":{}|<>_\-+]", password):
            errors.append("Password must contain at least one special character")
        return errors


class AuthService:
    @staticmethod
    def hash_password(password: str) -> str:
        # bcrypt enforces a maximum input length of 72 bytes
        truncated = password.encode("utf-8")[:72].decode("utf-8", errors="ignore")
        return pwd_context.hash(truncated)

    @staticmethod
    def verify_password(plain_password: str, hashed_password: str) -> bool:
        truncated = plain_password.encode("utf-8")[:72].decode("utf-8", errors="ignore")
        return pwd_context.verify(truncated, hashed_password)

    @staticmethod
    def create_access_token(data: dict[str, Any], expires_delta: Optional[datetime.timedelta] = None) -> str:
        """
        Signs and returns a JWT access token containing org/user claims.
        """
        to_encode = data.copy()
        now = datetime.datetime.now(datetime.timezone.utc)
        if expires_delta:
            expire = now + expires_delta
        else:
            expire = now + datetime.timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)

        to_encode.update({"exp": expire, "token_type": "access"})
        encoded_jwt = jwt.encode(to_encode, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM)
        return encoded_jwt

    @staticmethod
    def create_refresh_token(data: dict[str, Any]) -> str:
        """
        Creates a long-lived JWT refresh token.
        """
        to_encode = data.copy()
        now = datetime.datetime.now(datetime.timezone.utc)
        expire = now + datetime.timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)
        to_encode.update({"exp": expire, "token_type": "refresh"})
        return jwt.encode(to_encode, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM)

    @staticmethod
    def decode_access_token(token: str) -> Optional[dict[str, Any]]:
        """
        Validates JWT bearer token signatures and returns payload mapping.
        """
        try:
            payload = jwt.decode(token, settings.JWT_SECRET_KEY, algorithms=[settings.JWT_ALGORITHM])
            if payload.get("token_type") != "access":
                return None
            return payload
        except JWTError:
            return None

    @staticmethod
    def decode_refresh_token(token: str) -> Optional[dict[str, Any]]:
        """
        Validates a refresh token and returns payload mapping.
        """
        try:
            payload = jwt.decode(token, settings.JWT_SECRET_KEY, algorithms=[settings.JWT_ALGORITHM])
            if payload.get("token_type") != "refresh":
                return None
            return payload
        except JWTError:
            return None

    @staticmethod
    async def authenticate_user(
        db: AsyncSession,
        email: str,
        password: str
    ) -> Optional[User]:
        """
        Validates user credentials against PostgreSQL schemas.
        """
        stmt = select(User).where(User.email == email)
        result = await db.execute(stmt)
        user = result.scalar_one_or_none()

        if not user:
            return None

        if not AuthService.verify_password(password, user.password_hash):
            return None

        return user
