import '../../../../../../core/network/api_client.dart';
import '../../../../../../core/network/api_response.dart';

class TemplateRemoteDatasource {
  final ApiClient _client;
  static const String _basePath = '/agent-templates';

  TemplateRemoteDatasource(this._client);

  Future<ApiResponse> getTemplates() async {
    final response = await _client.get(_basePath);
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getTemplate(String id) async {
    final response = await _client.get('$_basePath/$id');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> createTemplate(Map<String, dynamic> data) async {
    final response = await _client.post(_basePath, data: data);
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> updateTemplate(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client.put('$_basePath/$id', data: data);
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> deleteTemplate(String id) async {
    final response = await _client.delete('$_basePath/$id');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> duplicateTemplate(String id, String newName) async {
    final response = await _client.post(
      '$_basePath/$id/duplicate',
      data: {'name': newName},
    );
    return ApiResponse.fromResponse(response);
  }
}
