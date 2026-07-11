# API Documentation

Base URL: `http://localhost:8100/api/v1`

All endpoints except `/auth/login` require Bearer token authentication.

## Authentication

### POST /auth/login

Authenticate with email and password.

**Request:**
```json
{
  "email": "user@example.com",
  "password": "your-password"
}
```

**Response (200):**
```json
{
  "access_token": "eyJ...",
  "refresh_token": "eyJ...",
  "token_type": "bearer",
  "expires_in": 3600
}
```

### POST /auth/refresh

Refresh an expired access token using a valid refresh token.

**Headers:** `Authorization: Bearer <refresh_token>`

**Response (200):** Same structure as login.

### GET /auth/me

Get the currently authenticated user's profile.

**Headers:** `Authorization: Bearer <access_token>`

**Response (200):**
```json
{
  "id": "uuid",
  "organization_id": "uuid",
  "email": "user@example.com",
  "name": "User Name",
  "role": "admin",
  "permissions": ["view_dashboard", "manage_crm"]
}
```

### POST /auth/users

Create a new user. Requires `manage_team` permission.

**Request:**
```json
{
  "email": "newuser@example.com",
  "password": "secure-password",
  "name": "New User",
  "organization_id": "uuid"
}
```

---

## Health

### GET /health

Check system health status.

**Response (200):**
```json
{
  "status": "healthy",
  "uptime_seconds": 1234.56,
  "database": "connected",
  "version": "1.0.0"
}
```

---

## Organizations

### GET /organizations/

List organizations. Requires `manage_settings` permission.

| Query Param | Type   | Description                          |
|-------------|--------|--------------------------------------|
| page        | int    | Page number (default: 1)             |
| limit       | int    | Items per page (default: 50, max 100)|
| status      | string | Filter by status                     |
| search      | string | Search by name                       |

### POST /organizations/

Create an organization. Requires `manage_settings` permission.

| Query Param | Type   | Description      |
|-------------|--------|------------------|
| name        | string | Organization name|
| slug        | string | Unique slug      |

### GET /organizations/{org_id}

Get organization details.

### PUT /organizations/{org_id}

Update organization fields.

| Query Param       | Type   | Description           |
|-------------------|--------|-----------------------|
| name              | string | Organization name     |
| status            | string | active/suspended/trial|
| timezone          | string | IANA timezone         |
| brand_color       | string | Hex color             |
| working_hours_start | string | HH:MM format       |
| working_hours_end   | string | HH:MM format       |
| working_days      | int[]  | Array of day numbers  |
| default_language  | string | Default language code |

### DELETE /organizations/{org_id}

Suspend an organization.

### GET /organizations/{org_id}/stats

Get organization statistics. Requires `view_dashboard` permission.

**Response:**
```json
{
  "organization_id": "uuid",
  "total_conversations": 150,
  "total_leads": 45,
  "total_users": 8
}
```

---

## WhatsApp Accounts

### GET /whatsapp/accounts

List WhatsApp accounts for the current organization.

| Query Param | Type   | Description                          |
|-------------|--------|--------------------------------------|
| page        | int    | Page number (default: 1)             |
| limit       | int    | Items per page (default: 50)         |
| status      | string | Filter by status                     |

### POST /whatsapp/accounts

Create a WhatsApp account. Requires `manage_whatsapp` permission.

| Query Param   | Type   | Description       |
|---------------|--------|-------------------|
| phone_number  | string | Phone number      |
| business_name | string | Business name     |
| webhook_url   | string | Optional webhook  |

### GET /whatsapp/accounts/{account_id}

Get account details.

### PUT /whatsapp/accounts/{account_id}

Update account settings.

### DELETE /whatsapp/accounts/{account_id}

Deactivate a WhatsApp account.

### POST /whatsapp/accounts/{account_id}/connect

Initiate QR code connection.

### POST /whatsapp/accounts/{account_id}/disconnect

Disconnect the account.

### GET /whatsapp/accounts/{account_id}/qr

Get current QR code.

### GET /whatsapp/accounts/{account_id}/health

Get account health status.

### POST /whatsapp/accounts/{account_id}/webhook

Set webhook URL.

| Query Param | Type   | Description   |
|-------------|--------|---------------|
| webhook_url | string | Webhook URL   |

---

## Conversations

### GET /conversations/

List conversations for the current organization.

| Query Param    | Type    | Description                          |
|----------------|---------|--------------------------------------|
| page           | int     | Page number (default: 1)             |
| limit          | int     | Items per page (default: 50)         |
| status         | string  | Filter by status                     |
| department_id  | uuid    | Filter by department                 |
| assigned_to    | uuid    | Filter by assignee                   |
| search         | string  | Search by customer name/phone        |
| is_archived    | bool    | Filter archived status               |

