import '../../../../core/network/api_result.dart';
import '../models/auth_models.dart';

abstract class AuthRepositoryInterface {
  Future<ApiResult<AuthTokens>> login(String email, String password);
  Future<ApiResult<AuthTokens>> signup(
    String email,
    String password,
    String organizationName,
  );
  Future<ApiResult<AuthTokens>> refreshToken(String refreshToken);
}
