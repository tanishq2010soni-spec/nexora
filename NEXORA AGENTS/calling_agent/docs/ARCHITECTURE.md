# Architecture

## System Overview

The AI Calling Agent is a modular, event-driven voice calling platform built on a layered architecture. It separates concerns into domain, application, infrastructure, and presentation layers, following clean architecture principles.

## Component Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Presentation Layer                            │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │                    REST API (FastAPI)                         │   │
│  │  /api/v1/health, /auth, /calls, /campaigns, /leads, ...      │   │
│  └──────────────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │               WebSocket / Streaming Endpoints                 │   │
│  └──────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
                                   │
┌─────────────────────────────────────────────────────────────────────┐
│                        Application Layer                            │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ │
│  │  Auth    │ │ Campaign │ │  Call    │ │  Lead    │ │ Analytics│ │
│  │  Service │ │  Engine  │ │  Service │ │  Service │ │  Service │ │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘ │
└─────────────────────────────────────────────────────────────────────┘
                                   │
┌─────────────────────────────────────────────────────────────────────┐
│                        Domain Layer                                 │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  Entities: Organization, Call, Campaign, Lead, Contact,      │   │
│  │            Appointment, Script, Recording, User, ...         │   │
│  └──────────────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  Enums: CallStatus, CampaignStatus, STTProvider, TTSProvider,│   │
│  │         VADProvider, PhoneProvider, LeadStatus, ...          │   │
│  └──────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
                                   │
┌─────────────────────────────────────────────────────────────────────┐
│                      Infrastructure Layer                           │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  Database: SQLAlchemy ORM, async sessions, SQLite/PostgreSQL │   │
│  └──────────────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  Voice Pipeline                                               │   │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────────────┐   │   │
│  │  │STT (Whisper, Deepgram) │TTS (pyttsx3, ElevenLabs)      │   │   │
│  │  └─────────┘ └─────────┘ └─────────┘ └─────────────────┘   │   │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐                      │   │
│  │  │VAD (WebRTC, Silero)  │Noise Suppression │               │   │
│  │  └─────────┘ └─────────┘ └─────────┘                      │   │
│  └──────────────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  Phone Providers                                              │   │
│  │  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌──────────┐  │   │
│  │  │Twilio  │ │Exotel │ │Plivo   │ │SIP/PBX │ │Custom    │  │   │
│  │  └────────┘ └────────┘ └────────┘ └────────┘ └──────────┘  │   │
│  └──────────────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  Streaming: WebSocket audio streaming, real-time transport   │   │
│  └──────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

## Voice Pipeline Flow

```
┌──────────┐    Audio Frames     ┌──────────┐    Speech/Silence    ┌─────────┐
│  Mic /   │ ──────────────────▶ │   VAD    │ ──────────────────▶ │  Noise  │
│  Phone   │                     │(WebRTC/  │                     │ Suppress│
│  Stream  │                     │ Silero)  │                     │         │
└──────────┘                     └──────────┘                     └─────────┘
                                                                      │
                                                              Clean Audio
                                                                      │
                                                                      ▼
                                                              ┌──────────┐
                                                              │   STT    │
                                                              │ (Whisper/│
                                                              │ Deepgram)│
                                                              └──────────┘
                                                                      │
                                                               Text/Transcript
                                                                      │
                                                                      ▼
                                                          ┌──────────────────┐
                                                          │  AI Agent / LLM   │
                                                          │  (Response Gen)   │
                                                          └──────────────────┘
                                                                      │
                                                              Response Text
                                                                      │
                                                                      ▼
                                                              ┌──────────┐
                                                              │   TTS    │
                                                              │(pyttsx3/ │
                                                              │ElevenLabs)│
                                                              └──────────┘
                                                                      │
                                                              Audio Chunks
                                                                      │
                                                                      ▼
                                                              ┌──────────┐
                                                              │ Speaker /│
                                                              │ Phone    │
                                                              └──────────┘
```

### Voice Pipeline Components

1. **VAD (Voice Activity Detection)**: Detects when a person is speaking vs. silence. Two implementations:
   - WebRTC VAD: Lightweight, fast, browser-compatible
   - Silero VAD: Deep learning-based, more accurate in noisy environments

2. **Noise Suppression**: Reduces background noise before STT processing to improve transcription accuracy

3. **STT (Speech-to-Text)**: Converts audio to text. Providers:
   - Whisper: Local, privacy-preserving, multiple model sizes
   - Deepgram: Cloud-based, real-time, high accuracy

4. **TTS (Text-to-Speech)**: Converts AI response text to audio. Providers:
   - pyttsx3: Local, offline, multiple voices
   - ElevenLabs: Cloud-based, natural voices, emotion control

5. **Interruption Detection**: Allows the human to interrupt the AI mid-speech, enabling natural conversation flow

## Data Flow

### Outbound Call Flow

```
1. User creates Campaign with leads
2. Campaign Engine checks schedule & picks next lead
3. Engine calls Phone Provider API (e.g., Twilio)
4. Phone Provider initiates call to lead's number
5. When answered, Voice Pipeline starts:
   a. VAD detects speech from lead
   b. STT transcribes lead's speech
   c. AI Agent generates response
   d. TTS converts response to audio
   e. Audio streamed back to lead via phone provider
6. Call completes with disposition
7. Analytics updated
8. Lead marked as contacted
9. If retry needed, lead re-queued based on retry logic
```

### Inbound Call Flow

```
1. Incoming call via Phone Provider webhook
2. Call routed to available AI agent or human
3. Voice Pipeline handles conversation
4. If AI cannot handle, call is handed off to human agent
5. Call disposition set, analytics updated
```

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Backend Framework | FastAPI (Python 3.12+) |
| ORM | SQLAlchemy 2.0 (async) |
| Validation | Pydantic v2 |
| Authentication | JWT (python-jose), bcrypt (passlib) |
| Database | SQLite (development), PostgreSQL (production) |
| STT | Whisper (local), Deepgram (cloud) |
| TTS | pyttsx3 (local), ElevenLabs (cloud) |
| VAD | WebRTC VAD, Silero VAD |
| Phone | Twilio, Exotel, Plivo, SIP/PBX |
| Streaming | WebSocket, async generators |
| Frontend | Flutter/Dart |

## Directory Structure

```
calling_agent/
├── backend/
│   ├── api/           # REST API routers
│   ├── application/   # Application services
│   ├── config.py      # Configuration
│   ├── domain/        # Domain entities & enums
│   ├── infrastructure/
│   │   ├── database/  # SQLAlchemy models & sessions
│   │   ├── phone/     # Phone provider integrations
│   │   ├── voice/     # Voice pipeline (STT, TTS, VAD)
│   │   └── streaming/ # WebSocket streaming
│   ├── services/      # Business logic services
│   └── tests/         # Test suites
├── docs/              # Documentation
├── lib/               # Flutter frontend
└── assets/            # Static assets
```
