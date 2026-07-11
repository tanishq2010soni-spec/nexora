import '../enums/step_type.dart';

class WorkflowStep {
  final String id;
  final String workflowId;
  final StepType stepType;
  final int order;
  final String? configJson;
  final List<String> dependsOnStepIds;

  const WorkflowStep({
    required this.id,
    required this.workflowId,
    required this.stepType,
    this.order = 0,
    this.configJson,
    this.dependsOnStepIds = const [],
  });

  factory WorkflowStep.fromJson(Map<String, dynamic> json) => WorkflowStep(
    id: json['id'] as String,
    workflowId: json['workflow_id'] as String,
    stepType: StepType.fromJson(json['step_type'] as String),
    order: json['order'] as int? ?? 0,
    configJson: json['config_json'] as String?,
    dependsOnStepIds: (json['depends_on_step_ids'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        const [],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'workflow_id': workflowId,
    'step_type': stepType.toJson(),
    'order': order,
    'config_json': configJson,
    'depends_on_step_ids': dependsOnStepIds,
  };
}
