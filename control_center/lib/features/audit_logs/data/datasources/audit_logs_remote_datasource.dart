import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';

class AuditLogsRemoteDatasource {
  final ApiClient _client;

  const AuditLogsRemoteDatasource(this._client);

  Future<ApiResponse> getLogs() async {
    final response = await _client.get('/audit-logs');
    return ApiResponse.fromResponse(response);
  }
}
