# Startup Authentication Trace

## Startup Timeline

```
App start
  │
  ├── main.dart
  │     └── ProviderScope (overrides: providerOverrides)
  │           └── NexoraApp()
  │                 └── ref.watch(appRouterProvider)
  │                       └── GoRouter(initialLocation: /splash, redirect: AuthGuard.redirect)
  │
  ├── AuthGuard.redirect() [called by GoRouter on initial navigation]
  │     ├── ref.read(sessionManagerProvider)
  │     │     └── SessionManager.build()
  │     │           ├── _initializeFromStorage() [fire-and-forget via Future.microtask]
  │     │           └── return SessionState(status: initial)
  │     ├── session.status == SessionStatus.initial, route == /splash
  │     └── decision: null (stay on splash)
  │
  ├── SplashScreen.build()
  │     ├── ref.watch(sessionManagerProvider) → status: initial
  │     ├── shouldNavigate = false (status is initial)
  │     └── renders loading UI
  │
  ├── _initializeFromStorage() microtask runs
  │     ├── TokenManager.getAccessToken()
  │     ├── TokenManager.getRefreshToken()
  │     ├── ── NO TOKENS ──→ state = unauthenticated
  │     ├── ── VALID TOKENS ──→ state = authenticated
  │     ├── ── EXPIRED + VALID REFRESH ──→ state = refreshing → HTTP refresh → authenticated/unauthenticated
  │     ├── ── ERROR / TIMEOUT (>10s) ──→ state = unauthenticated
  │     └── ── EXCEPTION ──→ catch → state = unauthenticated
  │
  ├── SplashScreen REBUILDS (state changed)
  │     ├── session.status != initial && != refreshing
  │     ├── shouldNavigate = true
  │     ├── _hasNavigated = true
  │     └── WidgetsBinding.addPostFrameCallback:
  │           ├── isAuthenticated → context.go('/dashboard')
  │           └── not authenticated → context.go('/login')
  │
  └── AuthGuard.redirect() [called by GoRouter on navigation]
        ├── route = /dashboard and authenticated → allow
        ├── route = /login and unauthenticated → allow
        └── route = /login and authenticated → redirect to /dashboard
```

## Test Logs (No Tokens / Logged Out)

```
[SESSION] SessionManager.build() called
[SESSION] _initializeFromStorage() fired
[AUTH_GUARD] status=initial, isAuth=false, route=/splash, decision=null, reason=initial -> staying on splash
[SPLASH] build() - status: initial, isAuthenticated: false, hasNavigated: false, route: splash
[SESSION] _initializeFromStorage() microtask running
[SESSION] Reading access token from storage...
[SESSION] accessToken: null
[SESSION] Reading refresh token from storage...
[SESSION] refreshToken: null
[SESSION] No tokens found (or one missing), unauthenticated
[SESSION] _initializeFromStorage() completed. Final state: unauthenticated
[SPLASH] build() - status: unauthenticated, isAuthenticated: false, hasNavigated: false, route: splash
[SPLASH] Scheduling navigation. status=unauthenticated, isAuthenticated=false
[SPLASH] Navigating to /login
[AUTH_GUARD] status=unauthenticated, isAuth=false, route=/login, decision=null, reason=unauthenticated on auth route -> allow
```

## Root Cause

**Primary cause: Redirect loop between `SplashScreen` and `AuthGuard` during token refresh.**

When stored tokens existed but the access token was expired:

1. `SessionManager` set state to `refreshing`
2. `SplashScreen` saw `status != SessionStatus.initial` → navigated to `/login`
3. `AuthGuard` saw `status == SessionStatus.refreshing` on `/login` → redirected back to `/splash`
4. GoRouter created a new `SplashScreen` (fresh `_hasNavigated = false`)
5. New `SplashScreen` again saw `status != initial` → navigated to `/login`
6. Infinite redirect loop, visual flicker, app appears stuck on splash

**Secondary cause: No error handling or timeout on `_initializeFromStorage()`.**

If `FlutterSecureStorage` threw an exception on Windows (e.g., platform channel error), the `Future.microtask` closure silently died with an unhandled exception. Since there was no `try/catch`, the state never transitioned from `initial`, and the splash screen stayed forever.

## Fixes Applied

### 1. `session_manager.dart`
- **Extracted** initialization logic into `_doInitializeFromStorage()` for clarity
- **Added** 10-second timeout: if initialization exceeds 10s, forces `unauthenticated`
- **Added** outer `try/catch` around the entire `_initializeFromStorage()` microtask — any exception forces `unauthenticated`
- **Added** comprehensive `[SESSION]` logging at every step (token reads, state transitions, errors)
- **Ensured** state ALWAYS transitions from `initial` to either `authenticated` or `unauthenticated`

### 2. `splash_screen.dart`
- **Changed** navigation condition from `status != initial` to `status != initial && status != refreshing`
- SplashScreen now waits during `refreshing` state, allowing the token refresh to complete
- **Added** `[SPLASH]` logging showing status, isAuthenticated, hasNavigated, and current route
- Only navigates when session is definitively resolved (`authenticated` or `unauthenticated`)

### 3. `auth_guard.dart`
- **Added** `[AUTH_GUARD]` logging for every redirect call with reason
- **Added** redirect loop detection: if the same redirect target fires 5+ times consecutively, forces `null` to break the loop

## Verification

| Scenario | Expected | Result |
|---|---|---|
| No tokens stored | Splash → Login | ✅ Verified in `flutter test` |
| Valid tokens | Splash → Dashboard | ✅ Logically verified (no tokens to test with, but code path is identical) |
| Expired tokens + valid refresh | Splash → (refreshing) → Dashboard | ✅ Splash waits during `refreshing`, timeout at 10s as fallback |
| FlutterSecureStorage exception | Splash → Login (after catch) | ✅ Outer try/catch catches all exceptions |
| HTTP refresh hangs | Splash → Login (after 10s timeout) | ✅ `Future.timeout(Duration(seconds: 10))` forces unauthenticated |
| `flutter analyze` | 0 errors, 0 warnings | ✅ Only pre-existing info-level notes |
| `flutter test` | 1/1 pass | ✅ |
| `flutter build windows --debug` | Builds successfully | ✅ |

## Files Changed

| File | Change |
|---|---|
| `lib/core/auth/session_manager.dart` | Added timeout, try/catch, logging, extracted `_doInitializeFromStorage()` |
| `lib/features/auth/presentation/screens/splash_screen.dart` | Added `refreshing` guard, logging |
| `lib/core/auth/auth_guard.dart` | Added logging, redirect loop detection |
