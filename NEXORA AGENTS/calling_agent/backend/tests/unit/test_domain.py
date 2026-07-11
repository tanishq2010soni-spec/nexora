from __future__ import annotations

from datetime import datetime
from decimal import Decimal
from uuid import UUID

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


class TestOrganization:
    def test_create(self):
        org = Organization(name="Test Corp", slug="test-corp")
        assert org.name == "Test Corp"
        assert org.slug == "test-corp"
        assert org.status == "active"
        assert isinstance(org.id, UUID)
        assert isinstance(org.created_at, datetime)

    def test_from_attributes(self):
        data = {
            "id": "550e8400-e29b-41d4-a716-446655440000",
            "name": "Test Org",
            "slug": "test-org",
            "status": "active",
            "timezone": "America/New_York",
            "brand_color": "#000000",
            "business_hours_start": "08:00",
            "business_hours_end": "17:00",
            "working_days": [1, 2, 3, 4, 5],
            "default_country_code": "91",
            "max_concurrent_calls": 100,
            "max_agents": 20,
            "recording_enabled": False,
            "transcription_enabled": False,
            "extra_data": {"region": "us-east"},
            "created_at": datetime(2024, 1, 1),
            "updated_at": datetime(2024, 1, 1),
        }
        org = Organization.model_validate(data)
        assert org.name == "Test Org"
        assert org.timezone == "America/New_York"
        assert org.max_concurrent_calls == 100

    def test_defaults(self):
        org = Organization(name="Default", slug="default")
        assert org.brand_color == "#6366f1"
        assert org.working_days == [0, 1, 2, 3, 4, 5, 6]
        assert org.recording_enabled is True
        assert org.transcription_enabled is True
        assert org.default_country_code == "1"


class TestCall:
    def test_create(self):
        org_id = UUID("550e8400-e29b-41d4-a716-446655440000")
        call = Call(
            organization_id=org_id,
            direction="outbound",
            from_number="+1234567890",
            to_number="+0987654321",
        )
        assert call.organization_id == org_id
        assert call.direction == "outbound"
        assert call.status == "queued"
        assert call.ai_handled is True
        assert call.cost == Decimal("0.00")
        assert isinstance(call.id, UUID)

    def test_from_attributes(self):
        data = {
            "id": "550e8400-e29b-41d4-a716-446655440000",
            "organization_id": "550e8400-e29b-41d4-a716-446655440001",
            "direction": "inbound",
            "from_number": "+1111111111",
            "to_number": "+2222222222",
            "status": "completed",
            "disposition": "interested",
            "duration_seconds": 120,
            "cost": 1.50,
            "ai_handled": True,
            "tags": ["important", "follow-up"],
            "created_at": datetime(2024, 1, 1),
            "updated_at": datetime(2024, 1, 1),
        }
        call = Call.model_validate(data)
        assert call.direction == "inbound"
        assert call.status == "completed"
        assert call.disposition == "interested"
        assert call.duration_seconds == 120
        assert call.cost == Decimal("1.50")
        assert "follow-up" in call.tags

    def test_call_event(self):
        call_id = UUID("550e8400-e29b-41d4-a716-446655440000")
        org_id = UUID("550e8400-e29b-41d4-a716-446655440001")
        event = CallEvent(
            call_id=call_id,
            organization_id=org_id,
            event_type="status_change",
            data={"from": "queued", "to": "ringing"},
        )
        assert event.call_id == call_id
        assert event.event_type == "status_change"


class TestCampaign:
    def test_create(self):
        org_id = UUID("550e8400-e29b-41d4-a716-446655440000")
        campaign = Campaign(
            organization_id=org_id,
            name="Q1 Outreach",
            type="cold_calling",
        )
        assert campaign.name == "Q1 Outreach"
        assert campaign.type == "cold_calling"
        assert campaign.status == "draft"
        assert campaign.max_attempts == 3

    def test_from_attributes(self):
        data = {
            "id": "550e8400-e29b-41d4-a716-446655440000",
            "organization_id": "550e8400-e29b-41d4-a716-446655440001",
            "name": "Test Campaign",
            "type": "follow_up",
            "status": "active",
            "max_calls_per_day": 200,
            "max_attempts": 5,
            "retry_delay_minutes": 30,
            "working_days": [1, 2, 3, 4, 5],
            "total_calls": 50,
            "total_answered": 20,
            "total_converted": 5,
            "total_cost": 25.0,
            "created_at": datetime(2024, 1, 1),
            "updated_at": datetime(2024, 1, 1),
        }
        campaign = Campaign.model_validate(data)
        assert campaign.status == "active"
        assert campaign.max_attempts == 5
        assert campaign.total_calls == 50
        assert campaign.total_cost == Decimal("25.00")


