// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_analytics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConversationAnalyticsImpl _$$ConversationAnalyticsImplFromJson(
  Map<String, dynamic> json,
) => _$ConversationAnalyticsImpl(
  messagesToday: (json['messagesToday'] as num?)?.toInt() ?? 0,
  callsToday: (json['callsToday'] as num?)?.toInt() ?? 0,
  activeConversations: (json['activeConversations'] as num?)?.toInt() ?? 0,
  resolutionRate: (json['resolutionRate'] as num?)?.toDouble() ?? 0,
  avgResponseTimeMs: (json['avgResponseTimeMs'] as num?)?.toDouble() ?? 0.0,
  totalConversations: (json['totalConversations'] as num?)?.toInt() ?? 0,
  resolvedToday: (json['resolvedToday'] as num?)?.toInt() ?? 0,
  pendingConversations: (json['pendingConversations'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$ConversationAnalyticsImplToJson(
  _$ConversationAnalyticsImpl instance,
) => <String, dynamic>{
  'messagesToday': instance.messagesToday,
  'callsToday': instance.callsToday,
  'activeConversations': instance.activeConversations,
  'resolutionRate': instance.resolutionRate,
  'avgResponseTimeMs': instance.avgResponseTimeMs,
  'totalConversations': instance.totalConversations,
  'resolvedToday': instance.resolvedToday,
  'pendingConversations': instance.pendingConversations,
};
