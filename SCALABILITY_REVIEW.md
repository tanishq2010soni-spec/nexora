# SCALABILITY_REVIEW.md

**Project:** Nexora Control Center
**Date:** 2026-06-19 (Architecture Improvement Phase)
**Version:** 1.0
**Status:** Pre-Implementation Review

---

## 1. Executive Summary

This document identifies future bottlenecks, architectural weaknesses, areas likely to require refactoring, and missing enterprise modules. It provides recommendations to address each finding.

---

## 2. Future Bottlenecks

### 2.1 Search Index Scaling

**Finding:** In-memory search index will not scale beyond ~10,000 entries on desktop.

**Impact:** As agents, leads, customers, and documents grow, search will degrade.

**Recommendation:**
- Implement pagination in search results (limit 50 per query)
- Add debounced search (300ms) to avoid excessive re-indexing
- Consider SQLite FTS5 for desktop if index exceeds 50,000 entries
- For now, index only: name, email, phone, filename (not full content)

### 2.2 Provider Invalidation Cascade

**Finding:** Workspace switching invalidates ALL providers, causing a thundering herd of API calls.

**Impact:** On workspace switch, 20+ providers fire simultaneously.

**Recommendation:**
- Lazy loading: only invalidate providers that are currently watched
- Stale-while-revalidate: show old data while fetching new
- Batch API calls where possible (dashboard aggregates)
- Add request deduplication in ApiClient

### 2.3 Token Refresh Storms

**Finding:** Multiple concurrent requests hitting 401 simultaneously each trigger refresh attempts.

**Impact:** N requests = N refresh attempts (only 1 should succeed).

**Recommendation:**
- Already addressed: Completer-based queuing in SessionManager
- Additionally: AuthInterceptor should queue pending requests during refresh
- Use a single refresh attempt with request replay

### 2.4 Table Performance at Scale

**Finding:** DataTableWidget renders all rows in DOM.

**Impact:** Tables with 1000+ rows will cause frame drops.

**Recommendation:**
- Implement virtual scrolling (only render visible rows)
- Lazy load additional pages on scroll
- Add server-side pagination (already supported: limit/offset)
- Max display: 200 rows per page

### 2.5 Memory on Desktop

**Finding:** All feature providers keep state in memory indefinitely.

**Impact:** Long-running desktop sessions may accumulate memory.

**Recommendation:**
- Dispose unused provider state after 5 minutes of inactivity
- Cache eviction for search index
- Periodic garbage collection hint for Dart VM

---

## 3. Architectural Weaknesses

### 3.1 No Offline Support

**Finding:** All data requires API connectivity. No local cache.

**Impact:** Application is unusable without network.

**Recommendation:**
- Phase 2: Add Hive or Isar for local caching
- Cache critical data: agents, business profile, workspace list
- Sync strategy: pull on app resume, push on mutation
- Show cached data with "Offline" banner

### 3.2 No Real-Time Updates

**Finding:** All data is fetched via polling or manual refresh.

**Impact:** Users miss live conversation updates, new leads, system alerts.

**Recommendation:**
- Phase 2: Add WebSocket client for real-time events
- Events: new_message, lead_captured, agent_status_change, alert
- Fallback: polling every 15s for critical data (health, notifications)

### 3.3 No Undo/Redo

**Finding:** Desktop keyboard shortcuts include Cmd+Z but no undo stack exists.

**Impact:** Users expect undo after destructive actions.

**Recommendation:**
- Implement command pattern for mutations
- Store last N actions (max 20)
- Support undo for: delete, status change, bulk actions
- Undo window: 30 seconds

### 3.4 Feature Module Isolation Too Strict

**Finding:** Feature modules cannot import each other.

**Impact:** Some cross-feature data is needed (e.g., agent list in search, lead count on dashboard).

**Recommendation:**
- Allow shared domain models via a shared/ package
- Or: use provider dependency injection to share data
- Dashboard aggregates from multiple repositories via a DashboardAggregator

