import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/recording.dart';

class RecordingProvider extends ChangeNotifier {
  bool _loading = false;
  String? _error;
  List<Recording> _recordings = [];

  bool get loading => _loading;
  String? get error => _error;
  List<Recording> get recordings => _recordings;

  Future<void> fetchRecordings() async {
    _loading = true;
    notifyListeners();
    final result = await ApiService.getList('/recordings');
    if (result.isSuccess && result.data != null) {
      _recordings = result.data!.map((e) => Recording.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      _error = result.error;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> deleteRecording(String id) async {
    final result = await ApiService.delete('/recordings/$id');
    if (result.isSuccess) {
      await fetchRecordings();
    }
  }

  Future<void> archiveRecording(String id) async {
    final result = await ApiService.put('/recordings/$id/archive', {});
    if (result.isSuccess) {
      await fetchRecordings();
    }
  }
}
