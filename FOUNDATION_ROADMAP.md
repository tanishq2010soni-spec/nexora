# FOUNDATION_ROADMAP.md

**Project:** Nexora Control Center
**Date:** 2026-06-19 (Architecture Improvement Phase)
**Version:** 3.0
**Phase:** Phase 1 — Foundation Only

---

## Phase 1 Scope

Build only the foundation. No business modules.

Includes: project setup, core infrastructure, app shell, authentication, API layer, shared components, session management, global search, notifications framework, workspace support, and desktop power-user features.

---

## Deliverables

### 1. Project Setup

| Task | Priority | Notes |
|------|----------|-------|
| Create Flutter project (control_center/) | P0 | Desktop targets: Windows, macOS, Linux |
| Configure pubspec.yaml | P0 | All dependencies |
| Configure analysis_options.yaml | P0 | Strict linting |
| Create .env + env.g.dart | P0 | Environment config with envied |
| Create folder structure | P0 | Clean Architecture layers |

### 2. Core — Theme System

| Task | Priority | Notes |
|------|----------|-------|
| AppColors | P0 | Dark theme colors |
| AppTypography | P0 | Inter font family |
| AppSpacing | P0 | 4px base unit |
| AppShadows | P0 | Elevation system |
| AppTheme | P0 | Material 3, dark first |

### 3. Core — Network Layer

| Task | Priority | Notes |
|------|----------|-------|
| ApiClient | P0 | Dio instance, base config |
| AuthInterceptor | P0 | JWT attachment |
| RetryInterceptor | P0 | 3 retries, exponential backoff |
| ApiInterceptor | P0 | Logging + error mapping |
| ApiResponse | P0 | Raw response wrapper |
| ApiResult | P0 | Typed Result wrapper |
| ConnectivityService | P1 | Online/offline detection |

### 4. Core — Error Handling

| Task | Priority | Notes |
|------|----------|-------|
| AppException hierarchy | P0 | Network, Auth, Validation, Server, Timeout, RateLimit, Unknown |
| ErrorHandler | P0 | Maps Dio errors to AppException |
| ResultBuilder | P0 | UI helper for ApiResult |

### 5. Core — Auth (core/auth/)

| Task | Priority | Notes |
|------|----------|-------|
| SessionState | P0 | Freezed state model |
| SessionManager | P0 | Lifecycle provider, concurrent refresh queue |
| TokenManager | P0 | JWT + refresh token operations |
| AuthGuard | P0 | GoRouter redirect guard |
| App lifecycle hooks | P0 | Resume: validate, Pause: cancel timer |

### 6. Core — Storage & Environment

| Task | Priority | Notes |
|------|----------|-------|
| SecureStorageService | P0 | flutter_secure_storage |
| Env | P0 | envied config class |
| AppLogger | P0 | Production-grade logging |

### 7. Core — Router

| Task | Priority | Notes |
|------|----------|-------|
| AppRouter | P0 | GoRouter config |
| RouteNames | P0 | All Phase 1 routes |
| Auth redirect logic | P0 | Protected routes -> login |

### 8. Core — Global Search

| Task | Priority | Notes |
|------|----------|-------|
| SearchEntry | P1 | Freezed model |
| SearchFilter | P1 | Module filter |
| SearchIndex | P1 | In-memory index |
| SearchRepository | P1 | Interface + implementation |
| SearchProvider | P1 | Riverpod state |
| CommandPalette | P1 | Cmd+K UI overlay |

### 9. Core — Notifications Framework

| Task | Priority | Notes |
|------|----------|-------|
| AppNotification | P1 | Freezed model |
| NotificationPreferences | P1 | Per-type toggles |
| NotificationsRepository | P1 | Interface + implementation |
| NotificationsProvider | P1 | Riverpod state |
| NotificationBadgeProvider | P1 | Unread count |
| NotificationBell | P1 | Top bar widget |
| NotificationPanel | P1 | Dropdown panel |

### 10. Core — Workspace Support

| Task | Priority | Notes |
|------|----------|-------|
| Workspace | P1 | Freezed model |
| WorkspaceContext | P1 | Active workspace |
| WorkspaceListProvider | P1 | All workspaces |
| ActiveWorkspaceProvider | P1 | Current workspace |
| WorkspaceSwitcher | P1 | Sidebar widget |

### 11. App Shell

| Task | Priority | Notes |
|------|----------|-------|
| main.dart | P0 | ProviderScope + runApp |
| App widget | P0 | MaterialApp.router + theme |
| AppShell | P0 | Layout wrapper |
| AppSidebar | P0 | Collapsible, keyboard shortcuts |
| AppTopBar | P0 | Breadcrumbs, search, notification bell |
| DesktopShell | P0 | Desktop-specific layout |
| ResponsiveLayout | P0 | Breakpoints |

### 12. Core Widgets

| Task | Priority | Notes |
|------|----------|-------|
| AppTextField | P0 | Dark theme styled |
| AppButton | P0 | All 4 variants |
| ConfirmDialog | P0 | Reusable |
| AppLoader | P0 | Spinner |
| SkeletonLoader | P0 | Content placeholder |
| ErrorView | P0 | Error state + retry |
| EmptyState | P0 | No data |
| StatCard | P0 | Metric display |
| DataTableWidget | P0 | Sortable, paginated, multi-select, right-click |
| ResultBuilder | P0 | ApiResult handler |

### 13. Authentication

