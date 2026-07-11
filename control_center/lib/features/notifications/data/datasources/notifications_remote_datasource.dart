import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';

class NotificationsRemoteDatasource {
  final ApiClient _apiClient;

  const NotificationsRemoteDatasource(this._apiClient);

  static const _baseUrl = '/notifications';

  Future<ApiResponse> getNotifications({
    bool? unreadOnly,
    int page = 1,
    int limit = 20,
  }) async {
    final query = <String, dynamic>{
      'limit': limit,
      'offset': (page - 1) * limit,
    };
    if (unreadOnly == true) query['is_read'] = false;

    final response = await _apiClient.get('$_baseUrl/', queryParameters: query);
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getUnreadCount() async {
    final response = await _apiClient.get('$_baseUrl/unread-count');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> markAsRead(String id) async {
    final response = await _apiClient.patch('$_baseUrl/$id/read');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> markAllAsRead() async {
    final response = await _apiClient.patch('$_baseUrl/read-all');
    return ApiResponse.fromResponse(response);
  }
}
