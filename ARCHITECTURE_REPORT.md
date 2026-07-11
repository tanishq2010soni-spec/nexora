# ARCHITECTURE_REPORT.md

**Project:** Nexora Control Center  
**Date:** 2026-06-19 (Revised)  
**Status:** Pre-Implementation (Awaiting Approval)  
**Version:** 2.0

---

## 1. Project Overview

Nexora Control Center is a Flutter desktop-first application serving as the central operating system for the Nexora Brain AI platform. It manages WhatsApp Agents, Calling Agents, Knowledge Bases, Leads, Customers, Conversations, Analytics, Audit Logs, System Health, Billing, and Settings.

**Backend:** Nexora Brain FastAPI at `http://localhost:8000/api/v1/`  
**Architecture:** Clean Architecture (4 layers)  
**Primary Platform:** Desktop (Windows, macOS, Linux)  
**Companion Platform:** Mobile (Android, iOS)

---

## 2. Folder Structure

```
control_center/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_constants.dart
│   │   │   ├── app_constants.dart
│   │   │   └── storage_constants.dart
│   │   ├── env/
│   │   │   ├── env.dart
│   │   │   └── env.g.dart
│   │   ├── errors/
│   │   │   ├── app_exception.dart
│   │   │   ├── api_result.dart              # [NEW] Typed Result wrapper
│   │   │   └── error_handler.dart
│   │   ├── extensions/
│   │   │   ├── context_extensions.dart
│   │   │   └── result_extensions.dart       # [NEW] Result.map/flatMap
│   │   ├── logging/
│   │   │   └── app_logger.dart
│   │   ├── network/
│   │   │   ├── api_client.dart
│   │   │   ├── api_interceptor.dart
│   │   │   ├── auth_interceptor.dart
│   │   │   ├── retry_interceptor.dart
│   │   │   └── connectivity_service.dart
│   │   ├── router/
│   │   │   ├── app_router.dart
│   │   │   └── route_names.dart
│   │   ├── session/
│   │   │   ├── session_manager.dart          # [NEW] Session lifecycle
│   │   │   └── session_state.dart
│   │   ├── storage/
│   │   │   └── secure_storage_service.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   ├── app_colors.dart
│   │   │   ├── app_typography.dart
│   │   │   ├── app_spacing.dart
│   │   │   └── app_shadows.dart
│   │   └── search/
│   │       ├── global_search_delegate.dart   # [NEW] Command palette search
│   │       └── search_index.dart
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── auth_remote_datasource.dart
│   │   │   │   └── repositories/
│   │   │   │       └── auth_repository.dart
│   │   │   ├── domain/
│   │   │   │   ├── models/
│   │   │   │   │   └── auth_models.dart      # User, AuthState, TokenPair
│   │   │   │   └── repositories/
│   │   │   │       └── auth_repository_interface.dart
│   │   │   ├── providers/
│   │   │   │   └── auth_provider.dart
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   └── login_screen.dart
│   │   │       └── widgets/
│   │   │           ├── login_form.dart
│   │   │           └── login_header.dart
│   │   │
│   │   ├── dashboard/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   ├── providers/
│   │   │   └── presentation/
│   │   │
│   │   ├── agent_center/                     # [REVISED] Centralized Agent Hub
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── agent_center_remote_datasource.dart
│   │   │   │   └── repositories/
│   │   │   │       └── agent_center_repository.dart
│   │   │   ├── domain/
│   │   │   │   ├── models/
│   │   │   │   │   ├── agent.dart
│   │   │   │   │   ├── agent_config.dart
│   │   │   │   │   └── agent_status.dart
│   │   │   │   └── repositories/
│   │   │   │       └── agent_center_repository_interface.dart
│   │   │   ├── providers/
│   │   │   │   ├── agent_list_provider.dart
│   │   │   │   ├── agent_editor_provider.dart
│   │   │   │   └── agent_status_provider.dart
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   ├── agent_list_screen.dart
│   │   │       │   ├── agent_detail_screen.dart
│   │   │       │   └── agent_editor_screen.dart
│   │   │       └── widgets/
│   │   │           ├── agent_card.dart
│   │   │           ├── agent_status_badge.dart
│   │   │           ├── prompt_editor.dart
│   │   │           └── knowledge_base_linker.dart
│   │   │
│   │   ├── ai_models/                         # [NEW] Model Registry
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── ai_models_remote_datasource.dart
│   │   │   │   └── repositories/
│   │   │   │       └── ai_models_repository.dart
│   │   │   ├── domain/
│   │   │   │   ├── models/
│   │   │   │   │   ├── ai_model.dart
│   │   │   │   │   ├── model_config.dart
│   │   │   │   │   └── model_health.dart
│   │   │   │   └── repositories/
│   │   │   │       └── ai_models_repository_interface.dart
│   │   │   ├── providers/
│   │   │   │   ├── model_list_provider.dart
│   │   │   │   └── model_health_provider.dart
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   ├── model_registry_screen.dart
│   │   │       │   └── model_detail_screen.dart
│   │   │       └── widgets/
│   │   │           ├── model_card.dart
│   │   │           ├── model_status_indicator.dart
│   │   │           └── model_config_editor.dart
│   │   │
│   │   ├── knowledge_base/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   ├── providers/
│   │   │   └── presentation/
│   │   │
│   │   ├── leads/
│   │   ├── customers/
│   │   ├── conversations/
│   │   ├── analytics/
│   │   ├── audit_logs/
│   │   │
│   │   ├── system_monitoring/                 # [NEW] Health + Metrics + Alerts
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── monitoring_remote_datasource.dart
│   │   │   │   └── repositories/
│   │   │   │       └── monitoring_repository.dart
│   │   │   ├── domain/
│   │   │   │   ├── models/
│   │   │   │   │   ├── system_health.dart
│   │   │   │   │   ├── service_status.dart
│   │   │   │   │   ├── health_metric.dart
│   │   │   │   │   └── alert_rule.dart
│   │   │   │   └── repositories/
│   │   │   │       └── monitoring_repository_interface.dart
│   │   │   ├── providers/
│   │   │   │   ├── health_provider.dart
│   │   │   │   ├── metrics_provider.dart
│   │   │   │   └── alerts_provider.dart
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   └── system_health_screen.dart
│   │   │       └── widgets/
│   │   │           ├── service_health_card.dart
│   │   │           ├── health_timeline.dart
│   │   │           └── alert_banner.dart
│   │   │
│   │   ├── notifications/                     # [NEW] In-App Notifications
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── notifications_remote_datasource.dart
│   │   │   │   └── repositories/
│   │   │   │       └── notifications_repository.dart
│   │   │   ├── domain/
│   │   │   │   ├── models/
│   │   │   │   │   ├── app_notification.dart
│   │   │   │   │   └── notification_preferences.dart
│   │   │   │   └── repositories/
│   │   │   │       └── notifications_repository_interface.dart
│   │   │   ├── providers/
│   │   │   │   ├── notifications_provider.dart
│   │   │   │   └── notification_badge_provider.dart
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   └── notifications_screen.dart
│   │   │       └── widgets/
│   │   │           ├── notification_tile.dart
│   │   │           ├── notification_badge.dart
│   │   │           └── notification_panel.dart
│   │   │
│   │   ├── billing/
│   │   └── settings/
│   │
│   └── shared/
│       ├── widgets/
│       │   ├── sidebar/
│       │   │   ├── app_sidebar.dart
│       │   │   └── sidebar_item.dart
│       │   ├── topbar/
│       │   │   ├── app_topbar.dart
│       │   │   ├── user_avatar.dart
│       │   │   └── notification_bell.dart     # [NEW] Bell icon + badge
│       │   ├── dialogs/
│       │   │   ├── confirm_dialog.dart
│       │   │   └── command_palette.dart        # [NEW] Cmd+K search
│       │   ├── tables/
│       │   │   └── data_table_widget.dart
│       │   ├── forms/
│       │   │   └── app_text_field.dart
│       │   ├── cards/
│       │   │   └── stat_card.dart
│       │   ├── loading/
│       │   │   ├── app_loader.dart
│       │   │   └── skeleton_loader.dart
│       │   ├── errors/
│       │   │   ├── error_view.dart
│       │   │   └── empty_state.dart
│       │   └── result/
│       │       └── result_builder.dart         # [NEW] UI helper for ApiResult
│       └── layouts/
│           ├── app_shell.dart
│           └── responsive_layout.dart
│
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
│
├── analysis_options.yaml
├── pubspec.yaml
└── README.md
```

