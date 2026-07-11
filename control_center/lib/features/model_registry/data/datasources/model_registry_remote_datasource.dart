import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/models/model_registry_entry.dart';

class ModelRegistryRemoteDatasource {
  final ApiClient _apiClient;
  static const String _endpoint = '/models';

  ModelRegistryRemoteDatasource(this._apiClient);

  Future<ApiResponse> getModels() async {
    final response = await _apiClient.get(_endpoint);
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getModel(String id) async {
    final response = await _apiClient.get('$_endpoint/$id');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> registerModel(ModelRegistryEntry model) async {
    final response = await _apiClient.post(
      _endpoint,
      data: model.toJson(),
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> updateModel(
    String id,
    ModelRegistryEntry model,
  ) async {
    final response = await _apiClient.put(
      '$_endpoint/$id',
      data: model.toJson(),
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> deleteModel(String id) async {
    final response = await _apiClient.delete('$_endpoint/$id');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> toggleModelStatus(String id, bool isActive) async {
    final response = await _apiClient.patch(
      '$_endpoint/$id/status',
      data: {'isActive': isActive},
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getModelsByProvider(String providerId) async {
    final response = await _apiClient.get(
      _endpoint,
      queryParameters: {'providerId': providerId},
    );
    return ApiResponse.fromResponse(response);
  }
}
