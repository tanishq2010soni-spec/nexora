import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';

class KnowledgeBaseRemoteDatasource {
  final ApiClient _client;

  KnowledgeBaseRemoteDatasource(this._client);

  Future<ApiResponse> getKnowledgeBases() async {
    final response = await _client.get('/knowledge-bases');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getKnowledgeBase(String id) async {
    final response = await _client.get('/knowledge-bases/$id');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> createKnowledgeBase(Map<String, dynamic> data) async {
    final response = await _client.post('/knowledge-bases', data: data);
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> updateKnowledgeBase(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client.put('/knowledge-bases/$id', data: data);
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> deleteKnowledgeBase(String id) async {
    final response = await _client.delete('/knowledge-bases/$id');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getDocuments(String knowledgeBaseId) async {
    final response = await _client.get(
      '/knowledge-bases/$knowledgeBaseId/documents',
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getDocument(String id) async {
    final response = await _client.get('/documents/$id');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> uploadDocument(
    String knowledgeBaseId,
    List<int> fileBytes,
    String filename,
  ) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(fileBytes, filename: filename),
    });
    final response = await _client.post(
      '/knowledge-bases/$knowledgeBaseId/documents',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> deleteDocument(String id) async {
    final response = await _client.delete('/documents/$id');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> reindexDocument(String id) async {
    final response = await _client.post('/documents/$id/reindex');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> searchDocuments(
    String knowledgeBaseId,
    String query,
  ) async {
    final response = await _client.get(
      '/knowledge-bases/$knowledgeBaseId/search',
      queryParameters: {'q': query},
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getStatistics() async {
    final response = await _client.get('/knowledge-bases/statistics');
    return ApiResponse.fromResponse(response);
  }
}
