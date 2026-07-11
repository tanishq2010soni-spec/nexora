from __future__ import annotations

from pathlib import Path

from pydantic import model_validator
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    app_name: str = "Calling Agent"
    app_version: str = "1.0.0"
    debug: bool = False
    testing: bool = False

    host: str = "0.0.0.0"
    port: int = 8200

    database_url: str = "sqlite+aiosqlite:///./calling_agent.db"
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
    calls_dir: str = ""
    recordings_dir: str = ""
    scripts_dir: str = ""
    knowledge_dir: str = ""
    plugin_dir: str = ""
    log_dir: str = ""

    max_recording_size_mb: int = 200
    max_call_duration_minutes: int = 120
    rate_limit_per_minute: int = 60

    cors_origins: list[str] = ["http://localhost:3000", "http://localhost:8200"]

    @model_validator(mode="after")
    def _validate_secret_key(self) -> "Settings":
        if not self.secret_key and not self.testing:
            raise ValueError(
                "CA_SECRET_KEY environment variable is required. "
                "Generate one with: python -c \"import secrets; print(secrets.token_urlsafe(64))\""
            )
        if not self.secret_key and self.testing:
            self.secret_key = "test-secret-key-not-for-production"
        return self

    stt_provider: str = "whisper"
    stt_model: str = "base"
    stt_language: str = "en"
    stt_sample_rate: int = 16000

    tts_provider: str = "pyttsx3"
    tts_voice: str = "default"
    tts_speed: float = 1.0
    tts_pitch: float = 1.0
    tts_emotion: str = "neutral"

    vad_mode: int = 1
    vad_frame_ms: int = 30
    vad_silence_ms: int = 500

    twilio_account_sid: str = ""
    twilio_auth_token: str = ""
    twilio_phone_number: str = ""

    exotel_api_key: str = ""
    exotel_api_token: str = ""
    exotel_sid: str = ""

    plivo_auth_id: str = ""
    plivo_auth_token: str = ""
    plivo_phone_number: str = ""

    webhook_base_url: str = "http://localhost:8200"
    webhook_max_retries: int = 3
    webhook_timeout_seconds: int = 30

    analytics_retention_days: int = 90
    log_retention_days: int = 30
    recording_retention_days: int = 365

    max_concurrent_calls: int = 50
    default_country_code: str = "1"
    call_timeout_seconds: int = 60
    ring_timeout_seconds: int = 30

    class Config:
        env_file = ".env"
        env_prefix = "CA_"
        extra = "ignore"

    @property
    def resolved_nexora_path(self) -> Path:
        if self.nexora_ai_path:
            return Path(self.nexora_ai_path).resolve()
        return Path(__file__).parent.parent.parent / "nexora_ai"

    @property
    def resolved_calls_dir(self) -> Path:
        return Path(self.calls_dir or "data/calls").resolve()

    @property
    def resolved_recordings_dir(self) -> Path:
        return Path(self.recordings_dir or "data/recordings").resolve()

    @property
    def resolved_scripts_dir(self) -> Path:
        return Path(self.scripts_dir or "scripts").resolve()

    @property
    def resolved_knowledge_dir(self) -> Path:
        return Path(self.knowledge_dir or "data/knowledge").resolve()

    @property
    def resolved_plugin_dir(self) -> Path:
        return Path(self.plugin_dir or "plugins").resolve()

    @property
    def resolved_log_dir(self) -> Path:
        return Path(self.log_dir or "data/logs").resolve()

    def ensure_dirs(self) -> None:
        for d in [self.resolved_calls_dir, self.resolved_recordings_dir,
                  self.resolved_scripts_dir, self.resolved_knowledge_dir,
                  self.resolved_plugin_dir, self.resolved_log_dir]:
            d.mkdir(parents=True, exist_ok=True)


settings = Settings()
