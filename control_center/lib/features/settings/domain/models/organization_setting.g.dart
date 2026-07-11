// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_setting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrganizationSettingImpl _$$OrganizationSettingImplFromJson(
  Map<String, dynamic> json,
) => _$OrganizationSettingImpl(
  id: json['id'] as String,
  orgId: json['orgId'] as String,
  key: json['key'] as String,
  value: json['value'] as String,
  description: json['description'] as String?,
  category: json['category'] as String?,
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$OrganizationSettingImplToJson(
  _$OrganizationSettingImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'orgId': instance.orgId,
  'key': instance.key,
  'value': instance.value,
  'description': instance.description,
  'category': instance.category,
  'updatedAt': instance.updatedAt.toIso8601String(),
};
