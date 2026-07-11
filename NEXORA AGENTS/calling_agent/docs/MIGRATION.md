# Migration Guide

## Upgrading from v0.x to v1.0.0

### Breaking Changes

1. **Database Schema Changes**
   - All models now use GUID primary keys (String(36)) instead of integers
   - New tables added: `call_events`, `voice_settings`, `phone_providers`, `knowledge_documents`, `prompt_templates`, `audit_logs`, `plugins`, `analytics_events`
   - JSON fields replaced string/text fields for flexible data storage

2. **Configuration Changes**
   - Environment variable prefix changed to `CA_`
   - New configuration options required:
     - `CA_SECRET_KEY` (was `SECRET_KEY`)
     - `CA_DATABASE_URL` (was `DATABASE_URL`)
   - Phone provider configs moved to database (PhoneProviderConfig model)
   - Voice settings moved to database (VoiceSettings model)

3. **API Changes**
   - All endpoints now under `/api/v1/` prefix
   - Authentication now uses JWT tokens instead of API keys
   - Permission system introduced for access control
   - Call management endpoints restructured

### Migration Steps

#### Step 1: Database Migration

```bash
# Backup existing database
cp calling_agent.db calling_agent_backup.db

# The application will auto-create new tables on startup
# Run the server to create schema
python -m backend.main

# Data migration script (if needed)
python scripts/migrate_v0_to_v1.py
```

#### Step 2: Update Configuration

```bash
# Old .env format
SECRET_KEY=old-key
DATABASE_URL=sqlite:///./calling_agent.db

# New .env format
CA_SECRET_KEY=new-secure-key
CA_DATABASE_URL=sqlite+aiosqlite:///./calling_agent.db
CA_APP_NAME=Calling Agent
CA_APP_VERSION=1.0.0
```

#### Step 3: Update API Calls

**Old API:**
```http
POST /api/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "pass"
}
```

**New API:**
```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "pass"
}
```

**Old API:**
```http
GET /calls?status=active
Authorization: Bearer <token>
```

**New API:**
```http
GET /api/v1/calls?status=in_progress
Authorization: Bearer <token>
```

#### Step 4: Migrate Phone Providers

Phone provider configuration moved from environment variables to database:

```python
# Old: environment variables
TWILIO_ACCOUNT_SID=...
TWILIO_AUTH_TOKEN=...

# New: API call to create provider
POST /api/v1/phone-providers
{
  "name": "My Twilio",
  "provider_type": "twilio",
  "config": {
    "account_sid": "...",
    "auth_token": "..."
  },
  "phone_numbers": ["+15551234567"],
  "default_phone_number": "+15551234567"
}
```

#### Step 5: Migrate Voice Settings

Voice settings moved from environment variables to database:

```python
# Old: environment variables
STT_PROVIDER=whisper
TTS_PROVIDER=pyttsx3

# New: API call to update voice settings
PATCH /api/v1/voice-settings
{
  "stt_provider": "whisper",
  "stt_config": {"model": "base"},
  "tts_provider": "pyttsx3",
  "tts_config": {"voice": "default"},
  "vad_provider": "webrtc",
  "vad_config": {"mode": 1}
}
```

### New Features in v1.0.0

1. **Real-time Voice Streaming**: WebSocket-based audio streaming
2. **Plugin System**: Extensible plugin architecture
3. **Advanced Analytics**: Comprehensive analytics and reporting
4. **Multiple VAD Providers**: WebRTC and Silero VAD support
5. **Campaign Engine**: Automated campaign scheduling and retry logic
6. **Lead Scoring**: Automated lead scoring system
7. **Permission System**: Granular role-based access control
8. **Knowledge Base**: Document management and search
9. **Prompt Templates**: Configurable AI prompt management

### Deprecated Features

- API key authentication (use JWT tokens instead)
- Environment variable-based phone provider config (use database)
- Environment variable-based voice settings (use database)

## Upgrading from v1.0.0 to v1.1.0

### Changes

- TBD

### Migration Steps

- TBD

## Database Migrations

### Using Alembic (if configured)

```bash
# Generate a new migration
alembic revision --autogenerate -m "description"

# Apply migrations
alembic upgrade head

# Rollback
alembic downgrade -1
```

### Manual Migration

If not using Alembic, the application auto-creates tables on startup via `Base.metadata.create_all()`. For schema changes, you'll need to:

1. Backup database
2. Run migration SQL scripts
3. Verify data integrity

## Configuration Migration

### Old to New Environment Variables

| Old Variable | New Variable | Notes |
|-------------|-------------|-------|
| SECRET_KEY | CA_SECRET_KEY | Required |
| DATABASE_URL | CA_DATABASE_URL | Must use `+aiosqlite` for SQLite |
| TWILIO_SID | (removed) | Use API to configure |
| TWILIO_TOKEN | (removed) | Use API to configure |
| STT_PROVIDER | (removed) | Use Voice Settings API |
| TTS_PROVIDER | (removed) | Use Voice Settings API |

### New Required Variables

| Variable | Description | Default |
|----------|-------------|---------|
| CA_SECRET_KEY | JWT signing key | (required) |
| CA_DATABASE_URL | Database connection URL | sqlite+aiosqlite:///./calling_agent.db |
| CA_APP_NAME | Application name | Calling Agent |
| CA_APP_VERSION | Application version | 1.0.0 |

## Rollback Plan

If migration fails:

1. Stop the application
2. Restore database from backup
3. Revert environment variables to old format
4. Restore old application version
5. Verify system functionality
