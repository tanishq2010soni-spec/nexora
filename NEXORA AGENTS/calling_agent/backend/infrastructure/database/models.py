from __future__ import annotations

from datetime import datetime
from decimal import Decimal
from typing import Any, Optional
from uuid import uuid4

from sqlalchemy import JSON, Boolean, Column, DateTime, Float, ForeignKey, Integer, String, Text
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship
from sqlalchemy.types import TypeDecorator


class Base(DeclarativeBase):
    pass


class GUID(TypeDecorator):
    impl = String(36)
    cache_ok = True

    def process_bind_param(self, value: Any, dialect: Any) -> Any:
        if value is None:
            return None
        return str(value)

    def process_result_value(self, value: Any, dialect: Any) -> Any:
        from uuid import UUID
        if value is None:
            return None
        return UUID(value)


class OrganizationModel(Base):
    __tablename__ = "organizations"

    id: Mapped[str] = mapped_column(GUID, primary_key=True, default=lambda: str(uuid4()))
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    slug: Mapped[str] = mapped_column(String(100), unique=True, nullable=False, index=True)
    status: Mapped[str] = mapped_column(String(20), default="active")
    timezone: Mapped[str] = mapped_column(String(50), default="UTC")
    brand_color: Mapped[str] = mapped_column(String(7), default="#6366f1")
    brand_logo_url: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    business_hours_start: Mapped[str] = mapped_column(String(5), default="09:00")
    business_hours_end: Mapped[str] = mapped_column(String(5), default="18:00")
    working_days: Mapped[Any] = mapped_column(JSON, default=lambda: [0, 1, 2, 3, 4, 5, 6])
    default_country_code: Mapped[str] = mapped_column(String(5), default="1")
    max_concurrent_calls: Mapped[int] = mapped_column(Integer, default=50)
    max_agents: Mapped[int] = mapped_column(Integer, default=10)
    recording_enabled: Mapped[bool] = mapped_column(Boolean, default=True)
    transcription_enabled: Mapped[bool] = mapped_column(Boolean, default=True)
    extra_data: Mapped[Any] = mapped_column(JSON, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    users = relationship("UserModel", back_populates="organization", cascade="all, delete-orphan")
    calls = relationship("CallModel", back_populates="organization", cascade="all, delete-orphan")
    campaigns = relationship("CampaignModel", back_populates="organization", cascade="all, delete-orphan")
    leads = relationship("LeadModel", back_populates="organization", cascade="all, delete-orphan")
    contacts = relationship("ContactModel", back_populates="organization", cascade="all, delete-orphan")
    appointments = relationship("AppointmentModel", back_populates="organization", cascade="all, delete-orphan")
    scripts = relationship("ScriptModel", back_populates="organization", cascade="all, delete-orphan")
    recordings = relationship("RecordingModel", back_populates="organization", cascade="all, delete-orphan")


class UserModel(Base):
    __tablename__ = "users"

    id: Mapped[str] = mapped_column(GUID, primary_key=True, default=lambda: str(uuid4()))
    organization_id: Mapped[str] = mapped_column(GUID, ForeignKey("organizations.id"), nullable=False, index=True)
    email: Mapped[str] = mapped_column(String(255), nullable=False)
    password_hash: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    role: Mapped[str] = mapped_column(String(20), default="agent")
    extension: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)
    sip_uri: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    is_available: Mapped[bool] = mapped_column(Boolean, default=True)
    max_concurrent_calls: Mapped[int] = mapped_column(Integer, default=3)
    permissions: Mapped[Any] = mapped_column(JSON, default=list)
    last_login_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    organization = relationship("OrganizationModel", back_populates="users")


