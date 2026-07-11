# WhatsApp Agent

Enterprise-grade, multi-tenant WhatsApp AI Agent platform for automated customer engagement, lead management, and team collaboration.

## Features

- **Multi-Tenant Architecture** — Isolated organizations with independent settings and data
- **WhatsApp Integration** — Connect multiple WhatsApp Business accounts per organization
- **AI-Powered Conversations** — Smart message handling with sentiment, intent, and language detection
- **Lead Scoring & Qualification** — Automated lead scoring based on engagement patterns
- **Pipeline Management** — Track leads through stages from new to closed-won
- **Campaign Management** — Broadcast and drip campaigns with scheduling
- **Team Collaboration** — Multi-agent inbox with handoff system and department routing
- **Knowledge Base** — Document upload, FAQ management, and semantic search
- **Workflow Automation** — Event-driven workflows with conditional branching
- **Role-Based Access Control** — Granular permissions for admin, supervisor, agent, and viewer roles
- **Plugin System** — Extend functionality with custom plugins
- **Analytics & Reporting** — Track conversations, leads, revenue, and satisfaction metrics
- **Audit Logging** — Comprehensive activity log for compliance and monitoring

## Quick Start

### Prerequisites

- Python 3.12+

### Installation

```bash
# Clone and enter the project
cd whatsapp_agent

# Create virtual environment
python -m venv venv

# Activate it
# Windows:
venv\Scripts\activate
# Linux/Mac:
source venv/bin/activate

# Install dependencies
cd backend
pip install -r requirements.txt
```

### Configure

```bash
# Copy the .env template
cp .env.example .env
# Edit .env with your settings
```

### Run

```bash
python main.py
```

The server starts at `http://localhost:8100`. API documentation is available at `http://localhost:8100/docs`.

## Architecture Overview

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Clients   │───>│  FastAPI    │───>│  Services   │
│  Dashboard  │    │  API Layer  │    │  Layer      │
└─────────────┘    └─────────────┘    └──────┬──────┘
                                             │
                                    ┌────────▼──────┐
                                    │   Domain      │
                                    │   Layer       │
                                    └───────┬───────┘
                                            │
                                    ┌───────▼───────┐
                                    │ Infrastructure│
                                    │   (DB, etc.)  │
                                    └───────────────┘
```

The system uses a layered architecture:

- **API Layer** — FastAPI route handlers (15 routers)
- **Service Layer** — Business logic (scoring, sentiment, intent, language, summarization)
- **Domain Layer** — Pydantic v2 entities and string enums
- **Infrastructure Layer** — SQLAlchemy async ORM, file storage, WhatsApp adapters

## Documentation

| Document               | Description                               |
|------------------------|-------------------------------------------|
| [Architecture](docs/ARCHITECTURE.md) | System design, components, data flow |
| [API Reference](docs/API.md) | Complete API endpoint documentation |
| [Deployment](docs/DEPLOYMENT.md) | Installation, configuration, production setup |
| [Testing](docs/TESTING.md) | Test structure, running tests, mock strategies |
| [Plugin Development](docs/PLUGIN.md) | Creating and registering plugins |
| [User Guide](docs/USER_GUIDE.md) | Dashboard, inbox, CRM, workflows |
| [Developer Guide](docs/DEVELOPER.md) | Setup, conventions, adding features |

## Tech Stack

| Component        | Technology                          |
|------------------|-------------------------------------|
| Framework        | FastAPI (Python 3.12+)              |
| ORM              | SQLAlchemy 2.0 (async)              |
| Database         | SQLite / PostgreSQL                 |
| Validation       | Pydantic v2                         |
| Auth             | JWT + bcrypt                        |
| Sentiment        | TextBlob                            |
| Language Detect  | langdetect                          |
| Task Scheduling  | APScheduler                         |
| HTTP Client      | httpx                               |

## Project Structure

```
backend/
├── api/                # 15 API routers
├── domain/             # Entities + enums
├── services/           # Business logic
├── infrastructure/     # Database, storage, adapters
├── tests/              # Unit, integration, contract, workflow, e2e
├── plugins/            # Plugin modules
├── workflows/          # Workflow definitions
├── knowledge/          # Knowledge base processing
├── main.py             # App entrypoint
├── config.py           # Settings
└── requirements.txt    # Dependencies
```

## License

Proprietary. All rights reserved.
