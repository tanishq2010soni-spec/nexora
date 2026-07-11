import 'package:flutter/material.dart';
import '../models/audit_log.dart';
import '../services/api_service.dart';

class LogProvider extends ChangeNotifier {
  final ApiService _api;

  List<AuditLog> _logs = [];
  bool _isLoading = false;
  String? _error;
  String _actionFilter = '';
  String _resourceFilter = '';
  String _userFilter = '';
  DateTime? _startDate;
  DateTime? _endDate;

  LogProvider(this._api);

  List<AuditLog> get logs => _logs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadLogs() async {
    _isLoading = true;
    notifyListeners();

    final filters = <String, String>{};
    if (_actionFilter.isNotEmpty) filters['action'] = _actionFilter;
    if (_resourceFilter.isNotEmpty) filters['resource_type'] = _resourceFilter;
    if (_userFilter.isNotEmpty) filters['user_name'] = _userFilter;
    if (_startDate != null) filters['start_date'] = _startDate!.toIso8601String().split('T').first;
    if (_endDate != null) filters['end_date'] = _endDate!.toIso8601String().split('T').first;

    final result = await _api.getLogs(filters: filters);
    if (result.isSuccess) {
      _logs = result.data ?? [];
      _error = null;
    } else {
      _error = result.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  void setActionFilter(String filter) {
    _actionFilter = filter;
    loadLogs();
  }

  void setResourceFilter(String filter) {
    _resourceFilter = filter;
    loadLogs();
  }

  void setUserFilter(String filter) {
    _userFilter = filter;
    loadLogs();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    loadLogs();
  }

  void clearFilters() {
    _actionFilter = '';
    _resourceFilter = '';
    _userFilter = '';
    _startDate = null;
    _endDate = null;
    loadLogs();
  }
}
