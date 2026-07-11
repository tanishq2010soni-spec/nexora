import '../../../../../../core/network/api_client.dart';
import '../../../../../../core/network/api_response.dart';
import '../../domain/models/agent_settings.dart';
import '../../domain/models/available_model.dart';

class AgentCenterSettingsRemoteDatasource {
  final ApiClient _apiClient;

  AgentCenterSettingsRemoteDatasource(this._apiClient);

  Future<ApiResponse> getAgentSettings(String agentId) async {
    final response = await _apiClient.get('/agents/$agentId/settings');
    return ApiResponse(
      statusCode: response.statusCode ?? 0,
      data: AgentSettings.fromJson(response.data as Map<String, dynamic>),
      message: (response.data as Map<String, dynamic>?)?['message'] as String?,
    );
  }

  Future<ApiResponse> updateAgentSettings(
    String agentId,
    AgentSettings settings,
  ) async {
    final response = await _apiClient.put(
      '/agents/$agentId/settings',
      data: settings.toJson(),
    );
    return ApiResponse(
      statusCode: response.statusCode ?? 0,
      data: AgentSettings.fromJson(response.data as Map<String, dynamic>),
      message: (response.data as Map<String, dynamic>?)?['message'] as String?,
    );
  }

  Future<ApiResponse> getAvailableModels() async {
    final response = await _apiClient.get('/models');
    final List<dynamic> modelList = response.data as List<dynamic>;
    return ApiResponse(
      statusCode: response.statusCode ?? 0,
      data: modelList
          .map((e) => AvailableModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