### 3.5 No Error Recovery UI

**Finding:** ErrorView shows error but no structured recovery path.

**Impact:** Users see error messages but don't know next steps.

**Recommendation:**
- Add recovery actions per error type
- Network: "Check connection" + retry button
- Auth: "Session expired" + login redirect
- Server: "Service unavailable" + status page link
- Validation: Highlight specific fields

---

## 4. Areas Likely to Require Refactoring

### 4.1 Agent Center Growth

**Finding:** WhatsApp and Calling agents may diverge significantly.

**Refactoring Expected:**
- WhatsApp: webhook management, template messages, business verification
- Calling: Twilio integration, recording playback, voice selection
- Each sub-module may need its own data layer

**Mitigation:** Already addressed with sub-module structure. Monitor for DRY violations.

### 4.2 AI Models Multi-Provider

**Finding:** Ollama is the only current provider. OpenAI/Claude/Gemini will require different API patterns.

**Refactoring Expected:**
- Each provider has different: auth, API format, rate limits, pricing
- ModelHealth check differs per provider
- Token counting differs per provider

**Mitigation:** Use strategy pattern. Each provider implements AiModelProviderInterface.

### 4.3 Notification System Growth

**Finding:** In-app notifications will grow to include email, push, webhooks.

**Refactoring Expected:**
- Notification channel abstraction
- Delivery status tracking
- User preference per channel per event type

**Mitigation:** Design NotificationChannel interface now, implement InAppChannel first.

### 4.4 Analytics Dashboard

**Finding:** Analytics will require aggregated data, charts, date ranges, exports.

**Refactoring Expected:**
- Chart library integration (fl_chart or syncfusion)
- Date range picker
- Data aggregation queries
- PDF/CSV export

**Mitigation:** Keep analytics datasource separate. Design for chart-ready data format.

### 4.5 Billing Integration

**Finding:** Billing will require Stripe/payment integration.

**Refactoring Expected:**
- Payment provider abstraction
- Invoice generation
- Subscription management
- Usage-based billing

**Mitigation:** Design billing module interface now, implement stubs first.

---

## 5. Missing Enterprise Modules

### 5.1 RBAC (Role-Based Access Control)

**Current:** Simple role field (admin/member) on User model.

**Needed:**
- Granular permissions (agent.create, lead.delete, billing.view)
- Role definitions (Owner, Admin, Manager, Viewer)
- Permission checks in UI (hide/disable buttons)
- Permission checks in API (backend enforcement)

**Recommendation:** Add permissions model in Phase 2.

### 5.2 Audit Logging UI

**Current:** Backend has AuditLog model. No frontend UI.

**Needed:**
- Audit log list with filters (action, user, date, resource)
- Audit log detail view
- Export audit logs as CSV
- Real-time audit log stream

**Recommendation:** Implement in Phase 3.

### 5.3 API Key Management

**Current:** No API key support.

**Needed:**
- Generate API keys for programmatic access
- Key rotation
- Rate limiting per key
- Key scoping (read-only, write, admin)

**Recommendation:** Implement in Phase 3.

### 5.4 Multi-Tenancy Improvements

**Current:** Single org per user via JWT claim.

**Needed:**
- Multiple organizations per user
- Organization switching (like workspace)
- Cross-org data isolation enforcement
- Org-level billing

**Recommendation:** Design now, implement in Phase 3.

### 5.5 Webhook Management

**Current:** No webhook support.

**Needed:**
- Configure webhooks for events (lead_created, message_received)
- Webhook delivery logs
- Retry failed deliveries
- Webhook security (HMAC signing)

**Recommendation:** Implement in Phase 3.

### 5.6 Import/Export

**Current:** CSV export only (planned).

**Needed:**
- Import leads from CSV
- Import customers from CSV
- Export leads as CSV/PDF
- Export customers as CSV/PDF
- Import agents from template
- Bulk operations

