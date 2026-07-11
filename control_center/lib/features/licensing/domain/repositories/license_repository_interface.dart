import '../../../../core/network/api_result.dart';
import '../models/license_model.dart';

abstract class LicenseRepositoryInterface {
  Future<ApiResult<LicenseModel>> getLicense(String orgId);
  Future<ApiResult<LicenseModel>> activateLicense({
    required String orgId,
    required String activationCode,
  });
  Future<ApiResult<LicenseModel>> updateLicense(
    String orgId,
    LicenseModel license,
  );
  Future<ApiResult<LicenseModel>> renewLicense(String orgId);
  Future<ApiResult<void>> cancelLicense(String orgId);
  Future<ApiResult<Map<String, dynamic>>> getLicenseUsage(String orgId);
}
