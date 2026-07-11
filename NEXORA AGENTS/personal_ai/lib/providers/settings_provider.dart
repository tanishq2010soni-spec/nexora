import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class SettingsProvider extends ChangeNotifier {
  final ApiService _apiService;

  String _model = 'gpt-4';
  double _temperature = 0.7;
  int _memoryLimit = 100;
  Map<String, bool> _toolPermissions = {};
  bool _darkTheme = true;
  bool _voiceEnabled = false;
  String _language = 'en';
  String _workspace = 'default';
  bool _loading = false;
  String? _error;

  SettingsProvider({required ApiService apiService}) : _apiService = apiService;

  String get model => _model;
  double get temperature => _temperature;
  int get memoryLimit => _memoryLimit;
  Map<String, bool> get toolPermissions => _toolPermissions;
  bool get darkTheme => _darkTheme;
  bool get voiceEnabled => _voiceEnabled;
  String get language => _language;
  String get workspace => _workspace;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadSettings() async {
    _loading = true;
    _error = null;
    notifyListeners();

    final result = await _apiService.getSettings();
    if (result.isSuccess) {
      final data = result.data!;
      _model = data['model'] as String? ?? _model;
      _temperature = (data['temperature'] as num?)?.toDouble() ?? _temperature;
      _memoryLimit = (data['memory_limit'] as num?)?.toInt() ?? _memoryLimit;
      if (data['tool_permissions'] != null) {
        _toolPermissions = Map<String, bool>.from(data['tool_permissions'] as Map);
      }
      _darkTheme = data['dark_theme'] as bool? ?? _darkTheme;
      _voiceEnabled = data['voice_enabled'] as bool? ?? _voiceEnabled;
      _language = data['language'] as String? ?? _language;
      _workspace = data['workspace'] as String? ?? _workspace;
    } else {
      _error = result.error;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> updateSetting(String key, dynamic value) async {
    switch (key) {
      case 'model':
        _model = value as String;
        break;
      case 'temperature':
        _temperature = (value as num).toDouble();
        break;
      case 'memory_limit':
        _memoryLimit = value as int;
        break;
      case 'dark_theme':
        _darkTheme = value as bool;
        break;
      case 'voice_enabled':
        _voiceEnabled = value as bool;
        break;
      case 'language':
        _language = value as String;
        break;
      case 'workspace':
        _workspace = value as String;
        break;
    }
    notifyListeners();

    final result = await _apiService.updateSettings({
      'model': _model,
      'temperature': _temperature,
      'memory_limit': _memoryLimit,
      'tool_permissions': _toolPermissions,
      'dark_theme': _darkTheme,
      'voice_enabled': _voiceEnabled,
      'language': _language,
      'workspace': _workspace,
    });
    if (!result.isSuccess) {
      _error = result.error;
      notifyListeners();
    }
  }

  Future<void> resetDefaults() async {
    _model = 'gpt-4';
    _temperature = 0.7;
    _memoryLimit = 100;
    _toolPermissions = {};
    _darkTheme = true;
    _voiceEnabled = false;
    _language = 'en';
    _workspace = 'default';
    notifyListeners();

    await _apiService.updateSettings({
      'model': _model,
      'temperature': _temperature,
      'memory_limit': _memoryLimit,
      'tool_permissions': _toolPermissions,
      'dark_theme': _darkTheme,
      'voice_enabled': _voiceEnabled,
      'language': _language,
      'workspace': _workspace,
    });
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
