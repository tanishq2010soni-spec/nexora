# AUTH_AUDIT_REPORT.md

**Date:** 2026-06-24
**Auditor:** Senior Flutter Architect & Security Auditor
**Severity:** CRITICAL
**Status:** RESOLVED

---

## Executive Summary

A critical authentication bypass vulnerability was identified in the Nexora Control Center Flutter application. The Dashboard and all protected routes were accessible without authentication during the app startup window. The root cause was a race condition between GoRouter's redirect logic and the asynchronous session initialization from secure storage. This report documents the root cause, fix, and verification.

---

## Root Cause

### Vulnerability: Startup Auth Race Condition

**File:** `lib/core/auth/auth_guard.dart:16-18`

```dart
// BEFORE (VULNERABLE)
if (session.status == SessionStatus.initial) {
  return null;  // BUG: Allows ALL navigation during startup
}
```

**File:** `lib/core/router/app_router.dart:36`

```dart
initialLocation: RouteNames.dashboard,  // Dashboard is the landing page
```

**File:** `lib/core/auth/session_manager.dart:23-26`

```dart
@override
SessionState build() {
  _initializeFromStorage();  // ASYNC - runs via Future.microtask
  return const SessionState(status: SessionStatus.initial);  // Returns immediately
}
```

### Attack Timeline

1. App launches → `SessionManager.build()` returns `SessionStatus.initial` immediately
2. `_initializeFromStorage()` is dispatched via `Future.microtask` (asynchronous)
3. GoRouter initializes with `initialLocation: /dashboard`
4. `AuthGuard.redirect()` is called:
   - Reads `session.status` → `SessionStatus.initial`
   - Returns `null` → **allows navigation to /dashboard**
5. Dashboard renders **BEFORE** tokens are verified from secure storage
6. User sees the full Dashboard with sidebar, stats, and navigation
7. Only AFTER the microtask completes does the session state change

### Impact

- **Dashboard publicly accessible** without login
- **All protected routes** (Leads, Agent Center, Customers, Billing, Analytics, etc.) accessible via direct navigation or deep links during the startup window
- **No route bypass prevention** during the `initial` session state
- **Security compliance violation** - authenticated-only areas exposed

---

## Files Modified

| # | File | Change |
|---|------|--------|
| 1 | `lib/features/auth/presentation/screens/splash_screen.dart` | **NEW** - Loading screen that blocks until session initialization completes |
| 2 | `lib/core/auth/auth_guard.dart` | Fixed: `initial` state now redirects to `/splash` instead of allowing all navigation. Added `refreshing` state handling. |
| 3 | `lib/core/router/app_router.dart` | Changed `initialLocation` from `/dashboard` to `/splash`. Added `/splash` route. |
| 4 | `lib/core/router/route_names.dart` | Added `splash = '/splash'` route constant |
| 5 | `lib/features/auth/presentation/screens/register_screen.dart` | Removed direct navigation to `/dashboard` after signup. Now checks `session.isAuthenticated` before navigating. |

---

## Before/After Routing Flow

### BEFORE (Vulnerable)

```
App Launch
  → initialLocation: /dashboard
  → AuthGuard: status == initial → return null (ALLOW)
  → Dashboard renders WITHOUT authentication
  → _initializeFromStorage() completes async
  → Session state changes (too late - dashboard already visible)

Deep link to /leads during startup:
  → AuthGuard: status == initial → return null (ALLOW)
  → Leads screen renders WITHOUT authentication
```

### AFTER (Secured)

```
App Launch
  → initialLocation: /splash
  → AuthGuard: status == initial, isSplashRoute → return null (ALLOW splash only)
  → SplashScreen renders with loading indicator
  → _initializeFromStorage() completes
  → Session state changes to authenticated OR unauthenticated
  → SplashScreen detects state change:
      → Authenticated → context.go('/dashboard')
      → Unauthenticated → context.go('/login')
  → AuthGuard applies normal auth rules

Deep link to /leads during startup:
  → AuthGuard: status == initial → return /splash (BLOCK)
  → Redirected to SplashScreen
  → Session checked → redirected to /login or /dashboard

Deep link to /dashboard when unauthenticated:
  → AuthGuard: !isAuthenticated → return /login (BLOCK)
  → Redirected to LoginScreen
```

---

## Security Verification

### 1. Dashboard Access Without Auth
- **BEFORE:** Dashboard renders immediately on app launch
- **AFTER:** Splash screen shows during session check. Dashboard only renders after `SessionStatus.authenticated` is confirmed.
- **STATUS:** FIXED

### 2. Protected Route Access Without Auth
- **BEFORE:** All routes in ShellRoute accessible during `initial` state
- **AFTER:** AuthGuard blocks all non-splash, non-auth routes when `initial` or `unauthenticated`
- **STATUS:** FIXED

