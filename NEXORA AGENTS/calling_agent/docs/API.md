# API Documentation

Base URL: `http://localhost:8200/api/v1`

## Authentication

All endpoints except health and login require a Bearer JWT token in the Authorization header.

```
Authorization: Bearer <access_token>
```

### Get Token

```
POST /api/v1/auth/login
```

Request:
```json
{
  "email": "user@example.com",
  "password": "yourpassword"
}
```

Response:
```json
{
  "access_token": "eyJ...",
  "refresh_token": "eyJ...",
  "token_type": "bearer",
  "expires_in": 3600
}
```

### Refresh Token

```
POST /api/v1/auth/refresh
```

Request:
```json
{
  "refresh_token": "eyJ..."
}
```

### Get Current User

```
GET /api/v1/auth/me
```

### Create User

```
POST /api/v1/auth/users
```

Requires `manage_team` permission.

Request:
```json
{
  "email": "newuser@example.com",
  "name": "New User",
  "password": "securepass",
  "role": "agent",
  "extension": "123",
  "sip_uri": "sip:newuser@example.com"
}
```

## Health

### Health Check

```
GET /api/v1/health
```

Response:
```json
{
  "status": "ok",
  "uptime_seconds": 3600.5,
  "database": "ok",
  "version": "1.0.0",
  "app_name": "Calling Agent"
}
```

## Calls

### List Calls

```
GET /api/v1/calls
```

Query Parameters:
| Parameter | Type | Description |
|-----------|------|-------------|
| status | string | Filter by status (queued, ringing, in_progress, etc.) |
| direction | string | inbound or outbound |
| campaign_id | UUID | Filter by campaign |
| lead_id | UUID | Filter by lead |
| user_id | UUID | Filter by assigned user |
| date_from | datetime | Start date filter |
| date_to | datetime | End date filter |
| search | string | Search in numbers and notes |
| page | int | Page number (default: 1) |
| limit | int | Items per page (default: 50, max: 200) |

Response:
```json
{
  "items": [
    {
      "id": "uuid",
      "organization_id": "uuid",
      "direction": "outbound",
      "from_number": "+15551234567",
      "to_number": "+15559876543",
      "status": "completed",
      "disposition": "interested",
      "duration_seconds": 120,
      "cost": 1.50,
      "ai_handled": true,
      "tags": [],
      "created_at": "2024-01-01T00:00:00Z"
    }
  ],
  "total": 1,
  "page": 1,
  "limit": 50,
  "pages": 1
}
```

### Get Active Calls

```
GET /api/v1/calls/active
```

Returns calls with status: ringing, in_progress, hold, transferring, conferencing.

### Get Call

```
GET /api/v1/calls/{call_id}
```

### Update Call Status

```
PATCH /api/v1/calls/{call_id}/status
```

Request:
```json
{
  "status": "in_progress"
}
```

Valid statuses: queued, ringing, in_progress, hold, transferring, conferencing, completed, failed, missed, voicemail, cancelled.

### Set Call Disposition

```
PATCH /api/v1/calls/{call_id}/disposition
```

Request:
```json
{
  "disposition": "interested"
}
```

Valid dispositions: completed, interested, not_interested, call_back, wrong_number, no_answer, busy, voicemail, disconnected, qualified, appointment_set, sale_made, follow_up_required, dnc.

### Assign Call

```
PATCH /api/v1/calls/{call_id}/assign
```

Request:
```json
{
  "user_id": "uuid"
}
```

### Add Note to Call

```
PATCH /api/v1/calls/{call_id}/notes
```

Request:
```json
{
  "note": "Customer requested callback tomorrow",
  "author": "Agent Name"
}
```

### Update Call Tags

```
PATCH /api/v1/calls/{call_id}/tags
```

Request:
```json
{
  "tags": ["important", "follow-up"]
}
```

### Set Call Quality Score

```
PATCH /api/v1/calls/{call_id}/quality
```

Request:
```json
{
  "score": 85
}
```

Score must be between 0 and 100.

### Hold Call

```
POST /api/v1/calls/{call_id}/hold
```

### Resume Call

```
POST /api/v1/calls/{call_id}/resume
```

