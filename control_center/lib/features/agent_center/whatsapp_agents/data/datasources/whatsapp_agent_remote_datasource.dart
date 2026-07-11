import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_response.dart';

class WhatsAppAgentRemoteDatasource {
  final ApiClient _client;

  WhatsAppAgentRemoteDatasource(this._client);

  Future<ApiResponse> getAgents() async {
    final response = await _client.get(
      '/agents',
      queryParameters: {'platform_type': 'whatsapp'},
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getAgent(String id) async {
    final response = await _client.get('/agents/$id');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> createAgent(Map<String, dynamic> data) async {
    final response = await _client.post('/agents', data: data);
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> updateAgent(String id, Map<String, dynamic> data) async {
    final response = await _client.put('/agents/$id', data: data);
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> deleteAgent(String id) async {
    final response = await _client.delete('/agents/$id');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> toggleAgentStatus(String id, bool enabled) async {
    final response = await _client.patch(
      '/agents/$id/status',
      data: {'enabled': enabled},
    );
    return ApiResponse.fromResponse(response);
  }
}
