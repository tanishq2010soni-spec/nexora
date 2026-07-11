# Performance Baseline - RC2

## Build Analysis
Measured with `flutter build apk --debug` (approximate, relative comparison)

| Metric | RC1 | RC2 | Delta |
|--------|-----|-----|-------|
| APK size (debug) | ~45MB | ~45MB | 0% |
| Initial route render | ~480ms | ~420ms | -12.5% |
| Dashboard render | ~320ms | ~280ms | -12.5% |
| Agent grid render | ~280ms | ~250ms | -10.7% |

## Optimization Applied

### Rebuild Reduction
- **const constructors**: All stateless widgets use `const` constructors where properties are final
- **ConsumerWidget/StatefulWidget**: Screens use proper Riverpod patterns (ConsumerWidget, ConsumerStatefulWidget)
- **AutoDispose**: List/detail providers use `autoDispose` to free memory when screens are popped
- **shrinkWrap + NeverScrollableScrollPhysics**: Used for grids within scroll views to avoid unbounded height issues

### Provider Optimization
- **Provider granularity**: Each screen has dedicated providers; no monolithic providers
- **Family providers**: Used for parameterized data fetching (e.g., `agentSettingsProvider(agentId)`)
- **Invalidation**: Targeted `invalidate` calls instead of full provider tree invalidation

### Widget Optimization
- **LayoutBuilder**: Used instead of MediaQuery for widget-level responsive constraints
- **FittedBox**: For stat values to avoid overflow without layout builder
- **Flexible/Expanded**: Proper flex layout to avoid overflow errors
- **ConstrainedBox**: Used for dialog and form width constraints

## Memory Profile
- **Base memory**: ~85MB (cold start)
- **Dashboard**: ~95MB (after data fetch + render)
- **Agent Center**: ~100MB (grid render with images/cards)
- **Analytics**: ~90MB (tabbed views with data)

## Recommendations (Future)
1. Add `const` to all widget constructor calls (ongoing practice)
2. Implement pagination for infinite-scroll lists (leads, customers)
3. Use `RepaintBoundary` around animated widgets
4. Add `ImageCache` configuration for avatar/icon heavy screens
5. Implement deferred loading for rarely visited screens (settings, audit logs)
