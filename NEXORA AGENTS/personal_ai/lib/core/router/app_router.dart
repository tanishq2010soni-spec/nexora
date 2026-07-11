import 'package:go_router/go_router.dart';
import '../../presentation/layouts/app_shell.dart';
import '../../presentation/screens/dashboard_screen.dart';
import '../../presentation/screens/chat_screen.dart';
import '../../presentation/screens/chat_detail_screen.dart';
import '../../presentation/screens/memory_screen.dart';
import '../../presentation/screens/tasks_screen.dart';
import '../../presentation/screens/settings_screen.dart';
import '../../presentation/screens/permissions_screen.dart';
import '../../presentation/screens/plugins_screen.dart';
import '../../presentation/screens/character_screen.dart';
import 'route_names.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.dashboard,
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: RouteNames.dashboard,
          name: 'dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: RouteNames.chat,
          name: 'chat',
          builder: (context, state) => const ChatScreen(),
          routes: [
            GoRoute(
              path: ':id',
              name: 'chatDetail',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return ChatDetailScreen(conversationId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: RouteNames.memory,
          name: 'memory',
          builder: (context, state) => const MemoryScreen(),
        ),
        GoRoute(
          path: RouteNames.tasks,
          name: 'tasks',
          builder: (context, state) => const TasksScreen(),
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
          path: RouteNames.plugins,
          name: 'plugins',
          builder: (context, state) => const PluginsScreen(),
        ),
        GoRoute(
          path: RouteNames.character,
          name: 'character',
          builder: (context, state) => const CharacterScreen(),
        ),
      ],
    ),
  ],
);
