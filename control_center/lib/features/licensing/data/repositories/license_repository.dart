import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/models/license_model.dart';
import '../../domain/repositories/license_repository_interface.dart';
import '../datasources/license_remote_datasource.dart';

class LicenseRepository implements LicenseRepositoryInterface {
  final LicenseRemoteDatasource _datasource;

  LicenseRepository(this._datasource);

  @override
  Future<ApiResult<LicenseModel>> getLicense(String orgId) async {
    try {
      final response = await _datasource.getLicense(orgId);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to fetch license',
            statusCode: response.statusCode,
          ),
        );
      }
      final license = LicenseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      return ApiSuccess(license);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<LicenseModel>> activateLicense({
    required String orgId,
    required String activationCode,
  }) async {
    try {
      final response = await _datasource.activateLicense(
        orgId: orgId,
        activationCode: activationCode,
      );
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to activate license',
            statusCode: response.statusCode,
          ),
        );
      }
      final license = LicenseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      return ApiSuccess(license);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<LicenseModel>> updateLicense(
    String orgId,
    LicenseModel license,
  ) async {
    try {
      final response = await _datasource.updateLicense(orgId, license);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to update license',
            statusCode: response.statusCode,
          ),
        );
      }
      final updated = LicenseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      return ApiSuccess(updated);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<LicenseModel>> renewLicense(String orgId) async {
    try {
      final response = await _datasource.renewLicense(orgId);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to renew license',
            statusCode: response.statusCode,
          ),
        );
      }
      final license = LicenseModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      return ApiSuccess(license);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> cancelLicense(String orgId) async {
    try {
      final response = await _datasource.cancelLicense(orgId);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to cancel license',
            statusCode: response.statusCode,
          ),
        );
      }
      return const ApiSuccess(null);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<Map<String, dynamic>>> getLicenseUsage(String orgId) async {
    try {
      final response = await _datasource.getLicenseUsage(orgId);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to fetch license usage',
            statusCode: response.statusCode,
          ),
        );
      }
      final usage = response.data as Map<String, dynamic>;
      return ApiSuccess(usage);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }
}
