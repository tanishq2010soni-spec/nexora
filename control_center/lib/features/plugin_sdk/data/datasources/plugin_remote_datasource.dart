import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/models/plugin_model.dart';

class PluginRemoteDatasource {
  final ApiClient _apiClient;
  static const String _endpoint = '/plugins';

  PluginRemoteDatasource(this._apiClient);

  Future<ApiResponse> getPlugins() async {
    final response = await _apiClient.get(_endpoint);
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getPlugin(String id) async {
    final response = await _apiClient.get('$_endpoint/$id');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> installPlugin(PluginModel plugin) async {
    final response = await _apiClient.post(
      _endpoint,
      data: plugin.toJson(),
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> updatePlugin(String id, PluginModel plugin) async {
    final response = await _apiClient.put(
      '$_endpoint/$id',
      data: plugin.toJson(),
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> uninstallPlugin(String id) async {
    final response = await _apiClient.delete('$_endpoint/$id');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> togglePluginStatus(String id, bool isEnabled) async {
    final response = await _apiClient.patch(
      '$_endpoint/$id/status',
      data: {'isEnabled': isEnabled},
    );
    return ApiResponse.fromResponse(response);
  }
}
