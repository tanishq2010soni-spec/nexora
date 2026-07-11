import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/models/knowledge_source.dart';

class KnowledgeSourceRemoteDatasource {
  final ApiClient _apiClient;
  static const String _endpoint = '/knowledge-sources';

  KnowledgeSourceRemoteDatasource(this._apiClient);

  Future<ApiResponse> getSources(String kbId) async {
    final response = await _apiClient.get(
      _endpoint,
      queryParameters: {'kbId': kbId},
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getSource(String id) async {
    final response = await _apiClient.get('$_endpoint/$id');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> createSource(KnowledgeSource source) async {
    final response = await _apiClient.post(
      _endpoint,
      data: source.toJson(),
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> updateSource(
    String id,
    KnowledgeSource source,
  ) async {
    final response = await _apiClient.put(
      '$_endpoint/$id',
      data: source.toJson(),
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> deleteSource(String id) async {
    final response = await _apiClient.delete('$_endpoint/$id');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> triggerIndexing(String id) async {
    final response = await _apiClient.post('$_endpoint/$id/index');
    return ApiResponse.fromResponse(response);
  }
}
