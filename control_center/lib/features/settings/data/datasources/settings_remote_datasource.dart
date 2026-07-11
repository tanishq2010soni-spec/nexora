import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';

class SettingsRemoteDatasource {
  final ApiClient _apiClient;

  const SettingsRemoteDatasource(this._apiClient);

  static const _baseUrl = '/settings';

  Future<ApiResponse> getSettings() async {
    final response = await _apiClient.get('$_baseUrl/settings');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> updateSetting(String key, String value) async {
    final response = await _apiClient.post(
      '$_baseUrl/settings',
      data: {'key': key, 'value': value},
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getApiKeys() async {
    final response = await _apiClient.get('$_baseUrl/api-keys');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> createApiKey({
    required String name,
    String? description,
    List<String>? scopes,
    DateTime? expiresAt,
  }) async {
    final response = await _apiClient.post(
      '$_baseUrl/api-keys',
      data: {
        'name': name,
        'description': ?description,
        'scopes': ?scopes,
        'expires_at': ?expiresAt?.toIso8601String(),
      },
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> deleteApiKey(String id) async {
    final response = await _apiClient.delete('$_baseUrl/api-keys/$id');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getIntegrations() async {
    final response = await _apiClient.get('$_baseUrl/integrations');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getIntegration(String id) async {
    final response = await _apiClient.get('$_baseUrl/integrations/$id');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> updateIntegration(
    String id, {
    Map<String, String>? config,
  }) async {
    final response = await _apiClient.patch(
      '$_baseUrl/integrations/$id',
      data: {'config': ?config},
    );
    return ApiResponse.fromResponse(response);
  }
}
