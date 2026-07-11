import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _analytics;

  bool get loading => _loading;
  String? get error => _error;
  Map<String, dynamic>? get analytics => _analytics;

  Future<void> fetchAnalytics({String? startDate, String? endDate}) async {
    _loading = true;
    notifyListeners();
    String path = '/analytics/overview';
    if (startDate != null || endDate != null) {
      path += '?start_date=$startDate&end_date=$endDate';
    }
    final result = await ApiService.get(path);
    if (result.isSuccess) {
      _analytics = result.data;
    } else {
      _error = result.error;
    }
    _loading = false;
    notifyListeners();
  }
}
