import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/models/license_model.dart';

class LicenseRemoteDatasource {
  final ApiClient _apiClient;
  static const String _endpoint = '/licenses';

  LicenseRemoteDatasource(this._apiClient);

  Future<ApiResponse> getLicense(String orgId) async {
    final response = await _apiClient.get('$_endpoint/$orgId');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> activateLicense({
    required String orgId,
    required String activationCode,
  }) async {
    final response = await _apiClient.post(
      '$_endpoint/$orgId/activate',
      data: {'activationCode': activationCode},
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> updateLicense(
    String orgId,
    LicenseModel license,
  ) async {
    final response = await _apiClient.put(
      '$_endpoint/$orgId',
      data: license.toJson(),
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> renewLicense(String orgId) async {
    final response = await _apiClient.post('$_endpoint/$orgId/renew');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> cancelLicense(String orgId) async {
    final response = await _apiClient.post('$_endpoint/$orgId/cancel');
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> getLicenseUsage(String orgId) async {
    final response = await _apiClient.get('$_endpoint/$orgId/usage');
    return ApiResponse.fromResponse(response);
  }
}
