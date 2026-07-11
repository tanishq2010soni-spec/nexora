import 'package:flutter/material.dart';
import '../models/department.dart';
import '../services/api_service.dart';

class InboxProvider extends ChangeNotifier {
  final ApiService _api;

  Map<String, dynamic>? _overview;
  List<Department> _departments = [];
  bool _isLoading = false;
  String? _error;

  InboxProvider(this._api);

  Map<String, dynamic>? get overview => _overview;
  List<Department> get departments => _departments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadOverview() async {
    _isLoading = true;
    notifyListeners();

    final result = await _api.getInboxOverview();
    if (result.isSuccess) {
      _overview = result.data;
      _error = null;
    } else {
      _error = result.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadDepartments() async {
    final result = await _api.getDepartments();
    if (result.isSuccess) {
      _departments = result.data ?? [];
    }
    notifyListeners();
  }

  Future<bool> createDepartment(Map<String, dynamic> data) async {
    final result = await _api.createDepartment(data);
    if (result.isSuccess) {
      _departments.add(result.data!);
      notifyListeners();
      return true;
    }
    _error = result.error;
    notifyListeners();
    return false;
  }

  Future<bool> updateDepartment(int id, Map<String, dynamic> data) async {
    final result = await _api.updateDepartment(id, data);
    if (result.isSuccess) {
      final index = _departments.indexWhere((d) => d.id == id);
      if (index != -1) _departments[index] = result.data!;
      notifyListeners();
      return true;
    }
    _error = result.error;
    notifyListeners();
    return false;
  }
}
