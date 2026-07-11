# Architecture

## System Overview

WhatsApp Agent is a multi-tenant, AI-powered conversational platform that enables businesses to manage WhatsApp communications at scale. It provides automated responses, lead qualification, CRM integration, campaign management, and team collaboration — all through a plugin-extensible architecture.

The system follows a **layered architecture** with clear separation of concerns:

- **API Layer** — FastAPI routes handling HTTP requests
- **Application Layer** — Orchestration of business workflows
- **Domain Layer** — Core business entities and enums
- **Service Layer** — Business logic (scoring, sentiment, intent, language, summarization)
- **Infrastructure Layer** — Database, external APIs, storage, WhatsApp adapters

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Clients / Dashboard                         │
└───────────────────────────┬─────────────────────────────────────────┘
                            │ HTTP / WebSocket
                            ▼
┌─────────────────────────────────────────────────────────────────────┐
│                          API Layer (FastAPI)                        │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐   │
│  │Health│ │ Auth │ │  Org │ │Whats │ │ Conv │ │ CRM  │ │  KB  │   │
│  └──────┘ └──────┘ └──────┘ └──────┘ └──────┘ └──────┘ └──────┘   │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐   │
│  │Workfl│ │Campgn│ │Analyt│ │Inbox │ │Settng│ │Perms │ │ Logs │   │
│  └──────┘ └──────┘ └──────┘ └──────┘ └──────┘ └──────┘ └──────┘   │
│  ┌──────┐                                                          │
│  │Plugin│                                                          │
│  └──────┘                                                          │
└───────────────────────────┬─────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────────┐
│                       Application / Services Layer                  │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐  │
│  │  Lead    │ │Sentiment │ │  Intent  │ │ Language │ │  Conv    │  │
│  │  Scorer  │ │ Analyzer │ │ Detector │ │ Detector │ │Summarizer│  │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘  │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐                            │
│  │Scheduler │ │Analytics │ │  Plugin  │                            │
│  │          │ │ Service  │ │  Manager │                            │
│  └──────────┘ └──────────┘ └──────────┘                            │
└───────────────────────────┬─────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────────┐
│                       Domain Layer (Entities + Enums)               │
│  Organization │ WhatsAppAccount │ Conversation │ Message │ Lead     │
│  Customer │ User │ Department │ KnowledgeDocument │ Workflow       │
│  Campaign │ AnalyticsEvent │ AuditLog │ Plugin │ WebhookEvent      │
└───────────────────────────┬─────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      Infrastructure Layer                           │
│  ┌────────────────────┐ ┌────────────────┐ ┌────────────────────┐   │
│  │  Database (SQLite) │ │ WhatsApp Adapter│ │ Storage / File     │   │
│  │  SQLAlchemy Async  │ │ baileys-based   │ │ Knowledge Docs     │   │
│  └────────────────────┘ └────────────────┘ └────────────────────┘   │
│  ┌────────────────────┐ ┌────────────────┐                         │
│  │  External APIs     │ │  Redis Cache   │                         │
│  │  Nexora AI         │ │  (optional)    │                         │
│  └────────────────────┘ └────────────────┘                         │
└─────────────────────────────────────────────────────────────────────┘
```

## Component Descriptions

### API Layer

15 router groups, each mounted under `/api/v1/`:

| Router       | Prefix            | Description                           |
|--------------|-------------------|---------------------------------------|
| Health       | `/health`         | System health and uptime              |
| Auth         | `/auth`           | Login, token refresh, user management |
| Organizations| `/organizations`  | Multi-tenant organization CRUD        |
| WhatsApp     | `/whatsapp`       | WhatsApp account management           |
| Conversations| `/conversations`  | Chat conversation management          |
| CRM          | `/crm`            | Leads, customers, pipeline management |
| Knowledge    | `/knowledge`      | Document upload, FAQ, search          |
| Workflows    | `/workflows`      | Automated workflow engine             |
| Campaigns    | `/campaigns`      | Broadcast and drip campaigns          |
| Analytics    | `/analytics`      | Metrics, revenue, satisfaction        |
| Team Inbox   | `/inbox`          | Department management, assignments    |
| Settings     | `/settings`       | Organization settings, prompts, models|
| Permissions  | `/permissions`    | Role-based access control             |
| Logs         | `/logs`           | Audit log management                  |
| Plugins      | `/plugins`        | Plugin installation and config        |

### Domain Layer

Pydantic v2 models with `from_attributes = True` for SQLAlchemy compatibility. Enums are string-based (`str, enum.Enum`) for natural serialization.

### Service Layer

- **LeadScorer** — Weighted scoring (frequency, sentiment, intent, response time, custom fields)
- **SentimentAnalyzer** — TextBlob-based polarity analysis with conversation-level trending
- **IntentDetector** — Regex pattern matching with Nexora AI fallback
- **LanguageDetector** — langdetect library with language map
- **ConversationSummarizer** — Extractive summarization using TF scoring

### Infrastructure Layer

- **Database** — SQLAlchemy 2.0 async with SQLite (aiosqlite), designed for migration to PostgreSQL
- **WhatsApp** — Adapter pattern for baileys-based WhatsApp Web JS bridge
- **Storage** — Local file storage with knowledge document indexing

## Data Flow

```
Incoming WhatsApp Message
        │
        ▼