---

## 3. Dependency Flow (Clean Architecture)

```
┌─────────────────────────────────────────────────────────┐
│                   presentation/                           │
│  Screens, Widgets, Providers (Riverpod)                  │
│  Depends on: domain/ only (via providers)                │
│  NEVER imports: data/, core/network/                     │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│                   domain/                                │
│  Models (Freezed), Repository Interfaces                 │
│  Depends on: nothing (pure Dart, zero framework deps)    │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│                   data/                                  │
│  Repository Implementations, DataSources                 │
│  Depends on: domain/ (interfaces) + core/ (network)      │
│  NEVER imports: presentation/                            │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│                   core/                                  │
│  Network (Dio), Storage, Theme, Router, Logger,          │
│  Session, Search Index, Result types                     │
│  Depends on: external packages only                      │
│  NEVER imports: features/                                │
└─────────────────────────────────────────────────────────┘
```

### Layer Rules

1. `presentation/` imports only `domain/` + `core/` (no `data/`)
2. `domain/` imports nothing (pure Dart)
3. `data/` imports `domain/` (interfaces) + `core/` (ApiClient)
4. `core/` imports nothing from `features/`
5. Feature modules never import each other directly (communicate via providers)

---

## 4. Feature Structure (per Feature)

```
feature/
├── data/
│   ├── datasources/
│   │   └── feature_remote_datasource.dart    # Dio calls, returns Map/List
│   └── repositories/
│       └── feature_repository.dart           # Implements domain interface
├── domain/
│   ├── models/
│   │   └── feature_model.dart                # Freezed + json_serializable
│   └── repositories/
│       └── feature_repository_interface.dart  # Abstract class
├── providers/
│   └── feature_provider.dart                 # Riverpod providers
└── presentation/
    ├── screens/
    │   └── feature_screen.dart
    └── widgets/
        └── feature_widgets.dart
```

