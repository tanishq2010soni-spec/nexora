import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/models/tool_definition.dart';

class ToolRegistryRemoteDatasource {
  final ApiClient _apiClient;
  static const String _endpoint = '/tools';

  ToolRegistryRemoteDatasource(this._apiClient);

  Future<ApiResponse> getTools() async {
    final response = await _apiClient.get(_endpoint);
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getTool(String id) async {
    final response = await _apiClient.get('$_endpoint/$id');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> createTool(ToolDefinition tool) async {
    final response = await _apiClient.post(
      _endpoint,
      data: tool.toJson(),
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> updateTool(String id, ToolDefinition tool) async {
    final response = await _apiClient.put(
      '$_endpoint/$id',
      data: tool.toJson(),
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> deleteTool(String id) async {
    final response = await _apiClient.delete('$_endpoint/$id');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> toggleToolStatus(String id, bool isEnabled) async {
    final response = await _apiClient.patch(
      '$_endpoint/$id/status',
      data: {'isEnabled': isEnabled},
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getCategories() async {
    final response = await _apiClient.get('$_endpoint/categories');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getToolsByCategory(String category) async {
    final response = await _apiClient.get(
      _endpoint,
      queryParameters: {'category': category},
    );
    return ApiResponse.fromResponse(response);
  }
}
