# Frontend–Backend Contract Verification Report

**Date:** 2026-06-19
**Backend:** NexoraBrain v1.0.0 (http://localhost:8000)
**Frontend:** Nexora Control Center (Flutter)
**Status:** PARTIAL — 3 modules with working adapters, 4 modules without backend support

---

## Executive Summary

| Module | Endpoints | Working | Broken | Status |
|--------|-----------|---------|--------|--------|
| Auth | 3 | 3 | 0 | **PASS** |
| Dashboard | 0 | 0 | 1 | **FAIL** |
| Agent Center | 0 | 0 | 5 | **FAIL** |
| Knowledge Base | 0 | 0 | 9 | **FAIL** |
| Conversations | 0 | 0 | 9 | **FAIL** |
| Leads | 4 | 2 | 9 | **PARTIAL** |
| Customers | 3 | 2 | 9 | **PARTIAL** |
| **Total** | **10** | **7** | **42** | — |

---

## Mapper Layer Architecture

### Created Mapper Classes

| Mapper | Location | Purpose |
|--------|----------|---------|
| `AuthMapper` | `features/auth/data/mappers/auth_mapper.dart` | Converts snake_case ↔ camelCase for auth tokens |
| `LeadMapper` | `features/leads/data/mappers/lead_mapper.dart` | Maps backend LeadResponse → frontend Lead |
| `CustomerMapper` | `features/customers/data/mappers/customer_mapper.dart` | Maps backend CustomerResponse → frontend Customer |

### Design Principles
- Domain models remain clean (camelCase, no backend-specific logic)
- All backend ↔ frontend conversion happens in data/mappers/
- Repositories use mappers instead of model.fromBackendResponse()
- No domain model modifications for backend compatibility

---

## Module 1: Authentication

### Backend Endpoints

| Endpoint | Method | Request Schema | Response Schema |
|----------|--------|----------------|-----------------|
| `/api/v1/auth/signup` | POST | `UserRegister` | `TokenResponse` |
| `/api/v1/auth/login` | POST | `UserLogin` | `TokenResponse` |
| `/api/v1/auth/refresh` | POST | `RefreshTokenRequest` | `TokenResponse` |

### Schema Comparison

#### Signup Request

| Field | Flutter (SignupRequest) | Backend (UserRegister) | Status |
|-------|------------------------|------------------------|--------|
| email | `email` (String) | `email` (string, email format) | **PASS** |
| password | `password` (String) | `password` (string, 1-128 chars) | **PASS** |
| organization_name | `organizationName` (String) | `organization_name` (string, 2-255 chars) | **PARTIAL** — Field name mismatch, datasource handles manually |

#### Login Request

| Field | Flutter (LoginRequest) | Backend (UserLogin) | Status |
|-------|----------------------|---------------------|--------|
| email | `email` (String) | `email` (string, email format) | **PASS** |
| password | `password` (String) | `password` (string, 1-128 chars) | **PASS** |

#### Token Response

| Field | Flutter (AuthTokens) | Backend (TokenResponse) | Status |
|-------|---------------------|-------------------------|--------|
| access_token | `accessToken` (String) | `access_token` (string) | **PASS** ✅ via AuthMapper |
| refresh_token | `refreshToken` (String) | `refresh_token` (string) | **PASS** ✅ via AuthMapper |
| token_type | `tokenType` (String, default 'bearer') | `token_type` (string, default 'bearer') | **PASS** ✅ via AuthMapper |
| org_id | `orgId` (String) | `org_id` (uuid) | **PASS** ✅ via AuthMapper |
| email | `email` (String) | `email` (string) | **PASS** |
| role | `role` (String) | `role` (string) | **PASS** |

#### Refresh Token Request

| Field | Flutter | Backend (RefreshTokenRequest) | Status |
|-------|---------|-------------------------------|--------|
| refresh_token | `String` | `refresh_token` (string) | **PASS** ✅ via datasource |

### Verification

| Check | Result |
|-------|--------|
| Request body format | **PASS** — Datasource constructs snake_case manually |
| Response parsing | **PASS** — AuthMapper converts snake_case → camelCase |
| Token storage | **PASS** — TokenManager stores raw JWT strings |
| Token refresh | **PASS** — Datasource sends snake_case refresh_token |
| Auth guard | **PASS** — Reads stored tokens directly |

### Overall: **PASS**

---

## Module 2: Dashboard

### Backend Endpoints

| Endpoint | Method | Status |
|----------|--------|--------|
| `/api/v1/health` | GET | Exists (HealthResponse) |
| `/api/v1/monitoring/health/details` | GET | Exists (SystemHealthDetail) |

### Flutter DashboardStats Model

```dart
class DashboardStats {
  int activeAgents;      // No backend endpoint
  int messagesToday;     // No backend endpoint
  int callsToday;        // No backend endpoint
  int leadsGenerated;    // No backend endpoint
  int customersManaged;  // No backend endpoint
  String systemHealth;   // Backend has /api/v1/health
}
```

### Schema Comparison

| Field | Flutter (DashboardStats) | Backend | Status |
|-------|-------------------------|---------|--------|
| activeAgents | `activeAgents` (int) | ❌ No endpoint | **FAIL** |
| messagesToday | `messagesToday` (int) | ❌ No endpoint | **FAIL** |
| callsToday | `callsToday` (int) | ❌ No endpoint | **FAIL** |
| leadsGenerated | `leadsGenerated` (int) | ❌ No endpoint | **FAIL** |
| customersManaged | `customersManaged` (int) | ❌ No endpoint | **FAIL** |
| systemHealth | `systemHealth` (String) | ✅ `GET /api/v1/health` → `HealthResponse` | **PARTIAL** |

### Missing Backend APIs

- `GET /api/v1/dashboard/stats` — Aggregated dashboard statistics
- `GET /api/v1/agents/count` — Active agent count
- `GET /api/v1/conversations/today` — Today's message/call counts

### Overall: **FAIL**

---

## Module 3: Agent Center

### Backend Endpoints

| Endpoint | Method | Status |
|----------|--------|--------|
| ❌ No agent endpoints exist | — | **FAIL** |

### Flutter Models Without Backend

| Model | Fields | Backend Schema | Status |
|-------|--------|----------------|--------|
| `WhatsAppAgent` | 12 fields | ❌ No endpoint | **FAIL** |
| `CallingAgent` | 14 fields | ❌ No endpoint | **FAIL** |
| `AgentTemplate` | 10 fields | ❌ No endpoint | **FAIL** |
| `AgentAnalytics` | 12 fields | ❌ No endpoint | **FAIL** |
| `AgentSettings` | 10 fields | ❌ No endpoint | **FAIL** |
| `Agent` (shared) | 12 fields | ❌ No endpoint | **FAIL** |
| `WhatsAppConfig` | 6 fields | ❌ No endpoint | **FAIL** |
| `VoiceConfig` | 6 fields | ❌ No endpoint | **FAIL** |
| `AvailableModel` | 6 fields | ❌ No endpoint | **FAIL** |

### Required Backend APIs

```
GET    /api/v1/agents/whatsapp           — List WhatsApp agents
POST   /api/v1/agents/whatsapp           — Create WhatsApp agent
GET    /api/v1/agents/whatsapp/{id}      — Get WhatsApp agent
PUT    /api/v1/agents/whatsapp/{id}      — Update WhatsApp agent
DELETE /api/v1/agents/whatsapp/{id}      — Delete WhatsApp agent

GET    /api/v1/agents/calling            — List Calling agents
POST   /api/v1/agents/calling            — Create Calling agent
GET    /api/v1/agents/calling/{id}       — Get Calling agent
PUT    /api/v1/agents/calling/{id}       — Update Calling agent
DELETE /api/v1/agents/calling/{id}       — Delete Calling agent

GET    /api/v1/agent-templates           — List templates
POST   /api/v1/agent-templates           — Create template
GET    /api/v1/agent-templates/{id}      — Get template
DELETE /api/v1/agent-templates/{id}      — Delete template

GET    /api/v1/agents/{id}/analytics     — Get agent analytics
GET    /api/v1/agents/{id}/settings      — Get agent settings
PUT    /api/v1/agents/{id}/settings      — Update agent settings
GET    /api/v1/models/available          — List available LLM models
```

### Overall: **FAIL**

---

## Module 4: Knowledge Base

### Backend Endpoints

| Endpoint | Method | Status |
|----------|--------|--------|
| `POST /api/v1/documents/upload` | POST | Exists (upload with kb_id query param) |
| `GET /api/v1/documents/` | GET | Exists (list with kb_id query param) |
| `DELETE /api/v1/documents/{doc_id}` | DELETE | Exists |

### Flutter Models

| Model | Fields | Backend Schema | Status |
|-------|--------|----------------|--------|
| `KnowledgeBase` | 10 fields | ❌ No endpoint | **FAIL** |
| `KbDocument` | 12 fields | ⚠️ `additionalProperties: true` | **UNKNOWN** |
| `KbStatistics` | 7 fields | ❌ No endpoint | **FAIL** |

### Endpoint Comparison

| Frontend Call | Backend Endpoint | Status |
|---------------|------------------|--------|
| `GET /api/v1/knowledge-bases` | ❌ Doesn't exist | **FAIL** |
| `POST /api/v1/knowledge-bases` | ❌ Doesn't exist | **FAIL** |
| `GET /api/v1/knowledge-bases/{id}` | ❌ Doesn't exist | **FAIL** |
| `PUT /api/v1/knowledge-bases/{id}` | ❌ Doesn't exist | **FAIL** |
| `DELETE /api/v1/knowledge-bases/{id}` | ❌ Doesn't exist | **FAIL** |
| `GET /api/v1/knowledge-bases/{id}/documents` | ❌ Wrong path | **FAIL** |
| `POST /api/v1/knowledge-bases/{id}/documents` | ❌ Wrong path | **FAIL** |
| `DELETE /api/v1/documents/{id}` | ✅ `DELETE /api/v1/documents/{doc_id}` | **PASS** |
| `POST /api/v1/documents/{id}/reindex` | ❌ Doesn't exist | **FAIL** |
| `GET /api/v1/knowledge-bases/{id}/search` | ❌ Doesn't exist | **FAIL** |
| `GET /api/v1/knowledge-bases/statistics` | ❌ Doesn't exist | **FAIL** |

### Path Mismatches

| Frontend Path | Backend Path | Issue |
|---------------|--------------|-------|
| `/knowledge-bases/{id}/documents` | `/documents/?kb_id={id}` | Different path structure |
| `/knowledge-bases/{id}/documents` (upload) | `/documents/upload?kb_id={id}` | Different path + param |

### Required Backend APIs

```
GET    /api/v1/knowledge-bases           — List knowledge bases
POST   /api/v1/knowledge-bases           — Create knowledge base
GET    /api/v1/knowledge-bases/{id}      — Get knowledge base
PUT    /api/v1/knowledge-bases/{id}      — Update knowledge base
DELETE /api/v1/knowledge-bases/{id}      — Delete knowledge base
GET    /api/v1/knowledge-bases/{id}/search — Search documents
GET    /api/v1/knowledge-bases/statistics — Get statistics
POST   /api/v1/documents/{id}/reindex    — Reindex document
```

### Overall: **FAIL**

---

## Module 5: Conversations

### Backend Endpoints

| Endpoint | Method | Status |
|----------|--------|--------|
| `POST /api/v1/chat/sessions` | POST | Exists (ChatSessionCreate → ChatSessionResponse) |
| `POST /api/v1/chat/sessions/{id}/message` | POST | Exists (ChatMessageRequest → ChatMessageResponse) |
| `POST /api/v1/chat/completions` | POST | Exists (ChatCompletionRequest → ChatCompletionResponse) |

### Flutter Models

| Model | Fields | Backend Schema | Status |
|-------|--------|----------------|--------|
| `Conversation` | 15 fields | ❌ No endpoint | **FAIL** |
| `Message` | 7 fields | ❌ No endpoint | **FAIL** |
| `ConversationAnalytics` | 8 fields | ❌ No endpoint | **FAIL** |
| `CallLog` | 12 fields | ❌ No endpoint | **FAIL** |

### Endpoint Comparison

| Frontend Call | Backend Endpoint | Status |
|---------------|------------------|--------|
| `GET /api/v1/conversations` | ❌ Doesn't exist | **FAIL** |
| `GET /api/v1/conversations/{id}` | ❌ Doesn't exist | **FAIL** |
| `GET /api/v1/conversations/{id}/messages` | ❌ Doesn't exist | **FAIL** |
| `GET /api/v1/conversations/call-logs` | ❌ Doesn't exist | **FAIL** |
| `GET /api/v1/conversations/call-logs/{id}` | ❌ Doesn't exist | **FAIL** |
| `GET /api/v1/conversations/search` | ❌ Doesn't exist | **FAIL** |
| `GET /api/v1/conversations/analytics` | ❌ Doesn't exist | **FAIL** |
| `GET /api/v1/conversations/export/csv` | ❌ Doesn't exist | **FAIL** |
| `POST /api/v1/chat/sessions` | ✅ Exists | **PASS** |
| `POST /api/v1/chat/sessions/{id}/message` | ✅ Exists | **PASS** |
| `POST /api/v1/chat/completions` | ✅ Exists | **PASS** |

### Backend Response Schemas (Existing)

#### ChatSessionResponse
```json
{
  "session_id": "uuid",
  "agent_id": "uuid",
  "customer_phone": "string",
  "status": "string"
}
```

**Frontend mismatch:** Flutter `Conversation` model has 15 fields; backend `ChatSessionResponse` has 4 fields. No mapper exists.

#### ChatMessageResponse
```json
{
  "response": "string",
  "sources": ["string"],
  "lead_captured": boolean
}
```

**Frontend mismatch:** Flutter `Message` model has 7 fields; backend `ChatMessageResponse` has 3 fields. No mapper exists.

#### ChatCompletionResponse
```json
{
  "response": "string",
  "model": "string",
  "finish_reason": "string"
}
```

**Frontend mismatch:** No Flutter model maps to this response.

### Required Backend APIs

```
GET    /api/v1/conversations              — List conversations
GET    /api/v1/conversations/{id}         — Get conversation
GET    /api/v1/conversations/{id}/messages — Get messages
GET    /api/v1/conversations/call-logs    — List call logs
GET    /api/v1/conversations/call-logs/{id} — Get call log
GET    /api/v1/conversations/search       — Search conversations
GET    /api/v1/conversations/analytics    — Get analytics
GET    /api/v1/conversations/export/csv   — Export CSV
```

### Overall: **FAIL**

---

## Module 6: Leads Intelligence Engine

### Backend Endpoints

| Endpoint | Method | Status |
|----------|--------|--------|
| `GET /api/v1/leads/` | GET | Exists (LeadResponse[]) |
| `GET /api/v1/leads/count` | GET | Exists ({count: int}) |
| `GET /api/v1/leads/{lead_id}` | GET | Exists (LeadResponse) |
| `DELETE /api/v1/leads/{lead_id}` | DELETE | Exists |

### Backend LeadResponse Schema

```json
{
  "id": "uuid",
  "session_id": "uuid",
  "name": "string|null",
  "phone": "string|null",
  "email": "string|null",
  "intent": "string|null",
  "product_interest": "string|null",
  "budget": "number|null",
  "score": "number (default: 0.0)",
  "created_at": "string"
}
```

### Flutter Lead Model

```dart
class Lead {
  String id;
  String orgId;
  String name;
  String? email;
  String? phone;
  String? company;
  String? jobTitle;
  LeadStatus status;
  LeadSource source;
  String? assignedTo;
  String? assignedToName;
  int aiScore;
  int intentScore;
  int budgetScore;
  int engagementScore;
  String? notes;
  Map<String, dynamic>? metadata;
  String? conversationId;
  DateTime? lastContactedAt;
  DateTime? qualifiedAt;
  DateTime? wonAt;
  DateTime? lostAt;
  DateTime createdAt;
  DateTime updatedAt;
}
```

### Field-by-Field Comparison

| Flutter Field | Backend Field | Type | Status |
|---------------|---------------|------|--------|
| `id` | `id` | uuid → String | **PASS** |
| `orgId` | ❌ Not in backend | — | **MISSING** |
| `name` | `name` | string? → String? | **PASS** |
| `email` | `email` | string? → String? | **PASS** |
| `phone` | `phone` | string? → String? | **PASS** |
| `company` | ❌ Not in backend | — | **MISSING** |
| `jobTitle` | ❌ Not in backend | — | **MISSING** |
| `status` | `intent` | string → LeadStatus | **MAPPED** ✅ via LeadMapper |
| `source` | ❌ Not in backend | — | **MISSING** |
| `assignedTo` | ❌ Not in backend | — | **MISSING** |
| `assignedToName` | ❌ Not in backend | — | **MISSING** |
| `aiScore` | `score` | number → int | **MAPPED** ✅ via LeadMapper |
| `intentScore` | ❌ Not in backend | — | **MISSING** |
| `budgetScore` | ❌ Not in backend | — | **MISSING** |
| `engagementScore` | ❌ Not in backend | — | **MISSING** |
| `notes` | ❌ Not in backend | — | **MISSING** |
| `metadata` | `product_interest` | string? → Map? | **MAPPED** ✅ via LeadMapper |
| `conversationId` | `session_id` | uuid → String | **MAPPED** ✅ via LeadMapper |
| `lastContactedAt` | ❌ Not in backend | — | **MISSING** |
| `qualifiedAt` | ❌ Not in backend | — | **MISSING** |
| `wonAt` | ❌ Not in backend | — | **MISSING** |
| `lostAt` | ❌ Not in backend | — | **MISSING** |
| `createdAt` | `created_at` | string → DateTime | **MAPPED** ✅ via LeadMapper |
| `updatedAt` | ❌ Not in backend | — | **MISSING** |

### Type Mismatches

| Field | Flutter Type | Backend Type | Issue |
|-------|-------------|--------------|-------|
| `score` | `int` | `number` (double) | Double → Int conversion |
| `created_at` | `DateTime` | `string` | String → DateTime parsing |
| `intent` | `LeadStatus` enum | `string` | String → Enum mapping |

### Endpoint Comparison

| Frontend Call | Backend Endpoint | Status |
|---------------|------------------|--------|
| `GET /api/v1/leads` | ✅ `GET /api/v1/leads/` | **PASS** ✅ via LeadMapper |
| `POST /api/v1/leads` | ❌ Doesn't exist | **FAIL** |
| `GET /api/v1/leads/{id}` | ✅ `GET /api/v1/leads/{lead_id}` | **PASS** ✅ via LeadMapper |
| `PUT /api/v1/leads/{id}` | ❌ Doesn't exist | **FAIL** |
| `DELETE /api/v1/leads/{id}` | ✅ `DELETE /api/v1/leads/{lead_id}` | **PASS** |
| `DELETE /api/v1/leads` (bulk) | ❌ Doesn't exist | **FAIL** |
| `PATCH /api/v1/leads/{id}/status` | ❌ Doesn't exist | **FAIL** |
| `PATCH /api/v1/leads/{id}/assign` | ❌ Doesn't exist | **FAIL** |
| `GET /api/v1/leads/{id}/activities` | ❌ Doesn't exist | **FAIL** |
| `POST /api/v1/leads/{id}/notes` | ❌ Doesn't exist | **FAIL** |
| `GET /api/v1/leads/analytics` | ❌ Doesn't exist | **FAIL** |
| `GET /api/v1/leads/search` | ❌ Doesn't exist | **FAIL** |
| `GET /api/v1/leads/export/csv` | ❌ Doesn't exist | **FAIL** |

### Required Backend APIs

```
POST   /api/v1/leads                    — Create lead
PUT    /api/v1/leads/{id}               — Update lead
PATCH  /api/v1/leads/{id}/status        — Update status
PATCH  /api/v1/leads/{id}/assign        — Assign lead
GET    /api/v1/leads/{id}/activities    — Get activities
POST   /api/v1/leads/{id}/notes         — Add note
GET    /api/v1/leads/analytics          — Get analytics
GET    /api/v1/leads/search             — Search leads
GET    /api/v1/leads/export/csv         — Export CSV
DELETE /api/v1/leads                    — Bulk delete
```

### Overall: **PARTIAL** — 4 endpoints exist, 2 working via mapper, 9 missing

---

## Module 7: Customer Memory System

### Backend Endpoints

| Endpoint | Method | Status |
|----------|--------|--------|
| `GET /api/v1/customers/` | GET | Exists (CustomerResponse[]) |
| `GET /api/v1/customers/{customer_id}` | GET | Exists (CustomerResponse) |
| `PATCH /api/v1/customers/{customer_id}` | PATCH | Exists (CustomerUpdate → CustomerResponse) |

### Backend CustomerResponse Schema

```json
{
  "id": "uuid",
  "phone": "string",
  "name": "string|null",
  "preferences": "string|null",
  "notes": "string|null",
  "created_at": "string",
  "updated_at": "string"
}
```

### Backend CustomerUpdate Schema

```json
{
  "name": "string (1-255 chars)|null",
  "preferences": "string|null",
  "notes": "string|null"
}
```

### Flutter Customer Model

```dart
class Customer {
  String id;
  String orgId;
  String name;
  String? email;
  String? phone;
  String? company;
  String? jobTitle;
  String? avatarUrl;
  CustomerSegment segment;
  int healthScore;
  int engagementScore;
  int retentionScore;
  int satisfactionScore;
  int revenueScore;
  String? assignedTo;
  String? assignedToName;
  String? leadId;
  int totalInteractions;
  double totalRevenue;
  List<String> tags;
  Map<String, dynamic>? preferences;
  Map<String, dynamic>? memory;
  DateTime? lastInteractionAt;
  DateTime? lastPurchaseAt;
  DateTime? churnedAt;
  DateTime createdAt;
  DateTime updatedAt;
}
```

### Field-by-Field Comparison

| Flutter Field | Backend Field | Type | Status |
|---------------|---------------|------|--------|
| `id` | `id` | uuid → String | **PASS** |
| `orgId` | ❌ Not in backend | — | **MISSING** |
| `name` | `name` | string? → String? | **PASS** |
| `email` | ❌ Not in backend | — | **MISSING** |
| `phone` | `phone` | string → String | **PASS** |
| `company` | ❌ Not in backend | — | **MISSING** |
| `jobTitle` | ❌ Not in backend | — | **MISSING** |
| `avatarUrl` | ❌ Not in backend | — | **MISSING** |
| `segment` | ❌ Not in backend | — | **MISSING** |
| `healthScore` | ❌ Not in backend | — | **MISSING** |
| `engagementScore` | ❌ Not in backend | — | **MISSING** |
| `retentionScore` | ❌ Not in backend | — | **MISSING** |
| `satisfactionScore` | ❌ Not in backend | — | **MISSING** |
| `revenueScore` | ❌ Not in backend | — | **MISSING** |
| `assignedTo` | ❌ Not in backend | — | **MISSING** |
| `assignedToName` | ❌ Not in backend | — | **MISSING** |
| `leadId` | ❌ Not in backend | — | **MISSING** |
| `totalInteractions` | ❌ Not in backend | — | **MISSING** |
| `totalRevenue` | ❌ Not in backend | — | **MISSING** |
| `tags` | ❌ Not in backend | — | **MISSING** |
| `preferences` | `preferences` | string? → Map? | **TYPE MISMATCH** ⚠️ |
| `memory` | ❌ Not in backend | — | **MISSING** |
| `lastInteractionAt` | ❌ Not in backend | — | **MISSING** |
| `lastPurchaseAt` | ❌ Not in backend | — | **MISSING** |
| `churnedAt` | ❌ Not in backend | — | **MISSING** |
| `createdAt` | `created_at` | string → DateTime | **MAPPED** ✅ via CustomerMapper |
| `updatedAt` | `updated_at` | string → DateTime | **MAPPED** ✅ via CustomerMapper |

### Type Mismatches

| Field | Flutter Type | Backend Type | Issue |
|-------|-------------|--------------|-------|
| `preferences` | `Map<String, dynamic>?` | `string?` | String → Map conversion needed |
| `created_at` | `DateTime` | `string` | String → DateTime parsing |
| `updated_at` | `DateTime` | `string` | String → DateTime parsing |

### Endpoint Comparison

| Frontend Call | Backend Endpoint | Status |
|---------------|------------------|--------|
| `GET /api/v1/customers` | ✅ `GET /api/v1/customers/` | **PASS** ✅ via CustomerMapper |
| `POST /api/v1/customers` | ❌ Doesn't exist | **FAIL** |
| `GET /api/v1/customers/{id}` | ✅ `GET /api/v1/customers/{customer_id}` | **PASS** ✅ via CustomerMapper |
| `PUT /api/v1/customers/{id}` | ❌ Wrong method (backend uses PATCH) | **FAIL** |
| `PATCH /api/v1/customers/{id}` | ✅ `PATCH /api/v1/customers/{customer_id}` | **PASS** ✅ via CustomerMapper |
| `DELETE /api/v1/customers/{id}` | ❌ Doesn't exist | **FAIL** |
| `DELETE /api/v1/customers` (bulk) | ❌ Doesn't exist | **FAIL** |
| `PATCH /api/v1/customers/{id}/segment` | ❌ Doesn't exist | **FAIL** |
| `PATCH /api/v1/customers/{id}/assign` | ❌ Doesn't exist | **FAIL** |
| `GET /api/v1/customers/{id}/activities` | ❌ Doesn't exist | **FAIL** |
| `POST /api/v1/customers/{id}/notes` | ❌ Doesn't exist | **FAIL** |
| `GET /api/v1/customers/analytics` | ❌ Doesn't exist | **FAIL** |
| `GET /api/v1/customers/search` | ❌ Doesn't exist | **FAIL** |
| `GET /api/v1/customers/export/csv` | ❌ Doesn't exist | **FAIL** |

### Required Backend APIs

```
POST   /api/v1/customers                  — Create customer
DELETE /api/v1/customers/{id}             — Delete customer
DELETE /api/v1/customers                  — Bulk delete customers
PATCH  /api/v1/customers/{id}/segment     — Update segment
PATCH  /api/v1/customers/{id}/assign      — Assign customer
GET    /api/v1/customers/{id}/activities  — Get activities
POST   /api/v1/customers/{id}/notes       — Add note
GET    /api/v1/customers/analytics        — Get analytics
GET    /api/v1/customers/search           — Search customers
GET    /api/v1/customers/export/csv       — Export CSV
```

### Overall: **PARTIAL** — 3 endpoints exist, 3 working via mapper, 9 missing

---

## Summary of All Broken Endpoints

### Missing Backend APIs (42 total)

| Module | Missing Endpoints | Count |
|--------|-------------------|-------|
| Dashboard | `/api/v1/dashboard/stats` | 1 |
| Agent Center | All agent CRUD, templates, analytics, settings, models | 17 |
| Knowledge Base | KB CRUD, search, statistics, reindex | 8 |
| Conversations | Conversation list, detail, messages, call-logs, search, analytics, export | 7 |
| Leads | Create, update, status, assign, activities, notes, analytics, search, export, bulk delete | 10 |
| Customers | Create, delete, bulk delete, segment, assign, activities, notes, analytics, search, export | 9 |
| **Total** | | **42** |

### Existing Backend APIs with Schema Mismatches (10 total)

| Module | Endpoint | Issue |
|--------|----------|-------|
| Auth | `/api/v1/auth/signup` | Request: `organizationName` → `organization_name` |
| Auth | `/api/v1/auth/login` | Response: snake_case → camelCase mapping needed |
| Auth | `/api/v1/auth/refresh` | Request/Response: snake_case ↔ camelCase |
| Leads | `GET /api/v1/leads/` | 14 fields missing from backend, intent→status mapping |
| Leads | `GET /api/v1/leads/{id}` | 14 fields missing from backend |
| Leads | `GET /api/v1/leads/count` | Response: `{count: int}` only |
| Customers | `GET /api/v1/customers/` | 18 fields missing from backend |
| Customers | `GET /api/v1/customers/{id}` | 18 fields missing from backend |
| Customers | `PATCH /api/v1/customers/{id}` | Only accepts name, preferences, notes |
| Documents | `GET /api/v1/documents/` | Schema: `additionalProperties: true` (dynamic) |

---

## Verification Gates

| Gate | Result |
|------|--------|
| `flutter analyze` | 0 errors, 0 warnings |
| `flutter test` | All tests pass |
| `build_runner` | Generates cleanly |
| Domain models clean | ✅ No backend-specific logic in models |
| Mapper layer | ✅ All conversion in data/mappers/ |
| Repository pattern | ✅ All repos use mappers |

---

## Recommendations

### Priority 1: Fix Auth Token Parsing (Critical)

The auth module works because the datasource manually constructs request bodies. However, the `AuthTokens.fromJson()` call would fail when parsing the backend's snake_case response. The `AuthMapper` fixes this.

**Status:** FIXED ✅ — AuthMapper converts snake_case → camelCase

### Priority 2: Extend Backend APIs (Critical)

The following backend endpoints are required for the frontend to function:

1. **Agent Center** — 17 endpoints for agent CRUD, templates, analytics
2. **Knowledge Base** — 8 endpoints for KB CRUD, search, statistics
3. **Conversations** — 7 endpoints for conversation management
4. **Leads** — 10 endpoints for lead CRUD, activities, analytics
5. **Customers** — 9 endpoints for customer CRUD, segments, analytics
6. **Dashboard** — 1 endpoint for aggregated stats

### Priority 3: Fix Data Model Alignment (High)

Backend responses need additional fields:

1. **LeadResponse** — Add: orgId, company, jobTitle, source, assignedTo, intentScore, budgetScore, engagementScore, notes, lastContactedAt, qualifiedAt, wonAt, lostAt, updatedAt
2. **CustomerResponse** — Add: orgId, email, company, jobTitle, avatarUrl, segment, healthScore, engagementScore, retentionScore, satisfactionScore, revenueScore, assignedTo, leadId, totalInteractions, totalRevenue, tags, memory, lastInteractionAt, lastPurchaseAt, churnedAt
3. **ChatSessionResponse** — Add: orgId, externalUserId, agentName, platform, status, messageCount, callDurationSeconds, lastMessagePreview, lastMessageAt, assignedTo, metadata, createdAt, updatedAt

### Priority 4: Create Conversation Mappers (Medium)

The backend has 3 chat endpoints but no mappers exist:

1. `ChatSessionResponse` → `Conversation` mapper
2. `ChatMessageResponse` → `Message` mapper
3. `ChatCompletionResponse` → needs new Flutter model

---

## Files Created/Modified

### Created
- `features/auth/data/mappers/auth_mapper.dart`
- `features/leads/data/mappers/lead_mapper.dart`
- `features/customers/data/mappers/customer_mapper.dart`

### Modified
- `features/auth/data/repositories/auth_repository.dart` — Uses AuthMapper
- `features/leads/data/repositories/lead_repository.dart` — Uses LeadMapper
- `features/customers/data/repositories/customer_repository.dart` — Uses CustomerMapper
- `features/leads/domain/models/lead.dart` — Removed fromBackendResponse factory
- `features/customers/domain/models/customer.dart` — Removed fromBackendResponse factory

---

## Conclusion

**Overall Status: PARTIAL**

- **3 modules** (Auth, Leads, Customers) have working adapter layers via mappers
- **4 modules** (Dashboard, Agent Center, Knowledge Base, Conversations) have no backend support
- **42 backend endpoints** are missing
- **10 existing endpoints** have schema mismatches (all handled by mappers)
- **Domain models remain clean** — All backend-specific logic is in data/mappers/
- **All verification gates pass** — 0 errors, tests pass, build_runner generates cleanly

The mapper layer architecture is in place and working. The next step is to extend the backend API to support the missing 42 endpoints.
