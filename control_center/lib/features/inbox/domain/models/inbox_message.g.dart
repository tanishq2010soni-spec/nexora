// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InboxMessageImpl _$$InboxMessageImplFromJson(Map<String, dynamic> json) =>
    _$InboxMessageImpl(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      senderType: $enumDecode(_$MessageSenderTypeEnumMap, json['senderType']),
      content: json['content'] as String,
      channel: json['channel'] as String,
      attachmentUrl: json['attachmentUrl'] as String?,
      attachmentType: json['attachmentType'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      platformMessageId: json['platformMessageId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$InboxMessageImplToJson(_$InboxMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conversationId': instance.conversationId,
      'senderType': _$MessageSenderTypeEnumMap[instance.senderType]!,
      'content': instance.content,
      'channel': instance.channel,
      'attachmentUrl': instance.attachmentUrl,
      'attachmentType': instance.attachmentType,
      'isRead': instance.isRead,
      'platformMessageId': instance.platformMessageId,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$MessageSenderTypeEnumMap = {
  MessageSenderType.user: 'user',
  MessageSenderType.bot: 'bot',
  MessageSenderType.agent: 'agent',
  MessageSenderType.system: 'system',
};
