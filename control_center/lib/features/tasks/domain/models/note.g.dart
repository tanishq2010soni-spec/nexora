// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TaskNoteImpl _$$TaskNoteImplFromJson(Map<String, dynamic> json) =>
    _$TaskNoteImpl(
      id: json['id'] as String,
      orgId: json['orgId'] as String,
      entityType: json['entityType'] as String,
      entityId: json['entityId'] as String,
      content: json['content'] as String,
      createdBy: json['createdBy'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$TaskNoteImplToJson(_$TaskNoteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orgId': instance.orgId,
      'entityType': instance.entityType,
      'entityId': instance.entityId,
      'content': instance.content,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
    };
