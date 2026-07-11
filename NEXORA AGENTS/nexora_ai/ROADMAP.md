# Nexora AI Roadmap

## Phase A: Core Framework (Current — v0.1.0)

- [x] Domain entities and enums
- [x] Provider interface and base adapter
- [x] LLM provider adapters (OpenAI, Anthropic, GLM, Gemini, DeepSeek, Groq, Mistral, Ollama, LM Studio, OpenRouter)
- [x] Provider routing, rate limiting, health monitoring
- [x] Async event bus with priority, DLQ, retry
- [x] Memory system (in-memory, SQLite, vector)
- [x] Layered configuration (YAML, env, CLI, encryption)
- [x] Structured JSON logging with spans and metrics
- [x] Permission manager and audit logging
- [x] Tool registry with validation, timeout, categories
- [x] Automation workflow engine with scheduling
- [x] AI runtime with lifecycle, hot-reload, health
- [x] Plugin SDK with manifest, hooks, lifecycle
- [x] Screen/desktop automation (OCR, capture, clipboard)
- [x] DI container (singleton, transient, scoped)
- [x] Conversation use cases
- [x] Planning service with dependency resolution
- [x] Retry service with exponential backoff
- [x] Comprehensive test suite (unit, integration, contract)
- [x] Documentation (architecture, modules, API, guides)

## Phase B: Agent Implementation (Next)

- [ ] Agent factory and configuration DSL
- [ ] Tool-use agents (ReAct, function calling)
- [ ] Multi-agent orchestration
- [ ] Memory-augmented agents (RAG, summarization)
- [ ] Human-in-the-loop approval flows
- [ ] Agent monitoring and tracing
- [ ] Session management and persistence
- [ ] Built-in system tools (file I/O, web search, code execution)
- [ ] Example agents (chat, research, automation)

## Phase C: Production Hardening

- [ ] OpenTelemetry integration
- [ ] Structured error taxonomy and recovery
- [ ] Circuit breaker pattern for providers
- [ ] Advanced caching (response, embedding)
- [ ] Rate limiting with token bucket algorithm
- [ ] Request deduplication and idempotency
- [ ] Graceful degradation and fallback chains
- [ ] Load shedding and back-pressure
- [ ] Comprehensive audit trails
- [ ] Performance benchmarks and regression suite
- [ ] Security hardening (input sanitization, prompt injection defense)
- [ ] Multi-tenant isolation

## Phase D: Ecosystem

- [ ] CLI tool (`nexora` command)
- [ ] FastAPI integration (REST API server)
- [ ] WebSocket support for real-time streaming
- [ ] Admin dashboard (web UI)
- [ ] Plugin registry and marketplace
- [ ] LangChain/LlamaIndex integration bridges
- [ ] Kubernetes operator for agent deployment
- [ ] Helm charts and Docker images
- [ ] Terraform provider for infrastructure management
- [ ] Documentation site and interactive playground
- [ ] Community contribution templates and guides
