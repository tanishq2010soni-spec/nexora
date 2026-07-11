# Nexora AI Architecture

## Clean Architecture Layers

Nexora AI follows **Clean Architecture** principles, dividing the system into four concentric layers:

```
+-------------------------------------------------------------+
|                    PRESENTATION LAYER                        |
|  (CLI, API, GUI adapters - none bundled by default)         |
+-------------------------------------------------------------+
                            |
                            v
+-------------------------------------------------------------+
|                   APPLICATION LAYER                          |
|  Use Cases: ConversationUseCases, PlanningService           |
|  Services: ToolRegistry, AutomationEngine, PluginLoader,    |
|            RetryService                                     |
|  Orchestration, DTO mapping, no business rules              |
+-------------------------------------------------------------+
                            |
                            v
+-------------------------------------------------------------+
|                      DOMAIN LAYER                            |
|  Entities: Conversation, Message, Thread, MemoryEntry,      |
|            Task, ToolDefinition, StreamingChunk              |
|  Enums: All type definitions across modules                  |
|  Interfaces: ProviderInterface (contracts)                   |
|  Events: Domain events                                       |
|  Exceptions: Domain exceptions                               |
|  Pure business logic, no external dependencies               |
+-------------------------------------------------------------+
                            |
                            v
+-------------------------------------------------------------+
|                   INFRASTRUCTURE LAYER                       |
|  Providers: OpenAI, Anthropic, GLM, Gemini, Groq, etc.      |
|  Memory: SQLiteBackend, VectorBackend, InMemoryBackend      |
|  Config: YAML, ENV, CLI, Encrypted                           |
|  Logging: JSON logger with spans & metrics                   |
|  Event Bus: Async pub/sub with priority, DLQ, retry          |
|  Tools: Registry, execution, sandboxing                      |
|  Security: Permission manager, audit, constraints            |
|  Automation: Workflow engine, scheduling                     |
|  Runtime: Agent lifecycle, hot-reload, health                |
|  Plugin SDK: Manifest, hooks, lifecycle                      |
|  Screen: Capture, OCR, clipboard, automation                 |
|  Implements domain interfaces, IO, external APIs             |
+-------------------------------------------------------------+
```

### Dependency Rule

Dependencies always point **inward**:

- **Presentation** → **Application** → **Domain** ← **Infrastructure**
- The Domain layer has **no dependencies** on any other layer.
- The Application layer depends only on Domain.
- The Infrastructure layer depends on Domain and may depend on Application interfaces.

## Module Dependency Graph

```
                     nexora_ai
                        |
         +--------------+--------------+
         |              |              |
     domain       application     infrastructure
         |              |              |
    +----+----+    +----+----+    +----+----+
    |    |    |    |    |    |    |    |    |
entities enums interfaces use_cases services providers memory
    |    |         |         |        |       |
events exceptions  |         |        event_bus
                   |         |        logging
                   |         |        config
                   |         |        tools
                   |         |        security
                   |         |        automation
                   |         |        runtime
                   |         |        plugin_sdk
                   |         |        screen
```

## DI Container Pattern

The framework uses a **manual DI container** that supports three scopes:

| Scope      | Behavior                                        |
|------------|-------------------------------------------------|
| Singleton  | One instance per container lifetime              |
| Transient  | New instance on every resolution                 |
| Scoped     | One instance per named scope (e.g., per request) |

Dependencies are registered by name and resolved at runtime. No decorators or auto-wiring — explicit and testable.

```
container.register("provider", OpenAIProviderAdapter, scope=Scope.SINGLETON, config={...})
container.register("memory", SQLiteMemoryBackend, scope=Scope.SINGLETON, config={...})
container.register("conversation", ConversationUseCases, scope=Scope.TRANSIENT)

provider = container.resolve("provider")
```

## Async Architecture

- **Async end-to-end**: All I/O is async (HTTP calls, database, streaming).
- **`asyncio`** is the concurrency model.
- Providers return `AsyncIterator[StreamingChunk]` for streaming responses.
- Event bus dispatches handlers concurrently.
- Workflow engine runs steps with `asyncio.gather` for parallel execution.

## Configuration Layering

```
1. Built-in defaults
2. YAML config file  →  ConfigManager.load_file()
3. Environment vars  →  ConfigManager.load_env()
4. CLI arguments     →  ConfigManager.load_cli()
5. Runtime overrides →  ConfigManager.set()
```

Each layer overrides the previous one. Sensitive values can be encrypted with `cryptography`.

## Security Model

```
PermissionManager
    │
    ├── Rules (resource_type, resource_id, effect, actions, constraints)
    ├── Default effect: DENY
    ├── Audit log for all AUDIT_ONLY rules
    └── Constraint evaluation (role-based, attribute-based)

Sandbox levels: NONE, RESTRICTED, ISOLATED
```

- **Allow rules** grant access to specific resources.
- **Deny rules** block access (evaluated first).
- **Audit-only rules** allow but log every access.
- **Constraints** enable fine-grained control (e.g., `role == "admin"`, `rate < 100`).
