import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/call.dart';

class MonitoringProvider extends ChangeNotifier {
  bool _loading = false;
  String? _error;
  List<Call> _activeCalls = [];
  List<Map<String, dynamic>> _agents = [];
  Map<String, dynamic>? _queueOverview;

  bool get loading => _loading;
  String? get error => _error;
  List<Call> get activeCalls => _activeCalls;
  List<Map<String, dynamic>> get agents => _agents;
  Map<String, dynamic>? get queueOverview => _queueOverview;

  Future<void> fetchActiveCalls() async {
    final result = await ApiService.getList('/monitoring/active-calls');
    if (result.isSuccess && result.data != null) {
      _activeCalls = result.data!.map((e) => Call.fromJson(e as Map<String, dynamic>)).toList();
      notifyListeners();
    }
  }

  Future<void> fetchAgents() async {
    final result = await ApiService.getList('/monitoring/agents');
    if (result.isSuccess && result.data != null) {
      _agents = result.data!.cast<Map<String, dynamic>>();
      notifyListeners();
    }
  }

  Future<void> fetchQueueOverview() async {
    final result = await ApiService.get('/monitoring/queue');
    if (result.isSuccess) {
      _queueOverview = result.data;
      notifyListeners();
    }
  }

  Future<void> sendWhisper(String callId, String message) async {
    await ApiService.post('/monitoring/whisper', {
      'call_id': callId,
      'message': message,
    });
  }

  Future<void> bargeIn(String callId) async {
    await ApiService.post('/monitoring/barge-in', {
      'call_id': callId,
    });
  }
}
