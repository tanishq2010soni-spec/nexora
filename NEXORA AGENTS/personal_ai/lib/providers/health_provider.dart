import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/system_health.dart';
import '../services/api_service.dart';

class HealthProvider extends ChangeNotifier {
  final ApiService _apiService;

  SystemHealth? _health;
  bool _connected = false;
  bool _loading = false;
  String? _error;
  Timer? _pollTimer;

  HealthProvider({required ApiService apiService}) : _apiService = apiService;

  SystemHealth? get health => _health;
  bool get connected => _connected;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> checkHealth() async {
    _loading = true;
    notifyListeners();

    final result = await _apiService.getHealth();
    if (result.isSuccess) {
      _health = SystemHealth.fromJson(result.data!);
      _connected = true;
      _error = null;
    } else {
      _connected = false;
      _error = result.error;
    }
    _loading = false;
    notifyListeners();
  }

  void startPolling(int intervalSeconds) {
    _pollTimer?.cancel();
    checkHealth();
    _pollTimer = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (_) => checkHealth(),
    );
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
