import '../../../../core/network/api_result.dart';
import '../models/organization_setting.dart';
import '../models/api_key.dart';
import '../models/integration.dart';

abstract class SettingsRepositoryInterface {
  Future<ApiResult<List<OrganizationSetting>>> getSettings();

  Future<ApiResult<OrganizationSetting>> updateSetting(
    String key,
    String value,
  );

  Future<ApiResult<List<ApiKey>>> getApiKeys();

  Future<ApiResult<ApiKey>> createApiKey({
    required String name,
    String? description,
    List<String>? scopes,
    DateTime? expiresAt,
  });

  Future<ApiResult<void>> deleteApiKey(String id);

  Future<ApiResult<List<Integration>>> getIntegrations();

  Future<ApiResult<Integration>> getIntegration(String id);

  Future<ApiResult<Integration>> updateIntegration(
    String id, {
    Map<String, String>? config,
  });
}
