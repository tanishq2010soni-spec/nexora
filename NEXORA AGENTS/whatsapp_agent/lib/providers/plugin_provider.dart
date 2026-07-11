import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PluginProvider extends ChangeNotifier {
  final ApiService _api;

  List<Map<String, dynamic>> _plugins = [];
  bool _isLoading = false;
  String? _error;

  PluginProvider(this._api);

  List<Map<String, dynamic>> get plugins => _plugins;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPlugins() async {
    _isLoading = true;
    notifyListeners();

    final result = await _api.getPlugins();
    if (result.isSuccess) {
      _plugins = result.data ?? [];
      _error = null;
    } else {
      _error = result.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> installPlugin(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    final result = await _api.installPlugin(data);
    if (result.isSuccess) {
      _plugins.add(result.data!);
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

  Future<bool> togglePlugin(int id, bool enabled) async {
    final result = await _api.togglePlugin(id, enabled);
    if (result.isSuccess) {
      final index = _plugins.indexWhere((p) => p['id'] == id);
      if (index != -1) {
        _plugins[index]['enabled'] = enabled;
      }
      notifyListeners();
      return true;
    }
    _error = result.error;
    notifyListeners();
    return false;
  }

  Future<bool> updatePluginConfig(int id, Map<String, dynamic> config) async {
    final result = await _api.updatePluginConfig(id, config);
    if (result.isSuccess) {
      final index = _plugins.indexWhere((p) => p['id'] == id);
      if (index != -1) {
        _plugins[index]['config'] = config;
      }
      notifyListeners();
      return true;
    }
    _error = result.error;
    notifyListeners();
    return false;
  }
}