**Recommendation:** Implement in Phase 2.

### 5.7 Version Control for Prompts

**Current:** System prompt is a single text field.

**Needed:**
- Prompt version history
- Diff between versions
- Rollback to previous version
- A/B testing prompts
- Prompt performance metrics

**Recommendation:** Implement in Phase 2.

---

## 6. Performance Recommendations

### 6.1 Lazy Loading

- Load feature data only when navigating to feature
- Preload next likely feature (based on usage patterns)
- Skeleton screens during load

### 6.2 Caching Strategy

| Data | Cache Duration | Refresh Trigger |
|------|---------------|-----------------|
| User profile | Until logout | Manual |
| Workspace list | 5 minutes | Pull-to-refresh |
| Agents | 2 minutes | Pull-to-refresh |
| Leads | 1 minute | Pull-to-refresh |
| Dashboard stats | 30 seconds | Auto-poll |
| Health status | 15 seconds | Auto-poll |
| Notifications | 30 seconds | Auto-poll |

### 6.3 Image Optimization

- Agent avatars: cache with fade-in transition
- Document thumbnails: lazy load with placeholder
- Dashboard charts: cache rendered widgets

### 6.4 Bundle Size

- Tree-shake unused Lucide icons
- Minimize Google Fonts subsets
- Split code by feature (deferred imports)

---

## 7. Security Recommendations

### 7.1 Token Security

- Access token: in-memory only (Riverpod state)
- Refresh token: flutter_secure_storage (OS keychain)
- Never store tokens in SharedPreferences or files
- Clear tokens on logout (including OS keychain)

### 7.2 Input Validation

- Validate all user inputs client-side before API call
- Sanitize search queries (no SQL injection via search)
- Validate file uploads (type, size, content)

### 7.3 API Security

- All API calls over HTTPS (except localhost dev)
- JWT expiry enforced client-side
- Auto-refresh before expiry
- Forced logout on 401

### 7.4 Data Privacy

- No sensitive data in logs
- No tokens in error reports
- PII masking in analytics
- Secure disposal of sensitive data

---

## 8. Testing Strategy Recommendations

### 8.1 Unit Test Coverage Target

| Module | Target Coverage |
|--------|----------------|
| core/auth | 95% |
| core/network | 90% |
| features/auth | 90% |
| features/dashboard | 85% |
| features/agent_center | 85% |
| All other features | 80% |

### 8.2 Widget Test Coverage

- All shared widgets: 100%
- All screens: at least smoke test
- Form validation: 100%
- Error states: 100%

### 8.3 Integration Test Coverage

- Auth flow: login -> dashboard -> logout
- Agent CRUD: create -> edit -> delete
- Lead flow: list -> detail -> edit
- Knowledge base: upload -> list -> delete

---

## 9. Migration Strategy

### 9.1 Backend API Versioning

- Current: /api/v1/
- When breaking changes needed: /api/v2/
- Client supports both v1 and v2 during transition
- Deprecation warnings in logs

### 9.2 Schema Migration

- Freezed models must be backward-compatible
- Use @JsonKey(alwaysSend: true) for new fields
- Default values for all new optional fields
- Test with old API responses

---

## 10. Summary of Recommendations

| Priority | Recommendation | Phase |
|----------|---------------|-------|
| High | Virtual scrolling for tables | 2 |
| High | Offline cache (Hive/Isar) | 2 |
| High | WebSocket for real-time | 2 |
| High | RBAC permissions | 2 |
| Medium | Undo/redo command pattern | 2 |
| Medium | Provider lazy invalidation | 1 |
| Medium | Request deduplication | 1 |
| Medium | CSV import/export | 2 |
| Medium | Prompt version control | 2 |
| Medium | Audit log UI | 3 |
| Low | API key management | 3 |
| Low | Webhook management | 3 |
| Low | Multi-org support | 3 |
| Low | Billing integration | 3 |

---

**Awaiting approval before proceeding to implementation.**
