import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'providers/auth_provider.dart';
import 'providers/organization_provider.dart';
import 'providers/call_provider.dart';
import 'providers/campaign_provider.dart';
import 'providers/lead_provider.dart';
import 'providers/contact_provider.dart';
import 'providers/appointment_provider.dart';
import 'providers/script_provider.dart';
import 'providers/recording_provider.dart';
import 'providers/knowledge_provider.dart';
import 'providers/analytics_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/permission_provider.dart';
import 'providers/log_provider.dart';
import 'providers/plugin_provider.dart';
import 'providers/monitoring_provider.dart';

class CallingAgentApp extends StatelessWidget {
  const CallingAgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OrganizationProvider()),
        ChangeNotifierProvider(create: (_) => CallProvider()),
        ChangeNotifierProvider(create: (_) => CampaignProvider()),
        ChangeNotifierProvider(create: (_) => LeadProvider()),
        ChangeNotifierProvider(create: (_) => ContactProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => ScriptProvider()),
        ChangeNotifierProvider(create: (_) => RecordingProvider()),
        ChangeNotifierProvider(create: (_) => KnowledgeProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => PermissionProvider()),
        ChangeNotifierProvider(create: (_) => LogProvider()),
        ChangeNotifierProvider(create: (_) => PluginProvider()),
        ChangeNotifierProvider(create: (_) => MonitoringProvider()),
      ],
      child: MaterialApp.router(
        title: 'Calling Agent',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: appRouter,
      ),
    );
  }
}
