import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/logging/app_logger.dart';

class DashboardRemoteDatasource {
  final ApiClient _client;

  DashboardRemoteDatasource(this._client);

  Future<ApiResponse> getStats() async {
    const endpoint = '/dashboard/stats';
    AppLogger.instance.info(
      '[DASHBOARD] Fetching stats -> endpoint: $endpoint',
    );
    final response = await _client.get(endpoint);
    AppLogger.instance.info(
      '[DASHBOARD] Stats response -> status: ${response.statusCode}',
    );
    return ApiResponse.fromResponse(response);
  }
}
