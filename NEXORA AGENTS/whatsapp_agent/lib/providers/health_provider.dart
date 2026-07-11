import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HealthProvider extends ChangeNotifier {
  final ApiService _api;

  Map<String, dynamic>? _health;
  bool _isLoading = false;
  String? _error;
  Timer? _pollTimer;

  HealthProvider(this._api);

  Map<String, dynamic>? get health => _health;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isHealthy => _health?['status'] == 'healthy';
  List<dynamic> get accounts => _health?['whatsapp_accounts'] as List<dynamic>? ?? [];
  String? get databaseStatus => _health?['database'] as String?;
  String? get aiRuntimeStatus => _health?['ai_runtime'] as String?;
  double? get uptimeHours => (_health?['uptime_seconds'] as num?)?.toDouble() != null
      ? (_health!['uptime_seconds'] as num).toDouble() / 3600
      : null;
  List<dynamic> get recentErrors => _health?['recent_errors'] as List<dynamic>? ?? [];

  Future<void> loadHealth() async {
    _isLoading = true;
    notifyListeners();

    final result = await _api.getHealth();
    if (result.isSuccess) {
      _health = result.data;
      _error = null;
    } else {
      _error = result.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  void startPolling({Duration interval = const Duration(seconds: 30)}) {
    stopPolling();
    loadHealth();
    _pollTimer = Timer.periodic(interval, (_) => loadHealth());
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
