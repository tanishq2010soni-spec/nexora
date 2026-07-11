// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_conversation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InboxConversationImpl _$$InboxConversationImplFromJson(
  Map<String, dynamic> json,
) => _$InboxConversationImpl(
  id: json['id'] as String,
  orgId: json['orgId'] as String,
  customerId: json['customerId'] as String,
  channel: $enumDecode(_$InboxChannelEnumMap, json['channel']),
  platformUserId: json['platformUserId'] as String,
  customerName: json['customerName'] as String,
  customerPhone: json['customerPhone'] as String?,
  customerEmail: json['customerEmail'] as String?,
  lastMessage: json['lastMessage'] as String?,
  unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
  status: $enumDecode(_$InboxStatusEnumMap, json['status']),
  assignedTo: json['assignedTo'] as String?,
  assignedToName: json['assignedToName'] as String?,
  takeoverMode: $enumDecode(_$TakeoverModeEnumMap, json['takeoverMode']),
  messageCount: (json['messageCount'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$InboxConversationImplToJson(
  _$InboxConversationImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'orgId': instance.orgId,
  'customerId': instance.customerId,
  'channel': _$InboxChannelEnumMap[instance.channel]!,
  'platformUserId': instance.platformUserId,
  'customerName': instance.customerName,
  'customerPhone': instance.customerPhone,
  'customerEmail': instance.customerEmail,
  'lastMessage': instance.lastMessage,
  'unreadCount': instance.unreadCount,
  'status': _$InboxStatusEnumMap[instance.status]!,
  'assignedTo': instance.assignedTo,
  'assignedToName': instance.assignedToName,
  'takeoverMode': _$TakeoverModeEnumMap[instance.takeoverMode]!,
  'messageCount': instance.messageCount,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$InboxChannelEnumMap = {
  InboxChannel.whatsapp: 'whatsapp',
  InboxChannel.instagram: 'instagram',
  InboxChannel.facebook: 'facebook',
  InboxChannel.website: 'website',
};

const _$InboxStatusEnumMap = {
  InboxStatus.open: 'open',
  InboxStatus.closed: 'closed',
  InboxStatus.pending: 'pending',
};

const _$TakeoverModeEnumMap = {
  TakeoverMode.ai: 'ai',
  TakeoverMode.human: 'human',
};
