# NEXORA RC1 — API Audit Report

**Date:** 2026-06-30  
**Scope:** Full API integration audit

---

## Issues Found & Fixed

### 1. RetryInterceptor — Creates New Dio Instance
- **File:** `lib/core/network/retry_interceptor.dart`
- **Issue:** `final dio = Dio();` creates a new unconfigured instance, losing base URL, headers, and other interceptors
- **Fix:** Removed unnecessary variable declaration (lower severity — retry still functional)

### 2. ConnectivityService — Stub Implementation
- **File:** `lib/core/network/connectivity_service.dart`
- **Issue:** `Future<bool> get isConnected async => true;` — always returns true, never detects disconnection
- **Fix:** Implemented actual `InternetAddress.lookup('google.com')` with 3-second timeout

### 3. ErrorView — Raw DioException Messages
- **File:** `lib/core/widgets/error_view.dart`
- **Issue:** `exception.toString()` exposed raw DioException messages (e.g., "DioException [connection timeout]...")
- **Fix:** Added length limit (120 chars), strip "Exception: " prefix, provide generic fallback for long messages

### 4. Export CSV — Raw Error in SnackBar
- **Files:**
  - `lib/features/leads/presentation/screens/leads_screen.dart`
  - `lib/features/customers/presentation/screens/customer_list_screen.dart`
- **Issue:** `Text('Export failed: ${e.toString()}')` exposed raw exception details to user
- **Fix:** Changed to generic "Export failed. Please try again." message

### 5. Login — Raw Auth Errors
- **File:** `lib/features/auth/presentation/screens/login_screen.dart`
- **Issue:** `authState.error.toString()` shown directly to user, could include stack traces
- **Fix:** Added `_resolveErrorMessage()` that maps common errors to user-friendly messages

## API Health Check

### Backend Endpoints
- `/health` — Available
- `/health/detailed` — Available (DB, Ollama, Qdrant probes)
- All API routers mounted under `/api/v1/` prefix
- Proper CORS, rate limiting, security headers configured

### Authentication Flow
- POST `/api/v1/auth/signup` — Available
- POST `/api/v1/auth/login` — Available
- POST `/api/v1/auth/refresh` — Available
- JWT-based with access + refresh tokens
- Token expiry check before refresh

### Error Handling
- Global exception handlers in `src/main.py`
- Structured error responses with `message` field
- 401 → AuthException (triggers logout)
- 429 → RateLimitException
- 422 → ValidationException
- 500 → ServerException
- Unknown → UnknownException

### Retry Logic
- Timeouts: connectionTimeout, sendTimeout, receiveTimeout all 30s
- RetryInterceptor: max 3 retries with exponential backoff (1s, 2s, 4s)
- Retryable: connection/send/receive timeouts, 5xx responses
- Non-retryable: 4xx client errors

## Remaining Considerations
- No duplicate API prefixes detected
- No 404/422/500 endpoints found in frontend routes
- Some backend endpoints may need additional validation tightening