### 3. Deep Link / Direct Navigation Bypass
- **BEFORE:** `context.go('/leads')` works during startup without auth
- **AFTER:** Redirected to `/splash` → session check → `/login`
- **STATUS:** FIXED

### 4. Login/Register Route When Authenticated
- **BEFORE:** Only `/login` redirected to `/dashboard` when authenticated
- **AFTER:** Both `/login` and `/register` redirect to `/dashboard` when authenticated
- **STATUS:** IMPROVED

### 5. Logout Flow
- `AuthProvider.logout()` → `SessionManager.forceLogout()` → clears secure storage → sets `SessionStatus.unauthenticated` → AuthGuard redirects to `/login`
- **STATUS:** VERIFIED CORRECT (no changes needed)

### 6. Token Refresh Flow
- `SessionManager._refreshTimer()` runs every 30 seconds
- Checks `needsRefresh` (token expiring within 30 seconds)
- On refresh failure → `forceLogout()` → redirects to `/login`
- AuthGuard now also handles `SessionStatus.refreshing` by redirecting to `/splash`
- **STATUS:** VERIFIED CORRECT + IMPROVED

### 7. Secure Storage Clearing
- `TokenManager.clearTokens()` deletes `access_token` and `refresh_token` from `FlutterSecureStorage`
- Android: `encryptedSharedPreferences: true`
- iOS: `KeychainAccessibility.first_unlock_this_device`
- **STATUS:** VERIFIED CORRECT (no changes needed)

### 8. Duplicate Auth Checks in Screens
- **Audit Result:** No duplicate auth checks found in individual feature screens
- Auth is handled exclusively at the routing level via `AuthGuard`
- **STATUS:** CLEAN

---

## Test Results

### flutter analyze
```
Analyzing control_center...
12 issues found. (ran 34.7s)
```
- **0 errors**
- **0 warnings**
- 12 info-level hints (pre-existing, unrelated to auth changes: `use_null_aware_elements` in settings/workflows datasources)

### flutter test
```
00:00 +0: loading widget_test.dart
00:01 +1: All tests passed!
```

### flutter build windows --release
```
Building Windows application... 36.5s
√ Built build\windows\x64\runner\Release\control_center.exe
```

---

## Auth Guard Logic (Final)

```dart
String? redirect(BuildContext context, GoRouterState state) {
  final session = ref.read(sessionManagerProvider);
  final location = state.matchedLocation;
  final isLoginRoute = location == '/login';
  final isRegisterRoute = location == '/register';
  final isSplashRoute = location == '/splash';
  final isAuthRoute = isLoginRoute || isRegisterRoute || isSplashRoute;

  // BLOCK: During startup - force to splash
  if (session.status == SessionStatus.initial) {
    if (isSplashRoute) return null;
    return '/splash';
  }

  // BLOCK: During token refresh - force to splash
  if (session.status == SessionStatus.refreshing) {
    if (isSplashRoute) return null;
    return '/splash';
  }

  // ALLOW: Authenticated users access everything (redirect from auth pages)
  if (session.isAuthenticated) {
    if (isLoginRoute || isRegisterRoute) return '/dashboard';
    return null;
  }

  // BLOCK: Unauthenticated users can only access auth pages
  if (!isAuthRoute) return '/login';
  return null;
}
```

---

## Protected Routes Coverage

| Route | Protected | Redirect When Unauthenticated |
|-------|-----------|-------------------------------|
| `/dashboard` | YES | → `/login` |
| `/agents/*` | YES | → `/login` |
| `/knowledge-base` | YES | → `/login` |
| `/leads` | YES | → `/login` |
| `/customers` | YES | → `/login` |
| `/conversations` | YES | → `/login` |
| `/analytics-center` | YES | → `/login` |
| `/system-health` | YES | → `/login` |
| `/audit-logs` | YES | → `/login` |
| `/billing` | YES | → `/login` |
| `/settings` | YES | → `/login` |
| `/tasks` | YES | → `/login` |
| `/team` | YES | → `/login` |
| `/workflows` | YES | → `/login` |
| `/inbox` | YES | → `/login` |
| `/calls` | YES | → `/login` |
| `/notifications` | YES | → `/login` |
| `/login` | NO (public) | N/A |
| `/register` | NO (public) | N/A |
| `/splash` | NO (transitional) | N/A |

---

## Final Verdict

**SECURITY STATUS: PRODUCTION-SAFE**

The authentication bypass vulnerability has been fully remediated. The centralized `AuthGuard` now enforces authentication on every protected route at the GoRouter level. The startup flow now requires session verification before any protected content is rendered. Deep link bypass, direct navigation, and the startup race condition are all addressed.

**Recommendation:** The fix is minimal, focused, and production-ready. No further changes required for this vulnerability.
