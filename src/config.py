import os
from typing import Literal
from pydantic import Field, field_validator, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


def _read_secret_file(path: str) -> str | None:
    """Read secret from Docker secrets file."""
    try:
        with open(path, "r") as f:
            return f.read().strip()
    except (OSError, IOError):
        return None


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore"
    )

    # App Settings
    ENVIRONMENT: Literal["development", "production", "testing"] = "development"
    APP_NAME: str = "NexoraBrain"
    LOG_LEVEL: Literal["debug", "info", "warning", "error"] = "info"
    CORS_ORIGINS: str = "http://localhost:3000"
    PUBLIC_BASE_URL: str = Field(default="http://localhost:8000")

    # Database
    DATABASE_URL: str = Field(default="")

    # Security
    JWT_SECRET_KEY: str = Field(default="")
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 15
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7
    MIN_PASSWORD_LENGTH: int = 8
    PASSWORD_REQUIRE_UPPERCASE: bool = True
    PASSWORD_REQUIRE_LOWERCASE: bool = True
    PASSWORD_REQUIRE_DIGIT: bool = True
    PASSWORD_REQUIRE_SPECIAL: bool = True

    # Redis
    REDIS_URL: str = "redis://localhost:6379/0"

    # Vector DB & LLM
    OLLAMA_URL: str = "http://localhost:11434"
    OLLAMA_MODEL: str = "llama3"
    OLLAMA_TIMEOUT: int = 180
    OLLAMA_MAX_RETRIES: int = 2
    OLLAMA_RETRY_DELAY: float = 0.5
    QDRANT_URL: str = "http://localhost:6333"
    QDRANT_COLLECTION: str = "knowledge_base"
    EMBEDDING_DIMENSION: int = 384

    # Meta / WhatsApp / Facebook / Instagram
    META_APP_ID: str = ""
    META_APP_SECRET: str = ""
    META_VERIFY_TOKEN: str = ""
    META_ACCESS_TOKEN: str = ""
    META_PHONE_NUMBER_ID: str = ""
    META_PAGE_ID: str = ""
    META_PAGE_ACCESS_TOKEN: str = ""
    META_INSTAGRAM_ACCOUNT_ID: str = ""
    META_INSTAGRAM_ACCESS_TOKEN: str = ""

    # Twilio
    TWILIO_ACCOUNT_SID: str = ""
    TWILIO_AUTH_TOKEN: str = ""
    TWILIO_PHONE_NUMBER: str = ""

    # Stripe
    STRIPE_SECRET_KEY: str = ""
    STRIPE_PUBLISHABLE_KEY: str = ""
    STRIPE_WEBHOOK_SECRET: str = ""

    # Razorpay
    RAZORPAY_KEY_ID: str = ""
    RAZORPAY_KEY_SECRET: str = ""
    RAZORPAY_WEBHOOK_SECRET: str = ""

    # Email (SMTP)
    SMTP_HOST: str = ""
    SMTP_PORT: int = 587
    SMTP_USERNAME: str = ""
    SMTP_PASSWORD: str = ""
    SMTP_FROM_EMAIL: str = ""

    # Sentry (optional)
    SENTRY_DSN: str = ""

    # Agent Registration (temporary internal key for agent-to-brain communication)
    AGENT_REGISTRATION_KEY: str = ""

    # Provider API Key Encryption
    PROVIDER_ENCRYPTION_KEY: str = ""

    @model_validator(mode="before")
    @classmethod
    def validate_production_settings(cls, data: dict) -> dict:
        env = data.get("ENVIRONMENT") or os.getenv("ENVIRONMENT", "development")
        if env == "production":
            if not data.get("DATABASE_URL"):
                raise ValueError("DATABASE_URL must be set in production environment")
            if not data.get("JWT_SECRET_KEY"):
                raise ValueError("JWT_SECRET_KEY must be set in production environment")
            if not data.get("AGENT_REGISTRATION_KEY"):
                raise ValueError("AGENT_REGISTRATION_KEY must be set in production environment")
        return data

    @field_validator("DATABASE_URL", mode="before")
    @classmethod
    def validate_database_url(cls, v: str) -> str:
        if v:
            return v
        secret = _read_secret_file("/run/secrets/database_url")
        if secret:
            return secret
        return "sqlite+aiosqlite:///./nexora_dev.db"

    @field_validator("JWT_SECRET_KEY", mode="before")
    @classmethod
    def validate_jwt_secret(cls, v: str) -> str:
        secret = _read_secret_file("/run/secrets/jwt_secret_key")
        if secret:
            return secret
        if v:
            return v
        return ""

    @property
    def cors_origins_list(self) -> list[str]:
        return [origin.strip() for origin in self.CORS_ORIGINS.split(",")]

    @property
    def is_dev(self) -> bool:
        return self.ENVIRONMENT == "development"

    @property
    def is_prod(self) -> bool:
        return self.ENVIRONMENT == "production"

    @property
    def is_test(self) -> bool:
        return self.ENVIRONMENT == "testing"


# Global configurations singleton
settings = Settings()
