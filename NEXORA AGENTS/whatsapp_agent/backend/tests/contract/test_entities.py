from uuid import UUID

import pytest

from backend.domain.entities import (
    AnalyticsEvent, AuditLog, Campaign, Conversation, Customer, Department,
    KnowledgeDocument, Lead, Message, Organization, Plugin, PromptTemplate,
    User, WhatsAppAccount, WebhookEvent, Workflow, WorkflowExecution,
)
from backend.domain.enums import (
    AgentRole, AnalyticsMetric, CampaignStatus, CampaignType, ConversationStatus,
    CustomerTier, HandoffStatus, IntentCategory, KnowledgeType, LanguageCode,
    LeadSource, LeadStatus, LogLevel, MessageDirection, MessageStatus,
    OrganizationStatus, Permission, PipelineStage, SentimentLabel,
    WhatsAppAccountStatus, WorkflowActionType, WorkflowStatus, WorkflowTriggerType,
)


ALL_ENTITY_CLASSES = [
    Organization, WhatsAppAccount, Department, User, Conversation, Message,
    Lead, Customer, KnowledgeDocument, Workflow, WorkflowExecution, Campaign,
    AnalyticsEvent, AuditLog, PromptTemplate, Plugin, WebhookEvent,
]


ALL_ENUM_CLASSES = [
    OrganizationStatus, WhatsAppAccountStatus, ConversationStatus,
    MessageDirection, MessageStatus, LeadStatus, LeadSource, PipelineStage,
    CustomerTier, CampaignStatus, CampaignType, WorkflowStatus,
    WorkflowTriggerType, WorkflowActionType, HandoffStatus, AgentRole,
    Permission, KnowledgeType, SentimentLabel, IntentCategory, LanguageCode,
    LogLevel, AnalyticsMetric,
]


class TestEntityShape:
    @pytest.mark.parametrize("entity_cls", ALL_ENTITY_CLASSES)
    def test_entity_has_from_attributes_config(self, entity_cls):
        assert hasattr(entity_cls, "Config"), f"{entity_cls.__name__} missing Config"
        assert hasattr(entity_cls.Config, "from_attributes"), (
            f"{entity_cls.__name__}.Config missing from_attributes"
        )
        assert entity_cls.Config.from_attributes is True

    @pytest.mark.parametrize("entity_cls", ALL_ENTITY_CLASSES)
    def test_entity_is_pydantic_model(self, entity_cls):
        import pydantic
        assert issubclass(entity_cls, pydantic.BaseModel)

    @pytest.mark.parametrize("entity_cls", ALL_ENTITY_CLASSES)
    def test_entity_has_id_field(self, entity_cls):
        assert "id" in entity_cls.model_fields, f"{entity_cls.__name__} missing id field"
        field = entity_cls.model_fields["id"]
        assert field.annotation == UUID or str(field.annotation).startswith("UUID")

    @pytest.mark.parametrize("entity_cls", ALL_ENTITY_CLASSES)
    def test_entity_has_created_at(self, entity_cls):
        from datetime import datetime
        if hasattr(entity_cls, "model_fields"):
            if "created_at" in entity_cls.model_fields:
                field = entity_cls.model_fields["created_at"]
                assert field.annotation == datetime or "datetime" in str(field.annotation)


class TestOrganizationShape:
    def test_required_fields(self):
        required = {"name", "slug"}
        for field_name in required:
            assert field_name in Organization.model_fields, f"Organization missing {field_name}"
        assert Organization.model_fields["name"].is_required()
        assert Organization.model_fields["slug"].is_required()

    def test_default_values(self):
        org = Organization(name="T", slug="t")
        assert org.status == "active"
        assert org.timezone == "UTC"
        assert org.brand_color == "#6366f1"
        assert org.working_days == [0, 1, 2, 3, 4, 5, 6]
        assert org.max_whatsapp_accounts == 5
        assert org.max_users == 10
        assert org.max_leads == 10000


class TestWhatsAppAccountShape:
    def test_required_fields(self):
        assert "organization_id" in WhatsAppAccount.model_fields
        assert "phone_number" in WhatsAppAccount.model_fields
        assert WhatsAppAccount.model_fields["phone_number"].is_required()

    def test_default_values(self):
        wa = WhatsAppAccount(organization_id=UUID(int=0), phone_number="+1")
        assert wa.status == "disconnected"
        assert wa.health_status == "unknown"
        assert wa.is_active is True
        assert wa.rate_limit_per_minute == 30


