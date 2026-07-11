import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_response.dart';
import '../../domain/models/calling_agent.dart';

class CallingAgentRemoteDatasource {
  final ApiClient _apiClient;
  static const String _endpoint = '/agents/calling';

  CallingAgentRemoteDatasource(this._apiClient);

  Future<ApiResponse> getAgents() async {
    final response = await _apiClient.get(_endpoint);
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getAgent(String id) async {
    final response = await _apiClient.get('$_endpoint/$id');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> createAgent(CallingAgent agent) async {
    final response = await _apiClient.post(_endpoint, data: agent.toJson());
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> updateAgent(String id, CallingAgent agent) async {
    final response = await _apiClient.put(
      '$_endpoint/$id',
      data: agent.toJson(),
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> deleteAgent(String id) async {
    final response = await _apiClient.delete('$_endpoint/$id');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> toggleAgentStatus(String id, bool enabled) async {
    final response = await _apiClient.patch(
      '$_endpoint/$id/status',
      data: {'enabled': enabled},
    );
    return ApiResponse.fromResponse(response);
  }
}
