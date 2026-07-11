# AI Calling Agent

An intelligent AI-powered voice calling platform that automates outbound and inbound phone calls using advanced speech-to-text, text-to-speech, and voice activity detection technologies.

## Features

- **AI-Powered Calls**: Fully automated voice conversations using LLM-based AI agents
- **Multi-Provider Voice Pipeline**: Support for Whisper, Deepgram (STT), pyttsx3, ElevenLabs (TTS), WebRTC VAD, Silero VAD
- **Phone Provider Integration**: Twilio, Exotel, Plivo, SIP/PBX
- **Campaign Management**: Create and manage outbound calling campaigns with scheduling, retry logic, and lead scoring
- **Real-time Voice Streaming**: WebSocket-based audio streaming with VAD, noise suppression, and interruption handling
- **Analytics & Monitoring**: Comprehensive call analytics, quality scoring, sentiment analysis, and live monitoring
- **CRM Integration**: Contact management, appointment scheduling, and lead tracking
- **Plugin System**: Extensible plugin architecture for custom functionality

## Quick Start

### Prerequisites

- Python 3.12+
- pip

### Installation

```bash
# Clone the repository
git clone <repo-url>
cd calling_agent

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env with your settings

# Run the server
python -m backend.main
```

### Verify Installation

```bash
curl http://localhost:8200/api/v1/health
```

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    Frontend (Flutter)                     │
└──────────────────┬──────────────────────────────────────┘
                   │ REST API / WebSocket
┌──────────────────▼──────────────────────────────────────┐
│                    FastAPI Backend                        │
│  ┌─────────┐ ┌──────────┐ ┌──────────┐ ┌───────────┐   │
│  │ Auth    │ │ Campaign │ │ Voice    │ │ Analytics │   │
│  │ Service │ │ Engine   │ │ Pipeline │ │ Service   │   │
│  └─────────┘ └──────────┘ └──────────┘ └───────────┘   │
│  ┌──────────────────────────────────────────────────┐   │
│  │           Infrastructure Layer                    │   │
│  │  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐  │   │
│  │  │Twilio│ │Exotel│ │Plivo │ │ SIP  │ │Custom│  │   │
│  │  └──────┘ └──────┘ └──────┘ └──────┘ └──────┘  │   │
│  │  ┌──────┐ ┌──────┐ ┌──────┐ ┌────────────────┐ │   │
│  │  │STT   │ │TTS   │ │VAD   │ │Noise Suppress  │ │   │
│  │  └──────┘ └──────┘ └──────┘ └────────────────┘ │   │
│  └──────────────────────────────────────────────────┘   │
└──────────────────┬──────────────────────────────────────┘
                   │ SQLAlchemy
┌──────────────────▼──────────────────────────────────────┐
│                    Database (SQLite/PostgreSQL)           │
└─────────────────────────────────────────────────────────┘
```

## Documentation

- [Architecture](docs/ARCHITECTURE.md) - System architecture and design
- [API Reference](docs/API.md) - Complete API documentation
- [Deployment](docs/DEPLOYMENT.md) - Production deployment guide
- [Voice Setup](docs/VOICE_SETUP.md) - Voice pipeline configuration
- [Provider Integration](docs/PROVIDER_INTEGRATION.md) - Phone provider setup
- [Developer Guide](docs/DEVELOPER.md) - Development setup and conventions
- [Plugin Development](docs/PLUGIN.md) - Creating plugins
- [User Guide](docs/USER_GUIDE.md) - Platform usage manual
- [Testing Guide](docs/TESTING.md) - Testing methodology
- [Migration Guide](docs/MIGRATION.md) - Upgrading guide

## Tech Stack

- **Backend**: Python 3.12+, FastAPI, SQLAlchemy (async), Pydantic v2
- **Voice**: OpenAI Whisper, Deepgram, pyttsx3, ElevenLabs, WebRTC VAD, Silero VAD
- **Phone**: Twilio, Exotel, Plivo, SIP
- **Frontend**: Flutter/Dart
- **Database**: SQLite (dev) / PostgreSQL (prod)
- **Auth**: JWT (python-jose), bcrypt (passlib)
- **Streaming**: WebSocket, async generators

## License

Proprietary. All rights reserved.
