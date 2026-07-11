import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/models/workflow_model.dart';
import '../../domain/models/workflow_execution.dart';
import '../../domain/repositories/workflows_repository_interface.dart';
import '../datasources/workflows_remote_datasource.dart';

class WorkflowsRepository implements WorkflowsRepositoryInterface {
  final WorkflowsRemoteDatasource _datasource;

  const WorkflowsRepository(this._datasource);

  @override
  Future<ApiResult<List<WorkflowModel>>> getWorkflows() async {
    try {
      final response = await _datasource.getWorkflows();
      if (response.isSuccess && response.data != null) {
        final list = response.data! as List;
        final workflows = list
            .map((e) => WorkflowModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiSuccess(workflows);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to fetch workflows'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<WorkflowModel>> getWorkflow(String id) async {
    try {
      final response = await _datasource.getWorkflow(id);
      if (response.isSuccess && response.data != null) {
        final workflow = WorkflowModel.fromJson(
          response.data! as Map<String, dynamic>,
        );
        return ApiSuccess(workflow);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to fetch workflow'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<WorkflowModel>> createWorkflow({
    required String name,
    String? description,
    required WorkflowTriggerType triggerType,
    String? nodesJson,
    String? edgesJson,
  }) async {
    try {
      final response = await _datasource.createWorkflow(
        name: name,
        description: description,
        triggerType: triggerType.name,
        nodesJson: nodesJson,
        edgesJson: edgesJson,
      );
      if (response.isSuccess && response.data != null) {
        final workflow = WorkflowModel.fromJson(
          response.data! as Map<String, dynamic>,
        );
        return ApiSuccess(workflow);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to create workflow'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<WorkflowModel>> updateWorkflow(
    String id, {
    String? name,
    String? description,
    WorkflowTriggerType? triggerType,
    bool? isActive,
    String? nodesJson,
    String? edgesJson,
  }) async {
    try {
      final response = await _datasource.updateWorkflow(
        id,
        name: name,
        description: description,
        triggerType: triggerType?.name,
        isActive: isActive,
        nodesJson: nodesJson,
        edgesJson: edgesJson,
      );
      if (response.isSuccess && response.data != null) {
        final workflow = WorkflowModel.fromJson(
          response.data! as Map<String, dynamic>,
        );
        return ApiSuccess(workflow);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to update workflow'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> deleteWorkflow(String id) async {
    try {
      final response = await _datasource.deleteWorkflow(id);
      if (response.isSuccess) {
        return const ApiSuccess(null);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to delete workflow'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<List<WorkflowExecution>>> getExecutions(
    String workflowId,
  ) async {
    try {
      final response = await _datasource.getExecutions(workflowId);
      if (response.isSuccess && response.data != null) {
        final list = response.data! as List;
        final executions = list
            .map((e) => WorkflowExecution.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiSuccess(executions);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to fetch executions'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<WorkflowExecution>> executeWorkflow(
    String workflowId,
  ) async {
    try {
      final response = await _datasource.executeWorkflow(workflowId);
      if (response.isSuccess && response.data != null) {
        final execution = WorkflowExecution.fromJson(
          response.data! as Map<String, dynamic>,
        );
        return ApiSuccess(execution);
      }
      return ApiError(
        ServerException(response.message ?? 'Failed to execute workflow'),
      );
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }
}
