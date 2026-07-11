import '../enums/execution_status.dart';

class WorkflowExecutionModel {
  final String id;
  final String workflowId;
  final String orgId;
  final ExecutionStatus status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? inputJson;
  final String? outputJson;
  final String? errorMessage;
  final DateTime? createdAt;

  const WorkflowExecutionModel({
    required this.id,
    required this.workflowId,
    required this.orgId,
    this.status = ExecutionStatus.pending,
    this.startedAt,
    this.completedAt,
    this.inputJson,
    this.outputJson,
    this.errorMessage,
    this.createdAt,
  });

  factory WorkflowExecutionModel.fromJson(Map<String, dynamic> json) =>
      WorkflowExecutionModel(
        id: json['id'] as String,
        workflowId: json['workflow_id'] as String,
        orgId: json['org_id'] as String,
        status: json['status'] != null
            ? ExecutionStatus.fromJson(json['status'] as String)
            : ExecutionStatus.pending,
        startedAt: json['started_at'] != null
            ? DateTime.parse(json['started_at'] as String)
            : null,
        completedAt: json['completed_at'] != null
            ? DateTime.parse(json['completed_at'] as String)
            : null,
        inputJson: json['input_json'] as String?,
        outputJson: json['output_json'] as String?,
        errorMessage: json['error_message'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'workflow_id': workflowId,
    'org_id': orgId,
    'status': status.toJson(),
    'started_at': startedAt?.toIso8601String(),
    'completed_at': completedAt?.toIso8601String(),
    'input_json': inputJson,
    'output_json': outputJson,
    'error_message': errorMessage,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
  };
}
