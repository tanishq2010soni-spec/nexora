# API Reference

Base URL: `http://localhost:8755/api/v1`
WebSocket: `ws://localhost:8755/ws/v1`

## Authentication

Most endpoints require authentication via Bearer token:

```
Authorization: Bearer <token>
```

## Chat

### Send Message
```
POST /chat
Content-Type: application/json

{
  "conversation_id": "uuid",
  "message": "Hello, how are you?",
  "stream": true
}

Response (streaming disabled):
{
  "id": "msg_uuid",
  "role": "assistant",
  "content": "I'm doing well!",
  "tool_calls": [],
  "timestamp": "2026-06-30T12:00:00Z"
}
```

### Get Conversation History
```
GET /chat/{conversation_id}
Query: ?limit=50&offset=0

Response:
{
  "id": "conv_uuid",
  "title": "Conversation title",
  "messages": [...],
  "created_at": "...",
  "updated_at": "..."
}
```

### List Conversations
```
GET /chat/conversations
Query: ?search=keyword&page=1&per_page=20

Response:
{
  "conversations": [...],
  "total": 100,
  "page": 1
}
```

### Delete Conversation
```
DELETE /chat/{conversation_id}
```

## Memory

### Search Memories
```
GET /memory/search
Query: ?q=search_term&type=conversation&tags=important,work&limit=50

Response:
{
  "results": [
    {
      "id": "mem_uuid",
      "type": "conversation",
      "content": "Memory content text",
      "score": 0.92,
      "tags": ["important", "work"],
      "timestamp": "2026-06-30T12:00:00Z",
      "metadata": {...}
    }
  ],
  "total": 10
}
```

### Get Memory Entry
```
GET /memory/{id}
```

### Update Memory Tags
```
PATCH /memory/{id}/tags

{
  "tags": ["personal", "recipe"]
}
```

### Delete Memory
```
DELETE /memory/{id}
```

### Summarize Memories
```
POST /memory/summarize

{
  "ids": ["uuid1", "uuid2"]
}

Response:
{
  "summary": "Summarized text content"
}
```

### Memory Stats
```
GET /memory/stats

Response:
{
  "total": 1500,
  "by_type": {
    "conversation": 800,
    "fact": 300,
    "preference": 200,
    "task": 150,
    "file": 50
  },
  "tags": ["important", "work", "personal"]
}
```

## Tasks

### Create Task
```
POST /tasks

{
  "goal": "Research topic and write summary",
  "steps": [
    {"description": "Search web for recent articles"},
    {"description": "Read and extract key points"},
    {"description": "Write summary"}
  ]
}

Response:
{
  "id": "task_uuid",
  "goal": "...",
  "status": "pending",
  "steps": [...],
  "created_at": "..."
}
```

### Create Plan
```
POST /tasks/plan

{
  "description": "I need to organize my files and backup data"
}

Response:
{
  "plan": [
    {"step": 1, "description": "Scan documents folder"},
    {"step": 2, "description": "Categorize files by type"},
    {"step": 3, "description": "Create backup archive"}
  ]
}
```

### List Tasks
```
GET /tasks
Query: ?status=active&page=1&per_page=20

Response:
{
  "tasks": [...],
  "total": 25
}
```

### Get Task
```
GET /tasks/{id}
```

### Cancel Task
```
POST /tasks/{id}/cancel
```

### Delete Task
```
DELETE /tasks/{id}
```

### Retry Task
```
POST /tasks/{id}/retry
```

## Settings

### Get All Settings
```
GET /settings
```

### Update Setting
```
PATCH /settings

{
  "temperature": 0.8,
  "model": "gpt-4",
  "memory_limit": 2000,
  "auto_prune": true
}
```

### Save All Settings
```
POST /settings/save
```

## Permissions

### List Pending Permissions
```
GET /permissions/pending
```

### List Permission History
```
GET /permissions/history
Query: ?page=1&per_page=50
```

### Approve Permission
```
POST /permissions/{id}/approve

{
  "once": true
}
```

### Deny Permission
```
POST /permissions/{id}/deny
```

## Plugins

### List Installed Plugins
```
GET /plugins

Response:
{
  "plugins": [
    {
      "id": "plugin_uuid",
      "name": "Code Assistant",
      "version": "1.2.0",
      "description": "Provides code analysis and generation",
      "enabled": true,
      "author": "Nexora",
      "capabilities": ["code_analysis", "code_generation"],
      "permissions": ["files:read", "files:write"],
      "hooks": ["on_message", "on_command"]
    }
  ]
}
```

### Install Plugin
```
POST /plugins/install
Content-Type: multipart/form-data

file: plugin.whl (or .zip)

Response:
{
  "id": "plugin_uuid",
  "name": "...",
  "version": "..."
}
```

### Toggle Plugin
```
POST /plugins/{id}/toggle

{
  "enabled": true
}
```

### Uninstall Plugin
```
DELETE /plugins/{id}
```

### Refresh Plugins
```
POST /plugins/refresh
```

## Health

### Get Health Status
```
GET /health

Response:
{
  "status": "connected",
  "model_status": "loaded",
  "memory_usage": "45%",
  "memory_percent": 0.45,
  "active_tasks": 2,
  "uptime": "12h 34m"
}
```

## WebSocket Events

### Chat Streaming
```json
// Server -> Client: Token
{
  "type": "token",
  "conversation_id": "uuid",
  "content": "partial token text"
}

// Server -> Client: Tool Call
{
  "type": "tool_call",
  "conversation_id": "uuid",
  "tool": {
    "name": "search_web",
    "arguments": {"query": "latest AI news"}
  }
}

// Server -> Client: Permission Request
{
  "type": "permission_request",
  "id": "req_uuid",
  "action": "files:read",
  "description": "AI wants to read your Documents folder",
  "source": "Code Assistant plugin"
}

// Server -> Client: Done
{
  "type": "done",
  "conversation_id": "uuid"
}

// Server -> Client: Error
{
  "type": "error",
  "conversation_id": "uuid",
  "message": "Error description"
}
```

## Error Codes

| Code | Description |
|------|-------------|
| 400  | Bad Request - Invalid parameters |
| 401  | Unauthorized - Authentication required |
| 403  | Forbidden - Permission denied |
| 404  | Not Found - Resource does not exist |
| 409  | Conflict - Resource state conflict |
| 429  | Too Many Requests - Rate limit exceeded |
| 500  | Internal Server Error |
| 503  | Service Unavailable - Backend not ready |