class PhoneProviderConfigModel(Base):
    __tablename__ = "phone_providers"

    id: Mapped[str] = mapped_column(GUID, primary_key=True, default=lambda: str(uuid4()))
    organization_id: Mapped[str] = mapped_column(GUID, ForeignKey("organizations.id"), nullable=False, index=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    provider_type: Mapped[str] = mapped_column(String(30), nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    config: Mapped[Any] = mapped_column(JSON, default=dict)
    credentials: Mapped[Any] = mapped_column(JSON, default=dict)
    phone_numbers: Mapped[Any] = mapped_column(JSON, default=list)
    default_phone_number: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)
    rate_per_minute: Mapped[float] = mapped_column(Float, default=0.0)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class VoiceSettingsModel(Base):
    __tablename__ = "voice_settings"

    id: Mapped[str] = mapped_column(GUID, primary_key=True, default=lambda: str(uuid4()))
    organization_id: Mapped[str] = mapped_column(GUID, ForeignKey("organizations.id"), nullable=False, index=True)
    stt_provider: Mapped[str] = mapped_column(String(30), default="whisper")
    stt_config: Mapped[Any] = mapped_column(JSON, default=dict)
    tts_provider: Mapped[str] = mapped_column(String(30), default="pyttsx3")
    tts_config: Mapped[Any] = mapped_column(JSON, default=dict)
    tts_voice: Mapped[str] = mapped_column(String(50), default="default")
    tts_speed: Mapped[float] = mapped_column(Float, default=1.0)
    tts_pitch: Mapped[float] = mapped_column(Float, default=1.0)
    tts_emotion: Mapped[str] = mapped_column(String(20), default="neutral")
    vad_provider: Mapped[str] = mapped_column(String(20), default="webrtc")
    vad_config: Mapped[Any] = mapped_column(JSON, default=dict)
    noise_suppression: Mapped[bool] = mapped_column(Boolean, default=True)
    echo_cancellation: Mapped[bool] = mapped_column(Boolean, default=True)
    interruption_enabled: Mapped[bool] = mapped_column(Boolean, default=True)
    silence_timeout_ms: Mapped[int] = mapped_column(Integer, default=2000)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class CallModel(Base):
    __tablename__ = "calls"

    id: Mapped[str] = mapped_column(GUID, primary_key=True, default=lambda: str(uuid4()))
    organization_id: Mapped[str] = mapped_column(GUID, ForeignKey("organizations.id"), nullable=False, index=True)
    user_id: Mapped[Optional[str]] = mapped_column(GUID, nullable=True)
    campaign_id: Mapped[Optional[str]] = mapped_column(GUID, nullable=True)
    lead_id: Mapped[Optional[str]] = mapped_column(GUID, nullable=True)
    contact_id: Mapped[Optional[str]] = mapped_column(GUID, nullable=True)
    phone_provider_id: Mapped[Optional[str]] = mapped_column(GUID, nullable=True)
    direction: Mapped[str] = mapped_column(String(10), nullable=False)
    from_number: Mapped[str] = mapped_column(String(20), nullable=False)
    to_number: Mapped[str] = mapped_column(String(20), nullable=False)
    status: Mapped[str] = mapped_column(String(20), default="queued")
    disposition: Mapped[Optional[str]] = mapped_column(String(30), nullable=True)
    duration_seconds: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    billing_duration_seconds: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    cost: Mapped[float] = mapped_column(Float, default=0.0)
    recording_url: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    recording_status: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)
    transcription_url: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    transcription_status: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)
    transcript: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    summary: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    sentiment: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)
    intent: Mapped[Optional[str]] = mapped_column(String(30), nullable=True)
    quality_score: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    ai_handled: Mapped[bool] = mapped_column(Boolean, default=True)
    handoff_to: Mapped[Optional[str]] = mapped_column(GUID, nullable=True)
    handoff_reason: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    notes: Mapped[Any] = mapped_column(JSON, default=list)
    tags: Mapped[Any] = mapped_column(JSON, default=list)
    ivr_digits: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    provider_call_id: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    provider_data: Mapped[Any] = mapped_column(JSON, default=dict)
    extra_data: Mapped[Any] = mapped_column(JSON, default=dict)
    started_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    ended_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    scheduled_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    organization = relationship("OrganizationModel", back_populates="calls")


class CallEventModel(Base):
    __tablename__ = "call_events"

    id: Mapped[str] = mapped_column(GUID, primary_key=True, default=lambda: str(uuid4()))
    call_id: Mapped[str] = mapped_column(GUID, ForeignKey("calls.id"), nullable=False, index=True)
    organization_id: Mapped[str] = mapped_column(GUID, ForeignKey("organizations.id"), nullable=False)
    event_type: Mapped[str] = mapped_column(String(50), nullable=False)
    data: Mapped[Any] = mapped_column(JSON, default=dict)
    timestamp: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)


