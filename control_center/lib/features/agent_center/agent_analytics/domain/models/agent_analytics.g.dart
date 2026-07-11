// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_analytics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AgentAnalyticsImpl _$$AgentAnalyticsImplFromJson(Map<String, dynamic> json) =>
    _$AgentAnalyticsImpl(
      agentId: json['agentId'] as String,
      agentName: json['agentName'] as String,
      totalMessages: (json['totalMessages'] as num?)?.toInt() ?? 0,
      todayMessages: (json['todayMessages'] as num?)?.toInt() ?? 0,
      totalCalls: (json['totalCalls'] as num?)?.toInt() ?? 0,
      todayCalls: (json['todayCalls'] as num?)?.toInt() ?? 0,
      successRate: (json['successRate'] as num?)?.toDouble() ?? 0.0,
      avgResponseTimeMs: (json['avgResponseTimeMs'] as num?)?.toDouble() ?? 0.0,
      totalLeads: (json['totalLeads'] as num?)?.toInt() ?? 0,
      todayLeads: (json['todayLeads'] as num?)?.toInt() ?? 0,
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
    );

Map<String, dynamic> _$$AgentAnalyticsImplToJson(
  _$AgentAnalyticsImpl instance,
) => <String, dynamic>{
  'agentId': instance.agentId,
  'agentName': instance.agentName,
  'totalMessages': instance.totalMessages,
  'todayMessages': instance.todayMessages,
  'totalCalls': instance.totalCalls,
  'todayCalls': instance.todayCalls,
  'successRate': instance.successRate,
  'avgResponseTimeMs': instance.avgResponseTimeMs,
  'totalLeads': instance.totalLeads,
  'todayLeads': instance.todayLeads,
  'periodStart': instance.periodStart.toIso8601String(),
  'periodEnd': instance.periodEnd.toIso8601String(),
};
