import '../../domain/models/auth_models.dart';

/// Mapper class to convert between backend snake_case JSON and frontend camelCase models.
/// Keeps domain models clean with camelCase fields.
class AuthMapper {
  /// Convert backend TokenResponse (snake_case) to AuthTokens (camelCase).
  static AuthTokens tokenResponseToAuthTokens(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? 'bearer',
      orgId: json['org_id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
    );
  }

  /// Convert AuthTokens (camelCase) to backend TokenResponse (snake_case).
  static Map<String, dynamic> authTokensToTokenResponse(AuthTokens tokens) {
    return {
      'access_token': tokens.accessToken,
      'refresh_token': tokens.refreshToken,
      'token_type': tokens.tokenType,
      'org_id': tokens.orgId,
      'email': tokens.email,
      'role': tokens.role,
    };
  }

  /// Convert SignupRequest (camelCase) to backend UserRegister (snake_case).
  static Map<String, dynamic> signupRequestToUserRegister(
    SignupRequest request,
  ) {
    return {
      'email': request.email,
      'password': request.password,
      'organization_name': request.organizationName,
    };
  }

  /// Convert LoginRequest (camelCase) to backend UserLogin (snake_case).
  static Map<String, dynamic> loginRequestToUserLogin(LoginRequest request) {
    return {'email': request.email, 'password': request.password};
  }

  /// Convert RefreshTokenRequest to backend format.
  static Map<String, dynamic> refreshTokenToRefreshTokenRequest(
    String refreshToken,
  ) {
    return {'refresh_token': refreshToken};
  }
}
