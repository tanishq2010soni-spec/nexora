import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../layouts/app_shell.dart';
import 'route_names.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/live_calls/live_calls_screen.dart';
import '../../features/call_queue/call_queue_screen.dart';
import '../../features/campaigns/campaigns_screen.dart';
import '../../features/leads/leads_screen.dart';
import '../../features/crm/crm_screen.dart';
import '../../features/knowledge/knowledge_screen.dart';
import '../../features/analytics/analytics_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/permissions/permissions_screen.dart';
import '../../features/models/models_screen.dart';
import '../../features/logs/logs_screen.dart';
import '../../features/health/health_screen.dart';
import '../../features/plugins/plugins_screen.dart';
import '../../features/recordings/recordings_screen.dart';
import '../../features/scripts/scripts_screen.dart';
import '../../features/monitoring/monitoring_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return AppShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          name: RouteNames.dashboard,
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/live-calls',
          name: RouteNames.liveCalls,
          builder: (context, state) => const LiveCallsScreen(),
        ),
        GoRoute(
          path: '/call-queue',
          name: RouteNames.callQueue,
          builder: (context, state) => const CallQueueScreen(),
        ),
        GoRoute(
          path: '/campaigns',
          name: RouteNames.campaigns,
          builder: (context, state) => const CampaignsScreen(),
        ),
        GoRoute(
          path: '/leads',
          name: RouteNames.leads,
          builder: (context, state) => const LeadsScreen(),
        ),
        GoRoute(
          path: '/crm',
          name: RouteNames.crm,
          builder: (context, state) => const CrmScreen(),
        ),
        GoRoute(
          path: '/knowledge',
          name: RouteNames.knowledge,
          builder: (context, state) => const KnowledgeScreen(),
        ),
        GoRoute(
          path: '/analytics',
          name: RouteNames.analytics,
          builder: (context, state) => const AnalyticsScreen(),
        ),
        GoRoute(
          path: '/settings',
          name: RouteNames.settings,
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/permissions',
          name: RouteNames.permissions,
          builder: (context, state) => const PermissionsScreen(),
        ),
        GoRoute(
          path: '/models',
          name: RouteNames.models,
          builder: (context, state) => const ModelsScreen(),
        ),
        GoRoute(
          path: '/logs',
          name: RouteNames.logs,
          builder: (context, state) => const LogsScreen(),
        ),
        GoRoute(
          path: '/health',
          name: RouteNames.health,
          builder: (context, state) => const HealthScreen(),
        ),
        GoRoute(
          path: '/plugins',
          name: RouteNames.plugins,
          builder: (context, state) => const PluginsScreen(),
        ),
        GoRoute(
          path: '/recordings',
          name: RouteNames.recordings,
          builder: (context, state) => const RecordingsScreen(),
        ),
        GoRoute(
          path: '/scripts',
          name: RouteNames.scripts,
          builder: (context, state) => const ScriptsScreen(),
        ),
        GoRoute(
          path: '/monitoring',
          name: RouteNames.monitoring,
          builder: (context, state) => const MonitoringScreen(),
        ),
      ],
    ),
  ],
);
