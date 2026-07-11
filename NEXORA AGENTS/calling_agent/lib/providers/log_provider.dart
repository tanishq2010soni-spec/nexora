import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/audit_log.dart';

class LogProvider extends ChangeNotifier {
  bool _loading = false;
  String? _error;
  List<AuditLog> _logs = [];

  bool get loading => _loading;
  String? get error => _error;
  List<AuditLog> get logs => _logs;

  Future<void> fetchLogs({int page = 1, int limit = 100}) async {
    _loading = true;
    notifyListeners();
    final result = await ApiService.getList('/logs?page=$page&limit=$limit');
    if (result.isSuccess && result.data != null) {
      _logs = result.data!.map((e) => AuditLog.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      _error = result.error;
    }
    _loading = false;
    notifyListeners();
  }
}
