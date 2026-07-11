import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/models/provider_model.dart';

class ProviderRemoteDatasource {
  final ApiClient _apiClient;
  static const String _endpoint = '/providers';

  ProviderRemoteDatasource(this._apiClient);

  Future<ApiResponse> getProviders() async {
    final response = await _apiClient.get(_endpoint);
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getProvider(String id) async {
    final response = await _apiClient.get('$_endpoint/$id');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> createProvider(ProviderModel provider) async {
    final response = await _apiClient.post(
      _endpoint,
      data: provider.toJson(),
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> updateProvider(String id, ProviderModel provider) async {
    final response = await _apiClient.put(
      '$_endpoint/$id',
      data: provider.toJson(),
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> deleteProvider(String id) async {
    final response = await _apiClient.delete('$_endpoint/$id');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> toggleProviderStatus(String id, bool isActive) async {
    final response = await _apiClient.patch(
      '$_endpoint/$id/status',
      data: {'isActive': isActive},
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> checkHealth(String id) async {
    final response = await _apiClient.get('$_endpoint/$id/health');
    return ApiResponse.fromResponse(response);
  }
}
