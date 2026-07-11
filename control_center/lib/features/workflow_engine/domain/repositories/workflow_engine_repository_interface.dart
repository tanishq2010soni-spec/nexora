import '../../../../core/network/api_result.dart';
import '../models/workflow_definition.dart';
import '../models/workflow_execution_model.dart';

abstract class WorkflowEngineRepositoryInterface {
  Future<ApiResult<List<WorkflowDefinition>>> getWorkflows();
  Future<ApiResult<WorkflowDefinition>> getWorkflow(String id);
  Future<ApiResult<WorkflowDefinition>> createWorkflow(
    WorkflowDefinition workflow,
  );
  Future<ApiResult<WorkflowDefinition>> updateWorkflow(
    String id,
    WorkflowDefinition workflow,
  );
  Future<ApiResult<void>> deleteWorkflow(String id);
  Future<ApiResult<WorkflowDefinition>> toggleWorkflowStatus(
    String id,
    bool isActive,
  );
  Future<ApiResult<List<WorkflowExecutionModel>>> getExecutions(
    String workflowId,
  );
  Future<ApiResult<WorkflowExecutionModel>> getExecution(String id);
  Future<ApiResult<WorkflowExecutionModel>> triggerWorkflow(String workflowId);
  Future<ApiResult<WorkflowExecutionModel>> cancelExecution(String id);
}
