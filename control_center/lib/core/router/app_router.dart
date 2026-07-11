import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_guard.dart';
import '../auth/session_manager.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/agent_center/whatsapp_agents/presentation/screens/whatsapp_agents_screen.dart';
import '../../features/agent_center/calling_agents/presentation/screens/calling_agents_screen.dart';
import '../../features/agent_center/agent_templates/presentation/screens/templates_screen.dart';
import '../../features/agent_center/agent_analytics/presentation/screens/agent_analytics_screen.dart';
import '../../features/agent_center/agent_settings/presentation/screens/agent_settings_screen.dart';
import '../../features/knowledge_base/presentation/screens/knowledge_base_screen.dart';
import '../../features/conversations/presentation/screens/conversations_screen.dart';
import '../../features/leads/presentation/screens/leads_screen.dart';
import '../../features/customers/presentation/screens/customer_list_screen.dart';
import '../../features/tasks/presentation/screens/tasks_screen.dart';
import '../../features/team/presentation/screens/team_screen.dart';
import '../../features/billing/presentation/screens/billing_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/workflows/presentation/screens/workflows_screen.dart';
import '../../features/inbox/presentation/screens/inbox_screen.dart';
import '../../features/inbox/presentation/screens/inbox_detail_screen.dart';
import '../../features/calls/presentation/screens/calls_screen.dart';
import '../../features/calls/presentation/screens/call_detail_screen.dart';
import '../../features/calls/presentation/screens/call_queues_screen.dart';
import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/audit_logs/presentation/screens/audit_logs_screen.dart';
import '../../features/system_health/presentation/screens/system_health_screen.dart';
import '../../features/agent_management/presentation/screens/agent_management_screen.dart';
import '../../features/provider_management/presentation/screens/providers_screen.dart';
import '../../features/model_registry/presentation/screens/model_registry_screen.dart';
import '../../features/tool_registry/presentation/screens/tool_registry_screen.dart';
import '../../features/knowledge_sources/presentation/screens/knowledge_sources_screen.dart';
import '../../features/workflow_engine/presentation/screens/workflow_engine_screen.dart';
import '../../features/licensing/presentation/screens/licensing_screen.dart';
import '../../features/plugin_sdk/presentation/screens/plugins_screen.dart';
import '../../shared/layouts/app_shell.dart';
import 'route_names.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  ref.watch(sessionManagerProvider);
  final authGuard = AuthGuard(ref);

  return GoRouter(
    initialLocation: RouteNames.splash,
    redirect: authGuard.redirect,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.dashboard,
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: RouteNames.agents,
            name: 'agents',
            builder: (context, state) => const WhatsAppAgentsScreen(),
            routes: [
              GoRoute(
                path: 'whatsapp',
                name: 'whatsapp-agents',
                builder: (context, state) => const WhatsAppAgentsScreen(),
              ),
              GoRoute(
                path: 'whatsapp/create',
                name: 'whatsapp-agent-create',
                builder: (context, state) => const WhatsAppAgentsScreen(),
              ),
              GoRoute(
                path: 'whatsapp/:id',
                name: 'whatsapp-agent-detail',
                builder: (context, state) => const WhatsAppAgentsScreen(),
              ),
              GoRoute(
                path: 'calling',
                name: 'calling-agents',
                builder: (context, state) => const CallingAgentsScreen(),
              ),
              GoRoute(
                path: 'calling/create',
                name: 'calling-agent-create',
                builder: (context, state) => const CallingAgentsScreen(),
              ),
              GoRoute(
                path: 'calling/:id',
                name: 'calling-agent-detail',
                builder: (context, state) => const CallingAgentsScreen(),
              ),
              GoRoute(
                path: 'templates',
                name: 'agent-templates',
                builder: (context, state) => const TemplatesScreen(),
              ),
              GoRoute(
                path: 'analytics',
                name: 'agent-analytics',
                builder: (context, state) => const AgentAnalyticsScreen(),
              ),
              GoRoute(
                path: 'settings/:id',
                name: 'agent-settings',
                builder: (context, state) {
                  final agentId = state.pathParameters['id']!;
                  return AgentSettingsScreen(agentId: agentId);
                },
              ),
            ],
          ),
          GoRoute(
            path: RouteNames.knowledgeBase,
            name: 'knowledge-base',
            builder: (context, state) => const KnowledgeBaseScreen(),
          ),
          GoRoute(
            path: RouteNames.leads,
            name: 'leads',
            builder: (context, state) => const LeadsScreen(),
          ),
          GoRoute(
            path: RouteNames.customers,
            name: 'customers',
            builder: (context, state) => const CustomerListScreen(),
          ),
          GoRoute(
            path: RouteNames.conversations,
            name: 'conversations',
            builder: (context, state) => const ConversationsScreen(),
          ),
          GoRoute(
            path: RouteNames.analyticsCenter,
            name: 'analytics-center',
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: RouteNames.systemHealth,
            name: 'system-health',
            builder: (context, state) => const SystemHealthScreen(),
          ),
          GoRoute(
            path: RouteNames.auditLogs,
            name: 'audit-logs',
            builder: (context, state) => const AuditLogsScreen(),
          ),
          GoRoute(
            path: RouteNames.tasks,
            name: 'tasks',
            builder: (context, state) => const TasksScreen(),
          ),
          GoRoute(
            path: RouteNames.team,
            name: 'team',
            builder: (context, state) => const TeamScreen(),
          ),
          GoRoute(
            path: RouteNames.billing,
            name: 'billing',
            builder: (context, state) => const BillingScreen(),
          ),
          GoRoute(
            path: RouteNames.notifications,
            name: 'notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: RouteNames.settings,
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: RouteNames.workflows,
            name: 'workflows',
            builder: (context, state) => const WorkflowsScreen(),
          ),
          GoRoute(
            path: RouteNames.inbox,
            name: 'inbox',
            builder: (context, state) => const InboxScreen(),
          ),
          GoRoute(
            path: RouteNames.inboxDetail,
            name: 'inbox-detail',
            builder: (context, state) {
              final convId = state.pathParameters['id']!;
              return InboxDetailScreen(conversationId: convId);
            },
          ),
          GoRoute(
            path: RouteNames.calls,
            name: 'calls',
            builder: (context, state) => const CallsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                name: 'call-detail',
                builder: (context, state) {
                  final callId = state.pathParameters['id']!;
                  return CallDetailScreen(callId: callId);
                },
              ),
              GoRoute(
                path: 'queues',
                name: 'call-queues',
                builder: (context, state) => const CallQueuesScreen(),
              ),
            ],
          ),
          // Phase 2: Enterprise AI Platform routes
          GoRoute(
            path: RouteNames.agentManagement,
            name: 'agent-management',
            builder: (context, state) => const AgentManagementScreen(agentId: ''),
          ),
          GoRoute(
            path: RouteNames.providers,
            name: 'providers',
            builder: (context, state) => const ProvidersScreen(),
          ),
          GoRoute(
            path: RouteNames.modelRegistry,
            name: 'model-registry',
            builder: (context, state) => const ModelRegistryScreen(),
          ),
          GoRoute(
            path: RouteNames.toolRegistry,
            name: 'tool-registry',
            builder: (context, state) => const ToolRegistryScreen(),
          ),
          GoRoute(
            path: RouteNames.knowledgeSources,
            name: 'knowledge-sources',
            builder: (context, state) => const KnowledgeSourcesScreen(knowledgeBaseId: ''),
          ),
          GoRoute(
            path: RouteNames.workflowEngine,
            name: 'workflow-engine',
            builder: (context, state) => const WorkflowEngineScreen(),
          ),
          GoRoute(
            path: RouteNames.licensing,
            name: 'licensing',
            builder: (context, state) => const LicensingScreen(orgId: ''),
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
});
