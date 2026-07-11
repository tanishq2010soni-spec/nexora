import 'package:flutter/material.dart';
import '../models/analytics.dart';
import '../services/api_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  final ApiService _api;

  AnalyticsOverview? _overview;
  MetricsResponse? _metrics;
  bool _isLoading = false;
  String? _error;
  DateTime? _startDate;
  DateTime? _endDate;

  AnalyticsProvider(this._api);

  AnalyticsOverview? get overview => _overview;
  MetricsResponse? get metrics => _metrics;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  String get startDateStr =>
      _startDate?.toIso8601String().split('T').first ?? '';
  String get endDateStr =>
      _endDate?.toIso8601String().split('T').first ?? '';

  Future<void> loadOverview() async {
    _isLoading = true;
    notifyListeners();

    final params = <String, String>{};
    if (startDateStr.isNotEmpty) params['start_date'] = startDateStr;
    if (endDateStr.isNotEmpty) params['end_date'] = endDateStr;

    final result = await _api.getAnalyticsOverview(
      startDate: startDateStr.isNotEmpty ? startDateStr : null,
      endDate: endDateStr.isNotEmpty ? endDateStr : null,
    );
    if (result.isSuccess) {
      _overview = result.data;
      _error = null;
    } else {
      _error = result.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMetrics() async {
    final result = await _api.getMetrics(
      startDate: startDateStr.isNotEmpty ? startDateStr : null,
      endDate: endDateStr.isNotEmpty ? endDateStr : null,
    );
    if (result.isSuccess) {
      _metrics = result.data;
      _error = null;
    } else {
      _error = result.error;
    }
    notifyListeners();
  }

  Future<void> loadAll() async {
    await Future.wait([loadOverview(), loadMetrics()]);
  }

  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    loadAll();
  }

  void clearDateRange() {
    _startDate = null;
    _endDate = null;
    loadAll();
  }
}
