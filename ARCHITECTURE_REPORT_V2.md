# ARCHITECTURE_REPORT_V2.md

**Project:** Nexora Control Center
**Date:** 2026-06-19 (Architecture Improvement Phase)
**Status:** Pre-Implementation (Awaiting Approval)
**Version:** 3.0

---

## 1. Project Overview

Nexora Control Center is a Flutter desktop-first application serving as the central operating system for the Nexora Brain AI platform.

**Backend:** Nexora Brain FastAPI at http://localhost:8000/api/v1/
**Architecture:** Clean Architecture (4 layers)
**Primary Platform:** Desktop (Windows, macOS, Linux)
**Companion Platform:** Mobile (Android, iOS)

---

## 2. Complete Folder Structure

`
control_center/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   │
│   ├── core/
│   │   ├── auth/
│   │   │   ├── auth_guard.dart
│   │   │   ├── session_manager.dart
│   │   │   ├── session_state.dart
│   │   │   └── token_manager.dart
│   │   ├── constants/
│   │   │   ├── api_constants.dart
│   │   │   ├── app_constants.dart
│   │   │   └── storage_constants.dart
│   │   ├── env/
│   │   │   ├── env.dart
│   │   │   └── env.g.dart
│   │   ├── errors/
│   │   │   ├── app_exception.dart
│   │   │   └── error_handler.dart
│   │   ├── extensions/
│   │   │   ├── context_extensions.dart
│   │   │   ├── datetime_extensions.dart
│   │   │   └── result_extensions.dart
│   │   ├── logging/
│   │   │   └── app_logger.dart
│   │   ├── network/
│   │   │   ├── api_client.dart
│   │   │   ├── api_interceptor.dart
│   │   │   ├── api_response.dart
│   │   │   ├── api_result.dart
│   │   │   ├── auth_interceptor.dart
│   │   │   ├── connectivity_service.dart
│   │   │   └── retry_interceptor.dart
│   │   ├── router/
│   │   │   ├── app_router.dart
│   │   │   └── route_names.dart
│   │   ├── storage/
│   │   │   └── secure_storage_service.dart
│   │   ├── theme/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_shadows.dart
│   │   │   ├── app_spacing.dart
│   │   │   ├── app_theme.dart
│   │   │   └── app_typography.dart
│   │   └── widgets/
│   │       ├── app_button.dart
│   │       ├── app_loader.dart
│   │       ├── app_text_field.dart
│   │       ├── confirm_dialog.dart
│   │       ├── data_table_widget.dart
│   │       ├── empty_state.dart
│   │       ├── error_view.dart
│   │       ├── result_builder.dart
│   │       ├── search/
│   │       │   ├── command_palette.dart
│   │       │   ├── global_search_delegate.dart
│   │       │   └── search_index.dart
│   │       ├── sidebar/
│   │       │   ├── app_sidebar.dart
│   │       │   └── sidebar_item.dart
│   │       ├── stat_card.dart
│   │       └── topbar/
│   │           ├── app_topbar.dart
│   │           ├── notification_bell.dart
│   │           └── user_avatar.dart
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── datasources/auth_remote_datasource.dart
│   │   │   │   └── repositories/auth_repository.dart
│   │   │   ├── domain/
│   │   │   │   ├── models/auth_models.dart
│   │   │   │   └── repositories/auth_repository_interface.dart
│   │   │   ├── providers/auth_provider.dart
│   │   │   └── presentation/
│   │   │       ├── screens/login_screen.dart
│   │   │       └── widgets/ (login_form, login_header)
│   │   │
│   │   ├── dashboard/
│   │   │   ├── data/ (datasources, repositories)
│   │   │   ├── domain/ (models)
│   │   │   ├── providers/
│   │   │   └── presentation/ (screens, widgets)
│   │   │
│   │   ├── agent_center/
│   │   │   ├── whatsapp_agents/
│   │   │   │   ├── data/ (datasources, repositories)
│   │   │   │   ├── domain/ (models: whatsapp_agent, whatsapp_config)
│   │   │   │   ├── providers/
│   │   │   │   └── presentation/ (screens, widgets)
│   │   │   ├── calling_agents/
│   │   │   │   ├── data/ (datasources, repositories)
│   │   │   │   ├── domain/ (models: calling_agent, voice_config)
│   │   │   │   ├── providers/
│   │   │   │   └── presentation/ (screens, widgets)
│   │   │   ├── agent_templates/
│   │   │   │   ├── data/ (datasources, repositories)
│   │   │   │   ├── domain/ (models: agent_template)
│   │   │   │   ├── providers/
│   │   │   │   └── presentation/ (screens)
│   │   │   ├── agent_analytics/
│   │   │   │   ├── data/ (datasources, repositories)
│   │   │   │   ├── domain/ (models: agent_analytics)
│   │   │   │   ├── providers/
│   │   │   │   └── presentation/ (screens)
│   │   │   └── shared/
│   │   │       └── models/ (agent, agent_config, agent_status)
│   │   │
│   │   ├── ai_models/
│   │   │   ├── data/ (datasources, repositories)
│   │   │   ├── domain/
│   │   │   │   ├── models/
│   │   │   │   │   ├── ai_model.dart
│   │   │   │   │   ├── model_config.dart
│   │   │   │   │   ├── model_health.dart
│   │   │   │   │   ├── model_provider.dart
│   │   │   │   │   ├── model_routing_rule.dart
│   │   │   │   │   └── token_usage.dart
│   │   │   │   └── repositories/
│   │   │   ├── providers/ (model_list, model_health, model_routing)
│   │   │   └── presentation/ (screens, widgets)
│   │   │
│   │   ├── workspaces/
│   │   │   ├── data/ (datasources, repositories)
│   │   │   ├── domain/ (models: workspace, workspace_context)
│   │   │   ├── providers/ (workspace_list, active_workspace)
│   │   │   └── presentation/ (widgets: switcher, badge)
│   │   │
│   │   ├── search/
│   │   │   ├── data/ (datasources, repositories)
│   │   │   ├── domain/
│   │   │   │   ├── models/ (search_entry, search_result, search_filter)
│   │   │   │   └── repositories/
│   │   │   ├── providers/ (search, search_index)
│   │   │   └── presentation/ (widgets: command_palette)
│   │   │
│   │   ├── knowledge_base/
│   │   ├── leads/
│   │   ├── customers/
│   │   ├── conversations/
│   │   ├── analytics/
│   │   ├── audit_logs/
│   │   │
│   │   ├── system_monitoring/
│   │   │   ├── data/ (datasources, repositories)
│   │   │   ├── domain/
│   │   │   │   ├── models/
│   │   │   │   │   ├── system_health.dart
│   │   │   │   │   ├── service_status.dart
│   │   │   │   │   ├── health_metric.dart
│   │   │   │   │   ├── alert_rule.dart
│   │   │   │   │   ├── resource_metric.dart
│   │   │   │   │   └── api_latency_metric.dart
│   │   │   │   └── repositories/
│   │   │   ├── providers/ (health, metrics, resource, alerts)
│   │   │   └── presentation/
│   │   │       ├── screens/ (system_health_screen)
│   │   │       └── widgets/ (alert_banner, health_timeline, resource_gauge, service_health_card)
│   │   │
│   │   ├── notifications/
│   │   │   ├── data/ (datasources, repositories)
│   │   │   ├── domain/ (models: app_notification, notification_preferences)
│   │   │   ├── providers/ (notifications, notification_badge)
│   │   │   └── presentation/ (screens, widgets)
│   │   │
│   │   ├── billing/
│   │   │   ├── data/ (datasources, repositories)
│   │   │   ├── domain/ (models)
│   │   │   ├── providers/
│   │   │   └── presentation/ (screens, widgets)
│   │   │
│   │   └── settings/
│   │       ├── data/ (datasources, repositories)
│   │       ├── domain/ (models)
│   │       ├── providers/
│   │       └── presentation/ (screens, widgets)
│   │
│   └── shared/
│       └── layouts/
│           ├── app_shell.dart
│           ├── desktop_shell.dart
│           └── responsive_layout.dart
│
├── test/ (unit/, widget/, integration/)
├── analysis_options.yaml
├── pubspec.yaml
└── README.md
`

