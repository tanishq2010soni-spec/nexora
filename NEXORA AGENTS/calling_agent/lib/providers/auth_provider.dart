import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _loading = false;
  String? _error;
  String? _token;
  Map<String, dynamic>? _user;

  bool get loading => _loading;
  String? get error => _error;
  bool get authenticated => _token != null;
  Map<String, dynamic>? get user => _user;

  Future<void> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    final result = await ApiService.post('/auth/login', {
      'email': email,
      'password': password,
    });
    if (result.isSuccess && result.data != null) {
      _token = result.data!['access_token'] as String?;
      _user = result.data!['user'] as Map<String, dynamic>?;
      ApiService.setToken(_token);
    } else {
      _error = result.error ?? 'Login failed';
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    ApiService.setToken(null);
    notifyListeners();
  }
}