class TestConversationShape:
    def test_required_fields(self):
        for f in ("organization_id", "whatsapp_account_id", "customer_phone"):
            assert f in Conversation.model_fields

    def test_default_values(self):
        conv = Conversation(organization_id=UUID(int=0), whatsapp_account_id=UUID(int=0), customer_phone="+1")
        assert conv.status == "active"
        assert conv.is_unread is True
        assert conv.is_pinned is False
        assert conv.ai_active is True


class TestLeadShape:
    def test_required_fields(self):
        for f in ("organization_id", "customer_phone"):
            assert f in Lead.model_fields

    def test_default_values(self):
        lead = Lead(organization_id=UUID(int=0), customer_phone="+1")
        assert lead.status == "new"
        assert lead.source == "whatsapp"
        assert lead.score == 0.0
        assert lead.pipeline_stage == "new_lead"


class TestMessageShape:
    def test_required_fields(self):
        for f in ("organization_id", "conversation_id", "direction", "from_phone", "to_phone", "content"):
            assert f in Message.model_fields

    def test_default_values(self):
        from uuid import uuid4
        msg = Message(organization_id=uuid4(), conversation_id=uuid4(), direction="inbound", from_phone="+1", to_phone="+2", content="hi")
        assert msg.content_type == "text"
        assert msg.status == "sent"
        assert msg.is_ai_generated is False


class TestEnumShape:
    @pytest.mark.parametrize("enum_cls", ALL_ENUM_CLASSES)
    def test_enum_is_str_enum(self, enum_cls):
        import enum
        assert issubclass(enum_cls, (str, enum.Enum))

    @pytest.mark.parametrize("enum_cls", ALL_ENUM_CLASSES)
    def test_enum_has_at_least_one_value(self, enum_cls):
        assert len(enum_cls) > 0

    def test_organization_status_values(self):
        expected = {"active", "suspended", "trial", "cancelled"}
        actual = {e.value for e in OrganizationStatus}
        assert actual == expected

    def test_whatsapp_account_status_values(self):
        expected = {"disconnected", "connecting", "connected", "expired", "banned", "error"}
        actual = {e.value for e in WhatsAppAccountStatus}
        assert actual == expected

    def test_conversation_status_values(self):
        expected = {"active", "paused", "resolved", "archived", "spam"}
        actual = {e.value for e in ConversationStatus}
        assert actual == expected

    def test_message_direction_values(self):
        expected = {"inbound", "outbound"}
        actual = {e.value for e in MessageDirection}
        assert actual == expected

    def test_lead_status_values(self):
        expected = {"new", "qualified", "disqualified", "converted", "lost"}
        actual = {e.value for e in LeadStatus}
        assert actual == expected

    def test_lead_source_values(self):
        expected = {"whatsapp", "website", "referral", "campaign", "manual", "api"}
        actual = {e.value for e in LeadSource}
        assert actual == expected

    def test_sentiment_label_values(self):
        expected = {"very_negative", "negative", "neutral", "positive", "very_positive"}
        actual = {e.value for e in SentimentLabel}
        assert actual == expected

    def test_intent_category_values(self):
        expected = {"greeting", "information", "complaint", "purchase", "support", "feedback", "handoff", "spam", "unknown"}
        actual = {e.value for e in IntentCategory}
        assert actual == expected

    def test_agent_role_values(self):
        expected = {"admin", "supervisor", "agent", "viewer"}
        actual = {e.value for e in AgentRole}
        assert actual == expected

    def test_permission_values(self):
        expected = {
            "view_dashboard", "view_inbox", "manage_inbox", "view_crm", "manage_crm",
            "view_knowledge", "manage_knowledge", "view_workflows", "manage_workflows",
            "view_campaigns", "manage_campaigns", "view_analytics", "view_settings",
            "manage_settings", "manage_team", "manage_permissions", "manage_whatsapp",
            "view_logs", "view_health", "manage_plugins", "manage_models",
        }
        actual = {e.value for e in Permission}
        assert actual == expected
