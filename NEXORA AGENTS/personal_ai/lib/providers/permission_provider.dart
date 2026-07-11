import 'package:flutter/foundation.dart';
import '../models/perm_request.dart';
import '../services/api_service.dart';

class PermissionProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<PermissionRequest> _pending = [];
  final List<PermissionRequest> _history = [];
  bool _loading = false;
  String? _error;

  PermissionProvider({required ApiService apiService}) : _apiService = apiService;

  List<PermissionRequest> get pending => _pending;
  List<PermissionRequest> get history => _history;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadPending() async {
    _loading = true;
    _error = null;
    notifyListeners();

    final result = await _apiService.getPendingPermissions();
    if (result.isSuccess) {
      _pending = result.data ?? [];
    } else {
      _error = result.error;
    }
    _loading = false;
    notifyListeners();
  }

  Future<bool> approve(String id) async {
    final result = await _apiService.approvePermission(id);
    if (result.isSuccess) {
      _pending.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    }
    _error = result.error;
    notifyListeners();
    return false;
  }

  Future<bool> deny(String id) async {
    final result = await _apiService.denyPermission(id);
    if (result.isSuccess) {
      _pending.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    }
    _error = result.error;
    notifyListeners();
    return false;
  }

  Future<void> refresh() async {
    await loadPending();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
