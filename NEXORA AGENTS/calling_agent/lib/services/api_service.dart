import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_result.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8200/api/v1';

  static String? _token;

  static void setToken(String? token) {
    _token = token;
  }

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  static Future<ApiResult<Map<String, dynamic>>> get(String path) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResult.success(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      return ApiResult.failure(
        jsonDecode(response.body)['detail'] as String? ??
            'Request failed with status ${response.statusCode}',
      );
    } catch (e) {
      return ApiResult.failure('Network error: $e');
    }
  }

  static Future<ApiResult<List<dynamic>>> getList(String path) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResult.success(
          jsonDecode(response.body) as List<dynamic>,
        );
      }
      return ApiResult.failure(
        jsonDecode(response.body)['detail'] as String? ??
            'Request failed with status ${response.statusCode}',
      );
    } catch (e) {
      return ApiResult.failure('Network error: $e');
    }
  }

  static Future<ApiResult<Map<String, dynamic>>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
        body: jsonEncode(body),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResult.success(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      return ApiResult.failure(
        jsonDecode(response.body)['detail'] as String? ??
            'Request failed with status ${response.statusCode}',
      );
    } catch (e) {
      return ApiResult.failure('Network error: $e');
    }
  }

  static Future<ApiResult<Map<String, dynamic>>> put(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
        body: jsonEncode(body),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResult.success(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      return ApiResult.failure(
        jsonDecode(response.body)['detail'] as String? ??
            'Request failed with status ${response.statusCode}',
      );
    } catch (e) {
      return ApiResult.failure('Network error: $e');
    }
  }

  static Future<ApiResult<void>> delete(String path) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return const ApiResult(isSuccess: true);
      }
      return ApiResult.failure(
        jsonDecode(response.body)['detail'] as String? ??
            'Request failed with status ${response.statusCode}',
      );
    } catch (e) {
      return ApiResult.failure('Network error: $e');
    }
  }

  static Future<ApiResult<Map<String, dynamic>>> upload(
    String path,
    String filePath,
    String fieldName,
  ) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$path'),
      );
      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }
      request.files.add(
        await http.MultipartFile.fromPath(fieldName, filePath),
      );
      final response = await request.send();
      final body = jsonDecode(await response.stream.bytesToString());
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResult.success(body as Map<String, dynamic>);
      }
      return ApiResult.failure(
        body['detail'] as String? ??
            'Upload failed with status ${response.statusCode}',
      );
    } catch (e) {
      return ApiResult.failure('Upload error: $e');
    }
  }
}