---

## 3. Dependency Flow (Clean Architecture)

`
presentation/  →  domain/  →  data/  →  core/
`

### Layer Rules (Enforced)

1. presentation/ imports domain/ + core/widgets/ + core/theme/
2. domain/ imports nothing (pure Dart)
3. data/ imports domain/ + core/network/
4. core/ imports nothing from eatures/
5. Feature modules never import each other
6. core/auth/ is consumed by core/router/ and core/network/
7. core/widgets/ is consumed by presentation/ only

---

## 4. Agent Center Architecture (Restructured)

### Module Hierarchy

`
agent_center/
├── whatsapp_agents/      # WhatsApp-specific agent management
├── calling_agents/       # Voice/Calling-specific agent management
├── agent_templates/      # Reusable agent configurations
├── agent_analytics/      # Performance metrics per agent
└── shared/               # Common agent models, enums, utils
`

### Rationale

- WhatsApp and Calling agents have different configuration schemas
- Future: WhatsApp agents may need webhook management, message templates
- Future: Calling agents may need voice selection, recording management
- Templates reduce duplication when creating multiple similar agents
- Analytics grow independently (conversation volume, response time, lead conversion)

### Shared Agent Models

`dart
@freezed
class Agent with _ {
  const factory Agent({
    required String id,
    required String orgId,
    required String name,
    required AgentPlatform platform,
    required String systemPrompt,
    @Default('llama3') String llmModel,
    @Default(0.7) double temperature,
    required AgentStatus status,
    List<String>? knowledgeBaseIds,
    DateTime? lastActiveAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Agent;
}

enum AgentPlatform { whatsapp, calling, web }
enum AgentStatus { active, idle, error, disabled }
`

