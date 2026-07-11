import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();
  static final AppLogger _instance = AppLogger._();
  static AppLogger get instance => _instance;

  void info(String message) {
    debugPrint('[INFO] ${DateTime.now().toIso8601String()} - $message');
  }

  void error(String message, [Object? error]) {
    final suffix = error != null ? ' | Error: $error' : '';
    debugPrint('[ERROR] ${DateTime.now().toIso8601String()} - $message$suffix');
  }

  void debug(String message) {
    debugPrint('[DEBUG] ${DateTime.now().toIso8601String()} - $message');
  }

  void warning(String message) {
    debugPrint('[WARNING] ${DateTime.now().toIso8601String()} - $message');
  }
}
