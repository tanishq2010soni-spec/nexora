import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/script.dart';

class ScriptProvider extends ChangeNotifier {
  bool _loading = false;
  String? _error;
  List<Script> _scripts = [];

  bool get loading => _loading;
  String? get error => _error;
  List<Script> get scripts => _scripts;

  Future<void> fetchScripts() async {
    _loading = true;
    notifyListeners();
    final result = await ApiService.getList('/scripts');
    if (result.isSuccess && result.data != null) {
      _scripts = result.data!.map((e) => Script.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      _error = result.error;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> createScript(Map<String, dynamic> data) async {
    _loading = true;
    _error = null;
    notifyListeners();
    final result = await ApiService.post('/scripts', data);
    if (result.isSuccess) {
      await fetchScripts();
    } else {
      _error = result.error;
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateScript(String id, Map<String, dynamic> data) async {
    final result = await ApiService.put('/scripts/$id', data);
    if (result.isSuccess) {
      await fetchScripts();
    }
  }

  Future<void> deleteScript(String id) async {
    final result = await ApiService.delete('/scripts/$id');
    if (result.isSuccess) {
      await fetchScripts();
    }
  }
}
