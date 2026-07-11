from __future__ import annotations

from datetime import datetime, time
from decimal import Decimal
from typing import Any, Optional
from uuid import UUID, uuid4

from pydantic import BaseModel, EmailStr, Field

from backend.domain.enums import AgentRole, LogLevel


class Organization(BaseModel):
    id: UUID = Field(default_factory=uuid4)
    name: str
    slug: str
    status: str = "active"
    timezone: str = "UTC"
    brand_color: str = "#6366f1"
    brand_logo_url: Optional[str] = None
    working_hours_start: time = time(9, 0)
    working_hours_end: time = time(18, 0)
    working_days: list[int] = [0, 1, 2, 3, 4, 5, 6]
    default_language: str = "en"
    max_whatsapp_accounts: int = 5
    max_users: int = 10
    max_leads: int = 10000
    extra_data: dict[str, Any] = Field(default_factory=dict)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        from_attributes = True


class WhatsAppAccount(BaseModel):
    id: UUID = Field(default_factory=uuid4)
    organization_id: UUID
    phone_number: str
    phone_number_id: str = ""
    waba_id: str = ""
    business_name: str = ""
    status: str = "disconnected"
    qr_code: Optional[str] = None
    qr_expires_at: Optional[datetime] = None
    session_data: Optional[dict[str, Any]] = None
    webhook_url: Optional[str] = None
    webhook_secret: Optional[str] = None
    rate_limit_per_minute: int = 30
    daily_message_limit: int = 1000
    is_active: bool = True
    last_connected_at: Optional[datetime] = None
    last_health_check: Optional[datetime] = None
    health_status: str = "unknown"
    error_message: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        from_attributes = True


class Department(BaseModel):
    id: UUID = Field(default_factory=uuid4)
    organization_id: UUID
    name: str
    description: Optional[str] = None
    whatsapp_account_ids: list[UUID] = Field(default_factory=list)
    is_active: bool = True
    created_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        from_attributes = True


class User(BaseModel):
    id: UUID = Field(default_factory=uuid4)
    organization_id: UUID
    email: EmailStr
    name: str
    role: str = "agent"
    department_ids: list[UUID] = Field(default_factory=list)
    is_active: bool = True
    is_available: bool = True
    max_concurrent_chats: int = 5
    permissions: list[str] = Field(default_factory=list)
    last_login_at: Optional[datetime] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        from_attributes = True


class Conversation(BaseModel):
    id: UUID = Field(default_factory=uuid4)
    organization_id: UUID
    whatsapp_account_id: UUID
    customer_phone: str
    customer_name: Optional[str] = None
    status: str = "active"
    assigned_to: Optional[UUID] = None
    assigned_department: Optional[UUID] = None
    department_id: Optional[UUID] = None
    tags: list[str] = Field(default_factory=list)
    is_pinned: bool = False
    is_unread: bool = True
    is_archived: bool = False
    handoff_status: Optional[str] = None
    handoff_requested_by: Optional[str] = None
    handoff_assigned_to: Optional[UUID] = None
    handoff_note: Optional[str] = None
    sentiment: Optional[str] = None
    language: Optional[str] = None
    intent: Optional[str] = None
    summary: Optional[str] = None
    message_count: int = 0
    last_message_at: Optional[datetime] = None
    last_message_preview: Optional[str] = None
    ai_active: bool = True
    lead_id: Optional[UUID] = None
    extra_data: dict[str, Any] = Field(default_factory=dict)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        from_attributes = True


class Message(BaseModel):
    id: UUID = Field(default_factory=uuid4)
    organization_id: UUID
    conversation_id: UUID
    whatsapp_message_id: Optional[str] = None
    direction: str
    from_phone: str
    to_phone: str
    content: str
    content_type: str = "text"
    media_url: Optional[str] = None
    media_mime_type: Optional[str] = None
    status: str = "sent"
    is_ai_generated: bool = False
    is_handoff_message: bool = False
    extra_data: dict[str, Any] = Field(default_factory=dict)
    created_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        from_attributes = True