### Transfer Call

```
POST /api/v1/calls/{call_id}/transfer
```

Request:
```json
{
  "target_number": "+15559876543",
  "target_type": "number"
}
```

### Conference Call

```
POST /api/v1/calls/{call_id}/conference
```

Request:
```json
{
  "numbers": ["+15551111111", "+15552222222"]
}
```

### Handoff Call to Human

```
POST /api/v1/calls/{call_id}/handoff
```

Request:
```json
{
  "user_id": "uuid",
  "reason": "Customer requested human agent"
}
```

### Get Call Events

```
GET /api/v1/calls/{call_id}/events
```

Returns list of call events (status changes, assignments, notes, etc.).

## Campaigns

### List Campaigns

```
GET /api/v1/campaigns
```

Query Parameters: status, type, search, page, limit

### Create Campaign

```
POST /api/v1/campaigns
```

Request:
```json
{
  "name": "Q1 Outreach",
  "type": "cold_calling",
  "script_id": "uuid",
  "phone_provider_id": "uuid",
  "caller_id": "+15551234567",
  "max_calls_per_day": 100,
  "max_attempts": 3,
  "retry_delay_minutes": 60
}
```

### Get Campaign

```
GET /api/v1/campaigns/{campaign_id}
```

### Update Campaign

```
PATCH /api/v1/campaigns/{campaign_id}
```

### Delete Campaign

```
DELETE /api/v1/campaigns/{campaign_id}
```

### Start Campaign

```
POST /api/v1/campaigns/{campaign_id}/start
```

### Pause Campaign

```
POST /api/v1/campaigns/{campaign_id}/pause
```

### Get Campaign Leads

```
GET /api/v1/campaigns/{campaign_id}/leads
```

### Get Campaign Stats

```
GET /api/v1/campaigns/{campaign_id}/stats
```

## Leads

### List Leads

```
GET /api/v1/leads
```

Query Parameters: status, source, campaign_id, search, page, limit

### Create Lead

```
POST /api/v1/leads
```

Request:
```json
{
  "first_name": "John",
  "last_name": "Doe",
  "phone": "+15551234567",
  "email": "john@example.com",
  "company": "Acme Inc",
  "position": "CEO",
  "campaign_id": "uuid",
  "source": "manual",
  "tags": ["hot", "enterprise"]
}
```

### Get Lead

```
GET /api/v1/leads/{lead_id}
```

### Update Lead

```
PATCH /api/v1/leads/{lead_id}
```

### Delete Lead

```
DELETE /api/v1/leads/{lead_id}
```

### Import Leads

```
POST /api/v1/leads/import
```

Request:
```json
{
  "leads": [
    {
      "phone": "+15551111111",
      "first_name": "Alice",
      "last_name": "Smith",
      "email": "alice@example.com"
    }
  ],
  "campaign_id": "uuid"
}
```

### Bulk Assign Leads

```
POST /api/v1/leads/bulk-assign
```

Request:
```json
{
  "lead_ids": ["uuid1", "uuid2"],
  "campaign_id": "uuid"
}
```

## Contacts

### List Contacts

```
GET /api/v1/contacts
```

### Create Contact

```
POST /api/v1/contacts
```

### Get Contact

```
GET /api/v1/contacts/{contact_id}
```

### Update Contact

```
PATCH /api/v1/contacts/{contact_id}
```

### Delete Contact

```
DELETE /api/v1/contacts/{contact_id}
```

### Search Contacts

```
GET /api/v1/contacts/search?q=John
```

## Appointments

### List Appointments

```
GET /api/v1/appointments
```

### Create Appointment

```
POST /api/v1/appointments
```

### Get Appointment

```
GET /api/v1/appointments/{appointment_id}
```

### Update Appointment

```
PATCH /api/v1/appointments/{appointment_id}
```

### Cancel Appointment

```
PATCH /api/v1/appointments/{appointment_id}/cancel
```

### Confirm Appointment

```
PATCH /api/v1/appointments/{appointment_id}/confirm
```

## Scripts

### List Scripts

```
GET /api/v1/scripts
```

### Create Script

```
POST /api/v1/scripts
```

