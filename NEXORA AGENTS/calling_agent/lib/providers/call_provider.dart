import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/call.dart';

class CallProvider extends ChangeNotifier {
  bool _loading = false;
  String? _error;
  List<Call> _calls = [];
  Call? _selectedCall;

  bool get loading => _loading;
  String? get error => _error;
  List<Call> get calls => _calls;
  Call? get selectedCall => _selectedCall;

  Future<void> fetchCalls({String? status, int page = 1, int limit = 50}) async {
    _loading = true;
    notifyListeners();
    final params = '?page=$page&limit=$limit${status != null ? '&status=$status' : ''}';
    final result = await ApiService.getList('/calls$params');
    if (result.isSuccess && result.data != null) {
      _calls = result.data!.map((e) => Call.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      _error = result.error;
    }
    _loading = false;
    notifyListeners();
  }

  void selectCall(Call? call) {
    _selectedCall = call;
    notifyListeners();
  }

  Future<void> updateCallStatus(String id, String status) async {
    final result = await ApiService.put('/calls/$id/status', {'status': status});
    if (result.isSuccess) {
      await fetchCalls();
    }
  }
}
