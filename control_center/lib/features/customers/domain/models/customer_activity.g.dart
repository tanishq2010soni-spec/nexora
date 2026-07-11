// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CustomerActivityImpl _$$CustomerActivityImplFromJson(
  Map<String, dynamic> json,
) => _$CustomerActivityImpl(
  id: json['id'] as String,
  customerId: json['customerId'] as String,
  type: $enumDecode(_$CustomerActivityTypeEnumMap, json['type']),
  description: json['description'] as String,
  performedBy: json['performedBy'] as String?,
  performedByName: json['performedByName'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$CustomerActivityImplToJson(
  _$CustomerActivityImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'customerId': instance.customerId,
  'type': _$CustomerActivityTypeEnumMap[instance.type]!,
  'description': instance.description,
  'performedBy': instance.performedBy,
  'performedByName': instance.performedByName,
  'metadata': instance.metadata,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$CustomerActivityTypeEnumMap = {
  CustomerActivityType.leadConverted: 'leadConverted',
  CustomerActivityType.whatsappInteraction: 'whatsappInteraction',
  CustomerActivityType.callInteraction: 'callInteraction',
  CustomerActivityType.noteAdded: 'noteAdded',
  CustomerActivityType.statusChanged: 'statusChanged',
  CustomerActivityType.segmentChanged: 'segmentChanged',
};