### WhatsApp Config

`dart
@freezed
class WhatsAppConfig with _ {
  const factory WhatsAppConfig({
    String? phoneNumberId,
    String? businessAccountId,
    String? accessToken,
    @Default(true) bool autoReply,
    @Default(true) bool leadExtraction,
    Map<String, String>? quickReplies,
  }) = _WhatsAppConfig;
}
`

### Voice Config

`dart
@freezed
class VoiceConfig with _ {
  const factory VoiceConfig({
    @Default('alloy') String voiceId,
    String? twilioAccountSid,
    String? twilioAuthToken,
    String? phoneNumber,
    @Default(16000) int sampleRate,
    @Default(true) bool recordCalls,
  }) = _VoiceConfig;
}
`

### Agent Template

`dart
@freezed
class AgentTemplate with _ {
  const factory AgentTemplate({
    required String id,
    required String name,
    String? description,
    required AgentPlatform platform,
    required String systemPrompt,
    @Default('llama3') String llmModel,
    @Default(0.7) double temperature,
    Map<String, dynamic>? platformConfig,
    @Default(false) bool isSystemTemplate,
    required DateTime createdAt,
  }) = _AgentTemplate;
}
`

---

## 5. AI Models Module (Multi-Provider)

### Supported Providers

| Provider | Status | Models |
|----------|--------|--------|
| Ollama | Current | llama3, mistral, gemma, codellama |
| OpenAI | Future | gpt-4o, gpt-4-turbo, gpt-3.5-turbo |
| Claude | Future | claude-3.5-sonnet, claude-3-opus |
| Gemini | Future | gemini-1.5-pro, gemini-1.5-flash |
| Custom | Future | User-defined endpoints |

`dart
enum ModelProvider { ollama, openai, claude, gemini, custom }

@freezed
class AiModel with _ {
  const factory AiModel({
    required String id,
    required String name,
    required String displayName,
    required ModelProvider provider,
    String? description,
    String? size,
    required AiModelStatus status,
    DateTime? lastHealthCheck,
    Map<String, dynamic>? capabilities,
    Map<String, dynamic>? pricing,
    Map<String, dynamic>? metadata,
  }) = _AiModel;
}

enum AiModelStatus { available, loading, unavailable, error }
`

