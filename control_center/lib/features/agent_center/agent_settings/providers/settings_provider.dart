import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/network/api_result.dart';
import '../domain/models/agent_settings.dart';
import '../domain/models/available_model.dart';
import '../domain/repositories/settings_repository_interface.dart';
import '../data/datasources/settings_remote_datasource.dart';

final agentCenterSettingsDatasourceProvider =
    Provider<AgentCenterSettingsRemoteDatasource>((ref) {
      throw UnimplementedError('Must be overridden');
    });

final agentCenterSettingsRepositoryProvider =
    Provider<SettingsRepositoryInterface>((ref) {
      throw UnimplementedError('Must be overridden');
    });

final agentSettingsProvider = FutureProvider.family<AgentSettings, String>((
  ref,
  agentId,
) async {
  final repository = ref.watch(agentCenterSettingsRepositoryProvider);
  final result = await repository.getAgentSettings(agentId);
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw Exception('Unknown error'),
  };
});

final availableModelsProvider = FutureProvider<List<AvailableModel>>((
  ref,
) async {
  final repository = ref.watch(agentCenterSettingsRepositoryProvider);
  final result = await repository.getAvailableModels();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw Exception('Unknown error'),
  };
});
