// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workflow_execution.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkflowExecutionImpl _$$WorkflowExecutionImplFromJson(
  Map<String, dynamic> json,
) => _$WorkflowExecutionImpl(
  id: json['id'] as String,
  workflowId: json['workflowId'] as String,
  triggerEvent: json['triggerEvent'] as String?,
  status:
      $enumDecodeNullable(_$WorkflowExecutionStatusEnumMap, json['status']) ??
      WorkflowExecutionStatus.running,
  inputJson: json['inputJson'] as String?,
  outputJson: json['outputJson'] as String?,
  errorMessage: json['errorMessage'] as String?,
  startedAt: DateTime.parse(json['startedAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
);

Map<String, dynamic> _$$WorkflowExecutionImplToJson(
  _$WorkflowExecutionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'workflowId': instance.workflowId,
  'triggerEvent': instance.triggerEvent,
  'status': _$WorkflowExecutionStatusEnumMap[instance.status]!,
  'inputJson': instance.inputJson,
  'outputJson': instance.outputJson,
  'errorMessage': instance.errorMessage,
  'startedAt': instance.startedAt.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
};

const _$WorkflowExecutionStatusEnumMap = {
  WorkflowExecutionStatus.running: 'running',
  WorkflowExecutionStatus.completed: 'completed',
  WorkflowExecutionStatus.failed: 'failed',
};
