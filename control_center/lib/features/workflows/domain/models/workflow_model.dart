import 'package:freezed_annotation/freezed_annotation.dart';

part 'workflow_model.freezed.dart';
part 'workflow_model.g.dart';

enum WorkflowTriggerType {
  newLead,
  customerReplied,
  callMissed,
  appointmentBooked,
  manual,
}

@freezed
class WorkflowModel with _$WorkflowModel {
  const factory WorkflowModel({
    required String id,
    required String orgId,
    required String name,
    String? description,
    @Default(WorkflowTriggerType.manual) WorkflowTriggerType triggerType,
    @Default(true) bool isActive,
    @Default('[]') String nodesJson,
    @Default('[]') String edgesJson,
    @Default(0) int executionCount,
    DateTime? lastExecutedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _WorkflowModel;

  factory WorkflowModel.fromJson(Map<String, dynamic> json) =>
      _$WorkflowModelFromJson(json);
}