| Task | Priority | Notes |
|------|----------|-------|
| User model (Freezed) | P0 | id, email, role, orgId |
| AuthState (Freezed) | P0 | States |
| AuthRepositoryInterface | P0 | Abstract |
| AuthRemoteDatasource | P0 | Dio calls |
| AuthRepository | P0 | Returns ApiResult |
| AuthProvider | P0 | AsyncNotifier |
| LoginScreen | P0 | Per UI_SYSTEM.md |
| LoginForm | P0 | Email + password |
| LoginHeader | P0 | Logo + title |
| Auth redirect | P0 | Router guard |

### 14. Dashboard (Skeleton)

| Task | Priority | Notes |
|------|----------|-------|
| DashboardStats | P0 | Freezed model |
| DashboardRepository | P0 | Interface + implementation |
| DashboardProvider | P0 | FutureProvider |
| DashboardScreen | P0 | Stat cards + activity feed |

### 15. Tests

| Task | Priority | Notes |
|------|----------|-------|
| Unit tests — auth | P0 | Repository, provider |
| Unit tests — dashboard | P0 | Repository |
| Unit tests — core | P0 | ApiResult, SessionManager, SearchIndex |
| Widget tests — login | P0 | LoginForm, LoginScreen |
| Widget tests — sidebar | P0 | AppSidebar |
| Widget tests — shared | P0 | AppButton, AppTextField, ResultBuilder |
| Widget tests — command palette | P1 | CommandPalette |
| Integration test — auth flow | P0 | Login -> dashboard -> logout |

### 16. Verification

| Task | Priority | Notes |
|------|----------|-------|
| flutter pub get | P0 | Dependencies resolve |
| dart run build_runner build | P0 | Freezed/JSON generated |
| flutter analyze | P0 | Zero issues |
| flutter test | P0 | All pass |
| App compiles on Windows | P0 | Desktop target |
| App compiles on macOS | P0 | Desktop target |
| Login screen renders | P0 | Dark theme |
| Routing works | P0 | Protected redirect |
| API connects | P0 | Nexora Brain reachable |
| JWT flow works | P0 | Full lifecycle |
| Session manager works | P0 | Auto-refresh |
| Command palette opens | P1 | Cmd+K |
| FOUNDATION_VERIFICATION_REPORT.md | P0 | Final report |

---

## Implementation Order

### Sprint 1: Core Infrastructure (Days 1-3)

| Day | Tasks |
|-----|-------|
| 1 | Create Flutter project, pubspec.yaml, folder structure, analysis_options.yaml, .env |
| 2 | Theme system, AppLogger |
| 3 | SecureStorageService, AppException, ApiResult, ApiResponse, ErrorHandler, ResultBuilder, TokenManager, SessionManager, SessionState |

### Sprint 2: Network + Auth (Days 4-6)

| Day | Tasks |
|-----|-------|
| 4 | ApiClient, AuthInterceptor, RetryInterceptor, ApiInterceptor, ConnectivityService |
| 5 | Auth models, AuthRepositoryInterface, AuthRemoteDatasource, AuthRepository |
| 6 | AuthProvider, LoginScreen, LoginForm, LoginHeader, AppRouter + auth redirect |

### Sprint 3: Shell + Shared Widgets (Days 7-9)

| Day | Tasks |
|-----|-------|
| 7 | main.dart, App widget, AppShell, DesktopShell, ResponsiveLayout |
| 8 | AppSidebar, AppTopBar, NotificationBell |
| 9 | AppTextField, AppButton, ConfirmDialog, AppLoader, SkeletonLoader, ErrorView, EmptyState, StatCard, DataTableWidget |

### Sprint 4: Search + Notifications + Dashboard (Days 10-12)

| Day | Tasks |
|-----|-------|
| 10 | SearchEntry, SearchIndex, SearchRepository, CommandPalette |
| 11 | AppNotification, NotificationsRepository, NotificationsProvider, NotificationPanel, NotificationTile |
| 12 | DashboardStats, DashboardRepository, DashboardProvider, DashboardScreen |

### Sprint 5: Workspace + Testing (Days 13-14)

| Day | Tasks |
|-----|-------|
| 13 | Workspace model, WorkspaceContext, WorkspaceListProvider, ActiveWorkspaceProvider, WorkspaceSwitcher, unit tests |
| 14 | Widget tests, integration test, flutter analyze, verification, FOUNDATION_VERIFICATION_REPORT.md |

---

## Dependencies (pubspec.yaml)

`yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  go_router: ^14.8.1
  dio: ^5.7.0
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0
  flutter_secure_storage: ^9.2.4
  google_fonts: ^6.2.1
  lucide_icons: ^0.474.0
  intl: ^0.19.0
  envied: ^1.0.0
  logger: ^2.5.0
  uuid: ^4.5.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  build_runner: ^2.4.14
  freezed: ^2.5.8
  json_serializable: ^6.9.4
  riverpod_generator: ^2.6.3
  envied_generator: ^1.0.0
  mocktail: ^1.0.4
`

---

## What Phase 1 Does NOT Include

- Agent CRUD (Phase 2)
- Knowledge Base CRUD (Phase 2)
- Leads CRUD (Phase 2)
- Customers CRUD (Phase 2)
- Conversations UI (Phase 2)
- Analytics UI (Phase 2)
- Billing UI (Phase 3)
- Settings UI (Phase 3)
- Audit Logs UI (Phase 3)
- Real-time WebSocket (Phase 2)
- Push notifications (Phase 3)

---

## Risk Assessment

| Risk | Mitigation |
|------|-----------|
| Backend not running | Mock API for widget tests |
| Freezed issues | Pin versions, --delete-conflicting-outputs |
| Desktop compilation | Ensure Visual Studio installed |
| Secure storage on desktop | flutter_secure_storage supports desktop |
| Command palette performance | In-memory index, <100ms query |
| Refresh race conditions | Queue requests during refresh |

---

**Awaiting approval before proceeding to implementation.**
