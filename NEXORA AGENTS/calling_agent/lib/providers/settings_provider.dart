import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/voice_settings.dart';

class SettingsProvider extends ChangeNotifier {
  bool _loading = false;
  String? _error;
  VoiceSettings? _voiceSettings;
  List<Map<String, dynamic>> _phoneProviders = [];
  List<Map<String, dynamic>> _prompts = [];

  bool get loading => _loading;
  String? get error => _error;
  VoiceSettings? get voiceSettings => _voiceSettings;
  List<Map<String, dynamic>> get phoneProviders => _phoneProviders;
  List<Map<String, dynamic>> get prompts => _prompts;

  Future<void> fetchVoiceSettings() async {
    final result = await ApiService.get('/settings/voice');
    if (result.isSuccess && result.data != null) {
      _voiceSettings = VoiceSettings.fromJson(result.data!);
      notifyListeners();
    }
  }

  Future<void> updateVoiceSettings(Map<String, dynamic> data) async {
    _loading = true;
    _error = null;
    notifyListeners();
    final result = await ApiService.put('/settings/voice', data);
    if (result.isSuccess && result.data != null) {
      _voiceSettings = VoiceSettings.fromJson(result.data!);
    } else {
      _error = result.error;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> fetchPhoneProviders() async {
    final result = await ApiService.getList('/settings/phone-providers');
    if (result.isSuccess && result.data != null) {
      _phoneProviders = result.data!.cast<Map<String, dynamic>>();
      notifyListeners();
    }
  }

  Future<void> addPhoneProvider(Map<String, dynamic> data) async {
    final result = await ApiService.post('/settings/phone-providers', data);
    if (result.isSuccess) {
      await fetchPhoneProviders();
    }
  }

  Future<void> fetchPrompts() async {
    final result = await ApiService.getList('/settings/prompts');
    if (result.isSuccess && result.data != null) {
      _prompts = result.data!.cast<Map<String, dynamic>>();
      notifyListeners();
    }
  }

  Future<void> createPrompt(Map<String, dynamic> data) async {
    final result = await ApiService.post('/settings/prompts', data);
    if (result.isSuccess) {
      await fetchPrompts();
    }
  }
}
