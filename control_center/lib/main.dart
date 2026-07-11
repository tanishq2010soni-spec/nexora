import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/di/provider_overrides.dart';
import 'core/env/env.dart';
import 'core/logging/app_logger.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  AppLogger.instance.info('=== NEXORA APP STARTUP ===');
  AppLogger.instance.info('API Base URL: ${Env.apiBaseUrl}');
  AppLogger.instance.info('Environment Mode: ${Env.environment}');
  AppLogger.instance.info(
    'Debug Mode: const bool.fromEnvironment("dart.vm.product") == false',
  );

  runApp(ProviderScope(overrides: providerOverrides, child: const NexoraApp()));
}
