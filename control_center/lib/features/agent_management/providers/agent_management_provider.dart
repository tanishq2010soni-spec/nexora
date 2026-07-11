import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_result.dart';
import '../data/datasources/agent_management_remote_datasource.dart';
import '../domain/models/agent_capability.dart';
import '../domain/models/agent_configuration.dart';
import '../domain/models/agent_health.dart';
import '../domain/models/agent_heartbeat.dart';
import '../domain/models/agent_log.dart';
import '../domain/models/agent_version.dart';
import '../domain/repositories/agent_management_repository_interface.dart';

final agentManagementDatasourceProvider =
    Provider<AgentManagementRemoteDatasource>((ref) {
  throw UnimplementedError(
    'agentManagementDatasourceProvider must be overridden at the app level',
  );
});

final agentManagementRepositoryProvider =
    Provider<AgentManagementRepositoryInterface>((ref) {
  throw UnimplementedError(
    'agentManagementRepositoryProvider must be overridden at the app level',
  );
});

final agentVersionsProvider = FutureProvider.autoDispose
    .family<ApiResult<List<AgentVersion>>, String>((ref, agentId) async {
  final repository = ref.watch(agentManagementRepositoryProvider);
  return repository.getVersions(agentId);
});

final agentCapabilitiesProvider = FutureProvider.autoDispose
    .family<ApiResult<List<AgentCapability>>, String>((ref, agentId) async {
  final repository = ref.watch(agentManagementRepositoryProvider);
  return repository.getCapabilities(agentId);
});

final agentHealthProvider = FutureProvider.autoDispose
    .family<ApiResult<AgentHealth>, String>((ref, agentId) async {
  final repository = ref.watch(agentManagementRepositoryProvider);
  return repository.getHealth(agentId);
});

final agentConfigurationsProvider = FutureProvider.autoDispose
    .family<ApiResult<List<AgentConfiguration>>, String>((ref, agentId) async {
  final repository = ref.watch(agentManagementRepositoryProvider);
  return repository.getConfigurations(agentId);
});

final agentLogsProvider = FutureProvider.autoDispose
    .family<ApiResult<List<AgentLog>>, String>((ref, agentId) async {
  final repository = ref.watch(agentManagementRepositoryProvider);
  return repository.getLogs(agentId);
});

final agentHeartbeatsProvider = FutureProvider.autoDispose
    .family<ApiResult<List<AgentHeartbeat>>, String>((ref, agentId) async {
  final repository = ref.watch(agentManagementRepositoryProvider);
  return repository.getHeartbeats(agentId);
});