---

## 5. API Result Pattern

Every API call returns a typed `ApiResult<T>` instead of throwing exceptions.

### Definition

```dart
sealed class ApiResult<T> {
  const ApiResult();
}

class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  const ApiSuccess(this.data);
}

class ApiError<T> extends ApiResult<T> {
  final AppException exception;
  const ApiError(this.exception);
}

class ApiLoading<T> extends ApiResult<T> {
  const ApiLoading();
}
```

### Usage in Repository

```dart
class AuthRepository implements AuthRepositoryInterface {
  final ApiClient _client;

  @override
  Future<ApiResult<AuthTokens>> login(String email, String password) async {
    try {
      final response = await _client.post(
        '/api/v1/auth/login',
        data: {'email': email, 'password': password},
      );
      return ApiSuccess(AuthTokens.fromJson(response.data));
    } on DioException catch (e) {
      return ApiError(AppException.fromDio(e));
    }
  }
}
```

### Usage in Provider

```dart
@riverpod
class Auth extends _$Auth {
  @override
  Future<AuthState> build() async => const AuthState.unauthenticated();

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    final result = await ref.read(authRepositoryProvider).login(email, password);
    state = switch (result) {
      ApiSuccess(:final data) => AsyncData(AuthState.authenticated(data)),
      ApiError(:final e) => AsyncError(e, StackTrace.current),
      _ => state,
    };
  }
}
```

### Usage in UI

```dart
// ResultBuilder handles loading/error/data states
ResultBuilder(
  result: authState,
  loading: () => const AppLoader(),
  error: (e) => ErrorView(exception: e),
  data: (state) => DashboardScreen(state: state),
)
```