class TestLead:
    def test_create(self):
        org_id = UUID("550e8400-e29b-41d4-a716-446655440000")
        lead = Lead(
            organization_id=org_id,
            phone="+1234567890",
        )
        assert lead.phone == "+1234567890"
        assert lead.status == "new"
        assert lead.source == "manual"
        assert lead.score == 0.0
        assert lead.do_not_call is False

    def test_from_attributes(self):
        data = {
            "id": "550e8400-e29b-41d4-a716-446655440000",
            "organization_id": "550e8400-e29b-41d4-a716-446655440001",
            "first_name": "John",
            "last_name": "Doe",
            "phone": "+1234567890",
            "email": "john@example.com",
            "company": "Acme Inc",
            "status": "qualified",
            "source": "website",
            "score": 85.5,
            "tags": ["hot", "enterprise"],
            "do_not_call": False,
            "created_at": datetime(2024, 1, 1),
            "updated_at": datetime(2024, 1, 1),
        }
        lead = Lead.model_validate(data)
        assert lead.first_name == "John"
        assert lead.last_name == "Doe"
        assert lead.email == "john@example.com"
        assert lead.score == 85.5
        assert lead.source == "website"


class TestContact:
    def test_create(self):
        org_id = UUID("550e8400-e29b-41d4-a716-446655440000")
        contact = Contact(
            organization_id=org_id,
            phone="+1234567890",
        )
        assert contact.phone == "+1234567890"
        assert contact.total_calls == 0
        assert contact.lifetime_value == Decimal("0.00")

    def test_from_attributes(self):
        data = {
            "id": "550e8400-e29b-41d4-a716-446655440000",
            "organization_id": "550e8400-e29b-41d4-a716-446655440001",
            "first_name": "Jane",
            "last_name": "Smith",
            "phone": "+0987654321",
            "email": "jane@example.com",
            "company": "Corp Inc",
            "total_calls": 10,
            "total_spent": 45.50,
            "lifetime_value": 500.00,
            "created_at": datetime(2024, 1, 1),
            "updated_at": datetime(2024, 1, 1),
        }
        contact = Contact.model_validate(data)
        assert contact.total_calls == 10
        assert contact.total_spent == Decimal("45.50")
        assert contact.lifetime_value == Decimal("500.00")


class TestAppointment:
    def test_create(self):
        org_id = UUID("550e8400-e29b-41d4-a716-446655440000")
        apt = Appointment(
            organization_id=org_id,
            title="Demo Call",
            scheduled_at=datetime(2024, 6, 15, 14, 0, 0),
        )
        assert apt.title == "Demo Call"
        assert apt.status == "scheduled"
        assert apt.duration_minutes == 30
        assert apt.reminder_sent is False

    def test_from_attributes(self):
        data = {
            "id": "550e8400-e29b-41d4-a716-446655440000",
            "organization_id": "550e8400-e29b-41d4-a716-446655440001",
            "title": "Follow-up",
            "status": "confirmed",
            "scheduled_at": datetime(2024, 6, 20, 10, 0, 0),
            "duration_minutes": 45,
            "reminder_sent": True,
            "created_at": datetime(2024, 1, 1),
            "updated_at": datetime(2024, 1, 1),
        }
        apt = Appointment.model_validate(data)
        assert apt.status == "confirmed"
        assert apt.duration_minutes == 45


class TestScript:
    def test_create(self):
        org_id = UUID("550e8400-e29b-41d4-a716-446655440000")
        script = Script(
            organization_id=org_id,
            name="Cold Call Script",
            type="cold_calling",
            content="Hello {{name}}, this is {{agent}}...",
        )
        assert script.name == "Cold Call Script"
        assert script.type == "cold_calling"
        assert script.is_active is True
        assert script.version == 1

    def test_from_attributes(self):
        data = {
            "id": "550e8400-e29b-41d4-a716-446655440000",
            "organization_id": "550e8400-e29b-41d4-a716-446655440001",
            "name": "Support Script",
            "type": "support",
            "content": "How can I help you today?",
            "is_active": True,
            "version": 3,
            "tags": ["support", "english"],
            "created_at": datetime(2024, 1, 1),
            "updated_at": datetime(2024, 1, 1),
        }
        script = Script.model_validate(data)
        assert script.version == 3
        assert "support" in script.tags


