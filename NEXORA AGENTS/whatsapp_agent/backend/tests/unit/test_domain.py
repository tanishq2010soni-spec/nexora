from datetime import datetime, time
from uuid import UUID, uuid4

import pytest

from backend.domain.entities import (
    Organization, WhatsAppAccount, Conversation, Lead, Message, Customer,
    Department, User, KnowledgeDocument, Workflow, Campaign, AnalyticsEvent,
    AuditLog, PromptTemplate, Plugin, WebhookEvent, WorkflowExecution,
)
from backend.domain.enums import (
    OrganizationStatus, WhatsAppAccountStatus, ConversationStatus,
    MessageDirection, MessageStatus, LeadStatus, LeadSource, PipelineStage,
    CustomerTier, CampaignStatus, CampaignType, WorkflowStatus,
    WorkflowTriggerType, WorkflowActionType, HandoffStatus, AgentRole,
    Permission, KnowledgeType, SentimentLabel, IntentCategory, LanguageCode,
    LogLevel, AnalyticsMetric,
)


class TestOrganization:
    def test_create_organization(self):
        org = Organization(name="Test Corp", slug="test-corp")
        assert isinstance(org.id, UUID)
        assert org.name == "Test Corp"
        assert org.slug == "test-corp"
        assert org.status == "active"
        assert org.timezone == "UTC"
        assert org.brand_color == "#6366f1"
        assert org.working_hours_start == time(9, 0)
        assert org.working_hours_end == time(18, 0)
        assert org.working_days == [0, 1, 2, 3, 4, 5, 6]
        assert org.default_language == "en"
        assert org.max_whatsapp_accounts == 5
        assert org.max_users == 10
        assert org.max_leads == 10000
        assert org.extra_data == {}
        assert isinstance(org.created_at, datetime)
        assert isinstance(org.updated_at, datetime)

    def test_organization_from_attributes(self):
        data = {
            "id": str(uuid4()),
            "name": "Attr Org",
            "slug": "attr-org",
            "status": "active",
            "timezone": "America/New_York",
            "brand_color": "#000000",
        }
        org = Organization.model_validate(data)
        assert org.name == "Attr Org"
        assert org.slug == "attr-org"
        assert org.timezone == "America/New_York"

    def test_organization_default_status_enum(self):
        org = Organization(name="E", slug="e")
        assert org.status == OrganizationStatus.active.value


class TestWhatsAppAccount:
    def test_create_whatsapp_account(self):
        org_id = uuid4()
        acc = WhatsAppAccount(organization_id=org_id, phone_number="+1234567890")
        assert isinstance(acc.id, UUID)
        assert acc.organization_id == org_id
        assert acc.phone_number == "+1234567890"
        assert acc.status == "disconnected"
        assert acc.is_active is True
        assert acc.health_status == "unknown"
        assert acc.rate_limit_per_minute == 30
        assert acc.daily_message_limit == 1000

    def test_whatsapp_account_from_attributes(self):
        org_id = uuid4()
        acc_id = uuid4()
        data = {
            "id": str(acc_id),
            "organization_id": str(org_id),
            "phone_number": "+1987654321",
            "business_name": "Biz",
            "status": "connected",
        }
        acc = WhatsAppAccount.model_validate(data)
        assert acc.id == acc_id
        assert acc.organization_id == org_id
        assert acc.business_name == "Biz"
        assert acc.status == "connected"


class TestConversation:
    def test_create_conversation(self):
        org_id = uuid4()
        wa_id = uuid4()
        conv = Conversation(
            organization_id=org_id,
            whatsapp_account_id=wa_id,
            customer_phone="+1234567890",
        )
        assert isinstance(conv.id, UUID)
        assert conv.status == "active"
        assert conv.is_unread is True
        assert conv.is_archived is False
        assert conv.is_pinned is False
        assert conv.ai_active is True
        assert conv.message_count == 0
        assert conv.tags == []

    def test_conversation_from_attributes(self):
        org_id = uuid4()
        wa_id = uuid4()
        conv_id = uuid4()
        data = {
            "id": str(conv_id),
            "organization_id": str(org_id),
            "whatsapp_account_id": str(wa_id),
            "customer_phone": "+5555555555",
            "customer_name": "John Doe",
            "status": "resolved",
            "tags": ["support"],
        }
        conv = Conversation.model_validate(data)
        assert conv.id == conv_id
        assert conv.customer_name == "John Doe"
        assert conv.status == "resolved"
        assert conv.tags == ["support"]


