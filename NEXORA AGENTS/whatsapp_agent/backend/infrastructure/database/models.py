from __future__ import annotations

from datetime import datetime
from decimal import Decimal
from typing import Any, Optional
from uuid import uuid4

from sqlalchemy import JSON, Boolean, Column, DateTime, Enum, Float, ForeignKey, Integer, String, Text, Time, UniqueConstraint
from sqlalchemy.dialects.sqlite import JSON as SQLiteJSON
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship
from sqlalchemy.types import TypeDecorator

from backend.domain.enums import (AgentRole, AnalyticsMetric, CampaignStatus, CampaignType, ConversationStatus,
                                   CustomerTier, HandoffStatus, IntentCategory, KnowledgeType, LanguageCode,
                                   LeadSource, LeadStatus, LogLevel, MessageDirection, MessageStatus,
                                   OrganizationStatus, Permission, PipelineStage, SentimentLabel,
                                   WhatsAppAccountStatus, WorkflowActionType, WorkflowStatus, WorkflowTriggerType)


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
    working_hours_start: Mapped[str] = mapped_column(String(5), default="09:00")
    working_hours_end: Mapped[str] = mapped_column(String(5), default="18:00")
    working_days: Mapped[Any] = mapped_column(JSON, default=lambda: [0, 1, 2, 3, 4, 5, 6])
    default_language: Mapped[str] = mapped_column(String(10), default="en")
    max_whatsapp_accounts: Mapped[int] = mapped_column(Integer, default=5)
    max_users: Mapped[int] = mapped_column(Integer, default=10)
    max_leads: Mapped[int] = mapped_column(Integer, default=10000)
    extra_data: Mapped[Any] = mapped_column(JSON, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    whatsapp_accounts = relationship("WhatsAppAccountModel", back_populates="organization", cascade="all, delete-orphan")
    users = relationship("UserModel", back_populates="organization", cascade="all, delete-orphan")
    departments = relationship("DepartmentModel", back_populates="organization", cascade="all, delete-orphan")
    conversations = relationship("ConversationModel", back_populates="organization", cascade="all, delete-orphan")
    leads = relationship("LeadModel", back_populates="organization", cascade="all, delete-orphan")
    customers = relationship("CustomerModel", back_populates="organization", cascade="all, delete-orphan")
    knowledge_documents = relationship("KnowledgeDocumentModel", back_populates="organization", cascade="all, delete-orphan")
    workflows = relationship("WorkflowModel", back_populates="organization", cascade="all, delete-orphan")
    campaigns = relationship("CampaignModel", back_populates="organization", cascade="all, delete-orphan")
    prompt_templates = relationship("PromptTemplateModel", back_populates="organization", cascade="all, delete-orphan")
    audit_logs = relationship("AuditLogModel", back_populates="organization", cascade="all, delete-orphan")


class WhatsAppAccountModel(Base):
    __tablename__ = "whatsapp_accounts"

    id: Mapped[str] = mapped_column(GUID, primary_key=True, default=lambda: str(uuid4()))
    organization_id: Mapped[str] = mapped_column(GUID, ForeignKey("organizations.id"), nullable=False, index=True)
    phone_number: Mapped[str] = mapped_column(String(20), nullable=False)
    phone_number_id: Mapped[str] = mapped_column(String(100), default="")
    waba_id: Mapped[str] = mapped_column(String(100), default="")
    business_name: Mapped[str] = mapped_column(String(255), default="")
    status: Mapped[str] = mapped_column(String(20), default="disconnected")
    qr_code: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    qr_expires_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    session_data: Mapped[Optional[Any]] = mapped_column(JSON, nullable=True)
    webhook_url: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    webhook_secret: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    rate_limit_per_minute: Mapped[int] = mapped_column(Integer, default=30)
    daily_message_limit: Mapped[int] = mapped_column(Integer, default=1000)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    last_connected_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    last_health_check: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    health_status: Mapped[str] = mapped_column(String(20), default="unknown")
    error_message: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    organization = relationship("OrganizationModel", back_populates="whatsapp_accounts")
    conversations = relationship("ConversationModel", back_populates="whatsapp_account", cascade="all, delete-orphan")


class DepartmentModel(Base):
    __tablename__ = "departments"

    id: Mapped[str] = mapped_column(GUID, primary_key=True, default=lambda: str(uuid4()))
    organization_id: Mapped[str] = mapped_column(GUID, ForeignKey("organizations.id"), nullable=False, index=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    whatsapp_account_ids: Mapped[Any] = mapped_column(JSON, default=list)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    organization = relationship("OrganizationModel", back_populates="departments")


class UserModel(Base):
    __tablename__ = "users"

    id: Mapped[str] = mapped_column(GUID, primary_key=True, default=lambda: str(uuid4()))
    organization_id: Mapped[str] = mapped_column(GUID, ForeignKey("organizations.id"), nullable=False, index=True)
    email: Mapped[str] = mapped_column(String(255), nullable=False)
    password_hash: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    role: Mapped[str] = mapped_column(String(20), default="agent")
    department_ids: Mapped[Any] = mapped_column(JSON, default=list)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    is_available: Mapped[bool] = mapped_column(Boolean, default=True)
    max_concurrent_chats: Mapped[int] = mapped_column(Integer, default=5)
    permissions: Mapped[Any] = mapped_column(JSON, default=list)
    last_login_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    organization = relationship("OrganizationModel", back_populates="users")


class ConversationModel(Base):
    __tablename__ = "conversations"

    id: Mapped[str] = mapped_column(GUID, primary_key=True, default=lambda: str(uuid4()))
    organization_id: Mapped[str] = mapped_column(GUID, ForeignKey("organizations.id"), nullable=False, index=True)
    whatsapp_account_id: Mapped[str] = mapped_column(GUID, ForeignKey("whatsapp_accounts.id"), nullable=False)
    customer_phone: Mapped[str] = mapped_column(String(20), nullable=False, index=True)
    customer_name: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    status: Mapped[str] = mapped_column(String(20), default="active")
    assigned_to: Mapped[Optional[str]] = mapped_column(GUID, nullable=True)
    assigned_department: Mapped[Optional[str]] = mapped_column(GUID, nullable=True)
    department_id: Mapped[Optional[str]] = mapped_column(GUID, nullable=True)
    tags: Mapped[Any] = mapped_column(JSON, default=list)
    is_pinned: Mapped[bool] = mapped_column(Boolean, default=False)
    is_unread: Mapped[bool] = mapped_column(Boolean, default=True)
    is_archived: Mapped[bool] = mapped_column(Boolean, default=False)
    handoff_status: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)
    handoff_requested_by: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)
    handoff_assigned_to: Mapped[Optional[str]] = mapped_column(GUID, nullable=True)
    handoff_note: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    sentiment: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)
    language: Mapped[Optional[str]] = mapped_column(String(10), nullable=True)
    intent: Mapped[Optional[str]] = mapped_column(String(30), nullable=True)
    summary: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    message_count: Mapped[int] = mapped_column(Integer, default=0)
    last_message_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    last_message_preview: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    ai_active: Mapped[bool] = mapped_column(Boolean, default=True)
    lead_id: Mapped[Optional[str]] = mapped_column(GUID, nullable=True)
    extra_data: Mapped[Any] = mapped_column(JSON, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    organization = relationship("OrganizationModel", back_populates="conversations")
    whatsapp_account = relationship("WhatsAppAccountModel", back_populates="conversations")
    messages = relationship("MessageModel", back_populates="conversation", cascade="all, delete-orphan")


class MessageModel(Base):
    __tablename__ = "messages"

    id: Mapped[str] = mapped_column(GUID, primary_key=True, default=lambda: str(uuid4()))
    organization_id: Mapped[str] = mapped_column(GUID, ForeignKey("organizations.id"), nullable=False, index=True)
    conversation_id: Mapped[str] = mapped_column(GUID, ForeignKey("conversations.id"), nullable=False, index=True)
    whatsapp_message_id: Mapped[Optional[str]] = mapped_column(String(100), nullable=True, index=True)
    direction: Mapped[str] = mapped_column(String(10), nullable=False)
    from_phone: Mapped[str] = mapped_column(String(20), nullable=False)
    to_phone: Mapped[str] = mapped_column(String(20), nullable=False)
    content: Mapped[str] = mapped_column(Text, nullable=False)
    content_type: Mapped[str] = mapped_column(String(20), default="text")
    media_url: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    media_mime_type: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    status: Mapped[str] = mapped_column(String(20), default="sent")
    is_ai_generated: Mapped[bool] = mapped_column(Boolean, default=False)
    is_handoff_message: Mapped[bool] = mapped_column(Boolean, default=False)
    extra_data: Mapped[Any] = mapped_column(JSON, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    conversation = relationship("ConversationModel", back_populates="messages")


class LeadModel(Base):
    __tablename__ = "leads"

    id: Mapped[str] = mapped_column(GUID, primary_key=True, default=lambda: str(uuid4()))
    organization_id: Mapped[str] = mapped_column(GUID, ForeignKey("organizations.id"), nullable=False, index=True)
    conversation_id: Mapped[Optional[str]] = mapped_column(GUID, nullable=True)
    customer_phone: Mapped[str] = mapped_column(String(20), nullable=False)
    customer_name: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    customer_email: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    status: Mapped[str] = mapped_column(String(20), default="new")
    source: Mapped[str] = mapped_column(String(30), default="whatsapp")
    score: Mapped[float] = mapped_column(Float, default=0.0)
    pipeline_stage: Mapped[str] = mapped_column(String(30), default="new_lead")
    pipeline_id: Mapped[Optional[str]] = mapped_column(GUID, nullable=True)
    assigned_to: Mapped[Optional[str]] = mapped_column(GUID, nullable=True)
    department_id: Mapped[Optional[str]] = mapped_column(GUID, nullable=True)
    tags: Mapped[Any] = mapped_column(JSON, default=list)
    notes: Mapped[Any] = mapped_column(JSON, default=list)
    timeline: Mapped[Any] = mapped_column(JSON, default=list)
    custom_fields: Mapped[Any] = mapped_column(JSON, default=dict)
    extra_data: Mapped[Any] = mapped_column(JSON, default=dict)
    converted_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    converted_to_customer_id: Mapped[Optional[str]] = mapped_column(GUID, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    organization = relationship("OrganizationModel", back_populates="leads")


class CustomerModel(Base):
    __tablename__ = "customers"

    id: Mapped[str] = mapped_column(GUID, primary_key=True, default=lambda: str(uuid4()))
    organization_id: Mapped[str] = mapped_column(GUID, ForeignKey("organizations.id"), nullable=False, index=True)
    phone: Mapped[str] = mapped_column(String(20), nullable=False)
    name: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    email: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    tier: Mapped[str] = mapped_column(String(20), default="bronze")
    tags: Mapped[Any] = mapped_column(JSON, default=list)
    notes: Mapped[Any] = mapped_column(JSON, default=list)
    custom_fields: Mapped[Any] = mapped_column(JSON, default=dict)
    total_conversations: Mapped[int] = mapped_column(Integer, default=0)
    total_spent: Mapped[Decimal] = mapped_column(Float, default=0.0)
    lifetime_value: Mapped[Decimal] = mapped_column(Float, default=0.0)
    last_contact_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    extra_data: Mapped[Any] = mapped_column(JSON, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    organization = relationship("OrganizationModel", back_populates="customers")


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

    organization = relationship("OrganizationModel", back_populates="knowledge_documents")


class WorkflowModel(Base):
    __tablename__ = "workflows"

    id: Mapped[str] = mapped_column(GUID, primary_key=True, default=lambda: str(uuid4()))
    organization_id: Mapped[str] = mapped_column(GUID, ForeignKey("organizations.id"), nullable=False, index=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    trigger_type: Mapped[str] = mapped_column(String(30), nullable=False)
    trigger_config: Mapped[Any] = mapped_column(JSON, default=dict)
    steps: Mapped[Any] = mapped_column(JSON, default=list)
    status: Mapped[str] = mapped_column(String(20), default="active")
    is_editable: Mapped[bool] = mapped_column(Boolean, default=True)
    execution_count: Mapped[int] = mapped_column(Integer, default=0)
    last_executed_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    created_by: Mapped[Optional[str]] = mapped_column(GUID, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    organization = relationship("OrganizationModel", back_populates="workflows")


class CampaignModel(Base):
    __tablename__ = "campaigns"

    id: Mapped[str] = mapped_column(GUID, primary_key=True, default=lambda: str(uuid4()))
    organization_id: Mapped[str] = mapped_column(GUID, ForeignKey("organizations.id"), nullable=False, index=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    type: Mapped[str] = mapped_column(String(20), default="broadcast")
    template_id: Mapped[Optional[str]] = mapped_column(GUID, nullable=True)
    whatsapp_account_id: Mapped[Optional[str]] = mapped_column(GUID, nullable=True)
    target_filter: Mapped[Any] = mapped_column(JSON, default=dict)
    message_template: Mapped[str] = mapped_column(Text, default="")
    status: Mapped[str] = mapped_column(String(20), default="draft")
    scheduled_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    sent_count: Mapped[int] = mapped_column(Integer, default=0)
    delivered_count: Mapped[int] = mapped_column(Integer, default=0)
    read_count: Mapped[int] = mapped_column(Integer, default=0)
    replied_count: Mapped[int] = mapped_column(Integer, default=0)
    opted_out_count: Mapped[int] = mapped_column(Integer, default=0)
    total_recipients: Mapped[int] = mapped_column(Integer, default=0)
    created_by: Mapped[Optional[str]] = mapped_column(GUID, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    organization = relationship("OrganizationModel", back_populates="campaigns")


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

    organization = relationship("OrganizationModel", back_populates="prompt_templates")


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

    organization = relationship("OrganizationModel", back_populates="audit_logs")


class WorkflowExecutionModel(Base):
    __tablename__ = "workflow_executions"

    id: Mapped[str] = mapped_column(GUID, primary_key=True, default=lambda: str(uuid4()))
    workflow_id: Mapped[str] = mapped_column(GUID, ForeignKey("workflows.id"), nullable=False, index=True)
    organization_id: Mapped[str] = mapped_column(GUID, ForeignKey("organizations.id"), nullable=False, index=True)
    trigger_type: Mapped[str] = mapped_column(String(30), nullable=False)
    trigger_data: Mapped[Any] = mapped_column(JSON, default=dict)
    status: Mapped[str] = mapped_column(String(20), default="running")
    current_step: Mapped[int] = mapped_column(Integer, default=0)
    total_steps: Mapped[int] = mapped_column(Integer, default=0)
    steps_completed: Mapped[int] = mapped_column(Integer, default=0)
    steps_failed: Mapped[int] = mapped_column(Integer, default=0)
    error_message: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    started_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    completed_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)


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
