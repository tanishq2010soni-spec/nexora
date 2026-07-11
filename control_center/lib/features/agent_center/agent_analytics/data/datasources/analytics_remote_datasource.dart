import '../../../../../../core/network/api_client.dart';
import '../../../../../../core/network/api_response.dart';

class AnalyticsRemoteDatasource {
  final ApiClient _client;
  static const String _basePath = '/agent-analytics';

  AnalyticsRemoteDatasource(this._client);

  Future<ApiResponse> getAgentAnalytics() async {
    final response = await _client.get(_basePath);
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getAgentAnalyticsById(String agentId) async {
    final response = await _client.get('$_basePath/$agentId');
    return ApiResponse.fromResponse(response);
  }
}
