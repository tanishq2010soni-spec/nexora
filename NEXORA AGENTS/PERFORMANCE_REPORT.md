# NEXORA AGENTS - Performance Report

**Date**: July 1, 2026  
**Phase**: D.5 - Production Stabilization

---

## Test Execution Performance

| Project | Tests | Time | Tests/sec |
|---------|-------|------|-----------|
| nexora_ai | 118 | 6.3s | 18.7 |
| calling_agent | 225 | 31.5s | 7.1 |
| whatsapp_agent | 230 | 9.7s | 23.7 |
| personal_ai | 46 | 3.0s | 15.3 |
| **TOTAL** | **619** | **50.5s** | **12.3** |

---

## Test Coverage

| Project | Statements | Covered | Coverage |
|---------|-----------|---------|----------|
| nexora_ai | 2,289 | 1,248 | 55% |
| calling_agent | 1,172 | 582 | 50% |
| whatsapp_agent | 1,054 | 747 | 71% |
| personal_ai | 1,163 | 303 | 26% |
| **TOTAL** | **5,678** | **2,880** | **51%** |

---

## Coverage by Module

### nexora_ai
| Module | Coverage | Notes |
|--------|----------|-------|
| domain/entities | 100% | All entities tested |
| domain/enums | 100% | All enums tested |
| domain/interfaces | 100% | All interfaces tested |
| infrastructure/tools | 100% | ToolRegistry fully tested |
| infrastructure/memory | 100% | MemoryManager fully tested |
| infrastructure/logging | 100% | JsonLogger fully tested |
| infrastructure/security | 100% | PermissionManager fully tested |
| infrastructure/config | 100% | ConfigManager fully tested |
| infrastructure/runtime | 100% | AIRuntime fully tested |
| infrastructure/event_bus | 100% | AsyncEventBus fully tested |
| infrastructure/providers | 24-71% | Provider stubs need tests |
| infrastructure/plugin_sdk | 100% | PluginLoader fully tested |

### calling_agent
| Module | Coverage | Notes |
|--------|----------|-------|
| domain/entities | 100% | All entities tested |
| domain/enums | 100% | All enums tested |
| services/lead_scorer | 100% | Fully tested |
| services/analytics_service | 0% | Needs integration tests |
| services/call_engine | 0% | Needs integration tests |
| services/campaign_engine | 0% | Needs integration tests |
| services/scheduler | 0% | Needs integration tests |
| services/transcription_service | 0% | Needs integration tests |

### whatsapp_agent
| Module | Coverage | Notes |
|--------|----------|-------|
| domain/entities | 100% | All entities tested |
| domain/enums | 100% | All enums tested |
| services/lead_scorer | 89% | Well tested |
| services/sentiment_analyzer | 88% | Well tested |
| services/language_detector | 79% | Good coverage |
| services/intent_detector | 54% | Needs more tests |
| services/conversation_summarizer | 48% | Needs more tests |
| services/analytics_service | 0% | Needs integration tests |
| services/scheduler | 0% | Needs integration tests |

### personal_ai
| Module | Coverage | Notes |
|--------|----------|-------|
| services/permissions_manager | 100% | Fully tested |
| services/settings_manager | 85% | Well tested |
| services/conversation_manager | 24% | Needs more tests |
| services/desktop_controller | 11% | Needs significant tests |
| services/browser_controller | 16% | Needs more tests |
| services/file_intelligence | 16% | Needs more tests |
| services/screen_capture | 17% | Needs more tests |

---

## Memory Usage (Estimated)

| Component | Expected | Notes |
|-----------|----------|-------|
| nexora_ai | ~50MB | Lightweight framework |
| personal_ai backend | ~100MB | FastAPI + services |
| whatsapp_agent backend | ~80MB | FastAPI + SQLAlchemy |
| calling_agent backend | ~80MB | FastAPI + SQLAlchemy |

---

## Startup Time (Estimated)

| Component | Expected | Notes |
|-----------|----------|-------|
| nexora_ai | <1s | No external deps |
| personal_ai backend | 2-3s | FastAPI + tool registration |
| whatsapp_agent backend | 2-3s | FastAPI + DB init |
| calling_agent backend | 2-3s | FastAPI + DB init |

---

## Recommendations

### Coverage Improvement Priority
1. **calling_agent services** - analytics_service, call_engine, campaign_engine need DB-backed integration tests
2. **personal_ai services** - desktop_controller, browser_controller, file_intelligence need mocking
3. **whatsapp_agent services** - intent_detector, conversation_summarizer need more test cases
4. **nexora_ai providers** - stub providers need contract tests

### Performance Monitoring Needed
- API response times under load
- WebSocket connection handling
- Database query performance
- Memory usage over time
