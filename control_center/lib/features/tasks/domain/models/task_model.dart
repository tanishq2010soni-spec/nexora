import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_model.freezed.dart';
part 'task_model.g.dart';

enum TaskPriority { low, medium, high, urgent }

enum TaskStatus { pending, inProgress, completed, cancelled }

@freezed
class TaskModel with _$TaskModel {
  const factory TaskModel({
    required String id,
    required String orgId,
    required String title,
    String? description,
    @Default(TaskPriority.medium) TaskPriority priority,
    @Default(TaskStatus.pending) TaskStatus status,
    String? assignedTo,
    DateTime? dueDate,
    DateTime? reminderAt,
    String? entityType,
    String? entityId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TaskModel;

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);
}
