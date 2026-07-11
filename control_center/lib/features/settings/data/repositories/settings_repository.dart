import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/models/organization_setting.dart';
import '../../domain/models/api_key.dart';
import '../../domain/models/integration.dart';
import '../../domain/repositories/settings_repository_interface.dart';
import '../datasources/settings_remote_datasource.dart';

class SettingsRepository implements SettingsRepositoryInterface {
  final SettingsRemoteDatasource _datasource;

  const SettingsRepository(this._datasource);

  @override
  Future<ApiResult<List<OrganizationSetting>>> getSettings() async {
    try {
      final response = await _datasource.getSettings();
      if (response.isSuccess && response.data != null) {
        final list = response.data! as List;
        final settings = list
            .map((e) => OrganizationSetting.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiSuccess(settings);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to fetch settings'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<OrganizationSetting>> updateSetting(
    String key,
    String value,
  ) async {
    try {
      final response = await _datasource.updateSetting(key, value);
      if (response.isSuccess && response.data != null) {
        final setting = OrganizationSetting.fromJson(
          response.data! as Map<String, dynamic>,
        );
        return ApiSuccess(setting);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to update setting'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<List<ApiKey>>> getApiKeys() async {
    try {
      final response = await _datasource.getApiKeys();
      if (response.isSuccess && response.data != null) {
        final list = response.data! as List;
        final keys = list
            .map((e) => ApiKey.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiSuccess(keys);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to fetch API keys'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<ApiKey>> createApiKey({
    required String name,
    String? description,
    List<String>? scopes,
    DateTime? expiresAt,
  }) async {
    try {
      final response = await _datasource.createApiKey(
        name: name,
        description: description,
        scopes: scopes,
        expiresAt: expiresAt,
      );
      if (response.isSuccess && response.data != null) {
        return ApiSuccess(
          ApiKey.fromJson(response.data! as Map<String, dynamic>),
        );
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to create API key'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> deleteApiKey(String id) async {
    try {
      final response = await _datasource.deleteApiKey(id);
      if (response.isSuccess) {
        return const ApiSuccess(null);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to delete API key'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<List<Integration>>> getIntegrations() async {
    try {
      final response = await _datasource.getIntegrations();
      if (response.isSuccess && response.data != null) {
        final list = response.data! as List;
        final integrations = list
            .map((e) => Integration.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiSuccess(integrations);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to fetch integrations'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<Integration>> getIntegration(String id) async {
    try {
      final response = await _datasource.getIntegration(id);
      if (response.isSuccess && response.data != null) {
        final integration = Integration.fromJson(
          response.data! as Map<String, dynamic>,
        );
        return ApiSuccess(integration);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to fetch integration'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<Integration>> updateIntegration(
    String id, {
    Map<String, String>? config,
  }) async {
    try {
      final response = await _datasource.updateIntegration(id, config: config);
      if (response.isSuccess && response.data != null) {
        final integration = Integration.fromJson(
          response.data! as Map<String, dynamic>,
        );
        return ApiSuccess(integration);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to update integration'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }
}