class CampaignModel(Base):
    __tablename__ = "campaigns"

    id: Mapped[str] = mapped_column(GUID, primary_key=True, default=lambda: str(uuid4()))
    organization_id: Mapped[str] = mapped_column(GUID, ForeignKey("organizations.id"), nullable=False, index=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    type: Mapped[str] = mapped_column(String(30), nullable=False)
    status: Mapped[str] = mapped_column(String(20), default="draft")
    script_id: Mapped[Optional[str]] = mapped_column(GUID, nullable=True)
    phone_provider_id: Mapped[Optional[str]] = mapped_column(GUID, nullable=True)
    caller_id: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)
    target_filter: Mapped[Any] = mapped_column(JSON, default=dict)
    schedule: Mapped[Any] = mapped_column(JSON, default=dict)
    max_calls_per_day: Mapped[int] = mapped_column(Integer, default=100)
    max_attempts: Mapped[int] = mapped_column(Integer, default=3)
    retry_delay_minutes: Mapped[int] = mapped_column(Integer, default=60)
    call_window_start: Mapped[str] = mapped_column(String(5), default="09:00")
    call_window_end: Mapped[str] = mapped_column(String(5), default="18:00")
    working_days: Mapped[Any] = mapped_column(JSON, default=lambda: [0, 1, 2, 3, 4, 5, 6])
    timezone: Mapped[str] = mapped_column(String(50), default="UTC")
    total_calls: Mapped[int] = mapped_column(Integer, default=0)
    total_answered: Mapped[int] = mapped_column(Integer, default=0)
    total_converted: Mapped[int] = mapped_column(Integer, default=0)
    total_cost: Mapped[float] = mapped_column(Float, default=0.0)
    created_by: Mapped[Optional[str]] = mapped_column(GUID, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    organization = relationship("OrganizationModel", back_populates="campaigns")


class LeadModel(Base):
    __tablename__ = "leads"

    id: Mapped[str] = mapped_column(GUID, primary_key=True, default=lambda: str(uuid4()))
    organization_id: Mapped[str] = mapped_column(GUID, ForeignKey("organizations.id"), nullable=False, index=True)
    campaign_id: Mapped[Optional[str]] = mapped_column(GUID, nullable=True)
    first_name: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    last_name: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    phone: Mapped[str] = mapped_column(String(20), nullable=False, index=True)
    email: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    company: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    position: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    status: Mapped[str] = mapped_column(String(20), default="new")
    source: Mapped[str] = mapped_column(String(30), default="manual")
    score: Mapped[float] = mapped_column(Float, default=0.0)
    notes: Mapped[Any] = mapped_column(JSON, default=list)
    tags: Mapped[Any] = mapped_column(JSON, default=list)
    custom_fields: Mapped[Any] = mapped_column(JSON, default=dict)
    last_called_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    call_count: Mapped[int] = mapped_column(Integer, default=0)
    last_disposition: Mapped[Optional[str]] = mapped_column(String(30), nullable=True)
    next_call_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    timezone: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    best_time_to_call: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)
    do_not_call: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    organization = relationship("OrganizationModel", back_populates="leads")


class ContactModel(Base):
    __tablename__ = "contacts"

    id: Mapped[str] = mapped_column(GUID, primary_key=True, default=lambda: str(uuid4()))
    organization_id: Mapped[str] = mapped_column(GUID, ForeignKey("organizations.id"), nullable=False, index=True)
    first_name: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    last_name: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    phone: Mapped[str] = mapped_column(String(20), nullable=False)
    email: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    company: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    position: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    tags: Mapped[Any] = mapped_column(JSON, default=list)
    notes: Mapped[Any] = mapped_column(JSON, default=list)
    custom_fields: Mapped[Any] = mapped_column(JSON, default=dict)
    total_calls: Mapped[int] = mapped_column(Integer, default=0)
    total_spent: Mapped[float] = mapped_column(Float, default=0.0)
    lifetime_value: Mapped[float] = mapped_column(Float, default=0.0)
    last_contact_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    organization = relationship("OrganizationModel", back_populates="contacts")


class AppointmentModel(Base):
    __tablename__ = "appointments"

    id: Mapped[str] = mapped_column(GUID, primary_key=True, default=lambda: str(uuid4()))
    organization_id: Mapped[str] = mapped_column(GUID, ForeignKey("organizations.id"), nullable=False, index=True)
    lead_id: Mapped[Optional[str]] = mapped_column(GUID, nullable=True)
    contact_id: Mapped[Optional[str]] = mapped_column(GUID, nullable=True)
    call_id: Mapped[Optional[str]] = mapped_column(GUID, nullable=True)
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    status: Mapped[str] = mapped_column(String(20), default="scheduled")
    scheduled_at: Mapped[datetime] = mapped_column(DateTime, nullable=False)
    duration_minutes: Mapped[int] = mapped_column(Integer, default=30)
    assigned_to: Mapped[Optional[str]] = mapped_column(GUID, nullable=True)
    reminder_sent: Mapped[bool] = mapped_column(Boolean, default=False)
    notes: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    organization = relationship("OrganizationModel", back_populates="appointments")


