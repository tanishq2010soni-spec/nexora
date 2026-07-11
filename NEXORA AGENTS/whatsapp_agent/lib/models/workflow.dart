class Workflow {
  final int id;
  final int organizationId;
  final String name;
  final String? description;
  final String triggerType;
  final Map<String, dynamic> triggerConfig;
  final List<WorkflowStep> steps;
  final bool isActive;
  final int executionCount;
  final DateTime? lastRunAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Workflow({
    required this.id,
    required this.organizationId,
    required this.name,
    this.description,
    this.triggerType = 'manual',
    this.triggerConfig = const {},
    this.steps = const [],
    this.isActive = true,
    this.executionCount = 0,
    this.lastRunAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Workflow.fromJson(Map<String, dynamic> json) {
    return Workflow(
      id: json['id'] as int,
      organizationId: json['organization_id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      triggerType: json['trigger_type'] as String? ?? 'manual',
      triggerConfig: (json['trigger_config'] as Map<String, dynamic>?) ?? const {},
      steps: (json['steps'] as List<dynamic>?)
              ?.map((e) => WorkflowStep.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isActive: json['is_active'] as bool? ?? true,
      executionCount: json['execution_count'] as int? ?? 0,
      lastRunAt: json['last_run_at'] != null
          ? DateTime.parse(json['last_run_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'name': name,
      'description': description,
      'trigger_type': triggerType,
      'trigger_config': triggerConfig,
      'steps': steps.map((s) => s.toJson()).toList(),
      'is_active': isActive,
      'execution_count': executionCount,
      'last_run_at': lastRunAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get triggerLabel {
    switch (triggerType) {
      case 'manual':
        return 'Manual';
      case 'incoming_message':
        return 'Incoming Message';
      case 'lead_created':
        return 'Lead Created';
      case 'scheduled':
        return 'Scheduled';
      case 'campaign_completed':
        return 'Campaign Completed';
      default:
        return triggerType;
    }
  }
}

class WorkflowStep {
  final String type;
  final Map<String, dynamic> config;
  final int order;

  WorkflowStep({
    required this.type,
    this.config = const {},
    this.order = 0,
  });

  factory WorkflowStep.fromJson(Map<String, dynamic> json) {
    return WorkflowStep(
      type: json['type'] as String,
      config: (json['config'] as Map<String, dynamic>?) ?? const {},
      order: json['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'config': config,
      'order': order,
    };
  }

  String get typeLabel {
    switch (type) {
      case 'send_message':
        return 'Send Message';
      case 'update_lead':
        return 'Update Lead';
      case 'assign_agent':
        return 'Assign Agent';
      case 'add_tag':
        return 'Add Tag';
      case 'webhook':
        return 'Webhook';
      case 'condition':
        return 'Condition';
      default:
        return type;
    }
  }
}

class WorkflowExecution {
  final int id;
  final int workflowId;
  final String status;
  final String? triggerData;
  final String? result;
  final String? error;
  final DateTime startedAt;
  final DateTime? completedAt;

  WorkflowExecution({
    required this.id,
    required this.workflowId,
    this.status = 'running',
    this.triggerData,
    this.result,
    this.error,
    required this.startedAt,
    this.completedAt,
  });

  factory WorkflowExecution.fromJson(Map<String, dynamic> json) {
    return WorkflowExecution(
      id: json['id'] as int,
      workflowId: json['workflow_id'] as int,
      status: json['status'] as String? ?? 'running',
      triggerData: json['trigger_data'] as String?,
      result: json['result'] as String?,
      error: json['error'] as String?,
      startedAt: DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workflow_id': workflowId,
      'status': status,
      'trigger_data': triggerData,
      'result': result,
      'error': error,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  String get statusLabel {
    switch (status) {
      case 'running':
        return 'Running';
      case 'completed':
        return 'Completed';
      case 'failed':
        return 'Failed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Duration get duration {
    if (completedAt == null) return Duration.zero;
    return completedAt!.difference(startedAt);
  }
}
