// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CustomerNoteImpl _$$CustomerNoteImplFromJson(Map<String, dynamic> json) =>
    _$CustomerNoteImpl(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      content: json['content'] as String,
      authorId: json['authorId'] as String?,
      authorName: json['authorName'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$CustomerNoteImplToJson(_$CustomerNoteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customerId': instance.customerId,
      'content': instance.content,
      'authorId': instance.authorId,
      'authorName': instance.authorName,
      'tags': instance.tags,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