---

## 6. Agent Center Architecture

The Agent Center is the centralized hub for managing all AI agents (WhatsApp, Calling, Web).

### Data Flow

```
UI (AgentListScreen)
  │
  ▼
AgentListProvider (Riverpod NotifierProvider)
  │
  ▼
AgentCenterRepositoryInterface (domain/)
  │
  ▼
AgentCenterRepository (data/)
  │
  ▼
AgentCenterRemoteDatasource → Dio → /api/v1/agents/*
  │
  ▼
Nexora Brain API
```

### Agent Model (Freezed)

```dart
@freezed
class Agent with _$Agent {
  const factory Agent({
    required String id,
    required String orgId,
    required String name,
    required String platformType,    // "whatsapp" | "calling" | "web"
    required String systemPrompt,
    @Default('llama3') String llmModel,
    @Default(0.7) double temperature,
    required DateTime createdAt,
    required DateTime updatedAt,
    AgentStatus? status,             // Derived from last activity
    List<String>? knowledgeBaseIds,  // Linked KB IDs
  }) = _Agent;
}
```

### Agent Status

```dart
enum AgentStatus {
  active,    // Currently handling conversations
  idle,      // Configured but no recent activity
  error,     // LLM or connection failure
  disabled,  // Manually disabled by user
}
```

### Provider Architecture

```dart
// List of agents (cached, auto-refresh)
@riverpod
class AgentList extends _$AgentList { ... }

// Single agent editor state
@riverpod
class AgentEditor extends _$AgentEditor { ... }

// Real-time agent status (polled every 30s)
@riverpod
class AgentStatus extends _$AgentStatus { ... }
```

### UI Components

| Screen | Purpose |
|--------|---------|
| `AgentListScreen` | Grid/list of all agents with status badges, filters by platform |
| `AgentDetailScreen` | Full agent config, conversation history, analytics |
| `AgentEditorScreen` | Create/edit agent with prompt editor, KB linking |

---

## 7. AI Models Module

Manages the model registry — which LLMs are available, their configuration, and health.

### Data Sources

- **Ollama API** — `/api/tags` for available models, `/api/generate` for health checks
- **Agent configuration** — Which models are assigned to which agents

### AI Model (Freezed)

```dart
@freezed
class AiModel with _$AiModel {
  const factory AiModel({
    required String name,             // e.g. "llama3", "mistral"
    required String displayName,
    String? description,
    String? size,                     // e.g. "7B", "13B"
    required AiModelStatus status,
    DateTime? lastHealthCheck,
    Map<String, dynamic>? metadata,   // Parameters, quantization, etc.
  }) = _AiModel;
}
```

### AI Model Status

```dart
enum AiModelStatus {
  available,    // Loaded and responding
  loading,      // Currently being loaded into memory
  unavailable,  // Not responding
  error,        // Failed health check
}
```

### Provider Architecture

```dart
// All available models from Ollama
@riverpod
class ModelList extends _$ModelList { ... }

// Health status for a specific model (polled)
@riverpod
class ModelHealth extends _$ModelHealth { ... }
```

### UI Components

| Screen | Purpose |
|--------|---------|
| `ModelRegistryScreen` | Grid of all models with status, usage stats |
| `ModelDetailScreen` | Model info, assigned agents, health history |
| `ModelConfigEditor` | Edit temperature, context length, etc. |

---

## 8. System Monitoring Module

Provides observability into all backend services.

### Monitored Services

| Service | Probe Method | Endpoint |
|---------|-------------|----------|
| PostgreSQL | `SELECT 1` | `/api/v1/health` |
| Ollama | HTTP GET `/api/tags` | `/api/v1/monitoring/health/details` |
| Qdrant | HTTP GET root | `/api/v1/monitoring/health/details` |
| Redis | Connection check | Client-side |
| Nexora Brain | Health endpoint | `/api/v1/health` |

### System Health Model (Freezed)

