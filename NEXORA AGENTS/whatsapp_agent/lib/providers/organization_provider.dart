import 'package:flutter/material.dart';
import '../models/organization.dart';
import '../services/api_service.dart';

class OrganizationProvider extends ChangeNotifier {
  final ApiService _api;

  Organization? _organization;
  bool _isLoading = false;
  String? _error;

  OrganizationProvider(this._api);

  Organization? get organization => _organization;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadOrganization(int id) async {
    _isLoading = true;
    notifyListeners();

    final result = await _api.getOrganization(id);
    if (result.isSuccess) {
      _organization = result.data;
      _error = null;
    } else {
      _error = result.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateOrganization(Map<String, dynamic> data) async {
    if (_organization == null) return false;

    _isLoading = true;
    notifyListeners();

    final result = await _api.updateOrganization(_organization!.id, data);
    if (result.isSuccess) {
      _organization = result.data;
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = result.error;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