### Token Usage Tracking

`dart
@freezed
class TokenUsage with _ {
  const factory TokenUsage({
    required String modelId,
    required String orgId,
    required int promptTokens,
    required int completionTokens,
    required int totalTokens,
    required DateTime recordedAt,
  }) = _TokenUsage;
}
`

### Multi-Model Routing

`dart
@freezed
class ModelRoutingRule with _ {
  const factory ModelRoutingRule({
    required String id,
    required String name,
    required String sourceModel,
    required String targetModel,
    required RoutingCondition condition,
    @Default(true) bool enabled,
    String? description,
  }) = _ModelRoutingRule;
}

enum RoutingCondition {
  fallback,
  loadBalancing,
  costOptimization,
  capabilityMatch,
}
`

---

## 6. Workspace Support

`dart
@freezed
class Workspace with _ {
  const factory Workspace({
    required String id,
    required String orgId,
    required String name,
    String? description,
    required WorkspaceRole role,
    @Default(false) bool isDefault,
    @Default(0) int agentCount,
    @Default(0) int memberCount,
    DateTime? createdAt,
  }) = _Workspace;
}

enum WorkspaceRole { owner, admin, member }
`

### Data Isolation

Every API call includes workspace context. Switching workspaces invalidates all cached data providers and triggers full data reload.

---

## 7. Global Search

### Indexed Modules

| Module | Items | Title | Subtitle | Route |
|--------|-------|-------|----------|-------|
| Agents | All agents | name | platform | /agents/{id} |
| Leads | All leads | name | email | /leads/{id} |
| Customers | All customers | name | phone | /customers/{id} |
| Conversations | All sessions | external_user_id | agent_name | /conversations/{id} |
| Knowledge Base | All KBs | name | doc_count | /kb/{id} |
| Documents | All docs | filename | kb_name | /kb/{doc.kb_id} |
| Settings | All sections | label | description | /settings/{section} |

`dart
enum SearchModule { agent, lead, customer, conversation, knowledgeBase, document, setting }

@freezed
class SearchEntry with _ {
  const factory SearchEntry({
    required String id,
    required SearchModule module,
    required String title,
    String? subtitle,
    required String route,
    Map<String, dynamic>? metadata,
    @Default(0.0) double relevanceScore,
  }) = _SearchEntry;
}
`

---

## 8. System Monitoring (Full Observability)

### Monitored Resources

| Category | Metric | Source |
|----------|--------|--------|
| Compute | CPU Usage | /system endpoint |
| Compute | RAM Usage | /system endpoint |
| Storage | Disk Usage | /system endpoint |
| Services | PostgreSQL | /api/v1/health |
| Services | Ollama | /api/v1/monitoring/health/details |
| Services | Qdrant | /api/v1/monitoring/health/details |
| Services | Redis | Connection check |
| Services | Nexora Brain | /api/v1/health |
| Application | API Latency | Request timing |
| Application | Active Agents | Agent status poll |
| Application | Active Sessions | Session count |

`dart
@freezed
class ResourceMetric with _ {
  const factory ResourceMetric({
    required ResourceMetricType type,
    required double value,
    required double? warningThreshold,
    required double? criticalThreshold,
    required DateTime recordedAt,
  }) = _ResourceMetric;
}

enum ResourceMetricType { cpu, ram, disk }

@freezed
class ApiLatencyMetric with _ {
  const factory ApiLatencyMetric({
    required String endpoint,
    required String method,
    required Duration latency,
    required int statusCode,
    required DateTime recordedAt,
  }) = _ApiLatencyMetric;
}

enum AlertCondition {
  latencyGreaterThan,
  statusEquals,
  errorRateGreaterThan,
  cpuGreaterThan,
  ramGreaterThan,
  diskGreaterThan,
}
`