```dart
@freezed
class SystemHealth with _$SystemHealth {
  const factory SystemHealth({
    required ServiceStatus database,
    required ServiceStatus ollama,
    required ServiceStatus qdrant,
    required ServiceStatus overall,
    required DateTime checkedAt,
  }) = _SystemHealth;
}

@freezed
class ServiceStatus with _$ServiceStatus {
  const factory ServiceStatus({
    required String name,
    required HealthState state,       // healthy | degraded | unhealthy
    String? message,
    Duration? latency,
    DateTime? lastChecked,
  }) = _ServiceStatus;
}

enum HealthState { healthy, degraded, unhealthy }
```

### Alert Rules

```dart
@freezed
class AlertRule with _$AlertRule {
  const factory AlertRule({
    required String id,
    required String service,
    required AlertCondition condition,
    required double threshold,
    required bool enabled,
    String? message,
  }) = _AlertRule;
}

enum AlertCondition {
  latencyGreaterThan,
  statusEquals,
  errorRateGreaterThan,
}
```

### Provider Architecture

```dart
// Polls /api/v1/monitoring/health/details every 15s
@riverpod
class HealthMonitor extends _$HealthMonitor { ... }

// Aggregated metrics over time
@riverpod
class HealthMetrics extends _$HealthMetrics { ... }

// Alert rules (CRUD)
@riverpod
class AlertRules extends _$AlertRules { ... }
```

### UI Components

| Screen | Purpose |
|--------|---------|
| `SystemHealthScreen` | Service status cards, latency graphs, alert config |
| `ServiceHealthCard` | Single service: status dot, latency, last check |
| `HealthTimeline` | Historical health chart |
| `AlertBanner` | Top-of-page alert when service is degraded |

---

## 9. Notifications Module

In-app notification system for alerts, events, and system messages.

### Notification Model (Freezed)

```dart
@freezed
class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required NotificationType type,
    required String title,
    required String message,
    @Default(false) bool read,
    String? actionUrl,              // Deep link to relevant screen
    DateTime? createdAt,
  }) = _AppNotification;
}

enum NotificationType {
  info,
  warning,
  error,
  success,
  system,
}
```

### Notification Preferences

```dart
@freezed
class NotificationPreferences with _$NotificationPreferences {
  const factory NotificationPreferences({
    @Default(true) bool agentAlerts,
    @Default(true) bool systemAlerts,
    @Default(true) bool leadNotifications,
    @Default(false) bool emailDigest,
  }) = _NotificationPreferences;
}
```

### Provider Architecture

```dart
// All notifications (paginated, cached)
@riverpod
class Notifications extends _$Notifications { ... }

// Unread count badge
@riverpod
class NotificationBadge extends _$NotificationBadge { ... }
```

### UI Components

| Component | Purpose |
|-----------|---------|
| `NotificationBell` | Top bar icon with unread count badge |
| `NotificationPanel` | Dropdown panel showing recent notifications |
| `NotificationTile` | Single notification: icon, title, time, read state |
| `NotificationsScreen` | Full notification history with filters |

---

## 10. Global Search Module

Cross-module search accessible via `Cmd+K` / `Ctrl+K` command palette.

### Search Index Structure

```dart
class SearchIndex {
  // In-memory index built on app startup
  final Map<String, SearchEntry> _entries = {};

  void index(SearchEntry entry) { ... }
  List<SearchEntry> query(String term) { ... }
}

@freezed
class SearchEntry with _$SearchEntry {
  const factory SearchEntry({
    required String id,
    required String module,           // "agent", "lead", "customer", etc.
    required String title,
    String? subtitle,
    required String route,            // Navigation target
    Map<String, dynamic>? metadata,   // Extra data for display
  }) = _SearchEntry;
}
```

### Indexed Modules

| Module | Items Indexed | Route |
|--------|--------------|-------|
| Agents | All agents by name | `/agents/{id}` |
| Knowledge Base | All KBs by name | `/knowledge/{id}` |
| Leads | All leads by name, email | `/leads/{id}` |
| Customers | All customers by name, phone | `/customers/{id}` |
| Settings | Setting labels | `/settings/{section}` |

