import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';

class WorkflowsRemoteDatasource {
  final ApiClient _apiClient;

  const WorkflowsRemoteDatasource(this._apiClient);

  static const _baseUrl = '/workflows';

  Future<ApiResponse> getWorkflows() async {
    final response = await _apiClient.get('$_baseUrl/');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getWorkflow(String id) async {
    final response = await _apiClient.get('$_baseUrl/$id');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> createWorkflow({
    required String name,
    String? description,
    required String triggerType,
    String? nodesJson,
    String? edgesJson,
  }) async {
    final response = await _apiClient.post(
      '$_baseUrl/',
      data: {
        'name': name,
        'description': ?description,
        'trigger_type': triggerType,
        'nodes_json': ?nodesJson,
        'edges_json': ?edgesJson,
      },
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> updateWorkflow(
    String id, {
    String? name,
    String? description,
    String? triggerType,
    bool? isActive,
    String? nodesJson,
    String? edgesJson,
  }) async {
    final response = await _apiClient.patch(
      '$_baseUrl/$id',
      data: {
        'name': ?name,
        'description': ?description,
        'trigger_type': ?triggerType,
        'is_active': ?isActive,
        'nodes_json': ?nodesJson,
        'edges_json': ?edgesJson,
      },
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> deleteWorkflow(String id) async {
    final response = await _apiClient.delete('$_baseUrl/$id');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getExecutions(String workflowId) async {
    final response = await _apiClient.get('$_baseUrl/$workflowId/executions');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> executeWorkflow(String workflowId) async {
    final response = await _apiClient.post('$_baseUrl/$workflowId/execute');
    return ApiResponse.fromResponse(response);
  }
}
