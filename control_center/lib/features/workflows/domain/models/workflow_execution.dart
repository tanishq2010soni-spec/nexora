import 'package:freezed_annotation/freezed_annotation.dart';

part 'workflow_execution.freezed.dart';
part 'workflow_execution.g.dart';

enum WorkflowExecutionStatus { running, completed, failed }

@freezed
class WorkflowExecution with _$WorkflowExecution {
  const factory WorkflowExecution({
    required String id,
    required String workflowId,
    String? triggerEvent,
    @Default(WorkflowExecutionStatus.running) WorkflowExecutionStatus status,
    String? inputJson,
    String? outputJson,
    String? errorMessage,
    required DateTime startedAt,
    DateTime? completedAt,
  }) = _WorkflowExecution;

  factory WorkflowExecution.fromJson(Map<String, dynamic> json) =>
      _$WorkflowExecutionFromJson(json);
}