### Command Palette

```
┌─────────────────────────────────────────────┐
│  🔍  Search agents, leads, customers...     │
├─────────────────────────────────────────────┤
│  Agents                                     │
│    Agent Alpha                    → /agents/1│
│    Agent Beta                     → /agents/2│
│  Leads                                       │
│    John Doe                       → /leads/1 │
│  Commands                                   │
│    Create New Agent               → /agents/new│
│    Go to Dashboard                → /dashboard │
│    Open Settings                  → /settings  │
└─────────────────────────────────────────────┘
```

### Keyboard Shortcut

- `Cmd+K` (macOS) / `Ctrl+K` (Windows/Linux) — Opens command palette
- `Escape` — Closes palette
- `↑↓` — Navigate results
- `Enter` — Select result

---

## 11. Workspace Support

Multi-workspace support for organizations with multiple teams or projects.

### Workspace Model (Freezed)

```dart
@freezed
class Workspace with _$Workspace {
  const factory Workspace({
    required String id,
    required String orgId,
    required String name,
    String? description,
    required String role,             // "owner" | "admin" | "member"
    @Default(false) bool isDefault,
    DateTime? createdAt,
  }) = _Workspace;
}
```

### Workspace Context

The active workspace is stored in session and affects all data queries:

```dart
// Stored in SecureStorageService
class WorkspaceContext {
  final String workspaceId;
  final String workspaceName;
  final String userRole;
}
```

### Provider Architecture

```dart
// All workspaces for current user
@riverpod
class WorkspaceList extends _$WorkspaceList { ... }

// Active workspace (persisted to secure storage)
@riverpod
class ActiveWorkspace extends _$ActiveWorkspace { ... }

// Switch workspace → reloads all data providers
@riverpod
class WorkspaceSwitcher extends _$WorkspaceSwitcher { ... }
```

### UI Components

| Component | Purpose |
|-----------|---------|
| `WorkspaceSwitcher` | Dropdown in top bar to switch workspaces |
| `WorkspaceBadge` | Shows current workspace name in sidebar |

---

## 12. Session Manager Architecture

Manages user session lifecycle: token refresh, expiry, background/foreground transitions.

### Session State

```dart
@freezed
class SessionState with _$SessionState {
  const SessionState._();

  const factory SessionState({
    required SessionStatus status,
    String? accessToken,
    DateTime? tokenExpiry,
    String? userId,
    String? orgId,
    String? role,
  }) = _SessionState;

  bool get isExpired => tokenExpiry?.isBefore(DateTime.now()) ?? true;
  bool get needsRefresh =>
      tokenExpiry?.difference(DateTime.now()).inSeconds < 30;
}

enum SessionStatus {
  initial,          // App just started
  authenticated,    // Valid session active
  refreshing,       // Token refresh in progress
  unauthenticated,  // No session / logged out
  expired,          // Session expired
}
```

### Session Lifecycle

```
App Start
  │
  ▼
Load tokens from SecureStorage
  │
  ├─ Tokens exist & not expired → SessionStatus.authenticated
  │                                  │
  │                                  ▼
  │                           Attach token to Dio
  │                                  │
  │                                  ▼
  │                           Monitor: tokenNeedsRefresh?
  │                                  │
  │                           Yes → Refresh token (background)
  │                                  │
  │                                  ▼
  │                           New token → Update state
  │                                  │
  │                                  ▼
  │                           No → Continue
  │
  ├─ Tokens exist but expired → Attempt refresh
  │                                │
  │                                ├─ Refresh success → Authenticated
  │                                └─ Refresh failed → Logout → Login screen
  │
  └─ No tokens → SessionStatus.unauthenticated → Login screen
```

### Session Manager Provider

