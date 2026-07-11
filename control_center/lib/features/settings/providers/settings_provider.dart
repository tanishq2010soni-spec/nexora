import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../data/datasources/settings_remote_datasource.dart';
import '../data/repositories/settings_repository.dart';
import '../domain/models/organization_setting.dart';
import '../domain/models/api_key.dart';
import '../domain/models/integration.dart';
import '../domain/repositories/settings_repository_interface.dart';

final settingsDatasourceProvider = Provider<SettingsRemoteDatasource>((ref) {
  throw UnimplementedError('Must be overridden');
});

final settingsRepositoryProvider = Provider<SettingsRepositoryInterface>((ref) {
  return SettingsRepository(ref.read(settingsDatasourceProvider));
});

final settingsListProvider = FutureProvider<List<OrganizationSetting>>((
  ref,
) async {
  final result = await ref.read(settingsRepositoryProvider).getSettings();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final updateSettingProvider =
    FutureProvider.family<OrganizationSetting, ({String key, String value})>((
      ref,
      params,
    ) async {
      final result = await ref
          .read(settingsRepositoryProvider)
          .updateSetting(params.key, params.value);
      return switch (result) {
        ApiSuccess(data: final data) => data,
        ApiError(exception: final exception) => throw exception,
        _ => throw UnknownException('Unknown error'),
      };
    });

final apiKeysProvider = FutureProvider<List<ApiKey>>((ref) async {
  final result = await ref.read(settingsRepositoryProvider).getApiKeys();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final createApiKeyProvider =
    FutureProvider.family<ApiKey, ({String name, String? description})>((
      ref,
      params,
    ) async {
      final result = await ref
          .read(settingsRepositoryProvider)
          .createApiKey(name: params.name, description: params.description);
      return switch (result) {
        ApiSuccess(data: final data) => data,
        ApiError(exception: final exception) => throw exception,
        _ => throw UnknownException('Unknown error'),
      };
    });

final deleteApiKeyProvider = FutureProvider.family<void, String>((
  ref,
  id,
) async {
  final result = await ref.read(settingsRepositoryProvider).deleteApiKey(id);
  return switch (result) {
    ApiSuccess() => null,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final integrationsProvider = FutureProvider<List<Integration>>((ref) async {
  final result = await ref.read(settingsRepositoryProvider).getIntegrations();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final integrationDetailProvider = FutureProvider.family<Integration, String>((
  ref,
  id,
) async {
  final result = await ref.read(settingsRepositoryProvider).getIntegration(id);
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final updateIntegrationProvider =
    FutureProvider.family<
      Integration,
      ({String id, Map<String, String>? config})
    >((ref, params) async {
      final result = await ref
          .read(settingsRepositoryProvider)
          .updateIntegration(params.id, config: params.config);
      return switch (result) {
        ApiSuccess(data: final data) => data,
        ApiError(exception: final exception) => throw exception,
        _ => throw UnknownException('Unknown error'),
      };
    });
