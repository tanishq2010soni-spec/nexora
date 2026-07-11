import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';
import '../layouts/app_shell.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/inbox/inbox_screen.dart';
import '../../features/crm/crm_screen.dart';
import '../../features/knowledge/knowledge_screen.dart';
import '../../features/workflows/workflows_screen.dart';
import '../../features/campaigns/campaigns_screen.dart';
import '../../features/analytics/analytics_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/permissions/permissions_screen.dart';
import '../../features/models/models_screen.dart';
import '../../features/logs/logs_screen.dart';
import '../../features/health/health_screen.dart';
import '../../features/plugins/plugins_screen.dart';

GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: RouteNames.dashboard,
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: RouteNames.dashboard,
          name: 'dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: RouteNames.inbox,
          name: 'inbox',
          builder: (context, state) => const InboxScreen(),
        ),
        GoRoute(
          path: RouteNames.crm,
          name: 'crm',
          builder: (context, state) => const CrmScreen(),
        ),
        GoRoute(
          path: RouteNames.knowledge,
          name: 'knowledge',
          builder: (context, state) => const KnowledgeScreen(),
        ),
        GoRoute(
          path: RouteNames.workflows,
          name: 'workflows',
          builder: (context, state) => const WorkflowsScreen(),
        ),
        GoRoute(
          path: RouteNames.campaigns,
          name: 'campaigns',
          builder: (context, state) => const CampaignsScreen(),
        ),
        GoRoute(
          path: RouteNames.analytics,
          name: 'analytics',
          builder: (context, state) => const AnalyticsScreen(),
        ),
        GoRoute(
          path: RouteNames.settings,
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: RouteNames.permissions,
          name: 'permissions',
          builder: (context, state) => const PermissionsScreen(),
        ),
        GoRoute(
          path: RouteNames.models,
          name: 'models',
          builder: (context, state) => const ModelsScreen(),
        ),
        GoRoute(
          path: RouteNames.logs,
          name: 'logs',
          builder: (context, state) => const LogsScreen(),
        ),
        GoRoute(
          path: RouteNames.health,
          name: 'health',
          builder: (context, state) => const HealthScreen(),
        ),
        GoRoute(
          path: RouteNames.plugins,
          name: 'plugins',
          builder: (context, state) => const PluginsScreen(),
        ),
      ],
    ),
  ],
);
