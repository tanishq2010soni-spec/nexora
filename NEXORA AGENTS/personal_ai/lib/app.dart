import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'services/api_service.dart';
import 'services/websocket_service.dart';
import 'providers/conversation_provider.dart';
import 'providers/memory_provider.dart';
import 'providers/task_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/permission_provider.dart';
import 'providers/health_provider.dart';
import 'providers/character_provider.dart';

class PersonalAIApp extends StatelessWidget {
  PersonalAIApp({super.key});

  final ApiService _apiService = ApiService();

  late final WebSocketService _wsService = WebSocketService();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ConversationProvider(apiService: _apiService, wsService: _wsService),
        ),
        ChangeNotifierProvider(
          create: (_) => MemoryProvider(apiService: _apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskProvider(apiService: _apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(apiService: _apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => PermissionProvider(apiService: _apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => HealthProvider(apiService: _apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => CharacterProvider(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Personal AI',
        theme: AppTheme.buildDarkTheme(),
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