class ScriptModel(Base):
    __tablename__ = "scripts"

    id: Mapped[str] = mapped_column(GUID, primary_key=True, default=lambda: str(uuid4()))
    organization_id: Mapped[str] = mapped_column(GUID, ForeignKey("organizations.id"), nullable=False, index=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    type: Mapped[str] = mapped_column(String(30), nullable=False)
    content: Mapped[str] = mapped_column(Text, nullable=False)
    variables: Mapped[Any] = mapped_column(JSON, default=list)
    sections: Mapped[Any] = mapped_column(JSON, default=list)
    tags: Mapped[Any] = mapped_column(JSON, default=list)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    version: Mapped[int] = mapped_column(Integer, default=1)
    created_by: Mapped[Optional[str]] = mapped_column(GUID, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    organization = relationship("OrganizationModel", back_populates="scripts")


class RecordingModel(Base):
    __tablename__ = "recordings"

    id: Mapped[str] = mapped_column(GUID, primary_key=True, default=lambda: str(uuid4()))
    organization_id: Mapped[str] = mapped_column(GUID, ForeignKey("organizations.id"), nullable=False, index=True)
    call_id: Mapped[str] = mapped_column(GUID, ForeignKey("calls.id"), nullable=False)
    file_path: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    file_size: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    duration_seconds: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    mime_type: Mapped[str] = mapped_column(String(50), default="audio/wav")
    status: Mapped[str] = mapped_column(String(20), default="processing")
    transcription_status: Mapped[str] = mapped_column(String(20), default="pending")
    transcription_text: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    is_archived: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    organization = relationship("OrganizationModel", back_populates="recordings")


class KnowledgeDocumentModel(Base):
    __tablename__ = "knowledge_documents"

    id: Mapped[str] = mapped_column(GUID, primary_key=True, default=lambda: str(uuid4()))
    organization_id: Mapped[str] = mapped_column(GUID, ForeignKey("organizations.id"), nullable=False, index=True)
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    type: Mapped[str] = mapped_column(String(20), nullable=False)
    content: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    file_path: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    file_size: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    mime_type: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    source_url: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    tags: Mapped[Any] = mapped_column(JSON, default=list)
    is_indexed: Mapped[bool] = mapped_column(Boolean, default=False)
    chunk_count: Mapped[int] = mapped_column(Integer, default=0)
    extra_data: Mapped[Any] = mapped_column(JSON, default=dict)
    created_by: Mapped[Optional[str]] = mapped_column(GUID, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class PromptTemplateModel(Base):
    __tablename__ = "prompt_templates"

    id: Mapped[str] = mapped_column(GUID, primary_key=True, default=lambda: str(uuid4()))
    organization_id: Mapped[str] = mapped_column(GUID, ForeignKey("organizations.id"), nullable=False, index=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    system_prompt: Mapped[str] = mapped_column(Text, nullable=False)
    context_prompt: Mapped[str] = mapped_column(Text, default="")
    temperature: Mapped[float] = mapped_column(Float, default=0.7)
    max_tokens: Mapped[int] = mapped_column(Integer, default=1024)
    model: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_by: Mapped[Optional[str]] = mapped_column(GUID, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class AuditLogModel(Base):
    __tablename__ = "audit_logs"

    id: Mapped[str] = mapped_column(GUID, primary_key=True, default=lambda: str(uuid4()))
    organization_id: Mapped[str] = mapped_column(GUID, ForeignKey("organizations.id"), nullable=False, index=True)
    user_id: Mapped[Optional[str]] = mapped_column(GUID, nullable=True)
    action: Mapped[str] = mapped_column(String(100), nullable=False)
    resource_type: Mapped[str] = mapped_column(String(50), nullable=False)
    resource_id: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    details: Mapped[Any] = mapped_column(JSON, default=dict)
    ip_address: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    user_agent: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)


class PluginModel(Base):
    __tablename__ = "plugins"

    id: Mapped[str] = mapped_column(GUID, primary_key=True, default=lambda: str(uuid4()))
    organization_id: Mapped[str] = mapped_column(GUID, ForeignKey("organizations.id"), nullable=False, index=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    version: Mapped[str] = mapped_column(String(50), default="1.0.0")
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    entry_point: Mapped[str] = mapped_column(String(500), default="")
    config_schema: Mapped[Any] = mapped_column(JSON, default=dict)
    config: Mapped[Any] = mapped_column(JSON, default=dict)
    is_enabled: Mapped[bool] = mapped_column(Boolean, default=True)
    is_official: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class AnalyticsEventModel(Base):
    __tablename__ = "analytics_events"

    id: Mapped[str] = mapped_column(GUID, primary_key=True, default=lambda: str(uuid4()))
    organization_id: Mapped[str] = mapped_column(GUID, ForeignKey("organizations.id"), nullable=False, index=True)
    metric: Mapped[str] = mapped_column(String(100), nullable=False)
    value: Mapped[float] = mapped_column(Float, default=0.0)
    tags: Mapped[Any] = mapped_column(JSON, default=dict)
    recorded_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