Webhook → API (whatsapp router)
        │
        ▼
Create/Update Conversation
        │
        ▼
Run Language Detection
        │
        ▼
Run Sentiment Analysis
        │
        ▼
Run Intent Detection
        │
        ▼
Run Lead Scoring (if applicable)
        │
        ▼
Trigger Workflows (new_message trigger)
        │
        ▼
Generate AI Reply (if ai_active)
        │
        ▼
Send Outbound Message
        │
        ▼
Log to Analytics & Audit
```

## Technology Stack

| Component        | Technology                          |
|------------------|-------------------------------------|
| Framework        | FastAPI (Python 3.12+)              |
| ORM              | SQLAlchemy 2.0 (async)              |
| Database         | SQLite (dev) / PostgreSQL (prod)    |
| Auth             | JWT (python-jose) + bcrypt          |
| Validation       | Pydantic v2                         |
| HTTP Client      | httpx                               |
| Sentiment        | TextBlob                            |
| Language Detect  | langdetect                          |
| Task Scheduling  | APScheduler                         |
| File Parsing     | PyMuPDF, python-docx, openpyxl      |
| Retry Logic      | tenacity                            |

## Directory Structure

```
backend/
├── api/                    # FastAPI route handlers
│   ├── analytics.py
│   ├── auth.py
│   ├── campaigns.py
│   ├── conversations.py
│   ├── crm.py
│   ├── health.py
│   ├── knowledge.py
│   ├── logs.py
│   ├── organizations.py
│   ├── permissions.py
│   ├── plugins.py
│   ├── settings.py
│   ├── team_inbox.py
│   ├── whatsapp.py
│   └── workflows.py
├── application/            # Application orchestration
│   └── __init__.py
├── config.py               # Pydantic settings
├── domain/                 # Entities and enums
│   ├── entities.py
│   └── enums.py
├── infrastructure/         # Database, external, storage, whatsapp
│   └── database/
│       ├── database.py
│       ├── models.py
│       └── repositories.py
├── knowledge/              # Knowledge base handlers
├── main.py                 # FastAPI app entrypoint
├── plugins/                # Plugin system
├── requirements.txt
├── services/               # Business logic services
│   ├── analytics_service.py
│   ├── conversation_summarizer.py
│   ├── intent_detector.py
│   ├── language_detector.py
│   ├── lead_scorer.py
│   ├── scheduler.py
│   └── sentiment_analyzer.py
├── setup.py
├── tests/                  # Test suites
│   ├── contract/
│   ├── e2e/
│   ├── integration/
│   ├── unit/
│   └── workflow/
└── workflows/              # Workflow definitions
```
