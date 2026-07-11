// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lead_activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LeadActivityImpl _$$LeadActivityImplFromJson(Map<String, dynamic> json) =>
    _$LeadActivityImpl(
      id: json['id'] as String,
      leadId: json['leadId'] as String,
      type: $enumDecode(_$ActivityTypeEnumMap, json['type']),
      description: json['description'] as String,
      performedBy: json['performedBy'] as String?,
      oldValue: json['oldValue'] as String?,
      newValue: json['newValue'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$LeadActivityImplToJson(_$LeadActivityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'leadId': instance.leadId,
      'type': _$ActivityTypeEnumMap[instance.type]!,
      'description': instance.description,
      'performedBy': instance.performedBy,
      'oldValue': instance.oldValue,
      'newValue': instance.newValue,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$ActivityTypeEnumMap = {
  ActivityType.created: 'created',
  ActivityType.statusChanged: 'statusChanged',
  ActivityType.noteAdded: 'noteAdded',
  ActivityType.assigned: 'assigned',
  ActivityType.contacted: 'contacted',
  ActivityType.qualified: 'qualified',
  ActivityType.won: 'won',
  ActivityType.lost: 'lost',
  ActivityType.imported: 'imported',
};
