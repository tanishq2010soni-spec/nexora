import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/models/auth_models.dart';
import '../../domain/repositories/auth_repository_interface.dart';
import '../datasources/auth_remote_datasource.dart';
import '../mappers/auth_mapper.dart';

class AuthRepository implements AuthRepositoryInterface {
  final AuthRemoteDatasource _datasource;

  AuthRepository(this._datasource);

  @override
  Future<ApiResult<AuthTokens>> login(String email, String password) async {
    try {
      final response = await _datasource.login(email, password);
      if (response.isSuccess && response.data != null) {
        final tokens = AuthMapper.tokenResponseToAuthTokens(
          response.data as Map<String, dynamic>,
        );
        return ApiSuccess(tokens);
      }
      return ApiError(
        ServerException(
          response.message ?? 'Login failed',
          statusCode: response.statusCode,
        ),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<AuthTokens>> signup(
    String email,
    String password,
    String organizationName,
  ) async {
    try {
      final response = await _datasource.signup(
        email,
        password,
        organizationName,
      );
      if (response.isSuccess && response.data != null) {
        final tokens = AuthMapper.tokenResponseToAuthTokens(
          response.data as Map<String, dynamic>,
        );
        return ApiSuccess(tokens);
      }
      return ApiError(
        ServerException(
          response.message ?? 'Signup failed',
          statusCode: response.statusCode,
        ),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<AuthTokens>> refreshToken(String refreshToken) async {
    try {
      final response = await _datasource.refreshToken(refreshToken);
      if (response.isSuccess && response.data != null) {
        final tokens = AuthMapper.tokenResponseToAuthTokens(
          response.data as Map<String, dynamic>,
        );
        return ApiSuccess(tokens);
      }
      return ApiError(
        ServerException(
          response.message ?? 'Refresh failed',
          statusCode: response.statusCode,
        ),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }
}
