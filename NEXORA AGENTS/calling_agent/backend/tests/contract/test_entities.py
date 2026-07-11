from __future__ import annotations

from datetime import datetime
from decimal import Decimal
from uuid import UUID, uuid4

import pytest

from backend.domain.entities import (
    AnalyticsEvent,
    Appointment,
    AuditLog,
    Call,
    CallEvent,
    Campaign,
    Contact,
    KnowledgeDocument,
    Lead,
    Organization,
    PhoneProviderConfig,
    Plugin,
    PromptTemplate,
    Recording,
    Script,
    User,
    VoiceSettings,
)
from backend.domain.enums import (
    AgentRole,
    AnalyticsMetric,
    AppointmentStatus,
    CallDirection,
    CallDisposition,
    CallStatus,
    CampaignStatus,
    CampaignType,
    IntentCategory,
    LeadSource,
    LeadStatus,
    LogLevel,
    Permission,
    PhoneProvider,
    RecordingStatus,
    ScriptType,
    SentimentLabel,
    STTProvider,
    TranscriptionStatus,
    TTSProvider,
    VADProvider,
    VoiceEmotion,
)


class ContractBase:
    def assert_entity_contract(self, entity, required_fields: list[str]):
        for field in required_fields:
            assert hasattr(entity, field), f"Missing required field: {field}"


class TestOrganizationContract(ContractBase):
    def test_organization_contract(self):
        org = Organization(name="Contract Test", slug="contract-test")
        self.assert_entity_contract(org, [
            "id", "name", "slug", "status", "timezone",
            "brand_color", "brand_logo_url", "business_hours_start",
            "business_hours_end", "working_days", "default_country_code",
            "max_concurrent_calls", "max_agents", "recording_enabled",
            "transcription_enabled", "extra_data", "created_at", "updated_at",
        ])
        assert isinstance(org.id, UUID)
        assert isinstance(org.created_at, datetime)
        assert org.Config.from_attributes is True

    def test_organization_from_dict(self):
        data = {
            "id": str(uuid4()),
            "name": "Org",
            "slug": "org",
            "status": "active",
            "timezone": "UTC",
            "brand_color": "#6366f1",
            "business_hours_start": "09:00",
            "business_hours_end": "18:00",
            "working_days": [0, 1, 2, 3, 4, 5, 6],
            "default_country_code": "1",
            "max_concurrent_calls": 50,
            "max_agents": 10,
            "recording_enabled": True,
            "transcription_enabled": True,
            "extra_data": {},
            "created_at": datetime.utcnow(),
            "updated_at": datetime.utcnow(),
        }
        org = Organization.model_validate(data)
        assert org.name == "Org"


class TestCallContract(ContractBase):
    def test_call_contract(self):
        call = Call(
            organization_id=uuid4(),
            direction="outbound",
            from_number="+1",
            to_number="+2",
        )
        self.assert_entity_contract(call, [
            "id", "organization_id", "user_id", "campaign_id", "lead_id",
            "contact_id", "phone_provider_id", "direction", "from_number",
            "to_number", "status", "disposition", "duration_seconds",
            "billing_duration_seconds", "cost", "recording_url",
            "recording_status", "transcription_url", "transcription_status",
            "transcript", "summary", "sentiment", "intent", "quality_score",
            "ai_handled", "handoff_to", "handoff_reason", "notes", "tags",
            "ivr_digits", "provider_call_id", "provider_data", "extra_data",
            "started_at", "ended_at", "scheduled_at", "created_at", "updated_at",
        ])
        assert call.Config.from_attributes is True

    def test_call_event_contract(self):
        event = CallEvent(
            call_id=uuid4(),
            organization_id=uuid4(),
            event_type="status_change",
        )
        self.assert_entity_contract(event, [
            "id", "call_id", "organization_id", "event_type", "data", "timestamp",
        ])

    def test_call_status_values(self):
        for status in CallStatus:
            assert isinstance(status.value, str)


class TestCampaignContract(ContractBase):
    def test_campaign_contract(self):
        campaign = Campaign(
            organization_id=uuid4(),
            name="Test Campaign",
            type="cold_calling",
        )
        self.assert_entity_contract(campaign, [
            "id", "organization_id", "name", "type", "status",
            "script_id", "phone_provider_id", "caller_id", "target_filter",
            "schedule", "max_calls_per_day", "max_attempts",
            "retry_delay_minutes", "call_window_start", "call_window_end",
            "working_days", "timezone", "total_calls", "total_answered",
            "total_converted", "total_cost", "created_by", "created_at",
            "updated_at",
        ])
        assert campaign.Config.from_attributes is True

    def test_campaign_status_values(self):
        for status in CampaignStatus:
            assert status.value in ["draft", "active", "paused", "completed", "cancelled"]

    def test_campaign_type_values(self):
        for ct in CampaignType:
            assert isinstance(ct.value, str)