---

## 9. Session Management (core/auth/)

### File Structure

`
core/auth/
├── auth_guard.dart          # GoRouter redirect guard
├── session_manager.dart     # Session lifecycle provider
├── session_state.dart       # Session state model (Freezed)
└── token_manager.dart       # JWT + refresh token operations
`

### Session State

`dart
@freezed
class SessionState with _ {
  const SessionState._();

  const factory SessionState({
    required SessionStatus status,
    String? accessToken,
    String? refreshToken,
    DateTime? tokenExpiry,
    String? userId,
    String? email,
    String? orgId,
    String? role,
  }) = _SessionState;

  bool get isAuthenticated => status == SessionStatus.authenticated;
  bool get isExpired => tokenExpiry?.isBefore(DateTime.now()) ?? true;
  bool get needsRefresh =>
      tokenExpiry?.difference(DateTime.now()).inSeconds < 30;
}

enum SessionStatus { initial, authenticated, refreshing, unauthenticated, expired }
`

### Token Manager

`dart
class TokenManager {
  Future<void> saveTokens(String accessToken, String refreshToken) async { ... }
  Future<String?> getAccessToken() async { ... }
  Future<String?> getRefreshToken() async { ... }
  Future<void> clearTokens() async { ... }
  Future<bool> refreshTokens() async { ... }
  bool isTokenExpired(String token) { ... }
  Map<String, dynamic>? decodeToken(String token) { ... }
}
`

### Session Manager

- Queues concurrent refresh attempts via Completer
- Forced logout on 401 from interceptor
- Timer-based refresh (30s before expiry)
- App lifecycle hooks (resume/pause)

---

## 10. API Result Pattern

### Core Types

`dart
sealed class ApiResult<T> {
  const ApiResult();
  R when<R>({required R Function(T) success, required R Function(AppException) error, R Function()? loading});
}

class ApiSuccess<T> extends ApiResult<T> { final T data; ... }
class ApiError<T> extends ApiResult<T> { final AppException exception; ... }
class ApiLoading<T> extends ApiResult<T> { ... }
`

### Exception Hierarchy

`dart
sealed class AppException implements Exception { ... }
class NetworkException extends AppException { ... }
class AuthException extends AppException { ... }
class ValidationException extends AppException { final Map<String, String> fieldErrors; ... }
class ServerException extends AppException { ... }
class TimeoutException extends AppException { ... }
class RateLimitException extends AppException { ... }
class UnknownException extends AppException { ... }
`

### Repository Contract

All repositories MUST return ApiResult<T>. No exceptions in business flow.

---

## 11. Desktop Power-User Features

### Command Palette

- Trigger: Cmd+K / Ctrl+K
- Content: Search + quick actions + navigation
- Actions: Create Agent, Upload Document, Go to Dashboard, Open Settings

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| Cmd/Ctrl + K | Command palette |
| Cmd/Ctrl + N | Create new |
| Cmd/Ctrl + S | Save form |
| Cmd/Ctrl + Shift + S | Save and close |
| Cmd/Ctrl + Z | Undo |
| Escape | Close / Cancel |
| Cmd/Ctrl + 1-9 | Jump to module |
| Cmd/Ctrl + , | Settings |
| Delete | Delete selected |
| Space | Multi-select toggle |

### Bulk Actions

- Multi-select with Space or checkbox
- Bulk delete, bulk status change, bulk CSV export

### CSV Export

- Export any data table as CSV
- Respects filters, sort, and multi-select

### Resizable Panels

- Drag divider to resize
- Double-click to reset to 50/50
- Minimum width: 300px
- State persisted to secure storage

### Multi-Select Tables

- Checkbox column
- Shift+Click range select
- Ctrl+Click individual toggle
- Ctrl+A select all

### Multi-Window Support (Future)

- Detach panel into separate window
- Independent navigation per window
- Shared session state

---

## 12. State Management Strategy

### Provider Dependency Graph

