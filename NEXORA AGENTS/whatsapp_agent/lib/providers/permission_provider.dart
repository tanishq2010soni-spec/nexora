import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class PermissionProvider extends ChangeNotifier {
  final ApiService _api;

  List<User> _users = [];
  List<String> _availablePermissions = [];
  bool _isLoading = false;
  String? _error;

  PermissionProvider(this._api);

  List<User> get users => _users;
  List<String> get availablePermissions => _availablePermissions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUsers() async {
    _isLoading = true;
    notifyListeners();

    final result = await _api.getUsers();
    if (result.isSuccess) {
      _users = result.data ?? [];
      _error = null;
    } else {
      _error = result.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadPermissions() async {
    final result = await _api.getAvailablePermissions();
    if (result.isSuccess) {
      _availablePermissions = result.data ?? [];
    }
    notifyListeners();
  }

  Future<void> loadAll() async {
    await Future.wait([loadUsers(), loadPermissions()]);
  }

  Future<bool> updateUserPermissions(int userId, List<String> permissions) async {
    final result = await _api.updateUserPermissions(userId, permissions);
    if (result.isSuccess) {
      await loadUsers();
      return true;
    }
    _error = result.error;
    notifyListeners();
    return false;
  }
}
