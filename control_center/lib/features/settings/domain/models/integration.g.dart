// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'integration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IntegrationImpl _$$IntegrationImplFromJson(Map<String, dynamic> json) =>
    _$IntegrationImpl(
      id: json['id'] as String,
      orgId: json['orgId'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String?,
      status:
          $enumDecodeNullable(_$IntegrationStatusEnumMap, json['status']) ??
          IntegrationStatus.disconnected,
      config:
          (json['config'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const <String, String>{},
      connectedAt: json['connectedAt'] == null
          ? null
          : DateTime.parse(json['connectedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$IntegrationImplToJson(_$IntegrationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orgId': instance.orgId,
      'name': instance.name,
      'type': instance.type,
      'description': instance.description,
      'logoUrl': instance.logoUrl,
      'status': _$IntegrationStatusEnumMap[instance.status]!,
      'config': instance.config,
      'connectedAt': instance.connectedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$IntegrationStatusEnumMap = {
  IntegrationStatus.connected: 'connected',
  IntegrationStatus.disconnected: 'disconnected',
  IntegrationStatus.error: 'error',
};
