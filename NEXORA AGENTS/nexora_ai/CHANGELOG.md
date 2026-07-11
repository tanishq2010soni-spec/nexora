# Changelog

## v0.1.0 (2026-06-30)

### Initial Release

**Core Framework**
- Domain entities, enums, and interfaces for provider, memory, conversation, planning, tools, automation, events, plugins, security, and logging
- Provider interface with chat(), complete(), embed(), generate_tool_call()
- Base provider adapter with rate limiting, retry, HTTP client management

**LLM Provider Adapters**
- OpenAI, Anthropic, Google Gemini, GLM (Zhipu AI), DeepSeek, Groq, Mistral AI, Ollama, LM Studio, OpenRouter
- Mock provider adapter for testing

**Infrastructure**
- Async event bus with priority ordering, subscription filtering, dead letter queue
- Memory system with in-memory backend (SQLite and vector backends stubbed)
- Layered configuration (YAML, env, CLI) with encryption support
- Structured JSON logging with correlation IDs, trace spans, performance metrics
- Permission manager with allow/deny/audit-only rules and constraint evaluation
- Tool registry with validation, timeout, category listing
- Automation workflow engine with step dependencies, conditions, retry, scheduling
- AI runtime with lifecycle management, hot-reload, health reporting
- Plugin SDK with manifest loading, dependency resolution, hook system
- Desktop automation primitives (screen capture, OCR, clipboard, input automation)
- DI container with singleton, transient, and scoped resolution

**Application Layer**
- Conversation use cases (create, send, stream, history, trimming, memory injection)
- Planning service (goal decomposition, dependency resolution, cycle detection, execution)

**Testing**
- 14 unit test suites covering all modules
- 3 integration test suites (memory, runtime, event bus)
- Contract tests for provider interface compliance
- Mock implementations for all major components

**Documentation**
- Architecture document (ARCHITECTURE.md)
- Development roadmap (ROADMAP.md)
- Module reference (MODULES.md)
- API reference (API_REFERENCE.md)
- Plugin development guide (PLUGIN_GUIDE.md)
- Memory system guide (MEMORY_GUIDE.md)
- Tool development guide (TOOL_GUIDE.md)
- Testing guide (TESTING_GUIDE.md)
- Contributing guide (CONTRIBUTING.md)
