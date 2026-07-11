from __future__ import annotations

from datetime import datetime, time
from decimal import Decimal
from typing import Any, Optional
from uuid import UUID, uuid4

from pydantic import BaseModel, EmailStr, Field


class Organization(BaseModel):
    id: UUID = Field(default_factory=uuid4)
    name: str
    slug: str
    status: str = "active"
    timezone: str = "UTC"
    brand_color: str = "#6366f1"
    brand_logo_url: Optional[str] = None
    business_hours_start: str = "09:00"
    business_hours_end: str = "18:00"
    working_days: list[int] = [0, 1, 2, 3, 4, 5, 6]
    default_country_code: str = "1"
    max_concurrent_calls: int = 50
    max_agents: int = 10
    recording_enabled: bool = True
    transcription_enabled: bool = True
    extra_data: dict[str, Any] = Field(default_factory=dict)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        from_attributes = True


class User(BaseModel):
    id: UUID = Field(default_factory=uuid4)
    organization_id: UUID
    email: EmailStr
    name: str
    role: str = "agent"
    extension: Optional[str] = None
    sip_uri: Optional[str] = None
    is_active: bool = True
    is_available: bool = True
    max_concurrent_calls: int = 3
    permissions: list[str] = Field(default_factory=list)
    last_login_at: Optional[datetime] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        from_attributes = True


class PhoneProviderConfig(BaseModel):
    id: UUID = Field(default_factory=uuid4)
    organization_id: UUID
    name: str
    provider_type: str
    is_active: bool = True
    config: dict[str, Any] = Field(default_factory=dict)
    credentials: dict[str, Any] = Field(default_factory=dict)
    phone_numbers: list[str] = Field(default_factory=list)
    default_phone_number: Optional[str] = None
    rate_per_minute: Decimal = Decimal("0.00")
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        from_attributes = True


class VoiceSettings(BaseModel):
    id: UUID = Field(default_factory=uuid4)
    organization_id: UUID
    stt_provider: str = "whisper"
    stt_config: dict[str, Any] = Field(default_factory=dict)
    tts_provider: str = "pyttsx3"
    tts_config: dict[str, Any] = Field(default_factory=dict)
    tts_voice: str = "default"
    tts_speed: float = 1.0
    tts_pitch: float = 1.0
    tts_emotion: str = "neutral"
    vad_provider: str = "webrtc"
    vad_config: dict[str, Any] = Field(default_factory=dict)
    noise_suppression: bool = True
    echo_cancellation: bool = True
    interruption_enabled: bool = True
    silence_timeout_ms: int = 2000
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        from_attributes = True


class Call(BaseModel):
    id: UUID = Field(default_factory=uuid4)
    organization_id: UUID
    user_id: Optional[UUID] = None
    campaign_id: Optional[UUID] = None
    lead_id: Optional[UUID] = None
    contact_id: Optional[UUID] = None
    phone_provider_id: Optional[UUID] = None
    direction: str
    from_number: str
    to_number: str
    status: str = "queued"
    disposition: Optional[str] = None
    duration_seconds: Optional[int] = None
    billing_duration_seconds: Optional[int] = None
    cost: Decimal = Decimal("0.00")
    recording_url: Optional[str] = None
    recording_status: Optional[str] = None
    transcription_url: Optional[str] = None
    transcription_status: Optional[str] = None
    transcript: Optional[str] = None
    summary: Optional[str] = None
    sentiment: Optional[str] = None
    intent: Optional[str] = None
    quality_score: Optional[float] = None
    ai_handled: bool = True
    handoff_to: Optional[UUID] = None
    handoff_reason: Optional[str] = None
    notes: list[dict[str, Any]] = Field(default_factory=list)
    tags: list[str] = Field(default_factory=list)
    ivr_digits: Optional[str] = None
    provider_call_id: Optional[str] = None
    provider_data: dict[str, Any] = Field(default_factory=dict)
    extra_data: dict[str, Any] = Field(default_factory=dict)
    started_at: Optional[datetime] = None
    ended_at: Optional[datetime] = None
    scheduled_at: Optional[datetime] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        from_attributes = True


class CallEvent(BaseModel):
    id: UUID = Field(default_factory=uuid4)
    call_id: UUID
    organization_id: UUID
    event_type: str
    data: dict[str, Any] = Field(default_factory=dict)
    timestamp: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        from_attributes = True


class Campaign(BaseModel):
    id: UUID = Field(default_factory=uuid4)
    organization_id: UUID
    name: str
    type: str
    status: str = "draft"
    script_id: Optional[UUID] = None
    phone_provider_id: Optional[UUID] = None
    caller_id: Optional[str] = None
    target_filter: dict[str, Any] = Field(default_factory=dict)
    schedule: dict[str, Any] = Field(default_factory=dict)
    max_calls_per_day: int = 100
    max_attempts: int = 3
    retry_delay_minutes: int = 60
    call_window_start: str = "09:00"
    call_window_end: str = "18:00"
    working_days: list[int] = [0, 1, 2, 3, 4, 5, 6]
    timezone: str = "UTC"
    total_calls: int = 0
    total_answered: int = 0
    total_converted: int = 0
    total_cost: Decimal = Decimal("0.00")
    created_by: Optional[UUID] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        from_attributes = True


