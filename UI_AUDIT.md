# NEXORA RC1 — UI Audit Report

**Date:** 2026-06-30  
**Scope:** Full UI audit across all screens

---

## Issues Found & Fixed

### 1. Analytics Screen — Double AppBar
- **File:** `lib/features/analytics/presentation/screens/analytics_screen.dart`
- **Issue:** Screen had its own Scaffold + AppBar while already inside ShellRoute with AppBar from AppShell/TopBar
- **Fix:** Removed Scaffold+AppBar, embedded content directly with proper page padding

### 2. Analytics Screen — Theme Inconsistency (Card/Colors.grey)
- **File:** `lib/features/analytics/presentation/screens/analytics_screen.dart`
- **Issue:** Used `Card` widget (which uses default M3 theming) and `Colors.grey` instead of `AppColors.surface` / `AppColors.textSecondary`
- **Fix:** Replaced with styled `Container` using `AppColors.surface`, `AppColors.surfaceBorder`, `AppColors.textPrimary`, `AppColors.textSecondary`

### 3. Analytics Screen — Theme Inconsistency (Theme.of)
- **File:** `lib/features/analytics/presentation/screens/analytics_screen.dart`
- **Issue:** All 6 tabs used `Theme.of(context).textTheme.*` instead of `AppTypography.*`
- **Fix:** Replaced every `Theme.of(context).textTheme.titleLarge/Medium/Small` with `AppTypography.h4/bodySmall` etc.

### 4. Analytics Screen — Missing TabBar Theme
- **File:** `lib/features/analytics/presentation/screens/analytics_screen.dart`
- **Issue:** TabBar used default theme (no explicit colors)
- **Fix:** Added TabBar styling with `AppColors.accent`, `AppColors.textSecondary`, `AppColors.surfaceBorder`

### 5. Analytics Screen — KPI Row Cards
- **File:** `lib/features/analytics/presentation/screens/analytics_screen.dart`
- **Issue:** `_kpiRow` used `Card` with hardcoded `Colors.grey[600]`
- **Fix:** Replaced with styled Container using AppColors

### 6. Login Screen — Raw Error Display
- **File:** `lib/features/auth/presentation/screens/login_screen.dart`
- **Issue:** `authState.error.toString()` displayed raw DioException/validation messages to user
- **Fix:** Added `_resolveErrorMessage()` that translates common errors to user-friendly messages

### 7. System Health Screen — Static Data
- **File:** `lib/features/system_health/presentation/screens/system_health_screen.dart`
- **Issue:** All status values were hardcoded ("Checking...", "Running", "Active")
- **Fix:** Created `health_provider.dart` with actual `/health` and `/health/detailed` API calls, added loading/error/empty states

### 8. Notification Bell — Hardcoded Count
- **File:** `lib/core/widgets/topbar/notification_bell.dart`
- **Issue:** `count: 3` hardcoded in app_topbar.dart
- **Fix:** Converted to `ConsumerWidget`, wired to `unreadCountProvider`

### 9. AppShell Mobile — Hardcoded Colors
- **File:** `lib/shared/layouts/app_shell.dart`
- **Issue:** Mobile layout used `Color(0xFF111111)`, `Colors.blue`, `Colors.grey`
- **Fix:** Replaced with `AppColors.surface`, `AppColors.accent`, `AppColors.textTertiary`

### 10. WhatsApp Agents — Hardcoded TextStyle
- **File:** `lib/features/agent_center/whatsapp_agents/presentation/screens/whatsapp_agents_screen.dart`
- **Issue:** Title used `TextStyle(fontSize: 24, fontWeight: FontWeight.w600)`
- **Fix:** Replaced with `AppTypography.h2.copyWith(color: AppColors.textPrimary)`

### 11. Calling Agents — Missing Title Color
- **File:** `lib/features/agent_center/calling_agents/presentation/screens/calling_agents_screen.dart`
- **Issue:** Title used `AppTypography.h2` without specifying color
- **Fix:** Added `.copyWith(color: AppColors.textPrimary)`

### 12. Calling Agents — Error as EmptyState
- **File:** `lib/features/agent_center/calling_agents/presentation/screens/calling_agents_screen.dart`
- **Issue:** Error state used `EmptyState` widget showing `error.toString()`
- **Fix:** Replaced with proper `ErrorView` widget with `UnknownException` fallback

### 13. Sidebar Item — Invalid Constants
- **File:** `lib/core/widgets/sidebar/sidebar_item.dart`
- **Issue:** `const EdgeInsets.symmetric` and `const SizedBox` used with runtime values (`isSubItem`)
- **Fix:** Removed `const` from those expressions

### 14. ErrorView — Duplicate Method
- **File:** `lib/core/widgets/error_view.dart`
- **Issue:** Duplicate `_resolveMessage()` method from partial edit
- **Fix:** Removed duplicate, kept improved version with length limiting

### 15. ErrorView — Undefined Getter
- **File:** `lib/core/widgets/error_view.dart`
- **Issue:** `exception.response?.statusCode` when exception is `Object` type
- **Fix:** Added explicit cast `(exception as DioException).response`
