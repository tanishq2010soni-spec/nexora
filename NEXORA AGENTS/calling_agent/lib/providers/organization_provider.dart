import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class OrganizationProvider extends ChangeNotifier {
  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _organization;

  bool get loading => _loading;
  String? get error => _error;
  Map<String, dynamic>? get organization => _organization;

  Future<void> fetchOrganization(String id) async {
    _loading = true;
    notifyListeners();
    final result = await ApiService.get('/organizations/$id');
    if (result.isSuccess) {
      _organization = result.data;
    } else {
      _error = result.error;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> updateOrganization(String id, Map<String, dynamic> data) async {
    _loading = true;
    _error = null;
    notifyListeners();
    final result = await ApiService.put('/organizations/$id', data);
    if (result.isSuccess) {
      _organization = result.data;
    } else {
      _error = result.error;
    }
    _loading = false;
    notifyListeners();
  }
}
