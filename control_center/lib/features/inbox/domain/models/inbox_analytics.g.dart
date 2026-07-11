// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_analytics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InboxAnalyticsImpl _$$InboxAnalyticsImplFromJson(Map<String, dynamic> json) =>
    _$InboxAnalyticsImpl(
      totalConversations: (json['totalConversations'] as num?)?.toInt() ?? 0,
      openConversations: (json['openConversations'] as num?)?.toInt() ?? 0,
      closedConversations: (json['closedConversations'] as num?)?.toInt() ?? 0,
      aiMode: (json['aiMode'] as num?)?.toInt() ?? 0,
      humanMode: (json['humanMode'] as num?)?.toInt() ?? 0,
      messagesToday: (json['messagesToday'] as num?)?.toInt() ?? 0,
      channelBreakdown:
          (json['channelBreakdown'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const <String, int>{},
      aiResolutionRate: (json['aiResolutionRate'] as num?)?.toDouble() ?? 0.0,
      humanResolutionRate:
          (json['humanResolutionRate'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$InboxAnalyticsImplToJson(
  _$InboxAnalyticsImpl instance,
) => <String, dynamic>{
  'totalConversations': instance.totalConversations,
  'openConversations': instance.openConversations,
  'closedConversations': instance.closedConversations,
  'aiMode': instance.aiMode,
  'humanMode': instance.humanMode,
  'messagesToday': instance.messagesToday,
  'channelBreakdown': instance.channelBreakdown,
  'aiResolutionRate': instance.aiResolutionRate,
  'humanResolutionRate': instance.humanResolutionRate,
};
