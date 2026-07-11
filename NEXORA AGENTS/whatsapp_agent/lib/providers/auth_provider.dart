import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api;

  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._api);

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _user != null;
  bool get isAdmin => _user?.role == 'admin';

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _api.login(email, password);
    if (result.isSuccess) {
      _token = result.data!['access_token'] as String;
      _api.setToken(_token);
      await _loadUser();
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

  Future<void> _loadUser() async {
    final result = await _api.getMe();
    if (result.isSuccess) {
      _user = result.data;
    }
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    _api.setToken(null);
    notifyListeners();
  }

  void setToken(String? token) {
    _token = token;
    _api.setToken(token);
    if (token != null) {
      _loadUser();
    }
    notifyListeners();
  }

  Future<void> checkAuth() async {
    if (_token != null) {
      _api.setToken(_token);
      await _loadUser();
      notifyListeners();
    }
  }
}
