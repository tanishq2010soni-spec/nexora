import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';

class ConversationRemoteDatasource {
  final ApiClient _client;

  ConversationRemoteDatasource(this._client);

  Future<ApiResponse> getConversations({
    String? platform,
    String? status,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'limit': limit};
    if (platform != null) queryParams['platform'] = platform;
    if (status != null) queryParams['status'] = status;
    if (search != null) queryParams['search'] = search;

    final response = await _client.get(
      '/conversations',
      queryParameters: queryParams,
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getConversation(String id) async {
    final response = await _client.get('/conversations/$id');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 50,
  }) async {
    final response = await _client.get(
      '/conversations/$conversationId/messages',
      queryParameters: {'page': page, 'limit': limit},
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getCallLogs({
    String? agentId,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'limit': limit};
    if (agentId != null) queryParams['agentId'] = agentId;

    final response = await _client.get(
      '/conversations/call-logs',
      queryParameters: queryParams,
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getCallLog(String id) async {
    final response = await _client.get('/conversations/call-logs/$id');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> searchConversations(
    String query, {
    String? platform,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{'q': query};
    if (platform != null) queryParams['platform'] = platform;
    if (status != null) queryParams['status'] = status;

    final response = await _client.get(
      '/conversations/search',
      queryParameters: queryParams,
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getAnalytics() async {
    final response = await _client.get('/conversations/analytics');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> exportCsv({
    String? platform,
    String? status,
    DateTime? from,
    DateTime? to,
  }) async {
    final queryParams = <String, dynamic>{};
    if (platform != null) queryParams['platform'] = platform;
    if (status != null) queryParams['status'] = status;
    if (from != null) queryParams['from'] = from.toIso8601String();
    if (to != null) queryParams['to'] = to.toIso8601String();

    final response = await _client.get(
      '/conversations/export/csv',
      queryParameters: queryParams,
    );
    return ApiResponse.fromResponse(response);
  }
}
