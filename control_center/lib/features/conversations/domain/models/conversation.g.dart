// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConversationImpl _$$ConversationImplFromJson(Map<String, dynamic> json) =>
    _$ConversationImpl(
      id: json['id'] as String,
      orgId: json['orgId'] as String,
      externalUserId: json['externalUserId'] as String,
      agentId: json['agentId'] as String,
      agentName: json['agentName'] as String,
      platform: $enumDecode(_$ConversationPlatformEnumMap, json['platform']),
      status: $enumDecode(_$ConversationStatusEnumMap, json['status']),
      messageCount: (json['messageCount'] as num?)?.toInt() ?? 0,
      callDurationSeconds: (json['callDurationSeconds'] as num?)?.toInt() ?? 0,
      lastMessagePreview: json['lastMessagePreview'] as String?,
      lastMessageAt: json['lastMessageAt'] == null
          ? null
          : DateTime.parse(json['lastMessageAt'] as String),
      assignedTo: json['assignedTo'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ConversationImplToJson(_$ConversationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orgId': instance.orgId,
      'externalUserId': instance.externalUserId,
      'agentId': instance.agentId,
      'agentName': instance.agentName,
      'platform': _$ConversationPlatformEnumMap[instance.platform]!,
      'status': _$ConversationStatusEnumMap[instance.status]!,
      'messageCount': instance.messageCount,
      'callDurationSeconds': instance.callDurationSeconds,
      'lastMessagePreview': instance.lastMessagePreview,
      'lastMessageAt': instance.lastMessageAt?.toIso8601String(),
      'assignedTo': instance.assignedTo,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$ConversationPlatformEnumMap = {
  ConversationPlatform.whatsapp: 'whatsapp',
  ConversationPlatform.calling: 'calling',
};

const _$ConversationStatusEnumMap = {
  ConversationStatus.active: 'active',
  ConversationStatus.resolved: 'resolved',
  ConversationStatus.pending: 'pending',
  ConversationStatus.archived: 'archived',
};