Request:
```json
{
  "name": "Cold Call Script",
  "type": "cold_calling",
  "content": "Hello {{name}}, this is {{agent}} from {{company}}...",
  "variables": [{"name": "name", "type": "string"}, {"name": "agent", "type": "string"}, {"name": "company", "type": "string"}],
  "sections": [{"name": "Introduction", "content": "..."}, {"name": "Objection Handling", "content": "..."}],
  "tags": ["english", "b2b"]
}
```

### Get Script

```
GET /api/v1/scripts/{script_id}
```

### Update Script

```
PATCH /api/v1/scripts/{script_id}
```

### Delete Script

```
DELETE /api/v1/scripts/{script_id}
```

## Recordings

### List Recordings

```
GET /api/v1/recordings
```

### Get Recording

```
GET /api/v1/recordings/{recording_id}
```

### Download Recording

```
GET /api/v1/recordings/{recording_id}/download
```

### Delete Recording

```
DELETE /api/v1/recordings/{recording_id}
```

### Get Recording Transcript

```
GET /api/v1/recordings/{recording_id}/transcript
```

## Knowledge Base

### List Documents

```
GET /api/v1/knowledge
```

### Create Document

```
POST /api/v1/knowledge
```

### Get Document

```
GET /api/v1/knowledge/{document_id}
```

### Update Document

```
PATCH /api/v1/knowledge/{document_id}
```

### Delete Document

```
DELETE /api/v1/knowledge/{document_id}
```

### Search Knowledge

```
GET /api/v1/knowledge/search?q=returns+policy
```

## Voice Settings

### Get Voice Settings

```
GET /api/v1/voice-settings
```

### Update Voice Settings

```
PATCH /api/v1/voice-settings
```

Request:
```json
{
  "stt_provider": "deepgram",
  "tts_provider": "elevenlabs",
  "tts_voice": "rachel",
  "vad_provider": "silero",
  "noise_suppression": true,
  "interruption_enabled": true
}
```

### Test Voice Settings

```
POST /api/v1/voice-settings/test
```

## Phone Providers

### List Providers

```
GET /api/v1/phone-providers
```

### Create Provider

```
POST /api/v1/phone-providers
```

### Update Provider

```
PATCH /api/v1/phone-providers/{provider_id}
```

### Delete Provider

```
DELETE /api/v1/phone-providers/{provider_id}
```

### Test Provider

```
POST /api/v1/phone-providers/{provider_id}/test
```

## Analytics

### Get Call Analytics

```
GET /api/v1/analytics/calls
```

Query Parameters: organization_id, date_from, date_to, group_by (day, week, month)

### Get Campaign Analytics

```
GET /api/v1/analytics/campaigns/{campaign_id}
```

### Get Agent Performance

```
GET /api/v1/analytics/agents/{user_id}
```

### Get Dashboard Summary

```
GET /api/v1/analytics/dashboard
```

### Get Trends

```
GET /api/v1/analytics/trends
```

## Webhooks

### Twilio Webhook

```
POST /api/v1/webhooks/twilio/voice
```

### Twilio Status Callback

```
POST /api/v1/webhooks/twilio/status
```

### Exotel Webhook

```
POST /api/v1/webhooks/exotel/voice
```

### Plivo Webhook

```
POST /api/v1/webhooks/plivo/voice
```

## Streaming

### WebSocket Audio Stream

```
WS /api/v1/stream/audio?call_id={call_id}&token={access_token}
```

### WebSocket Events

```
WS /api/v1/stream/events?call_id={call_id}&token={access_token}
```

## Error Responses

### 400 Bad Request
```json
{
  "detail": "Call must be in_progress to hold"
}
```

### 401 Unauthorized
```json
{
  "detail": "Could not validate credentials"
}
```

### 403 Forbidden
```json
{
  "detail": "Missing required permission: manage_calls"
}
```

### 404 Not Found
```json
{
  "detail": "Call not found"
}
```

### 409 Conflict
```json
{
  "detail": "Email already exists"
}
```

### 422 Validation Error
```json
{
  "detail": [
    {
      "loc": ["body", "email"],
      "msg": "value is not a valid email address",
      "type": "value_error.email"
    }
  ]
}
```