### GET /conversations/{conversation_id}

Get conversation with all messages.

### PATCH /conversations/{conversation_id}/status

Update conversation status. Requires `manage_inbox` permission.

| Query Param | Type   | Description |
|-------------|--------|-------------|
| status      | string | New status  |

### PATCH /conversations/{conversation_id}/assign

Assign conversation to a user. Requires `manage_inbox` permission.

| Query Param | Type | Description   |
|-------------|------|---------------|
| user_id     | uuid | Assignee ID   |

### PATCH /conversations/{conversation_id}/department

Assign conversation to a department.

### PATCH /conversations/{conversation_id}/pin

Toggle pin status.

### PATCH /conversations/{conversation_id}/archive

Toggle archive status.

### POST /conversations/{conversation_id}/tags

Update conversation tags.

| Query Param | Type   | Description |
|-------------|--------|-------------|
| tags        | string[] | Tag list  |

### POST /conversations/{conversation_id}/handoff/request

Request a handoff.

| Query Param | Type   | Description |
|-------------|--------|-------------|
| note        | string | Handoff note|

### POST /conversations/{conversation_id}/handoff/accept

Accept a pending handoff request. Requires `manage_inbox` permission.

### POST /conversations/{conversation_id}/handoff/complete

Complete an active handoff.

### POST /conversations/{conversation_id}/ai/toggle

Toggle AI on/off for the conversation. Requires `manage_inbox` permission.

### GET /conversations/{conversation_id}/messages

Get paginated messages for a conversation.

### POST /conversations/{conversation_id}/messages

Send a message in a conversation.

| Query Param | Type   | Description          |
|-------------|--------|----------------------|
| content     | string | Message content      |
| content_type| string | Message type (text)  |
| from_phone  | string | Sender phone         |
| to_phone    | string | Receiver phone       |

---

## CRM

### GET /crm/leads

List leads.

| Query Param     | Type   | Description                          |
|-----------------|--------|--------------------------------------|
| page            | int    | Page number (default: 1)             |
| limit           | int    | Items per page (default: 50)         |
| status          | string | Filter by status                     |
| source          | string | Filter by source                     |
| pipeline_stage  | string | Filter by pipeline stage             |
| assigned_to     | uuid   | Filter by assignee                   |
| search          | string | Search by name/phone/email           |

### POST /crm/leads

Create a lead. Requires `manage_crm` permission.

| Query Param    | Type   | Description          |
|----------------|--------|----------------------|
| customer_phone | string | Customer phone       |
| customer_name  | string | Customer name        |
| customer_email | string | Customer email       |
| source         | string | Lead source (default: whatsapp) |

### GET /crm/leads/{lead_id}

Get lead details.

### PUT /crm/leads/{lead_id}

Update lead.

### PATCH /crm/leads/{lead_id}/stage

Update pipeline stage.

### PATCH /crm/leads/{lead_id}/score

Update lead score (0-100).

### PATCH /crm/leads/{lead_id}/assign

Assign lead to a user.

### POST /crm/leads/{lead_id}/notes

Add a note to a lead.

### POST /crm/leads/{lead_id}/tags

Update lead tags.

### POST /crm/leads/{lead_id}/convert

Convert lead to customer.

### GET /crm/customers

List customers.

| Query Param | Type   | Description                          |
|-------------|--------|--------------------------------------|
| page        | int    | Page number (default: 1)             |
| limit       | int    | Items per page (default: 50)         |
| search      | string | Search by name/phone/email           |
| tier        | string | Filter by tier                       |

### GET /crm/customers/{customer_id}

Get customer details.

### PUT /crm/customers/{customer_id}

Update customer.

---

## Knowledge Base

### GET /knowledge/

List knowledge documents.

| Query Param | Type   | Description                          |
|-------------|--------|--------------------------------------|
| page        | int    | Page number (default: 1)             |
| limit       | int    | Items per page (default: 50)         |
| type        | string | Filter by document type              |
| tags        | string | Comma-separated tags                 |
| search      | string | Search by title/content              |

### POST /knowledge/

Upload a document. Requires `manage_knowledge` permission. Multipart form-data.

| Field  | Type   | Description   |
|--------|--------|---------------|
| title  | string | Document title|
| file   | file   | File upload   |
| tags   | string | Comma-separated tags |

### GET /knowledge/{doc_id}

Get document details.

### DELETE /knowledge/{doc_id}

Delete document.