class TestLeadContract(ContractBase):
    def test_lead_contract(self):
        lead = Lead(organization_id=uuid4(), phone="+1234567890")
        self.assert_entity_contract(lead, [
            "id", "organization_id", "campaign_id", "first_name", "last_name",
            "phone", "email", "company", "position", "status", "source",
            "score", "notes", "tags", "custom_fields", "last_called_at",
            "call_count", "last_disposition", "next_call_at", "timezone",
            "best_time_to_call", "do_not_call", "created_at", "updated_at",
        ])
        assert lead.Config.from_attributes is True


class TestContactContract(ContractBase):
    def test_contact_contract(self):
        contact = Contact(organization_id=uuid4(), phone="+1234567890")
        self.assert_entity_contract(contact, [
            "id", "organization_id", "first_name", "last_name", "phone",
            "email", "company", "position", "tags", "notes", "custom_fields",
            "total_calls", "total_spent", "lifetime_value", "last_contact_at",
            "created_at", "updated_at",
        ])
        assert contact.Config.from_attributes is True


class TestAppointmentContract(ContractBase):
    def test_appointment_contract(self):
        apt = Appointment(
            organization_id=uuid4(),
            title="Meeting",
            scheduled_at=datetime.utcnow(),
        )
        self.assert_entity_contract(apt, [
            "id", "organization_id", "lead_id", "contact_id", "call_id",
            "title", "description", "status", "scheduled_at",
            "duration_minutes", "assigned_to", "reminder_sent", "notes",
            "created_at", "updated_at",
        ])
        assert apt.Config.from_attributes is True


class TestScriptContract(ContractBase):
    def test_script_contract(self):
        script = Script(
            organization_id=uuid4(),
            name="Test Script",
            type="cold_calling",
            content="Hello {{name}}",
        )
        self.assert_entity_contract(script, [
            "id", "organization_id", "name", "type", "content",
            "variables", "sections", "tags", "is_active", "version",
            "created_by", "created_at", "updated_at",
        ])
        assert script.Config.from_attributes is True


class TestRecordingContract(ContractBase):
    def test_recording_contract(self):
        rec = Recording(
            organization_id=uuid4(),
            call_id=uuid4(),
        )
        self.assert_entity_contract(rec, [
            "id", "organization_id", "call_id", "file_path", "file_size",
            "duration_seconds", "mime_type", "status", "transcription_status",
            "transcription_text", "is_archived", "created_at",
        ])
        assert rec.Config.from_attributes is True


class TestEnumContracts:
    def test_all_enums_have_values(self):
        enums = [
            CallDirection, CallStatus, CallDisposition, PhoneProvider,
            STTProvider, TTSProvider, VADProvider, VoiceEmotion,
            CampaignStatus, CampaignType, LeadStatus, LeadSource,
            AppointmentStatus, ScriptType, RecordingStatus,
            TranscriptionStatus, AgentRole, SentimentLabel,
            IntentCategory, LogLevel, AnalyticsMetric, Permission,
        ]
        for enum_cls in enums:
            members = list(enum_cls)
            assert len(members) > 0, f"{enum_cls.__name__} has no members"
            for member in members:
                assert isinstance(member.value, str)

    def test_permission_enum_comprehensive(self):
        required_permissions = [
            "view_dashboard", "view_live_calls", "manage_calls",
            "view_call_queue", "manage_call_queue", "view_campaigns",
            "manage_campaigns", "view_leads", "manage_leads",
            "view_crm", "manage_crm", "view_knowledge", "manage_knowledge",
            "view_analytics", "view_recordings", "manage_recordings",
            "view_scripts", "manage_scripts", "monitor_calls",
            "barge_calls", "whisper_calls", "view_settings",
            "manage_settings", "manage_team", "manage_permissions",
            "manage_phone_providers", "manage_voice_providers",
            "view_logs", "view_health", "manage_plugins", "manage_models",
        ]
        for perm in required_permissions:
            assert Permission(perm), f"Missing permission: {perm}"

    def test_call_status_transitions(self):
        valid_statuses = {s.value for s in CallStatus}
        assert "queued" in valid_statuses
        assert "in_progress" in valid_statuses
        assert "completed" in valid_statuses
        assert "failed" in valid_statuses

    def test_disposition_values(self):
        valid = {d.value for d in CallDisposition}
        assert "completed" in valid
        assert "interested" in valid
        assert "not_interested" in valid
        assert "sale_made" in valid
        assert "dnc" in valid

    def test_analytics_metrics(self):
        metrics = {m.value for m in AnalyticsMetric}
        assert "total_calls" in metrics
        assert "conversion_rate" in metrics
        assert "appointments_set" in metrics
        assert "leads_generated" in metrics


