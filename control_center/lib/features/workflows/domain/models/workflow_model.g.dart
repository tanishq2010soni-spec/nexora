// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workflow_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkflowModelImpl _$$WorkflowModelImplFromJson(Map<String, dynamic> json) =>
    _$WorkflowModelImpl(
      id: json['id'] as String,
      orgId: json['orgId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      triggerType:
          $enumDecodeNullable(
            _$WorkflowTriggerTypeEnumMap,
            json['triggerType'],
          ) ??
          WorkflowTriggerType.manual,
      isActive: json['isActive'] as bool? ?? true,
      nodesJson: json['nodesJson'] as String? ?? '[]',
      edgesJson: json['edgesJson'] as String? ?? '[]',
      executionCount: (json['executionCount'] as num?)?.toInt() ?? 0,
      lastExecutedAt: json['lastExecutedAt'] == null
          ? null
          : DateTime.parse(json['lastExecutedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$WorkflowModelImplToJson(_$WorkflowModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orgId': instance.orgId,
      'name': instance.name,
      'description': instance.description,
      'triggerType': _$WorkflowTriggerTypeEnumMap[instance.triggerType]!,
      'isActive': instance.isActive,
      'nodesJson': instance.nodesJson,
      'edgesJson': instance.edgesJson,
      'executionCount': instance.executionCount,
      'lastExecutedAt': instance.lastExecutedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$WorkflowTriggerTypeEnumMap = {
  WorkflowTriggerType.newLead: 'newLead',
  WorkflowTriggerType.customerReplied: 'customerReplied',
  WorkflowTriggerType.callMissed: 'callMissed',
  WorkflowTriggerType.appointmentBooked: 'appointmentBooked',
  WorkflowTriggerType.manual: 'manual',
};