class Lead(BaseModel):
    id: UUID = Field(default_factory=uuid4)
    organization_id: UUID
    campaign_id: Optional[UUID] = None
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    phone: str
    email: Optional[EmailStr] = None
    company: Optional[str] = None
    position: Optional[str] = None
    status: str = "new"
    source: str = "manual"
    score: float = 0.0
    notes: list[dict[str, Any]] = Field(default_factory=list)
    tags: list[str] = Field(default_factory=list)
    custom_fields: dict[str, Any] = Field(default_factory=dict)
    last_called_at: Optional[datetime] = None
    call_count: int = 0
    last_disposition: Optional[str] = None
    next_call_at: Optional[datetime] = None
    timezone: Optional[str] = None
    best_time_to_call: Optional[str] = None
    do_not_call: bool = False
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        from_attributes = True


class Contact(BaseModel):
    id: UUID = Field(default_factory=uuid4)
    organization_id: UUID
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    phone: str
    email: Optional[EmailStr] = None
    company: Optional[str] = None
    position: Optional[str] = None
    tags: list[str] = Field(default_factory=list)
    notes: list[dict[str, Any]] = Field(default_factory=list)
    custom_fields: dict[str, Any] = Field(default_factory=dict)
    total_calls: int = 0
    total_spent: Decimal = Decimal("0.00")
    lifetime_value: Decimal = Decimal("0.00")
    last_contact_at: Optional[datetime] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        from_attributes = True


class Appointment(BaseModel):
    id: UUID = Field(default_factory=uuid4)
    organization_id: UUID
    lead_id: Optional[UUID] = None
    contact_id: Optional[UUID] = None
    call_id: Optional[UUID] = None
    title: str
    description: Optional[str] = None
    status: str = "scheduled"
    scheduled_at: datetime
    duration_minutes: int = 30
    assigned_to: Optional[UUID] = None
    reminder_sent: bool = False
    notes: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        from_attributes = True


class Script(BaseModel):
    id: UUID = Field(default_factory=uuid4)
    organization_id: UUID
    name: str
    type: str
    content: str
    variables: list[dict[str, Any]] = Field(default_factory=list)
    sections: list[dict[str, Any]] = Field(default_factory=list)
    tags: list[str] = Field(default_factory=list)
    is_active: bool = True
    version: int = 1
    created_by: Optional[UUID] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        from_attributes = True


class KnowledgeDocument(BaseModel):
    id: UUID = Field(default_factory=uuid4)
    organization_id: UUID
    title: str
    type: str
    content: Optional[str] = None
    file_path: Optional[str] = None
    file_size: Optional[int] = None
    mime_type: Optional[str] = None
    source_url: Optional[str] = None
    tags: list[str] = Field(default_factory=list)
    is_indexed: bool = False
    chunk_count: int = 0
    extra_data: dict[str, Any] = Field(default_factory=dict)
    created_by: Optional[UUID] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        from_attributes = True


class Recording(BaseModel):
    id: UUID = Field(default_factory=uuid4)
    organization_id: UUID
    call_id: UUID
    file_path: Optional[str] = None
    file_size: Optional[int] = None
    duration_seconds: Optional[int] = None
    mime_type: str = "audio/wav"
    status: str = "processing"
    transcription_status: str = "pending"
    transcription_text: Optional[str] = None
    is_archived: bool = False
    created_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        from_attributes = True


class PromptTemplate(BaseModel):
    id: UUID = Field(default_factory=uuid4)
    organization_id: UUID
    name: str
    description: Optional[str] = None
    system_prompt: str
    context_prompt: str = ""
    temperature: float = 0.7
    max_tokens: int = 1024
    model: Optional[str] = None
    is_active: bool = True
    created_by: Optional[UUID] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        from_attributes = True


class AuditLog(BaseModel):
    id: UUID = Field(default_factory=uuid4)
    organization_id: UUID
    user_id: Optional[UUID] = None
    action: str
    resource_type: str
    resource_id: Optional[str] = None
    details: dict[str, Any] = Field(default_factory=dict)
    ip_address: Optional[str] = None
    user_agent: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        from_attributes = True


class Plugin(BaseModel):
    id: UUID = Field(default_factory=uuid4)
    organization_id: UUID
    name: str
    version: str = "1.0.0"
    description: Optional[str] = None
    entry_point: str = ""
    config_schema: dict[str, Any] = Field(default_factory=dict)
    config: dict[str, Any] = Field(default_factory=dict)
    is_enabled: bool = True
    is_official: bool = False
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        from_attributes = True


class AnalyticsEvent(BaseModel):
    id: UUID = Field(default_factory=uuid4)
    organization_id: UUID
    metric: str
    value: float = 0.0
    tags: dict[str, Any] = Field(default_factory=dict)
    recorded_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        from_attributes = True
