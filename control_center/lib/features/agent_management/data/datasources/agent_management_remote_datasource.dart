import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/models/agent_configuration.dart';
import '../../domain/models/agent_heartbeat.dart';
import '../../domain/models/agent_version.dart';

class AgentManagementRemoteDatasource {
  final ApiClient _apiClient;
  static const String _endpoint = '/agents';

  AgentManagementRemoteDatasource(this._apiClient);

  Future<ApiResponse> getVersions(String agentId) async {
    final response = await _apiClient.get('$_endpoint/$agentId/versions');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getVersion(String id) async {
    final response = await _apiClient.get('$_endpoint/versions/$id');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> createVersion(AgentVersion version) async {
    final response = await _apiClient.post(
      '$_endpoint/${version.agentId}/versions',
      data: version.toJson(),
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getCapabilities(String agentId) async {
    final response = await _apiClient.get('$_endpoint/$agentId/capabilities');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> toggleCapability(String id, bool enabled) async {
    final response = await _apiClient.patch(
      '$_endpoint/capabilities/$id',
      data: {'enabled': enabled},
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getHealth(String agentId) async {
    final response = await _apiClient.get('$_endpoint/$agentId/health');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getConfigurations(String agentId) async {
    final response = await _apiClient.get('$_endpoint/$agentId/config');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> updateConfiguration(
    String agentId,
    AgentConfiguration config,
  ) async {
    final response = await _apiClient.put(
      '$_endpoint/$agentId/config/${config.id}',
      data: config.toJson(),
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getLogs(
    String agentId, {
    int page = 1,
    int limit = 50,
  }) async {
    final response = await _apiClient.get(
      '$_endpoint/$agentId/logs',
      queryParameters: {'page': page, 'limit': limit},
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getHeartbeats(String agentId) async {
    final response = await _apiClient.get('$_endpoint/$agentId/heartbeats');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> recordHeartbeat(AgentHeartbeat heartbeat) async {
    final response = await _apiClient.post(
      '$_endpoint/${heartbeat.agentId}/heartbeats',
      data: heartbeat.toJson(),
    );
    return ApiResponse.fromResponse(response);
  }
}
