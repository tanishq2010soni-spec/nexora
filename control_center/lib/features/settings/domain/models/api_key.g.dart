// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_key.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ApiKeyImpl _$$ApiKeyImplFromJson(Map<String, dynamic> json) => _$ApiKeyImpl(
  id: json['id'] as String,
  orgId: json['orgId'] as String,
  name: json['name'] as String,
  keyPrefix: json['keyPrefix'] as String,
  description: json['description'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  lastUsedAt: json['lastUsedAt'] == null
      ? null
      : DateTime.parse(json['lastUsedAt'] as String),
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  scopes: (json['scopes'] as List<dynamic>).map((e) => e as String).toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$ApiKeyImplToJson(_$ApiKeyImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orgId': instance.orgId,
      'name': instance.name,
      'keyPrefix': instance.keyPrefix,
      'description': instance.description,
      'isActive': instance.isActive,
      'lastUsedAt': instance.lastUsedAt?.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'scopes': instance.scopes,
      'createdAt': instance.createdAt.toIso8601String(),
    };
