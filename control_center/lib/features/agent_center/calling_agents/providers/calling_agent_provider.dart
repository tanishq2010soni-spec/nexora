import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_result.dart';
import '../data/datasources/calling_agent_remote_datasource.dart';
import '../domain/models/calling_agent.dart';
import '../domain/repositories/calling_agent_repository_interface.dart';

final callingAgentDatasourceProvider = Provider<CallingAgentRemoteDatasource>((
  ref,
) {
  throw UnimplementedError(
    'callingAgentDatasourceProvider must be overridden at the app level',
  );
});

final callingAgentRepositoryProvider =
    Provider<CallingAgentRepositoryInterface>((ref) {
      throw UnimplementedError(
        'callingAgentRepositoryProvider must be overridden at the app level',
      );
    });

final callingAgentsProvider =
    FutureProvider.autoDispose<ApiResult<List<CallingAgent>>>((ref) async {
      final repository = ref.watch(callingAgentRepositoryProvider);
      return repository.getAgents();
    });

final callingAgentDetailProvider = FutureProvider.autoDispose
    .family<ApiResult<CallingAgent>, String>((ref, id) async {
      final repository = ref.watch(callingAgentRepositoryProvider);
      return repository.getAgent(id);
    });
