import 'package:flutter/material.dart';
import '../models/workflow.dart';
import '../services/api_service.dart';

class WorkflowProvider extends ChangeNotifier {
  final ApiService _api;

  List<Workflow> _workflows = [];
  List<WorkflowExecution> _executions = [];
  bool _isLoading = false;
  String? _error;

  WorkflowProvider(this._api);

  List<Workflow> get workflows => _workflows;
  List<WorkflowExecution> get executions => _executions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadWorkflows() async {
    _isLoading = true;
    notifyListeners();

    final result = await _api.getWorkflows();
    if (result.isSuccess) {
      _workflows = result.data ?? [];
      _error = null;
    } else {
      _error = result.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createWorkflow(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    final result = await _api.createWorkflow(data);
    if (result.isSuccess) {
      _workflows.insert(0, result.data!);
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

  Future<bool> updateWorkflow(int id, Map<String, dynamic> data) async {
    final result = await _api.updateWorkflow(id, data);
    if (result.isSuccess) {
      final index = _workflows.indexWhere((w) => w.id == id);
      if (index != -1) _workflows[index] = result.data!;
      notifyListeners();
      return true;
    }
    _error = result.error;
    notifyListeners();
    return false;
  }

  Future<bool> deleteWorkflow(int id) async {
    final result = await _api.deleteWorkflow(id);
    if (result.isSuccess) {
      _workflows.removeWhere((w) => w.id == id);
      notifyListeners();
      return true;
    }
    _error = result.error;
    notifyListeners();
    return false;
  }

  Future<Map<String, dynamic>?> testWorkflow(int id) async {
    final result = await _api.testWorkflow(id);
    if (result.isSuccess) {
      return result.data;
    }
    _error = result.error;
    notifyListeners();
    return null;
  }

  Future<void> loadExecutions(int workflowId) async {
    final result = await _api.getWorkflowExecutions(workflowId);
    if (result.isSuccess) {
      _executions = result.data ?? [];
    }
    notifyListeners();
  }
}
