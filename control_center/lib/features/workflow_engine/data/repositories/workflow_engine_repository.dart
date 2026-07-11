import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/models/workflow_definition.dart';
import '../../domain/models/workflow_execution_model.dart';
import '../../domain/repositories/workflow_engine_repository_interface.dart';
import '../datasources/workflow_engine_remote_datasource.dart';

class WorkflowEngineRepository implements WorkflowEngineRepositoryInterface {
  final WorkflowEngineRemoteDatasource _datasource;

  WorkflowEngineRepository(this._datasource);

  @override
  Future<ApiResult<List<WorkflowDefinition>>> getWorkflows() async {
    try {
      final response = await _datasource.getWorkflows();
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to fetch workflows',
            statusCode: response.statusCode,
          ),
        );
      }
      final List<dynamic> data = response.data as List<dynamic>;
      final workflows = data
          .map(
            (json) =>
                WorkflowDefinition.fromJson(json as Map<String, dynamic>),
          )
          .toList();
      return ApiSuccess(workflows);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<WorkflowDefinition>> getWorkflow(String id) async {
    try {
      final response = await _datasource.getWorkflow(id);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to fetch workflow',
            statusCode: response.statusCode,
          ),
        );
      }
      final workflow = WorkflowDefinition.fromJson(
        response.data as Map<String, dynamic>,
      );
      return ApiSuccess(workflow);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<WorkflowDefinition>> createWorkflow(
    WorkflowDefinition workflow,
  ) async {
    try {
      final response = await _datasource.createWorkflow(workflow);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to create workflow',
            statusCode: response.statusCode,
          ),
        );
      }
      final created = WorkflowDefinition.fromJson(
        response.data as Map<String, dynamic>,
      );
      return ApiSuccess(created);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<WorkflowDefinition>> updateWorkflow(
    String id,
    WorkflowDefinition workflow,
  ) async {
    try {
      final response = await _datasource.updateWorkflow(id, workflow);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to update workflow',
            statusCode: response.statusCode,
          ),
        );
      }
      final updated = WorkflowDefinition.fromJson(
        response.data as Map<String, dynamic>,
      );
      return ApiSuccess(updated);
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
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to delete workflow',
            statusCode: response.statusCode,
          ),
        );
      }
      return const ApiSuccess(null);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<WorkflowDefinition>> toggleWorkflowStatus(
    String id,
    bool isActive,
  ) async {
    try {
      final response = await _datasource.toggleWorkflowStatus(id, isActive);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to toggle workflow status',
            statusCode: response.statusCode,
          ),
        );
      }
      final toggled = WorkflowDefinition.fromJson(
        response.data as Map<String, dynamic>,
      );
      return ApiSuccess(toggled);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<List<WorkflowExecutionModel>>> getExecutions(
    String workflowId,
  ) async {
    try {
      final response = await _datasource.getExecutions(workflowId);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to fetch workflow executions',
            statusCode: response.statusCode,
          ),
        );
      }
      final List<dynamic> data = response.data as List<dynamic>;
      final executions = data
          .map(
            (json) =>
                WorkflowExecutionModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
      return ApiSuccess(executions);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<WorkflowExecutionModel>> getExecution(String id) async {
    try {
      final response = await _datasource.getExecution(id);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to fetch workflow execution',
            statusCode: response.statusCode,
          ),
        );
      }
      final execution = WorkflowExecutionModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      return ApiSuccess(execution);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<WorkflowExecutionModel>> triggerWorkflow(
    String workflowId,
  ) async {
    try {
      final response = await _datasource.triggerWorkflow(workflowId);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to trigger workflow',
            statusCode: response.statusCode,
          ),
        );
      }
      final execution = WorkflowExecutionModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      return ApiSuccess(execution);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }

  @override
  Future<ApiResult<WorkflowExecutionModel>> cancelExecution(String id) async {
    try {
      final response = await _datasource.cancelExecution(id);
      if (!response.isSuccess) {
        return ApiError(
          ServerException(
            response.message ?? 'Failed to cancel workflow execution',
            statusCode: response.statusCode,
          ),
        );
      }
      final execution = WorkflowExecutionModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      return ApiSuccess(execution);
    } on AppException catch (e) {
      return ApiError(e);
    } catch (e) {
      return ApiError(UnknownException(e.toString()));
    }
  }
}
