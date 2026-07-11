import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'services/api_service.dart';
import 'providers/auth_provider.dart';
import 'providers/organization_provider.dart';
import 'providers/conversation_provider.dart';
import 'providers/lead_provider.dart';
import 'providers/analytics_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/campaign_provider.dart';
import 'providers/workflow_provider.dart';
import 'providers/health_provider.dart';
import 'providers/permission_provider.dart';
import 'providers/log_provider.dart';
import 'providers/plugin_provider.dart';
import 'providers/inbox_provider.dart';
import 'providers/knowledge_provider.dart';

class WhatsAppAgentApp extends StatelessWidget {
  final ApiService apiService;

  const WhatsAppAgentApp({super.key, required this.apiService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(apiService)),
        ChangeNotifierProvider(create: (_) => OrganizationProvider(apiService)),
        ChangeNotifierProvider(create: (_) => ConversationProvider(apiService)),
        ChangeNotifierProvider(create: (_) => LeadProvider(apiService)),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider(apiService)),
        ChangeNotifierProvider(create: (_) => SettingsProvider(apiService)),
        ChangeNotifierProvider(create: (_) => CampaignProvider(apiService)),
        ChangeNotifierProvider(create: (_) => WorkflowProvider(apiService)),
        ChangeNotifierProvider(create: (_) => HealthProvider(apiService)),
        ChangeNotifierProvider(create: (_) => PermissionProvider(apiService)),
        ChangeNotifierProvider(create: (_) => LogProvider(apiService)),
        ChangeNotifierProvider(create: (_) => PluginProvider(apiService)),
        ChangeNotifierProvider(create: (_) => InboxProvider(apiService)),
        ChangeNotifierProvider(create: (_) => KnowledgeProvider(apiService)),
      ],
      child: MaterialApp.router(
        title: 'WhatsApp AI Agent',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        routerConfig: appRouter,
      ),
    );
  }
}
