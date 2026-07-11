// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'available_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AvailableModelImpl _$$AvailableModelImplFromJson(Map<String, dynamic> json) =>
    _$AvailableModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      provider: json['provider'] as String,
      description: json['description'] as String?,
      size: json['size'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? true,
    );

Map<String, dynamic> _$$AvailableModelImplToJson(
  _$AvailableModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'provider': instance.provider,
  'description': instance.description,
  'size': instance.size,
  'isAvailable': instance.isAvailable,
};