### POST /knowledge/{doc_id}/index

Reindex document for search.

### POST /knowledge/query

Query the knowledge base.

| Query Param | Type   | Description |
|-------------|--------|-------------|
| text        | string | Search query|

### POST /knowledge/faq

Add an FAQ entry.

---

## Workflows

### GET /workflows/

List workflows.

| Query Param  | Type   | Description              |
|--------------|--------|--------------------------|
| page         | int    | Page number (default: 1) |
| limit        | int    | Items per page (default: 50) |
| status       | string | Filter by status         |
| trigger_type | string | Filter by trigger type   |

### POST /workflows/

Create a workflow.

### GET /workflows/{workflow_id}

Get workflow details.

### PUT /workflows/{workflow_id}

Update workflow.

### DELETE /workflows/{workflow_id}

Delete workflow.

### PATCH /workflows/{workflow_id}/status

Update workflow status (active/paused/archived).

### POST /workflows/{workflow_id}/test

Test run a workflow.

### GET /workflows/{workflow_id}/executions

Get workflow execution history.

### GET /workflows/executions/{exec_id}

Get execution details.

---

## Campaigns

### GET /campaigns/

List campaigns.

### POST /campaigns/

Create a campaign.

### GET /campaigns/{campaign_id}

Get campaign details.

### PUT /campaigns/{campaign_id}

Update campaign.

### DELETE /campaigns/{campaign_id}

Delete campaign.

### POST /campaigns/{campaign_id}/send

Start sending campaign.

### POST /campaigns/{campaign_id}/pause

Pause campaign sending.

### GET /campaigns/{campaign_id}/recipients

Get campaign recipients.

### POST /campaigns/{campaign_id}/test

Send test message.

---

## Analytics

### GET /analytics/overview

Get overview metrics for the period.

| Query Param | Type | Description              |
|-------------|------|--------------------------|
| days        | int  | Lookback period (1-365)  |

### GET /analytics/conversations

Daily conversation metrics.

### GET /analytics/leads

Lead metrics and status breakdown.

### GET /analytics/response-time

Average response time metrics.

### GET /analytics/revenue

Revenue metrics.

### GET /analytics/satisfaction

Customer satisfaction metrics.

### GET /analytics/model-usage

Token usage and model cost metrics.

### POST /analytics/events

Record a custom analytics event.

---

## Team Inbox

### GET /inbox/overview

Get inbox summary (unread, assigned, unassigned counts).

### GET /inbox/departments

List active departments.

### POST /inbox/departments

Create department.

### PUT /inbox/departments/{dept_id}

Update department.

### DELETE /inbox/departments/{dept_id}

Deactivate department.

### GET /inbox/assignments

Get conversations assigned to current user.

### POST /inbox/bulk/assign

Bulk assign conversations.

### POST /inbox/bulk/archive

Bulk archive conversations.

### POST /inbox/bulk/tags

Bulk tag conversations.

---

## Settings

### GET /settings/organization

Get current organization settings.

### PUT /settings/organization

Update organization settings.

### GET /settings/prompts

List prompt templates.

### POST /settings/prompts

Create prompt template.

### PUT /settings/prompts/{prompt_id}

Update prompt template.

### DELETE /settings/prompts/{prompt_id}

Delete prompt template.

### GET /settings/models

Get model configuration.

### PUT /settings/models

Update model configuration.

---

## Permissions

### GET /permissions/

List all permissions and role definitions.

### GET /permissions/users

List users with their permissions.

### PUT /permissions/users/{user_id}

Update user permissions.

### GET /permissions/roles

List role definitions.

### PUT /permissions/roles/{role_name}

Update role permissions (in-memory).

---

## Logs

### GET /logs/

List audit logs.

| Query Param   | Type   | Description              |
|---------------|--------|--------------------------|
| page          | int    | Page number              |
| limit         | int    | Items per page           |
| level         | string | Filter by log level      |
| action        | string | Filter by action         |
| user_id       | uuid   | Filter by user           |
| resource_type | string | Filter by resource type  |
| date_from     | datetime | Start date filter      |
| date_to       | datetime | End date filter        |

### GET /logs/{log_id}

Get log entry details.

### POST /logs/

Create a log entry.

---

## Plugins

### GET /plugins/

List installed plugins.

### POST /plugins/

Install a plugin.

### GET /plugins/{plugin_id}

Get plugin details.

### PUT /plugins/{plugin_id}

Update plugin configuration.

### DELETE /plugins/{plugin_id}

Uninstall plugin.

### POST /plugins/{plugin_id}/toggle

Toggle plugin enabled/disabled.
