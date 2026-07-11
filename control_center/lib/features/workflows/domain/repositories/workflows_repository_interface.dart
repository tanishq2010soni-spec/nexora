import '../../../../core/network/api_result.dart';
import '../models/workflow_model.dart';
import '../models/workflow_execution.dart';

abstract class WorkflowsRepositoryInterface {
  Future<ApiResult<List<WorkflowModel>>> getWorkflows();

  Future<ApiResult<WorkflowModel>> getWorkflow(String id);

  Future<ApiResult<WorkflowModel>> createWorkflow({
    required String name,
    String? description,
    required WorkflowTriggerType triggerType,
    String? nodesJson,
    String? edgesJson,
  });

  Future<ApiResult<WorkflowModel>> updateWorkflow(
    String id, {
    String? name,
    String? description,
    WorkflowTriggerType? triggerType,
    bool? isActive,
    String? nodesJson,
    String? edgesJson,
  });

  Future<ApiResult<void>> deleteWorkflow(String id);

  Future<ApiResult<List<WorkflowExecution>>> getExecutions(String workflowId);

  Future<ApiResult<WorkflowExecution>> executeWorkflow(String workflowId);
}