```dart
@riverpod
class SessionManager extends _$SessionManager {
  Timer? _refreshTimer;

  @override
  SessionState build() {
    // Initialize from secure storage
    // Set up periodic refresh check
    return const SessionState(status: SessionStatus.initial);
  }

  void startRefreshTimer() {
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkAndRefresh(),
    );
  }

  Future<void> _checkAndRefresh() async {
    if (state.needsRefresh) {
      await _refreshToken();
    }
  }

  Future<void> logout() async {
    _refreshTimer?.cancel();
    await clearSecureStorage();
    state = const SessionState(status: SessionStatus.unauthenticated);
  }
}
```

### Background/Foreground Handling

```dart
// On desktop: window focus/blur events
// On mobile: AppLifecycleState changes
void onAppLifecycleChanged(AppLifecycleState lifecycle) {
  switch (lifecycle) {
    case AppLifecycleState.resumed:
      sessionManager.checkSessionValidity();
      break;
    case AppLifecycleState.paused:
      sessionManager.cancelRefreshTimer();
      break;
    default:
      break;
  }
}
```

---

## 13. Desktop Power-User Features

### Command Palette (`Cmd+K`)

- Global search across all modules
- Quick actions: Create Agent, Upload Document, etc.
- Navigation shortcuts
- Recent items

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Cmd/Ctrl + K` | Open command palette |
| `Cmd/Ctrl + N` | Create new (context-aware) |
| `Cmd/Ctrl + S` | Save current form |
| `Cmd/Ctrl + Shift + S` | Save and close |
| `Cmd/Ctrl + Z` | Undo last action |
| `Cmd/Ctrl + Shift + Z` | Redo |
| `Escape` | Close dialog / Cancel / Back |
| `Cmd/Ctrl + 1-9` | Jump to module (1=Dashboard, 2=Agents, etc.) |
| `Cmd/Ctrl + ,` | Open settings |
| `Cmd/Ctrl + /` | Toggle keyboard shortcuts help |
| `Delete` / `Backspace` | Delete selected item (with confirmation) |
| `Enter` | Confirm / Submit |
| `Tab` | Next field |
| `Shift + Tab` | Previous field |

### Multi-Panel Layouts

Desktop supports splitting the main content area:

```
┌──────────┬──────────────────┬──────────────────┐
│          │  Agent List      │  Agent Detail    │
│ Sidebar  │  (master)        │  (detail)        │
│          │                  │                  │
│          │                  │                  │
└──────────┴──────────────────┴──────────────────┘
```

### Right-Click Context Menus

- Agent cards: Edit, Duplicate, Disable, Delete
- Table rows: View, Edit, Copy ID, Delete
- Navigation items: Open in new panel

### Inline Editing

- Table cells editable on double-click (where applicable)
- Prompt editor with syntax highlighting
- Live preview of agent configuration

### Drag and Drop

- Reorder agents in list view
- Drag documents to knowledge bases
- Reorder dashboard widgets

---

## 14. State Management Strategy (Riverpod)

### Provider Types

| Provider | Use Case | Example |
|----------|----------|---------|
| `Provider` | Singletons, services | `apiClientProvider`, `sessionManagerProvider` |
| `NotifierProvider` | Mutable state with logic | `authProvider`, `agentListProvider` |
| `AsyncNotifierProvider` | Async state with lifecycle | `healthMonitorProvider` |
| `FutureProvider` | Async one-shot reads | `modelListProvider` |
| `StreamProvider` | Real-time data | `notificationStreamProvider` |

### Provider Dependency Rules

```dart
// Providers can depend on other providers
@riverpod
AgentRepositoryInterface agentRepository(Ref ref) {
  return AgentRepository(
    datasource: ref.watch(agentCenterDatasourceProvider),
  );
}

// Feature providers depend on repositories
@riverpod
class AgentList extends _$AgentList {
  @override
  Future<List<Agent>> build() async {
    final repo = ref.watch(agentRepositoryProvider);
    final result = await repo.getAgents();
    return result.when(
      success: (data) => data,
      error: (e) => throw e,
    );
  }
}
```

---

## 15. API Strategy

### Dio Client Configuration

```dart
BaseOptions(
  baseUrl: env.apiBaseUrl,
  connectTimeout: Duration(seconds: 10),
  receiveTimeout: Duration(seconds: 15),
  headers: {'Content-Type': 'application/json'},
)
```

### Interceptor Chain (in order)

```
Request → AuthInterceptor (attach JWT)
       → RetryInterceptor (retry on 5xx, max 3)
       → ApiInterceptor (log, map errors)
       → Server
       ← Response