class TestEntityConversion:
    def test_organization_from_model_dict(self):
        data = {
            "id": str(uuid4()),
            "name": "Test",
            "slug": "test",
            "status": "active",
            "timezone": "UTC",
            "brand_color": "#6366f1",
            "brand_logo_url": None,
            "business_hours_start": "09:00",
            "business_hours_end": "18:00",
            "working_days": [0, 1, 2, 3, 4, 5, 6],
            "default_country_code": "1",
            "max_concurrent_calls": 50,
            "max_agents": 10,
            "recording_enabled": True,
            "transcription_enabled": True,
            "extra_data": {},
            "created_at": datetime.utcnow(),
            "updated_at": datetime.utcnow(),
        }
        org = Organization.model_validate(data)
        assert isinstance(org.id, UUID)
        assert org.name == "Test"

    def test_call_from_model_dict(self):
        data = {
            "id": str(uuid4()),
            "organization_id": str(uuid4()),
            "direction": "inbound",
            "from_number": "+1234567890",
            "to_number": "+0987654321",
            "status": "ringing",
            "cost": 0.0,
            "ai_handled": True,
            "notes": [],
            "tags": [],
            "provider_data": {},
            "extra_data": {},
            "created_at": datetime.utcnow(),
            "updated_at": datetime.utcnow(),
        }
        call = Call.model_validate(data)
        assert call.status == "ringing"
        assert call.cost == Decimal("0.00")

    def test_campaign_from_model_dict(self):
        data = {
            "id": str(uuid4()),
            "organization_id": str(uuid4()),
            "name": "Campaign",
            "type": "follow_up",
            "status": "draft",
            "target_filter": {},
            "schedule": {},
            "working_days": [0, 1, 2, 3, 4, 5, 6],
            "total_calls": 0,
            "total_answered": 0,
            "total_converted": 0,
            "total_cost": 0.0,
            "created_at": datetime.utcnow(),
            "updated_at": datetime.utcnow(),
        }
        campaign = Campaign.model_validate(data)
        assert campaign.type == "follow_up"

    def test_lead_from_model_dict(self):
        data = {
            "id": str(uuid4()),
            "organization_id": str(uuid4()),
            "phone": "+1234567890",
            "status": "new",
            "source": "manual",
            "score": 0.0,
            "notes": [],
            "tags": [],
            "custom_fields": {},
            "call_count": 0,
            "do_not_call": False,
            "created_at": datetime.utcnow(),
            "updated_at": datetime.utcnow(),
        }
        lead = Lead.model_validate(data)
        assert lead.phone == "+1234567890"

    def test_user_from_model_dict(self):
        data = {
            "id": str(uuid4()),
            "organization_id": str(uuid4()),
            "email": "user@test.com",
            "name": "Test User",
            "role": "agent",
            "is_active": True,
            "is_available": True,
            "permissions": [],
            "max_concurrent_calls": 3,
            "created_at": datetime.utcnow(),
            "updated_at": datetime.utcnow(),
        }
        user = User.model_validate(data)
        assert user.email == "user@test.com"

    def test_voice_settings_from_model_dict(self):
        data = {
            "id": str(uuid4()),
            "organization_id": str(uuid4()),
            "stt_provider": "deepgram",
            "stt_config": {},
            "tts_provider": "elevenlabs",
            "tts_config": {},
            "tts_voice": "rachel",
            "tts_speed": 1.0,
            "tts_pitch": 1.0,
            "tts_emotion": "neutral",
            "vad_provider": "silero",
            "vad_config": {},
            "noise_suppression": True,
            "echo_cancellation": True,
            "interruption_enabled": True,
            "silence_timeout_ms": 1500,
            "created_at": datetime.utcnow(),
            "updated_at": datetime.utcnow(),
        }
        vs = VoiceSettings.model_validate(data)
        assert vs.stt_provider == "deepgram"
        assert vs.tts_provider == "elevenlabs"
        assert vs.vad_provider == "silero"
        assert vs.silence_timeout_ms == 1500
