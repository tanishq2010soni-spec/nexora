class TaskStep {
  final String id;
  final String description;
  final String status;
  final String? result;
  final String? error;

  const TaskStep({
    required this.id,
    required this.description,
    required this.status,
    this.result,
    this.error,
  });

  factory TaskStep.fromJson(Map<String, dynamic> json) {
    return TaskStep(
      id: json['id'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      result: json['result'] as String?,
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'description': description,
    'status': status,
    'result': result,
    'error': error,
  };
}

class Task {
  final String id;
  final String goal;
  final String status;
  final List<TaskStep> steps;
  final DateTime createdAt;
  final DateTime? completedAt;

  const Task({
    required this.id,
    required this.goal,
    required this.status,
    this.steps = const [],
    required this.createdAt,
    this.completedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      goal: json['goal'] as String,
      status: json['status'] as String,
      steps: (json['steps'] as List<dynamic>?)
              ?.map((e) => TaskStep.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'goal': goal,
    'status': status,
    'steps': steps.map((e) => e.toJson()).toList(),
    'created_at': createdAt.toIso8601String(),
    'completed_at': completedAt?.toIso8601String(),
  };
}
