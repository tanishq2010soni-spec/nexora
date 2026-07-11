import 'workflow_step.dart';

class WorkflowDefinition {
  final String id;
  final String orgId;
  final String name;
  final String? description;
  final String? triggerType;
  final String? triggerConfigJson;
  final bool isActive;
  final String version;
  final List<WorkflowStep> steps;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WorkflowDefinition({
    required this.id,
    required this.orgId,
    required this.name,
    this.description,
    this.triggerType,
    this.triggerConfigJson,
    this.isActive = true,
    this.version = '1.0.0',
    this.steps = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory WorkflowDefinition.fromJson(Map<String, dynamic> json) =>
      WorkflowDefinition(
        id: json['id'] as String,
        orgId: json['org_id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        triggerType: json['trigger_type'] as String?,
        triggerConfigJson: json['trigger_config_json'] as String?,
        isActive: json['is_active'] as bool? ?? true,
        version: json['version'] as String? ?? '1.0.0',
        steps: (json['steps'] as List<dynamic>?)
                ?.map((e) =>
                    WorkflowStep.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'org_id': orgId,
    'name': name,
    'description': description,
    'trigger_type': triggerType,
    'trigger_config_json': triggerConfigJson,
    'is_active': isActive,
    'version': version,
    'steps': steps.map((s) => s.toJson()).toList(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