class Lead(BaseModel):
    id: UUID = Field(default_factory=uuid4)
    organization_id: UUID
    conversation_id: Optional[UUID] = None
    customer_phone: str
    customer_name: Optional[str] = None
    customer_email: Optional[EmailStr] = None
    status: str = "new"
    source: str = "whatsapp"
    score: float = 0.0
    pipeline_stage: str = "new_lead"
    pipeline_id: Optional[UUID] = None
    assigned_to: Optional[UUID] = None
    department_id: Optional[UUID] = None
    tags: list[str] = Field(default_factory=list)
    notes: list[dict[str, Any]] = Field(default_factory=list)
    timeline: list[dict[str, Any]] = Field(default_factory=list)
    custom_fields: dict[str, Any] = Field(default_factory=dict)
    extra_data: dict[str, Any] = Field(default_factory=dict)
    converted_at: Optional[datetime] = None
    converted_to_customer_id: Optional[UUID] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        from_attributes = True


class Customer(BaseModel):
    id: UUID = Field(default_factory=uuid4)
    organization_id: UUID
    phone: str
    name: Optional[str] = None
    email: Optional[EmailStr] = None
    tier: str = "bronze"
    tags: list[str] = Field(default_factory=list)
    notes: list[dict[str, Any]] = Field(default_factory=list)
    custom_fields: dict[str, Any] = Field(default_factory=dict)
    total_conversations: int = 0
    total_spent: Decimal = Decimal("0.00")
    lifetime_value: Decimal = Decimal("0.00")
    last_contact_at: Optional[datetime] = None
    extra_data: dict[str, Any] = Field(default_factory=dict)
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


class Workflow(BaseModel):
    id: UUID = Field(default_factory=uuid4)
    organization_id: UUID
    name: str
    description: Optional[str] = None
    trigger_type: str
    trigger_config: dict[str, Any] = Field(default_factory=dict)
    steps: list[dict[str, Any]] = Field(default_factory=list)
    status: str = "active"
    is_editable: bool = True
    execution_count: int = 0
    last_executed_at: Optional[datetime] = None
    created_by: Optional[UUID] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        from_attributes = True


class WorkflowExecution(BaseModel):
    id: UUID = Field(default_factory=uuid4)
    workflow_id: UUID
    organization_id: UUID
    trigger_type: str
    trigger_data: dict[str, Any] = Field(default_factory=dict)
    status: str = "running"
    current_step: int = 0
    total_steps: int = 0
    steps_completed: int = 0
    steps_failed: int = 0
    error_message: Optional[str] = None
    started_at: datetime = Field(default_factory=datetime.utcnow)
    completed_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class Campaign(BaseModel):
    id: UUID = Field(default_factory=uuid4)
    organization_id: UUID
    name: str
    type: str = "broadcast"
    template_id: Optional[UUID] = None
    whatsapp_account_id: Optional[UUID] = None
    target_filter: dict[str, Any] = Field(default_factory=dict)
    message_template: str = ""
    status: str = "draft"
    scheduled_at: Optional[datetime] = None
    sent_count: int = 0
    delivered_count: int = 0
    read_count: int = 0
    replied_count: int = 0
    opted_out_count: int = 0
    total_recipients: int = 0
    created_by: Optional[UUID] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        from_attributes = True


class AnalyticsEvent(BaseModel):
    id: UUID = Field(default_factory=uuid4)
    organization_id: UUID
    metric: str
    value: float
    tags: dict[str, str] = Field(default_factory=dict)
    recorded_at: datetime = Field(default_factory=datetime.utcnow)

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


class WebhookEvent(BaseModel):
    id: UUID = Field(default_factory=uuid4)
    organization_id: UUID
    whatsapp_account_id: Optional[UUID] = None
    event_type: str
    payload: dict[str, Any] = Field(default_factory=dict)
    status: str = "pending"
    processed_at: Optional[datetime] = None
    error_message: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        from_attributes = True