`
TokenManager (Provider)
  ├── SessionManager (NotifierProvider)
  │     ├── AuthGuard (GoRouter redirect)
  │     └── AuthInterceptor (Dio)
  ├── WorkspaceListProvider (FutureProvider)
  │     └── ActiveWorkspaceProvider (NotifierProvider)
  │           └── All feature providers (invalidate on switch)
  └── Feature Providers
        ├── AgentListProvider -> AgentRepository -> AgentDatasource
        ├── LeadListProvider -> LeadRepository -> LeadDatasource
        └── ...
`

---

## 13. API Strategy

### Interceptor Chain

`
Request  -> AuthInterceptor (attach JWT)
         -> RetryInterceptor (3 retries, exponential backoff)
         -> ApiInterceptor (log, map errors)
         -> Server
Response <- ApiInterceptor (wrap in ApiResponse)
         <- AuthInterceptor (handle 401 -> refresh -> retry)
`

### API Endpoint Map

| Module | Base Path | Endpoints |
|--------|-----------|-----------|
| Auth | /api/v1/auth | POST /signup, /login, /refresh |
| Business | /api/v1/business | GET /, POST /, PUT /{id}, DELETE /{id} |
| Documents | /api/v1/documents | POST /upload, GET /, DELETE /{id} |
| Chat | /api/v1/chat | POST /sessions, /sessions/{id}/message, /completions |
| Leads | /api/v1/leads | GET /, GET /count, GET /{id}, DELETE /{id} |
| Customers | /api/v1/customers | GET /, GET /{id}, PATCH /{id} |
| Health | /api/v1 | GET /health |
| Monitoring | /api/v1/monitoring | GET /health/details |

---

## 14. Security Strategy

- Access Token: In-memory (Riverpod state), attached via AuthInterceptor
- Refresh Token: flutter_secure_storage (OS keychain)
- Auto-refresh 30s before expiry
- Session validated on app resume
- Forced logout on refresh failure
- Role validation via require_role equivalent
- No secrets in source code, no tokens in logs

---

## 15. Environment Configuration

`dart
@Envied(path: '.env')
class Env {
  @EnviedField(varName: 'API_BASE_URL')
  static const String apiBaseUrl = _Env.apiBaseUrl;
  @EnviedField(varName: 'API_TIMEOUT')
  static const int apiTimeout = _Env.apiTimeout;
  @EnviedField(varName: 'ENVIRONMENT')
  static const String environment = _Env.environment;
  @EnviedField(varName: 'SENTRY_DSN')
  static const String? sentryDsn = _Env.sentryDsn;
}
`

---

## 16. Verification Strategy

### Per-Feature

1. Models compile (build_runner)
2. Analysis clean (flutter analyze)
3. Unit tests pass
4. Widget tests pass
5. Integration tests pass
6. API communication verified
7. Loading/error states verified
8. Keyboard navigation verified

### Foundation (Phase 1)

1. flutter pub get
2. dart run build_runner build
3. flutter analyze --zero issues
4. flutter test --all pass
5. App compiles on Windows/macOS
6. Login screen renders with dark theme
7. Routing works (protected -> login redirect)
8. API layer connects to Nexora Brain
9. JWT flow works (login -> token -> refresh -> logout)
10. Command palette opens with Cmd+K
11. Session manager handles token refresh
12. FOUNDATION_VERIFICATION_REPORT.md generated

---

## 17. Technology Constraints (from SKILL.md)

| Requirement | Implementation |
|-------------|----------------|
| Flutter Stable | Flutter 3.44.1 |
| Material 3 | useMaterial3: true |
| Riverpod | flutter_riverpod + riverpod_annotation |
| GoRouter | go_router with redirect guards |
| Dio | dio with interceptor chain |
| Freezed | freezed_annotation + freezed |
| Json Serializable | json_annotation + json_serializable |
| Clean Architecture | 4-layer enforced |
| Dark Theme First | Dark default, light optional |
| Desktop First | Sidebar nav, keyboard shortcuts, multi-panel |

---

**Awaiting approval before proceeding to implementation.**
