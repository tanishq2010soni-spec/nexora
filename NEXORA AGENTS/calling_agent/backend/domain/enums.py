from __future__ import annotations

import enum


class CallDirection(str, enum.Enum):
    inbound = "inbound"
    outbound = "outbound"


class CallStatus(str, enum.Enum):
    queued = "queued"
    ringing = "ringing"
    in_progress = "in_progress"
    hold = "hold"
    transferring = "transferring"
    conferencing = "conferencing"
    completed = "completed"
    failed = "failed"
    missed = "missed"
    voicemail = "voicemail"
    cancelled = "cancelled"


class CallDisposition(str, enum.Enum):
    completed = "completed"
    interested = "interested"
    not_interested = "not_interested"
    call_back = "call_back"
    wrong_number = "wrong_number"
    no_answer = "no_answer"
    busy = "busy"
    voicemail = "voicemail"
    disconnected = "disconnected"
    qualified = "qualified"
    appointment_set = "appointment_set"
    sale_made = "sale_made"
    follow_up_required = "follow_up_required"
    dnc = "dnc"


class PhoneProvider(str, enum.Enum):
    twilio = "twilio"
    exotel = "exotel"
    plivo = "plivo"
    sip = "sip"
    pbx = "pbx"
    custom = "custom"


class STTProvider(str, enum.Enum):
    whisper = "whisper"
    deepgram = "deepgram"
    google = "google"
    azure = "azure"
    assemblyai = "assemblyai"
    custom = "custom"


class TTSProvider(str, enum.Enum):
    pyttsx3 = "pyttsx3"
    elevenlabs = "elevenlabs"
    google = "google"
    azure = "azure"
    amazon = "amazon"
    custom = "custom"


class VADProvider(str, enum.Enum):
    webrtc = "webrtc"
    silero = "silero"
    custom = "custom"


class VoiceEmotion(str, enum.Enum):
    neutral = "neutral"
    happy = "happy"
    serious = "serious"
    sympathetic = "sympathetic"
    urgent = "urgent"
    energetic = "energetic"


class CampaignStatus(str, enum.Enum):
    draft = "draft"
    active = "active"
    paused = "paused"
    completed = "completed"
    cancelled = "cancelled"


class CampaignType(str, enum.Enum):
    cold_calling = "cold_calling"
    warm_calling = "warm_calling"
    follow_up = "follow_up"
    appointment_reminder = "appointment_reminder"
    survey = "survey"
    welcome = "welcome"
    reactivation = "reactivation"
    dunning = "dunning"


class LeadStatus(str, enum.Enum):
    new = "new"
    contacted = "contacted"
    qualified = "qualified"
    disqualified = "disqualified"
    converted = "converted"
    lost = "lost"


class LeadSource(str, enum.Enum):
    inbound_call = "inbound_call"
    outbound_call = "outbound_call"
    campaign = "campaign"
    website = "website"
    referral = "referral"
    manual = "manual"
    api = "api"


class AppointmentStatus(str, enum.Enum):
    scheduled = "scheduled"
    confirmed = "confirmed"
    completed = "completed"
    cancelled = "cancelled"
    rescheduled = "rescheduled"
    no_show = "no_show"


class ScriptType(str, enum.Enum):
    cold_calling = "cold_calling"
    follow_up = "follow_up"
    objection_handling = "objection_handling"
    closing = "closing"
    voicemail = "voicemail"
    appointment = "appointment"
    support = "support"
    welcome = "welcome"


class RecordingStatus(str, enum.Enum):
    processing = "processing"
    available = "available"
    archived = "archived"
    deleted = "deleted"


class TranscriptionStatus(str, enum.Enum):
    pending = "pending"
    processing = "processing"
    completed = "completed"
    failed = "failed"


class AgentRole(str, enum.Enum):
    admin = "admin"
    supervisor = "supervisor"
    agent = "agent"
    viewer = "viewer"


class Permission(str, enum.Enum):
    view_dashboard = "view_dashboard"
    view_live_calls = "view_live_calls"
    manage_calls = "manage_calls"
    view_call_queue = "view_call_queue"
    manage_call_queue = "manage_call_queue"
    view_campaigns = "view_campaigns"
    manage_campaigns = "manage_campaigns"
    view_leads = "view_leads"
    manage_leads = "manage_leads"
    view_crm = "view_crm"
    manage_crm = "manage_crm"
    view_knowledge = "view_knowledge"
    manage_knowledge = "manage_knowledge"
    view_analytics = "view_analytics"
    view_recordings = "view_recordings"
    manage_recordings = "manage_recordings"
    view_scripts = "view_scripts"
    manage_scripts = "manage_scripts"
    monitor_calls = "monitor_calls"
    barge_calls = "barge_calls"
    whisper_calls = "whisper_calls"
    view_settings = "view_settings"
    manage_settings = "manage_settings"
    manage_team = "manage_team"
    manage_permissions = "manage_permissions"
    manage_phone_providers = "manage_phone_providers"
    manage_voice_providers = "manage_voice_providers"
    view_logs = "view_logs"
    view_health = "view_health"
    manage_plugins = "manage_plugins"
    manage_models = "manage_models"


class SentimentLabel(str, enum.Enum):
    very_negative = "very_negative"
    negative = "negative"
    neutral = "neutral"
    positive = "positive"
    very_positive = "very_positive"


class IntentCategory(str, enum.Enum):
    greeting = "greeting"
    information = "information"
    complaint = "complaint"
    purchase = "purchase"
    support = "support"
    objection = "objection"
    appointment = "appointment"
    follow_up = "follow_up"
    handoff = "handoff"
    goodbye = "goodbye"
    silence = "silence"
    unknown = "unknown"


class LogLevel(str, enum.Enum):
    debug = "debug"
    info = "info"
    warning = "warning"
    error = "error"
    critical = "critical"


class AnalyticsMetric(str, enum.Enum):
    total_calls = "total_calls"
    total_duration = "total_duration"
    avg_duration = "avg_duration"
    answer_rate = "answer_rate"
    conversion_rate = "conversion_rate"
    revenue_attributed = "revenue_attributed"
    avg_sentiment = "avg_sentiment"
    quality_score = "quality_score"
    calls_per_agent = "calls_per_agent"
    token_usage = "token_usage"
    model_cost = "model_cost"
    avg_response_time = "avg_response_time"
    appointments_set = "appointments_set"
    leads_generated = "leads_generated"
