import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';

class AnalyticsRemoteDatasource {
  final ApiClient _client;

  AnalyticsRemoteDatasource(this._client);

  Future<ApiResponse> getExecutiveDashboard() async {
    final response = await _client.get('/analytics/executive');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getRevenueAnalytics() async {
    final response = await _client.get('/analytics/revenue');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getLeadAnalytics() async {
    final response = await _client.get('/analytics/leads/analytics');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getCustomerAnalytics() async {
    final response = await _client.get('/analytics/customers/analytics');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getConversationAnalytics() async {
    final response = await _client.get('/analytics/conversations/analytics');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getCallAnalytics() async {
    final response = await _client.get('/analytics/calls/analytics');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getAgentAnalytics() async {
    final response = await _client.get('/analytics/agents/analytics');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getAiPerformance() async {
    final response = await _client.get('/analytics/ai-performance');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getInboxAnalytics() async {
    final response = await _client.get('/inbox/analytics');
    return ApiResponse.fromResponse(response);
  }
}
