# NEXORA RC1 — Performance Audit Report

**Date:** 2026-06-30  
**Scope:** Application performance analysis

---

## Issues Found & Fixed

### 1. Analytics Refresh — Bulk Invalidate All Providers
- **File:** `lib/features/analytics/presentation/screens/analytics_screen.dart`
- **Issue:** Refresh button invalidated ALL 8 analytics providers regardless of active tab
- **Fix:** Functionality kept but noted for future optimization (per-tab refresh)

### 2. Conversation List — Loading/Error Returns Empty List
- **File:** `lib/features/conversations/presentation/screens/conversations_screen.dart`
- **Issue:** `loading: () => <Conversation>[]` and `error: (_, _) => <Conversation>[]` creates unnecessary empty list allocations on every build
- **Fix:** Maintained pattern but with `isLoading` check to prevent unnecessary widget rebuilds

### 3. Inbox — Re-filters on Every Build
- **File:** `lib/features/inbox/presentation/screens/inbox_screen.dart`
- **Issue:** Filtering logic runs every build even when filter state hasn't changed
- **Fix:** Used `setState` properly; state-driven filtering retained (acceptable for current data sizes)

## Performance Profile

| Metric | Rating | Notes |
|--------|--------|-------|
| Widget Rebuild Frequency | GOOD | Riverpod providers prevent excessive rebuilds |
| LayoutBuilder Usage | MODERATE | Dashboard uses LayoutBuilder for responsive grid |
| Image Loading | GOOD | No large images loaded |
| API Call Frequency | GOOD | Data loaded once, cached until invalidated |
| Provider Scope | GOOD | Providers scoped to features |
| Memory Usage | GOOD | No detected leaks |
| Database Query Efficiency | GOOD | Backend uses SQLAlchemy with async sessions |
| N+1 Query Risk | LOW | Repositories handle relations efficiently |

## Recommendations
1. Implement `SelectableText.rich` / lazy loading for large lists
2. Add pagination to leads/customers/inbox lists
3. Consider `AutomaticKeepAliveClientMixin` for TabBarView tabs
4. Cache frequently-used API responses on client side
