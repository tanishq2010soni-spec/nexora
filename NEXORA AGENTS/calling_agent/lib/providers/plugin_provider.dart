import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class PluginProvider extends ChangeNotifier {
  bool _loading = false;
  String? _error;
  List<Map<String, dynamic>> _plugins = [];

  bool get loading => _loading;
  String? get error => _error;
  List<Map<String, dynamic>> get plugins => _plugins;

  Future<void> fetchPlugins() async {
    _loading = true;
    notifyListeners();
    final result = await ApiService.getList('/plugins');
    if (result.isSuccess && result.data != null) {
      _plugins = result.data!.cast<Map<String, dynamic>>();
    } else {
      _error = result.error;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> togglePlugin(String id, bool enabled) async {
    final result = await ApiService.put('/plugins/$id', {'enabled': enabled});
    if (result.isSuccess) {
      await fetchPlugins();
    }
  }
}
