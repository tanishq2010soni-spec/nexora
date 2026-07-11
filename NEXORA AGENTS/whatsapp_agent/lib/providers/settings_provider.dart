import 'package:flutter/material.dart';
import '../models/prompt_template.dart';
import '../services/api_service.dart';

class SettingsProvider extends ChangeNotifier {
  final ApiService _api;

  Map<String, dynamic>? _settings;
  List<PromptTemplate> _prompts = [];
  bool _isLoading = false;
  String? _error;

  SettingsProvider(this._api);

  Map<String, dynamic>? get settings => _settings;
  List<PromptTemplate> get prompts => _prompts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get defaultModel => _settings?['default_model'] as String? ?? 'gpt-4';
  double get temperature => (_settings?['temperature'] as num?)?.toDouble() ?? 0.7;
  int get maxTokens => _settings?['max_tokens'] as int? ?? 2048;

  Future<void> loadSettings(int orgId) async {
    _isLoading = true;
    notifyListeners();

    final result = await _api.getSettings(orgId);
    if (result.isSuccess) {
      _settings = result.data;
      _error = null;
    } else {
      _error = result.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateSettings(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    final orgId = _settings?['id'] as int?;
    if (orgId == null) return false;

    final result = await _api.updateSettings(orgId, data);
    if (result.isSuccess) {
      _settings = result.data;
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

  Future<void> loadPrompts() async {
    final result = await _api.getPromptTemplates();
    if (result.isSuccess) {
      _prompts = result.data ?? [];
    }
    notifyListeners();
  }

  Future<bool> createPrompt(Map<String, dynamic> data) async {
    final result = await _api.createPromptTemplate(data);
    if (result.isSuccess) {
      _prompts.add(result.data!);
      notifyListeners();
      return true;
    }
    _error = result.error;
    notifyListeners();
    return false;
  }

  Future<bool> updatePrompt(int id, Map<String, dynamic> data) async {
    final result = await _api.updatePromptTemplate(id, data);
    if (result.isSuccess) {
      final index = _prompts.indexWhere((p) => p.id == id);
      if (index != -1) _prompts[index] = result.data!;
      notifyListeners();
      return true;
    }
    _error = result.error;
    notifyListeners();
    return false;
  }

  Future<bool> deletePrompt(int id) async {
    final result = await _api.deletePromptTemplate(id);
    if (result.isSuccess) {
      _prompts.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    }
    _error = result.error;
    notifyListeners();
    return false;
  }
}
