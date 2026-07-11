import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class PermissionProvider extends ChangeNotifier {
  bool _loading = false;
  String? _error;
  List<Map<String, dynamic>> _roles = [];
  List<Map<String, dynamic>> _permissions = [];

  bool get loading => _loading;
  String? get error => _error;
  List<Map<String, dynamic>> get roles => _roles;
  List<Map<String, dynamic>> get permissions => _permissions;

  Future<void> fetchRoles() async {
    _loading = true;
    notifyListeners();
    final result = await ApiService.getList('/permissions/roles');
    if (result.isSuccess && result.data != null) {
      _roles = result.data!.cast<Map<String, dynamic>>();
    } else {
      _error = result.error;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> fetchPermissions() async {
    _loading = true;
    notifyListeners();
    final result = await ApiService.getList('/permissions');
    if (result.isSuccess && result.data != null) {
      _permissions = result.data!.cast<Map<String, dynamic>>();
    } else {
      _error = result.error;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> updateRole(String id, Map<String, dynamic> data) async {
    final result = await ApiService.put('/permissions/roles/$id', data);
    if (result.isSuccess) {
      await fetchRoles();
    }
  }
}
