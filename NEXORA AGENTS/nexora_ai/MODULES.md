# Nexora AI Modules

## 1. Domain — Core Business Logic

**Location:** `nexora_ai/domain/`

### Entities
| Class | Description |
|-------|-------------|
| `Conversation`, `Message`, `Thread`, `StreamingChunk` | Conversation management |
| `MemoryEntry`, `MemorySearchQuery`, `MemorySearchResult`, `MemorySummary` | Memory system |
| `Task`, `ExecutionGraph`, `Plan`, `PlanResult`, `PlanError` | Planning system |
| `ToolDefinition`, `ToolParameter`, `ToolContext`, `ToolResult`, `ToolHealth` | Tool system |

### Enums
| File | Enums |
|------|-------|
| `provider_enums.py` | `ProviderType`, `ModelCapability`, `RoutingStrategy`, `ProviderStatus` |
| `memory_enums.py` | `MemoryType`, `MemoryBackendType`, `MemoryImportance`, `MemoryOperation` |
| `conversation_enums.py` | `MessageRole`, `MessageType`, `ConversationStatus`, `ContextStrategy`, `StreamingState` |
| `planner_enums.py` | `TaskStatus`, `TaskPriority`, `DependencyType`, `ExecutionStrategy`, `RollbackStrategy` |
| `tool_enums.py` | `ToolCategory`, `ToolExecutionMode`, `ToolPermission`, `ToolStatus` |
| `automation_enums.py` | `WorkflowStatus`, `ActionType`, `ScheduleType`, `ConditionOperator` |
| `event_enums.py` | `EventPriority`, `EventStatus`, `EventType` |
| `plugin_enums.py` | `PluginStatus`, `PluginPermissionScope`, `HotReloadStrategy` |
| `security_enums.py` | `PermissionEffect`, `ResourceType`, `AuditAction`, `SandboxLevel` |
| `logging_enums.py` | `LogLevel`, `LogCategory`, `LogFormat`, `OutputDestination` |

### Interfaces
| Interface | Methods |
|-----------|---------|
| `ProviderInterface` | `chat()`, `complete()`, `embed()`, `generate_tool_call()` |

**Dependencies:** None

---

## 2. Application — Use Cases & Services

**Location:** `nexora_ai/application/`

### Use Cases
- `ConversationUseCases` — `create_conversation()`, `send_message()`, `send_message_streaming()`, `get_history()`, `context_trimming()`, `memory_injection()`
- `PlanningService` — `decompose_goal()`, `resolve_dependencies()`, `detect_cycle()`, `execute_graph_sequential()`, `execute_graph_parallel()`, `rollback_on_failure()`

### Services
- `ToolRegistry` — `register()`, `execute()`, `list_by_category()`
- `AutomationEngine` — `create_workflow()`, `execute_workflow()`, `cancel_execution()`, `schedule_cron()`
- `PluginLoader` — `load_manifest()`, `unload()`, `list_installed()`, `enable()`, `disable()`
- `RetryService` — `execute()`

**Dependencies:** `domain`

---

## 3. Infrastructure — Provider Adapters

**Location:** `nexora_ai/infrastructure/providers/`

| Adapter | Provider | Dependencies |
|---------|----------|-------------|
| `BaseProviderAdapter` | Base class with rate limiting, retry, HTTP client | `httpx` |
| `OpenAIProviderAdapter` | OpenAI API | `openai` |
| `AnthropicProviderAdapter` | Anthropic Claude | `anthropic` |
| `GLMProviderAdapter` | GLM (Zhipu AI) | `httpx` |
| `GeminiProviderAdapter` | Google Gemini | `google-generativeai` |
| `DeepSeekProviderAdapter` | DeepSeek | `httpx` |
| `GroqProviderAdapter` | Groq | `groq` |
| `MistralProviderAdapter` | Mistral AI | `mistralai` |
| `OllamaProviderAdapter` | Local Ollama | `httpx` |
| `LMStudioProviderAdapter` | Local LM Studio | `httpx` |
| `OpenRouterProviderAdapter` | OpenRouter | `httpx` |
| `MockProviderAdapter` | Testing | None |

**Dependencies:** `domain`, `httpx`

---

## 4. Infrastructure — Memory

**Location:** `nexora_ai/infrastructure/memory/`

| Backend | Description |
|---------|-------------|
| `InMemoryMemoryBackend` | Dict-based, for testing |
| `SQLiteMemoryBackend` | Persistent SQLite via `aiosqlite` |
| `VectorMemoryBackend` | Vector search via `qdrant-client` or `chromadb` |

**Dependencies:** `domain`, `aiosqlite`, optional: `qdrant-client`, `chromadb`

---

## 5. Infrastructure — Event Bus

**Location:** `nexora_ai/infrastructure/event_bus/`

| Class | Description |
|-------|-------------|
| `AsyncEventBus` | Async pub/sub with priority ordering, subscription filtering, dead letter queue, retry |

**Dependencies:** `domain`

---

## 6. Infrastructure — Config

**Location:** `nexora_ai/infrastructure/config/`

| Class | Description |
|-------|-------------|
| `ConfigManager` | Layered config from YAML, env, CLI; encrypted values; validation |

**Dependencies:** `pyyaml`, `cryptography`

---

## 7. Infrastructure — Logging

**Location:** `nexora_ai/infrastructure/logging/`

| Class | Description |
|-------|-------------|
| `JsonLogger` | Structured JSON logging with levels, correlation IDs, trace spans, performance metrics |

**Dependencies:** None

---

## 8. Infrastructure — Tools

**Location:** `nexora_ai/infrastructure/tools/`

| Class | Description |
|-------|-------------|
| `ToolRegistry` | Register, validate, execute tools with timeout and sandboxing |

**Dependencies:** `domain`

---

## 9. Infrastructure — Security

**Location:** `nexora_ai/infrastructure/security/`

| Class | Description |
|-------|-------------|
| `PermissionManager` | Rule-based permission engine with allow/deny/audit-only, constraint evaluation, audit log |

**Dependencies:** `domain`

---

## 10. Infrastructure — Automation

**Location:** `nexora_ai/infrastructure/automation/`

| Class | Description |
|-------|-------------|
| `AutomationEngine` | Workflow creation, execution, step dependencies, conditions, retry, cancellation, cron scheduling |

**Dependencies:** `domain`

---

## 11. Infrastructure — Runtime

**Location:** `nexora_ai/infrastructure/runtime/`

| Class | Description |
|-------|-------------|
| `AIRuntime` | Agent lifecycle (start, shutdown, hot-reload), task execution, cancellation, health reporting |

**Dependencies:** `domain`

---

## 12. Infrastructure — Plugin SDK

**Location:** `nexora_ai/infrastructure/plugin_sdk/`

| Class | Description |
|-------|-------------|
| `PluginLoader` | Manifest loading, dependency resolution, enable/disable, hook registration |
| `PluginManifest` | Plugin metadata, permissions, entry point |

**Dependencies:** `domain`

---

## 13. Infrastructure — Screen

**Location:** `nexora_ai/infrastructure/screen/`

| Module | Description |
|--------|-------------|
| Screen capture, OCR (`pytesseract`), clipboard (`pyperclip`), mouse/keyboard automation (`pyautogui`), email (`aiosmtplib`) |

**Dependencies:** Optional: `pillow`, `pytesseract`, `pyautogui`, `pyperclip`, `aiosmtplib`

---

## 14. DI Container

**Location:** `nexora_ai/infrastructure/di/`

| Class | Description |
|-------|-------------|
| `DIContainer` | Manual DI with singleton, transient, and scoped resolution |

**Dependencies:** None