class TestRecording:
    def test_create(self):
        org_id = UUID("550e8400-e29b-41d4-a716-446655440000")
        call_id = UUID("550e8400-e29b-41d4-a716-446655440001")
        rec = Recording(
            organization_id=org_id,
            call_id=call_id,
        )
        assert rec.organization_id == org_id
        assert rec.call_id == call_id
        assert rec.status == "processing"
        assert rec.mime_type == "audio/wav"
        assert rec.transcription_status == "pending"
        assert rec.is_archived is False

    def test_from_attributes(self):
        data = {
            "id": "550e8400-e29b-41d4-a716-446655440000",
            "organization_id": "550e8400-e29b-41d4-a716-446655440001",
            "call_id": "550e8400-e29b-41d4-a716-446655440002",
            "file_path": "/recordings/test.wav",
            "file_size": 1048576,
            "duration_seconds": 60,
            "mime_type": "audio/mp3",
            "status": "available",
            "transcription_status": "completed",
            "transcription_text": "Hello world",
            "is_archived": False,
            "created_at": datetime(2024, 1, 1),
        }
        rec = Recording.model_validate(data)
        assert rec.status == "available"
        assert rec.transcription_status == "completed"
        assert rec.file_size == 1048576


class TestEnums:
    def test_call_direction_values(self):
        assert CallDirection.inbound.value == "inbound"
        assert CallDirection.outbound.value == "outbound"

    def test_call_status_values(self):
        assert CallStatus.queued.value == "queued"
        assert CallStatus.ringing.value == "ringing"
        assert CallStatus.in_progress.value == "in_progress"
        assert CallStatus.completed.value == "completed"
        assert CallStatus.failed.value == "failed"
        assert CallStatus.missed.value == "missed"
        assert CallStatus.voicemail.value == "voicemail"
        assert CallStatus.cancelled.value == "cancelled"

    def test_call_disposition_values(self):
        assert CallDisposition.completed.value == "completed"
        assert CallDisposition.interested.value == "interested"
        assert CallDisposition.not_interested.value == "not_interested"
        assert CallDisposition.call_back.value == "call_back"
        assert CallDisposition.wrong_number.value == "wrong_number"
        assert CallDisposition.no_answer.value == "no_answer"
        assert CallDisposition.busy.value == "busy"
        assert CallDisposition.voicemail.value == "voicemail"
        assert CallDisposition.disconnected.value == "disconnected"
        assert CallDisposition.qualified.value == "qualified"
        assert CallDisposition.appointment_set.value == "appointment_set"
        assert CallDisposition.sale_made.value == "sale_made"
        assert CallDisposition.follow_up_required.value == "follow_up_required"
        assert CallDisposition.dnc.value == "dnc"

    def test_phone_provider_values(self):
        assert PhoneProvider.twilio.value == "twilio"
        assert PhoneProvider.exotel.value == "exotel"
        assert PhoneProvider.plivo.value == "plivo"
        assert PhoneProvider.sip.value == "sip"
        assert PhoneProvider.pbx.value == "pbx"
        assert PhoneProvider.custom.value == "custom"

    def test_stt_provider_values(self):
        assert STTProvider.whisper.value == "whisper"
        assert STTProvider.deepgram.value == "deepgram"
        assert STTProvider.google.value == "google"
        assert STTProvider.azure.value == "azure"
        assert STTProvider.assemblyai.value == "assemblyai"
        assert STTProvider.custom.value == "custom"

    def test_tts_provider_values(self):
        assert TTSProvider.pyttsx3.value == "pyttsx3"
        assert TTSProvider.elevenlabs.value == "elevenlabs"
        assert TTSProvider.google.value == "google"
        assert TTSProvider.azure.value == "azure"
        assert TTSProvider.amazon.value == "amazon"
        assert TTSProvider.custom.value == "custom"

    def test_vad_provider_values(self):
        assert VADProvider.webrtc.value == "webrtc"
        assert VADProvider.silero.value == "silero"
        assert VADProvider.custom.value == "custom"

    def test_voice_emotion_values(self):
        assert VoiceEmotion.neutral.value == "neutral"
        assert VoiceEmotion.happy.value == "happy"
        assert VoiceEmotion.serious.value == "serious"
        assert VoiceEmotion.sympathetic.value == "sympathetic"
        assert VoiceEmotion.urgent.value == "urgent"
        assert VoiceEmotion.energetic.value == "energetic"

    def test_campaign_status_values(self):
        assert CampaignStatus.draft.value == "draft"
        assert CampaignStatus.active.value == "active"
        assert CampaignStatus.paused.value == "paused"
        assert CampaignStatus.completed.value == "completed"
        assert CampaignStatus.cancelled.value == "cancelled"

    def test_campaign_type_values(self):
        assert CampaignType.cold_calling.value == "cold_calling"
        assert CampaignType.warm_calling.value == "warm_calling"
        assert CampaignType.follow_up.value == "follow_up"
        assert CampaignType.appointment_reminder.value == "appointment_reminder"
        assert CampaignType.survey.value == "survey"
        assert CampaignType.welcome.value == "welcome"
        assert CampaignType.reactivation.value == "reactivation"
        assert CampaignType.dunning.value == "dunning"

    def test_lead_status_values(self):
        assert LeadStatus.new.value == "new"
        assert LeadStatus.contacted.value == "contacted"
        assert LeadStatus.qualified.value == "qualified"
        assert LeadStatus.disqualified.value == "disqualified"
        assert LeadStatus.converted.value == "converted"
        assert LeadStatus.lost.value == "lost"

    def test_lead_source_values(self):
        assert LeadSource.inbound_call.value == "inbound_call"
        assert LeadSource.outbound_call.value == "outbound_call"
        assert LeadSource.campaign.value == "campaign"
        assert LeadSource.website.value == "website"
        assert LeadSource.referral.value == "referral"
        assert LeadSource.manual.value == "manual"
        assert LeadSource.api.value == "api"

    def test_appointment_status_values(self):
        assert AppointmentStatus.scheduled.value == "scheduled"
        assert AppointmentStatus.confirmed.value == "confirmed"
        assert AppointmentStatus.completed.value == "completed"
        assert AppointmentStatus.cancelled.value == "cancelled"
        assert AppointmentStatus.rescheduled.value == "rescheduled"
        assert AppointmentStatus.no_show.value == "no_show"

    def test_script_type_values(self):
        assert ScriptType.cold_calling.value == "cold_calling"
        assert ScriptType.follow_up.value == "follow_up"
        assert ScriptType.objection_handling.value == "objection_handling"
        assert ScriptType.closing.value == "closing"
        assert ScriptType.voicemail.value == "voicemail"
        assert ScriptType.appointment.value == "appointment"
        assert ScriptType.support.value == "support"
        assert ScriptType.welcome.value == "welcome"

    def test_recording_status_values(self):
        assert RecordingStatus.processing.value == "processing"
        assert RecordingStatus.available.value == "available"
        assert RecordingStatus.archived.value == "archived"
        assert RecordingStatus.deleted.value == "deleted"

    def test_transcription_status_values(self):
        assert TranscriptionStatus.pending.value == "pending"
        assert TranscriptionStatus.processing.value == "processing"
        assert TranscriptionStatus.completed.value == "completed"
        assert TranscriptionStatus.failed.value == "failed"

    def test_agent_role_values(self):
        assert AgentRole.admin.value == "admin"
        assert AgentRole.supervisor.value == "supervisor"
        assert AgentRole.agent.value == "agent"
        assert AgentRole.viewer.value == "viewer"

    def test_sentiment_label_values(self):
        assert SentimentLabel.very_negative.value == "very_negative"
        assert SentimentLabel.negative.value == "negative"
        assert SentimentLabel.neutral.value == "neutral"
        assert SentimentLabel.positive.value == "positive"
        assert SentimentLabel.very_positive.value == "very_positive"

    def test_intent_category_values(self):
        assert IntentCategory.greeting.value == "greeting"
        assert IntentCategory.information.value == "information"
        assert IntentCategory.complaint.value == "complaint"
        assert IntentCategory.purchase.value == "purchase"
        assert IntentCategory.support.value == "support"
        assert IntentCategory.objection.value == "objection"
        assert IntentCategory.appointment.value == "appointment"
        assert IntentCategory.follow_up.value == "follow_up"
        assert IntentCategory.handoff.value == "handoff"
        assert IntentCategory.goodbye.value == "goodbye"
        assert IntentCategory.silence.value == "silence"
        assert IntentCategory.unknown.value == "unknown"

    def test_permission_values(self):
        assert Permission.view_dashboard.value == "view_dashboard"
        assert Permission.view_live_calls.value == "view_live_calls"
        assert Permission.manage_calls.value == "manage_calls"
        assert Permission.view_campaigns.value == "view_campaigns"
        assert Permission.manage_campaigns.value == "manage_campaigns"
        assert Permission.manage_team.value == "manage_team"
        assert Permission.manage_permissions.value == "manage_permissions"

    def test_analytics_metric_values(self):
        assert AnalyticsMetric.total_calls.value == "total_calls"
        assert AnalyticsMetric.total_duration.value == "total_duration"
        assert AnalyticsMetric.avg_duration.value == "avg_duration"
        assert AnalyticsMetric.answer_rate.value == "answer_rate"
        assert AnalyticsMetric.conversion_rate.value == "conversion_rate"
        assert AnalyticsMetric.appointments_set.value == "appointments_set"
        assert AnalyticsMetric.leads_generated.value == "leads_generated"

    def test_log_level_values(self):
        assert LogLevel.debug.value == "debug"
        assert LogLevel.info.value == "info"
        assert LogLevel.warning.value == "warning"
        assert LogLevel.error.value == "error"
        assert LogLevel.critical.value == "critical"


