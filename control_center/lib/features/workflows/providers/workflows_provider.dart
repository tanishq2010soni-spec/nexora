import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../data/datasources/workflows_remote_datasource.dart';
import '../data/repositories/workflows_repository.dart';
import '../domain/models/workflow_model.dart';
import '../domain/models/workflow_execution.dart';
import '../domain/repositories/workflows_repository_interface.dart';

final workflowsDatasourceProvider = Provider<WorkflowsRemoteDatasource>((ref) {
  throw UnimplementedError('Must be overridden');
});

final workflowsRepositoryProvider = Provider<WorkflowsRepositoryInterface>((
  ref,
) {
  return WorkflowsRepository(ref.read(workflowsDatasourceProvider));
});

final workflowsListProvider = FutureProvider<List<WorkflowModel>>((ref) async {
  final result = await ref.read(workflowsRepositoryProvider).getWorkflows();
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final workflowDetailProvider = FutureProvider.family<WorkflowModel, String>((
  ref,
  id,
) async {
  final result = await ref.read(workflowsRepositoryProvider).getWorkflow(id);
  return switch (result) {
    ApiSuccess(data: final data) => data,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final workflowExecutionsProvider =
    FutureProvider.family<List<WorkflowExecution>, String>((
      ref,
      workflowId,
    ) async {
      final result = await ref
          .read(workflowsRepositoryProvider)
          .getExecutions(workflowId);
      return switch (result) {
        ApiSuccess(data: final data) => data,
        ApiError(exception: final exception) => throw exception,
        _ => throw UnknownException('Unknown error'),
      };
    });

final createWorkflowProvider =
    FutureProvider.family<
      WorkflowModel,
      ({String name, String? description, WorkflowTriggerType triggerType})
    >((ref, params) async {
      final result = await ref
          .read(workflowsRepositoryProvider)
          .createWorkflow(
            name: params.name,
            description: params.description,
            triggerType: params.triggerType,
          );
      return switch (result) {
        ApiSuccess(data: final data) => data,
        ApiError(exception: final exception) => throw exception,
        _ => throw UnknownException('Unknown error'),
      };
    });

final updateWorkflowProvider =
    FutureProvider.family<
      WorkflowModel,
      ({
        String id,
        String? name,
        String? description,
        WorkflowTriggerType? triggerType,
        bool? isActive,
      })
    >((ref, params) async {
      final result = await ref
          .read(workflowsRepositoryProvider)
          .updateWorkflow(
            params.id,
            name: params.name,
            description: params.description,
            triggerType: params.triggerType,
            isActive: params.isActive,
          );
      return switch (result) {
        ApiSuccess(data: final data) => data,
        ApiError(exception: final exception) => throw exception,
        _ => throw UnknownException('Unknown error'),
      };
    });

final deleteWorkflowProvider = FutureProvider.family<void, String>((
  ref,
  id,
) async {
  final result = await ref.read(workflowsRepositoryProvider).deleteWorkflow(id);
  return switch (result) {
    ApiSuccess() => null,
    ApiError(exception: final exception) => throw exception,
    _ => throw UnknownException('Unknown error'),
  };
});

final executeWorkflowProvider =
    FutureProvider.family<WorkflowExecution, String>((ref, workflowId) async {
      final result = await ref
          .read(workflowsRepositoryProvider)
          .executeWorkflow(workflowId);
      return switch (result) {
        ApiSuccess(data: final data) => data,
        ApiError(exception: final exception) => throw exception,
        _ => throw UnknownException('Unknown error'),
      };
    });