class TestLead:
    def test_create_lead(self):
        org_id = uuid4()
        lead = Lead(organization_id=org_id, customer_phone="+1234567890")
        assert isinstance(lead.id, UUID)
        assert lead.status == "new"
        assert lead.source == "whatsapp"
        assert lead.score == 0.0
        assert lead.pipeline_stage == "new_lead"
        assert lead.tags == []
        assert lead.notes == []
        assert lead.timeline == []
        assert lead.custom_fields == {}
        assert lead.converted_at is None

    def test_lead_from_attributes(self):
        org_id = uuid4()
        lead_id = uuid4()
        data = {
            "id": str(lead_id),
            "organization_id": str(org_id),
            "customer_phone": "+9999999999",
            "customer_name": "Jane",
            "status": "qualified",
            "score": 85.5,
            "source": "website",
        }
        lead = Lead.model_validate(data)
        assert lead.id == lead_id
        assert lead.customer_name == "Jane"
        assert lead.status == "qualified"
        assert lead.score == 85.5
        assert lead.source == "website"

    def test_lead_enum_values(self):
        assert LeadStatus.new.value == "new"
        assert LeadStatus.qualified.value == "qualified"
        assert LeadStatus.converted.value == "converted"
        assert LeadSource.whatsapp.value == "whatsapp"
        assert LeadSource.website.value == "website"
        assert PipelineStage.new_lead.value == "new_lead"
        assert PipelineStage.closed_won.value == "closed_won"


class TestMessage:
    def test_create_message(self):
        org_id = uuid4()
        conv_id = uuid4()
        msg = Message(
            organization_id=org_id,
            conversation_id=conv_id,
            direction="inbound",
            from_phone="+sender",
            to_phone="+receiver",
            content="Hello, world!",
        )
        assert isinstance(msg.id, UUID)
        assert msg.direction == "inbound"
        assert msg.content == "Hello, world!"
        assert msg.content_type == "text"
        assert msg.status == "sent"
        assert msg.is_ai_generated is False

    def test_message_from_attributes(self):
        org_id = uuid4()
        conv_id = uuid4()
        data = {
            "id": str(uuid4()),
            "organization_id": str(org_id),
            "conversation_id": str(conv_id),
            "direction": "outbound",
            "from_phone": "+agent",
            "to_phone": "+customer",
            "content": "How can I help?",
            "content_type": "text",
            "status": "delivered",
        }
        msg = Message.model_validate(data)
        assert msg.direction == "outbound"
        assert msg.status == "delivered"
        assert msg.content == "How can I help?"

    def test_message_enum_values(self):
        assert MessageDirection.inbound.value == "inbound"
        assert MessageDirection.outbound.value == "outbound"
        assert MessageStatus.sent.value == "sent"
        assert MessageStatus.delivered.value == "delivered"
        assert MessageStatus.read.value == "read"
        assert MessageStatus.failed.value == "failed"


class TestCustomer:
    def test_create_customer(self):
        org_id = uuid4()
        cust = Customer(organization_id=org_id, phone="+1234567890")
        assert isinstance(cust.id, UUID)
        assert cust.phone == "+1234567890"
        assert cust.tier == "bronze"
        assert cust.total_conversations == 0

    def test_customer_from_attributes(self):
        data = {
            "id": str(uuid4()),
            "organization_id": str(uuid4()),
            "phone": "+1111111111",
            "name": "Acme Corp",
            "tier": "gold",
        }
        cust = Customer.model_validate(data)
        assert cust.name == "Acme Corp"
        assert cust.tier == "gold"