class TestUser:
    def test_create(self):
        org_id = UUID("550e8400-e29b-41d4-a716-446655440000")
        user = User(
            organization_id=org_id,
            email="agent@example.com",
            name="Agent Smith",
        )
        assert user.email == "agent@example.com"
        assert user.name == "Agent Smith"
        assert user.role == "agent"
        assert user.is_active is True
        assert user.is_available is True


class TestPhoneProviderConfig:
    def test_create(self):
        org_id = UUID("550e8400-e29b-41d4-a716-446655440000")
        config = PhoneProviderConfig(
            organization_id=org_id,
            name="My Twilio",
            provider_type="twilio",
        )
        assert config.name == "My Twilio"
        assert config.provider_type == "twilio"
        assert config.is_active is True
        assert config.rate_per_minute == Decimal("0.00")


class TestVoiceSettings:
    def test_create(self):
        org_id = UUID("550e8400-e29b-41d4-a716-446655440000")
        vs = VoiceSettings(
            organization_id=org_id,
        )
        assert vs.stt_provider == "whisper"
        assert vs.tts_provider == "pyttsx3"
        assert vs.vad_provider == "webrtc"
        assert vs.noise_suppression is True
        assert vs.silence_timeout_ms == 2000


class TestKnowledgeDocument:
    def test_create(self):
        org_id = UUID("550e8400-e29b-41d4-a716-446655440000")
        doc = KnowledgeDocument(
            organization_id=org_id,
            title="FAQ",
            type="document",
        )
        assert doc.title == "FAQ"
        assert doc.is_indexed is False
        assert doc.chunk_count == 0


