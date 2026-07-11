// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageImpl _$$MessageImplFromJson(Map<String, dynamic> json) =>
    _$MessageImpl(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      role: $enumDecode(_$MessageRoleEnumMap, json['role']),
      type: $enumDecode(_$MessageTypeEnumMap, json['type']),
      content: json['content'] as String,
      tokenCount: (json['tokenCount'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$MessageImplToJson(_$MessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conversationId': instance.conversationId,
      'role': _$MessageRoleEnumMap[instance.role]!,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'content': instance.content,
      'tokenCount': instance.tokenCount,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$MessageRoleEnumMap = {
  MessageRole.user: 'user',
  MessageRole.assistant: 'assistant',
  MessageRole.system: 'system',
};

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.image: 'image',
  MessageType.audio: 'audio',
  MessageType.file: 'file',
};
