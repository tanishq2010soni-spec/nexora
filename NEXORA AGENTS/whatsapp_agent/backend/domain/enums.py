from __future__ import annotations

import enum


class OrganizationStatus(str, enum.Enum):
    active = "active"
    suspended = "suspended"
    trial = "trial"
    cancelled = "cancelled"


class WhatsAppAccountStatus(str, enum.Enum):
    disconnected = "disconnected"
    connecting = "connecting"
    connected = "connected"
    expired = "expired"
    banned = "banned"
    error = "error"


class ConversationStatus(str, enum.Enum):
    active = "active"
    paused = "paused"
    resolved = "resolved"
    archived = "archived"
    spam = "spam"


class MessageDirection(str, enum.Enum):
    inbound = "inbound"
    outbound = "outbound"


class MessageStatus(str, enum.Enum):
    sent = "sent"
    delivered = "delivered"
    read = "read"
    failed = "failed"


class LeadStatus(str, enum.Enum):
    new = "new"
    qualified = "qualified"
    disqualified = "disqualified"
    converted = "converted"
    lost = "lost"


class LeadSource(str, enum.Enum):
    whatsapp = "whatsapp"
    website = "website"
    referral = "referral"
    campaign = "campaign"
    manual = "manual"
    api = "api"


class PipelineStage(str, enum.Enum):
    new_lead = "new_lead"
    contacted = "contacted"
    qualified = "qualified"
    proposal = "proposal"
    negotiation = "negotiation"
    closed_won = "closed_won"
    closed_lost = "closed_lost"


class CustomerTier(str, enum.Enum):
    bronze = "bronze"
    silver = "silver"
    gold = "gold"
    platinum = "platinum"


class CampaignStatus(str, enum.Enum):
    draft = "draft"
    scheduled = "scheduled"
    sending = "sending"
    completed = "completed"
    cancelled = "cancelled"


class CampaignType(str, enum.Enum):
    broadcast = "broadcast"
    drip = "drip"
    trigger = "trigger"


class WorkflowStatus(str, enum.Enum):
    active = "active"
    paused = "paused"
    archived = "archived"


class WorkflowTriggerType(str, enum.Enum):
    new_lead = "new_lead"
    new_message = "new_message"
    lead_qualified = "lead_qualified"
    lead_converted = "lead_converted"
    campaign_completed = "campaign_completed"
    schedule = "schedule"
    webhook = "webhook"


class WorkflowActionType(str, enum.Enum):
    send_message = "send_message"
    create_lead = "create_lead"
    update_lead = "update_lead"
    assign_salesperson = "assign_salesperson"
    notify_team = "notify_team"
    schedule_follow_up = "schedule_follow_up"
    add_tag = "add_tag"
    send_email = "send_email"
    webhook = "webhook"
    condition = "condition"
    delay = "delay"


class HandoffStatus(str, enum.Enum):
    requested = "requested"
    active = "active"
    completed = "completed"
    rejected = "rejected"


class AgentRole(str, enum.Enum):
    admin = "admin"
    supervisor = "supervisor"
    agent = "agent"
    viewer = "viewer"


class Permission(str, enum.Enum):
    view_dashboard = "view_dashboard"
    view_inbox = "view_inbox"
    manage_inbox = "manage_inbox"
    view_crm = "view_crm"
    manage_crm = "manage_crm"
    view_knowledge = "view_knowledge"
    manage_knowledge = "manage_knowledge"
    view_workflows = "view_workflows"
    manage_workflows = "manage_workflows"
    view_campaigns = "view_campaigns"
    manage_campaigns = "manage_campaigns"
    view_analytics = "view_analytics"
    view_settings = "view_settings"
    manage_settings = "manage_settings"
    manage_team = "manage_team"
    manage_permissions = "manage_permissions"
    manage_whatsapp = "manage_whatsapp"
    view_logs = "view_logs"
    view_health = "view_health"
    manage_plugins = "manage_plugins"
    manage_models = "manage_models"


class KnowledgeType(str, enum.Enum):
    pdf = "pdf"
    docx = "docx"
    excel = "excel"
    csv = "csv"
    markdown = "markdown"
    image = "image"
    website = "website"
    faq = "faq"
    text = "text"


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
    feedback = "feedback"
    handoff = "handoff"
    spam = "spam"
    unknown = "unknown"


class LanguageCode(str, enum.Enum):
    en = "en"
    es = "es"
    fr = "fr"
    de = "de"
    it = "it"
    pt = "pt"
    hi = "hi"
    ar = "ar"
    zh = "zh"
    ja = "ja"
    ko = "ko"
    ru = "ru"
    nl = "nl"
    tr = "tr"
    vi = "vi"
    th = "th"
    unknown = "unknown"


class LogLevel(str, enum.Enum):
    debug = "debug"
    info = "info"
    warning = "warning"
    error = "error"
    critical = "critical"


class AnalyticsMetric(str, enum.Enum):
    total_conversations = "total_conversations"
    total_messages = "total_messages"
    total_leads = "total_leads"
    qualified_leads = "qualified_leads"
    converted_leads = "converted_leads"
    avg_response_time = "avg_response_time"
    avg_resolution_time = "avg_resolution_time"
    customer_satisfaction = "customer_satisfaction"
    revenue_attributed = "revenue_attributed"
    token_usage = "token_usage"
    model_cost = "model_cost"
    handoff_rate = "handoff_rate"
    conversion_rate = "conversion_rate"
