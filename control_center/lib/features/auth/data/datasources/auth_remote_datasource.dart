import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/logging/app_logger.dart';

class AuthRemoteDatasource {
  final ApiClient _client;

  AuthRemoteDatasource(this._client);

  Future<ApiResponse> login(String email, String password) async {
    const endpoint = '/auth/login';
    AppLogger.instance.info('[AUTH] Login request -> endpoint: $endpoint');
    final response = await _client.post(
      endpoint,
      data: {'email': email, 'password': password},
    );
    AppLogger.instance.info(
      '[AUTH] Login response -> status: ${response.statusCode}',
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> signup(
    String email,
    String password,
    String organizationName,
  ) async {
    const endpoint = '/auth/signup';
    AppLogger.instance.info('[AUTH] Signup request -> endpoint: $endpoint');
    final response = await _client.post(
      endpoint,
      data: {
        'email': email,
        'password': password,
        'organization_name': organizationName,
      },
    );
    AppLogger.instance.info(
      '[AUTH] Signup response -> status: ${response.statusCode}',
    );
    return ApiResponse.fromResponse(response);
  }

  Future<ApiResponse> refreshToken(String refreshToken) async {
    const endpoint = '/auth/refresh';
    AppLogger.instance.info(
      '[AUTH] Token refresh request -> endpoint: $endpoint',
    );
    final response = await _client.post(
      endpoint,
      data: {'refresh_token': refreshToken},
    );
    AppLogger.instance.info(
      '[AUTH] Token refresh response -> status: ${response.statusCode}',
    );
    return ApiResponse.fromResponse(response);
  }
}
