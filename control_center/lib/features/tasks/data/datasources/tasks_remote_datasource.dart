import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';

class TasksRemoteDatasource {
  final ApiClient _apiClient;

  const TasksRemoteDatasource(this._apiClient);

  static const _baseUrl = '/tasks';

  Future<ApiResponse> getTasks({
    String? status,
    String? priority,
    String? search,
    String? assignedTo,
  }) async {
    final query = <String, dynamic>{};
    if (status != null) query['status'] = status;
    if (priority != null) query['priority'] = priority;
    if (search != null) query['search'] = search;
    if (assignedTo != null) query['assignedTo'] = assignedTo;

    final response = await _apiClient.get(_baseUrl, queryParameters: query);
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getTask(String id) async {
    final response = await _apiClient.get('$_baseUrl/$id');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> createTask(Map<String, dynamic> data) async {
    final response = await _apiClient.post(_baseUrl, data: data);
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> updateTask(String id, Map<String, dynamic> data) async {
    final response = await _apiClient.patch('$_baseUrl/$id', data: data);
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> deleteTask(String id) async {
    final response = await _apiClient.delete('$_baseUrl/$id');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getNotes({
    required String entityType,
    required String entityId,
  }) async {
    final response = await _apiClient.get(
      '/notes',
      queryParameters: {'entityType': entityType, 'entityId': entityId},
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> addNote({
    required String entityType,
    required String entityId,
    required String content,
  }) async {
    final response = await _apiClient.post(
      '/notes',
      data: {
        'entityType': entityType,
        'entityId': entityId,
        'content': content,
      },
    );
    return ApiResponse.fromResponse(response);
  }
}