class TestEnumValues:
    def test_organization_status(self):
        assert OrganizationStatus.active.value == "active"
        assert OrganizationStatus.suspended.value == "suspended"
        assert OrganizationStatus.trial.value == "trial"

    def test_whatsapp_account_status(self):
        assert WhatsAppAccountStatus.connected.value == "connected"
        assert WhatsAppAccountStatus.disconnected.value == "disconnected"
        assert WhatsAppAccountStatus.connecting.value == "connecting"

    def test_conversation_status(self):
        assert ConversationStatus.active.value == "active"
        assert ConversationStatus.paused.value == "paused"
        assert ConversationStatus.resolved.value == "resolved"
        assert ConversationStatus.archived.value == "archived"

    def test_customer_tier(self):
        assert CustomerTier.bronze.value == "bronze"
        assert CustomerTier.silver.value == "silver"
        assert CustomerTier.gold.value == "gold"
        assert CustomerTier.platinum.value == "platinum"

    def test_campaign_status(self):
        assert CampaignStatus.draft.value == "draft"
        assert CampaignStatus.scheduled.value == "scheduled"
        assert CampaignStatus.sending.value == "sending"
        assert CampaignStatus.completed.value == "completed"

    def test_workflow_trigger_types(self):
        assert WorkflowTriggerType.new_lead.value == "new_lead"
        assert WorkflowTriggerType.new_message.value == "new_message"
        assert WorkflowTriggerType.schedule.value == "schedule"

    def test_workflow_action_types(self):
        assert WorkflowActionType.send_message.value == "send_message"
        assert WorkflowActionType.create_lead.value == "create_lead"
        assert WorkflowActionType.assign_salesperson.value == "assign_salesperson"

    def test_sentiment_label(self):
        assert SentimentLabel.very_positive.value == "very_positive"
        assert SentimentLabel.positive.value == "positive"
        assert SentimentLabel.neutral.value == "neutral"
        assert SentimentLabel.negative.value == "negative"
        assert SentimentLabel.very_negative.value == "very_negative"

    def test_intent_category(self):
        assert IntentCategory.greeting.value == "greeting"
        assert IntentCategory.purchase.value == "purchase"
        assert IntentCategory.support.value == "support"
        assert IntentCategory.complaint.value == "complaint"
        assert IntentCategory.handoff.value == "handoff"
        assert IntentCategory.spam.value == "spam"

    def test_language_code(self):
        assert LanguageCode.en.value == "en"
        assert LanguageCode.es.value == "es"
        assert LanguageCode.fr.value == "fr"
        assert LanguageCode.de.value == "de"
        assert LanguageCode.unknown.value == "unknown"

    def test_agent_role(self):
        assert AgentRole.admin.value == "admin"
        assert AgentRole.supervisor.value == "supervisor"
        assert AgentRole.agent.value == "agent"
        assert AgentRole.viewer.value == "viewer"

    def test_permission(self):
        assert Permission.view_dashboard.value == "view_dashboard"
        assert Permission.manage_crm.value == "manage_crm"
        assert Permission.manage_plugins.value == "manage_plugins"

    def test_knowledge_type(self):
        assert KnowledgeType.pdf.value == "pdf"
        assert KnowledgeType.docx.value == "docx"
        assert KnowledgeType.markdown.value == "markdown"

    def test_analytics_metric(self):
        assert AnalyticsMetric.total_conversations.value == "total_conversations"
        assert AnalyticsMetric.conversion_rate.value == "conversion_rate"


class TestOtherEntities:
    def test_department(self):
        org_id = uuid4()
        dept = Department(organization_id=org_id, name="Support")
        assert dept.name == "Support"
        assert dept.is_active is True

    def test_user(self):
        org_id = uuid4()
        user = User(organization_id=org_id, email="test@example.com", name="Test User")
        assert user.email == "test@example.com"
        assert user.role == "agent"
        assert user.is_active is True
        assert user.max_concurrent_chats == 5

    def test_knowledge_document(self):
        org_id = uuid4()
        doc = KnowledgeDocument(organization_id=org_id, title="FAQ", type="faq")
        assert doc.title == "FAQ"
        assert doc.is_indexed is False

    def test_workflow(self):
        org_id = uuid4()
        wf = Workflow(organization_id=org_id, name="Auto Reply", trigger_type="new_message")
        assert wf.status == "active"
        assert wf.execution_count == 0

    def test_workflow_execution(self):
        wf_id = uuid4()
        org_id = uuid4()
        exec_ = WorkflowExecution(workflow_id=wf_id, organization_id=org_id, trigger_type="new_message")
        assert exec_.status == "running"
        assert exec_.current_step == 0

    def test_campaign(self):
        org_id = uuid4()
        camp = Campaign(organization_id=org_id, name="Summer Sale")
        assert camp.type == "broadcast"
        assert camp.status == "draft"

    def test_analytics_event(self):
        org_id = uuid4()
        event = AnalyticsEvent(organization_id=org_id, metric="total_conversations", value=42.0)
        assert event.metric == "total_conversations"
        assert event.value == 42.0

    def test_audit_log(self):
        org_id = uuid4()
        log = AuditLog(organization_id=org_id, action="user.login", resource_type="user")
        assert log.action == "user.login"

    def test_prompt_template(self):
        org_id = uuid4()
        pt = PromptTemplate(organization_id=org_id, name="default", system_prompt="You are a helpful assistant.")
        assert pt.temperature == 0.7
        assert pt.max_tokens == 1024

    def test_plugin(self):
        org_id = uuid4()
        plugin = Plugin(organization_id=org_id, name="analytics-export", entry_point="plugins.analytics_export")
        assert plugin.version == "1.0.0"
        assert plugin.is_enabled is True

    def test_webhook_event(self):
        org_id = uuid4()
        we = WebhookEvent(organization_id=org_id, event_type="message.received")
        assert we.status == "pending"
