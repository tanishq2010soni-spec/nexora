from __future__ import annotations

import os
from pathlib import Path
from typing import Final, Literal

from pydantic import model_validator
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    app_name: str = "WhatsApp Agent"
    app_version: str = "1.0.0"
    debug: bool = False
    testing: bool = False

    host: str = "0.0.0.0"
    port: int = 8100

    database_url: str = "sqlite+aiosqlite:///./whatsapp_agent.db"
    database_echo: bool = False
    database_pool_size: int = 20
    database_max_overflow: int = 10

    redis_url: str = "redis://localhost:6379/0"

    secret_key: str = ""
    access_token_expire_minutes: int = 60
    refresh_token_expire_days: int = 7
    algorithm: str = "HS256"

    auth_mode: str = "legacy"
    nexora_control_plane_url: str = "http://localhost:8000"

    nexora_ai_path: str = ""
    nexora_config_path: str = ""

    whatsapp_session_dir: str = ""

    storage_dir: str = ""
    knowledge_dir: str = ""
    workflow_dir: str = ""
    plugin_dir: str = ""
    log_dir: str = ""

    max_upload_size_mb: int = 50
    rate_limit_per_minute: int = 60
    rate_limit_per_hour: int = 1000

    cors_origins: list[str] = ["http://localhost:3000", "http://localhost:8100"]

    @model_validator(mode="after")
    def _validate_secret_key(self) -> "Settings":
        if not self.secret_key and not self.testing:
            raise ValueError(
                "WA_SECRET_KEY environment variable is required. "
                "Generate one with: python -c \"import secrets; print(secrets.token_urlsafe(64))\""
            )
        if not self.secret_key and self.testing:
            self.secret_key = "test-secret-key-not-for-production"
        return self

    webhook_max_retries: int = 3
    webhook_timeout_seconds: int = 30

    analytics_retention_days: int = 90
    log_retention_days: int = 30

    class Config:
        env_file = ".env"
        env_prefix = "WA_"
        extra = "ignore"

    @property
    def resolved_nexora_path(self) -> Path:
        if self.nexora_ai_path:
            return Path(self.nexora_ai_path).resolve()
        return Path(__file__).parent.parent.parent / "nexora_ai"

    @property
    def resolved_storage_dir(self) -> Path:
        return Path(self.storage_dir or "data/storage").resolve()

    @property
    def resolved_knowledge_dir(self) -> Path:
        return Path(self.knowledge_dir or "data/knowledge").resolve()

    @property
    def resolved_workflow_dir(self) -> Path:
        return Path(self.workflow_dir or "workflows").resolve()

    @property
    def resolved_plugin_dir(self) -> Path:
        return Path(self.plugin_dir or "plugins").resolve()

    @property
    def resolved_log_dir(self) -> Path:
        return Path(self.log_dir or "data/logs").resolve()

    @property
    def resolved_whatsapp_session_dir(self) -> Path:
        return Path(self.whatsapp_session_dir or "data/sessions").resolve()

    def ensure_dirs(self) -> None:
        for d in [self.resolved_storage_dir, self.resolved_knowledge_dir,
                  self.resolved_workflow_dir, self.resolved_plugin_dir,
                  self.resolved_log_dir, self.resolved_whatsapp_session_dir]:
            d.mkdir(parents=True, exist_ok=True)


settings = Settings()
