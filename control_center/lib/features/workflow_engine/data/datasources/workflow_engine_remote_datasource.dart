import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/models/workflow_definition.dart';

class WorkflowEngineRemoteDatasource {
  final ApiClient _apiClient;
  static const String _endpoint = '/workflows';

  WorkflowEngineRemoteDatasource(this._apiClient);

  Future<ApiResponse> getWorkflows() async {
    final response = await _apiClient.get(_endpoint);
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getWorkflow(String id) async {
    final response = await _apiClient.get('$_endpoint/$id');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> createWorkflow(WorkflowDefinition workflow) async {
    final response = await _apiClient.post(
      _endpoint,
      data: workflow.toJson(),
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> updateWorkflow(
    String id,
    WorkflowDefinition workflow,
  ) async {
    final response = await _apiClient.put(
      '$_endpoint/$id',
      data: workflow.toJson(),
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> deleteWorkflow(String id) async {
    final response = await _apiClient.delete('$_endpoint/$id');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> toggleWorkflowStatus(
    String id,
    bool isActive,
  ) async {
    final response = await _apiClient.patch(
      '$_endpoint/$id/status',
      data: {'isActive': isActive},
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getExecutions(String workflowId) async {
    final response = await _apiClient.get(
      '$_endpoint/$workflowId/executions',
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getExecution(String id) async {
    final response = await _apiClient.get('$_endpoint/executions/$id');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> triggerWorkflow(String workflowId) async {
    final response = await _apiClient.post(
      '$_endpoint/$workflowId/execute',
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> cancelExecution(String id) async {
    final response = await _apiClient.post(
      '$_endpoint/executions/$id/cancel',
    );
    return ApiResponse.fromResponse(response);
  }
}
