// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lead_note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LeadNoteImpl _$$LeadNoteImplFromJson(Map<String, dynamic> json) =>
    _$LeadNoteImpl(
      id: json['id'] as String,
      leadId: json['leadId'] as String,
      content: json['content'] as String,
      authorName: json['authorName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$LeadNoteImplToJson(_$LeadNoteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'leadId': instance.leadId,
      'content': instance.content,
      'authorName': instance.authorName,
      'createdAt': instance.createdAt.toIso8601String(),
    };