class TestPromptTemplate:
    def test_create(self):
        org_id = UUID("550e8400-e29b-41d4-a716-446655440000")
        pt = PromptTemplate(
            organization_id=org_id,
            name="sales-agent",
            system_prompt="You are a sales agent...",
        )
        assert pt.name == "sales-agent"
        assert pt.temperature == 0.7
        assert pt.max_tokens == 1024
        assert pt.is_active is True


class TestAuditLog:
    def test_create(self):
        org_id = UUID("550e8400-e29b-41d4-a716-446655440000")
        log = AuditLog(
            organization_id=org_id,
            action="user.login",
            resource_type="user",
        )
        assert log.action == "user.login"
        assert log.resource_type == "user"
        assert isinstance(log.id, UUID)


class TestPlugin:
    def test_create(self):
        org_id = UUID("550e8400-e29b-41d4-a716-446655440000")
        plugin = Plugin(
            organization_id=org_id,
            name="sentiment-analysis",
            entry_point="plugins.sentiment:analyze",
        )
        assert plugin.name == "sentiment-analysis"
        assert plugin.version == "1.0.0"
        assert plugin.is_enabled is True
        assert plugin.is_official is False


class TestAnalyticsEvent:
    def test_create(self):
        org_id = UUID("550e8400-e29b-41d4-a716-446655440000")
        event = AnalyticsEvent(
            organization_id=org_id,
            metric="total_calls",
            value=42.0,
        )
        assert event.metric == "total_calls"
        assert event.value == 42.0
