import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';

class InboxRemoteDatasource {
  final ApiClient _client;

  InboxRemoteDatasource(this._client);

  Future<ApiResponse> getConversations({
    String? channel,
    String? status,
    String? assignedTo,
    int limit = 20,
    int offset = 0,
  }) async {
    final queryParams = <String, dynamic>{'limit': limit, 'offset': offset};
    if (channel != null) queryParams['channel'] = channel;
    if (status != null) queryParams['status'] = status;
    if (assignedTo != null) queryParams['assigned_to'] = assignedTo;

    final response = await _client.get(
      '/inbox/conversations',
      queryParameters: queryParams,
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getConversation(String id) async {
    final response = await _client.get('/inbox/conversations/$id');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getConversationDetail(String id) async {
    final response = await _client.get('/inbox/conversations/$id/detail');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getMessages(
    String conversationId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _client.get(
      '/inbox/conversations/$conversationId/messages',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> sendMessage({
    required String conversationId,
    required String content,
    required String senderType,
  }) async {
    final response = await _client.post(
      '/inbox/messages',
      data: {
        'conversation_id': conversationId,
        'content': content,
        'sender_type': senderType,
      },
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> updateConversation(
    String id, {
    String? status,
    String? assignedTo,
    String? takeoverMode,
  }) async {
    final body = <String, dynamic>{};
    if (status != null) body['status'] = status;
    if (assignedTo != null) body['assigned_to'] = assignedTo;
    if (takeoverMode != null) body['takeover_mode'] = takeoverMode;

    final response = await _client.patch(
      '/inbox/conversations/$id',
      data: body,
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> toggleTakeover(String id) async {
    final response = await _client.patch('/inbox/conversations/$id/takeover');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> markRead(String conversationId) async {
    final response = await _client.post(
      '/inbox/mark-read',
      data: {'conversation_id': conversationId},
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> sendTypingIndicator({
    required String conversationId,
    required bool isTyping,
  }) async {
    final response = await _client.post(
      '/inbox/typing',
      data: {'conversation_id': conversationId, 'is_typing': isTyping},
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> searchConversations(String query) async {
    final response = await _client.get(
      '/inbox/search',
      queryParameters: {'q': query},
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getAnalytics() async {
    final response = await _client.get('/inbox/analytics');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> exportCsv() async {
    final response = await _client.get('/inbox/export/csv');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> deleteConversation(String id) async {
    final response = await _client.delete('/inbox/conversations/$id');
    return ApiResponse.fromResponse(response);
  }
}