```

### API Endpoint Map

| Module | Base Path | Endpoints |
|--------|-----------|-----------|
| Auth | `/api/v1/auth` | `POST /signup`, `POST /login`, `POST /refresh` |
| Business | `/api/v1/business` | `GET /`, `POST /`, `PUT /{id}`, `DELETE /{id}` |
| Documents | `/api/v1/documents` | `POST /upload`, `GET /`, `DELETE /{id}` |
| Chat | `/api/v1/chat` | `POST /sessions`, `POST /sessions/{id}/message`, `POST /completions` |
| Leads | `/api/v1/leads` | `GET /`, `GET /count`, `GET /{id}`, `DELETE /{id}` |
| Customers | `/api/v1/customers` | `GET /`, `GET /{id}`, `PATCH /{id}` |
| Health | `/api/v1` | `GET /health` |
| Monitoring | `/api/v1/monitoring` | `GET /health/details` |

---

## 16. Security Strategy

### Token Management

- **Access Token**: In-memory (Riverpod state), attached via `AuthInterceptor`
- **Refresh Token**: `flutter_secure_storage` (OS keychain)
- **Logout**: Clear secure storage + reset Riverpod state + cancel refresh timer

### Refresh Flow

```
Request → 401 → AuthInterceptor intercepts
              → Queues pending requests
              → Refresh token via /api/v1/auth/refresh
              → New tokens → Update state → Retry queued requests
              → Refresh failed → SessionManager.logout() → Login screen
```

### Rules

- No secrets in source code
- No tokens in logs
- `flutter_secure_storage` for all sensitive data
- JWT expiry checked client-side
- Auto-refresh 30 seconds before expiry
- Session validated on app resume

---

## 17. Environment Configuration

```dart
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
```

### .env

```
API_BASE_URL=http://localhost:8000
API_TIMEOUT=15
ENVIRONMENT=development
SENTRY_DSN=
```

---

## 18. Verification Strategy

### Per-Feature Verification

1. Models compile (`dart run build_runner build --delete-conflicting-outputs`)
2. Analysis clean (`flutter analyze` — 0 issues)
3. Unit tests pass
4. Widget tests pass
5. Integration tests pass
6. API communication verified against live backend
7. Loading states verified
8. Error states verified
9. Keyboard navigation verified

### Foundation Verification (Phase 1)

1. `flutter pub get` — dependencies resolve
2. `dart run build_runner build` — Freezed/JSON generated
3. `flutter analyze` — zero issues
4. `flutter test` — all tests pass
5. App compiles and starts on Windows/macOS
6. Login screen renders with dark theme
7. Routing works (protected → login redirect)
8. API layer connects to Nexora Brain
9. JWT flow works (login → token → refresh → logout)
10. Command palette opens with `Cmd+K`
11. Session manager handles token refresh
12. `FOUNDATION_VERIFICATION_REPORT.md` generated

---

## 19. Technology Constraints (from SKILL.md)

| Requirement | Implementation |
|-------------|----------------|
| Flutter Stable | Flutter 3.44.1 (stable channel) |
| Material 3 | `useMaterial3: true` in ThemeData |
| Riverpod | `flutter_riverpod` + `riverpod_annotation` |
| GoRouter | `go_router` with redirect guards |
| Dio | `dio` with interceptor chain |
| Freezed | `freezed_annotation` + `freezed` |
| Json Serializable | `json_annotation` + `json_serializable` |
| Clean Architecture | 4-layer folder structure enforced |
| Dark Theme First | Dark theme as default, light optional |
| Desktop First | Sidebar nav, keyboard shortcuts, multi-panel |

---

**Awaiting approval before proceeding to implementation.**
