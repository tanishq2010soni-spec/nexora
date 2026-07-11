import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/conversation.dart';
import '../models/message.dart';
import '../models/memory_entry.dart';
import '../models/task.dart';
import '../models/perm_request.dart';

class ApiResult<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  const ApiResult({this.data, this.error, required this.isSuccess});

  factory ApiResult.success(T data) => ApiResult(data: data, isSuccess: true);

  factory ApiResult.failure(String error) => ApiResult(error: error, isSuccess: false);
}

class ApiService {
  final String baseUrl;
  final http.Client _client;

  ApiService({this.baseUrl = 'http://localhost:8000/api', http.Client? client})
      : _client = client ?? http.Client();

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<ApiResult<T>> _get<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResult.success(fromJson(json));
      }
      return ApiResult.failure('HTTP ${response.statusCode}: ${response.body}');
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<List<T>>> _getList<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final list = jsonDecode(response.body) as List<dynamic>;
        return ApiResult.success(
          list.map((e) => fromJson(e as Map<String, dynamic>)).toList(),
        );
      }
      return ApiResult.failure('HTTP ${response.statusCode}: ${response.body}');
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<T>> _post<T>(
    String path,
    Map<String, dynamic> body,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
        body: jsonEncode(body),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResult.success(fromJson(json));
      }
      return ApiResult.failure('HTTP ${response.statusCode}: ${response.body}');
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<T>> _put<T>(
    String path,
    Map<String, dynamic> body,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
        body: jsonEncode(body),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResult.success(fromJson(json));
      }
      return ApiResult.failure('HTTP ${response.statusCode}: ${response.body}');
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<void>> _delete(String path) async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return const ApiResult(isSuccess: true);
      }
      return ApiResult.failure('HTTP ${response.statusCode}: ${response.body}');
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<Message>> sendMessage(String content, String? conversationId) async {
    return _post(
      conversationId != null
          ? '/conversations/$conversationId/messages'
          : '/messages',
      {'content': content, 'conversation_id': conversationId},
      (json) => Message.fromJson(json['message'] as Map<String, dynamic>),
    );
  }

  Future<ApiResult<List<Conversation>>> getConversations() async {
    return _getList('/conversations', Conversation.fromJson);
  }

  Future<ApiResult<Conversation>> getConversation(String id) async {
    return _get('/conversations/$id', Conversation.fromJson);
  }

  Future<ApiResult<void>> deleteConversation(String id) async {
    return _delete('/conversations/$id');
  }

  Future<ApiResult<List<MemoryEntry>>> searchMemory(String query) async {
    return _getList('/memory/search?q=${Uri.encodeComponent(query)}', MemoryEntry.fromJson);
  }

  Future<ApiResult<List<Task>>> getTasks() async {
    return _getList('/tasks', Task.fromJson);
  }

  Future<ApiResult<Task>> createTask(String goal) async {
    return _post('/tasks', {'goal': goal}, (json) => Task.fromJson(json['task'] as Map<String, dynamic>));
  }

  Future<ApiResult<void>> cancelTask(String id) async {
    return _post('/tasks/$id/cancel', {}, (_) => {});
  }

  Future<ApiResult<Map<String, dynamic>>> getHealth() async {
    return _get('/health', (json) => json);
  }

  Future<ApiResult<Map<String, dynamic>>> getSettings() async {
    return _get('/settings', (json) => json);
  }

  Future<ApiResult<void>> updateSettings(Map<String, dynamic> settings) async {
    return _put('/settings', settings, (_) => {});
  }

  Future<ApiResult<List<PermissionRequest>>> getPendingPermissions() async {
    return _getList('/permissions/pending', PermissionRequest.fromJson);
  }

  Future<ApiResult<void>> approvePermission(String id) async {
    return _post('/permissions/$id/approve', {}, (_) => {});
  }

  Future<ApiResult<void>> denyPermission(String id) async {
    return _post('/permissions/$id/deny', {}, (_) => {});
  }

  Future<ApiResult<List<Map<String, dynamic>>>> getTools() async {
    return _getList('/tools', (json) => json);
  }

  Future<ApiResult<Map<String, dynamic>>> executeTool(String name, Map<String, dynamic> args) async {
    return _post('/tools/execute', {'name': name, 'args': args}, (json) => json);
  }

  void dispose() {
    _client.close();
  }
}
