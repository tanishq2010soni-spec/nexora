import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_result.dart';
import '../data/datasources/workflow_engine_remote_datasource.dart';
import '../domain/models/workflow_definition.dart';
import '../domain/models/workflow_execution_model.dart';
import '../domain/repositories/workflow_engine_repository_interface.dart';

final workflowEngineDatasourceProvider =
    Provider<WorkflowEngineRemoteDatasource>((ref) {
  throw UnimplementedError(
    'workflowEngineDatasourceProvider must be overridden at the app level',
  );
});

final workflowEngineRepositoryProvider =
    Provider<WorkflowEngineRepositoryInterface>((ref) {
  throw UnimplementedError(
    'workflowEngineRepositoryProvider must be overridden at the app level',
  );
});

final workflowsProvider =
    FutureProvider.autoDispose<ApiResult<List<WorkflowDefinition>>>((ref) async {
  final repository = ref.watch(workflowEngineRepositoryProvider);
  return repository.getWorkflows();
});

final workflowDetailProvider =
    FutureProvider.autoDispose.family<ApiResult<WorkflowDefinition>, String>(
      (ref, id) async {
        final repository = ref.watch(workflowEngineRepositoryProvider);
        return repository.getWorkflow(id);
      },
    );

final workflowExecutionsProvider = FutureProvider.autoDispose
    .family<ApiResult<List<WorkflowExecutionModel>>, String>(
      (ref, workflowId) async {
        final repository = ref.watch(workflowEngineRepositoryProvider);
        return repository.getExecutions(workflowId);
      },
    );
