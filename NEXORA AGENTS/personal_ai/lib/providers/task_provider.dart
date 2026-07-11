import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/api_service.dart';

class TaskProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Task> _tasks = [];
  Task? _activeTask;
  bool _loading = false;
  String? _error;

  TaskProvider({required ApiService apiService}) : _apiService = apiService;

  List<Task> get tasks => _tasks;
  Task? get activeTask => _activeTask;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadTasks() async {
    _loading = true;
    _error = null;
    notifyListeners();

    final result = await _apiService.getTasks();
    if (result.isSuccess) {
      _tasks = result.data ?? [];
    } else {
      _error = result.error;
    }
    _loading = false;
    notifyListeners();
  }

  Future<Task?> createTask(String goal) async {
    _loading = true;
    _error = null;
    notifyListeners();

    final result = await _apiService.createTask(goal);
    if (result.isSuccess) {
      _tasks.insert(0, result.data!);
      _activeTask = result.data;
      _loading = false;
      notifyListeners();
      return result.data;
    }
    _error = result.error;
    _loading = false;
    notifyListeners();
    return null;
  }

  Future<bool> cancelTask(String id) async {
    final result = await _apiService.cancelTask(id);
    if (result.isSuccess) {
      if (_activeTask?.id == id) _activeTask = null;
      await loadTasks();
      return true;
    }
    _error = result.error;
    notifyListeners();
    return false;
  }

  Future<void> refreshTasks() async {
    await loadTasks();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
