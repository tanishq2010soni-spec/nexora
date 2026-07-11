// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'executive_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExecutiveSummaryImpl _$$ExecutiveSummaryImplFromJson(
  Map<String, dynamic> json,
) => _$ExecutiveSummaryImpl(
  summary: SummaryData.fromJson(json['summary'] as Map<String, dynamic>),
  kpis: KpiData.fromJson(json['kpis'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$ExecutiveSummaryImplToJson(
  _$ExecutiveSummaryImpl instance,
) => <String, dynamic>{'summary': instance.summary, 'kpis': instance.kpis};

_$SummaryDataImpl _$$SummaryDataImplFromJson(Map<String, dynamic> json) =>
    _$SummaryDataImpl(
      totalLeads: (json['totalLeads'] as num?)?.toInt() ?? 0,
      leadsThisMonth: (json['leadsThisMonth'] as num?)?.toInt() ?? 0,
      leadsConverted: (json['leadsConverted'] as num?)?.toInt() ?? 0,
      totalCustomers: (json['totalCustomers'] as num?)?.toInt() ?? 0,
      totalAgents: (json['totalAgents'] as num?)?.toInt() ?? 0,
      totalConversations: (json['totalConversations'] as num?)?.toInt() ?? 0,
      openConversations: (json['openConversations'] as num?)?.toInt() ?? 0,
      messagesToday: (json['messagesToday'] as num?)?.toInt() ?? 0,
      totalCalls: (json['totalCalls'] as num?)?.toInt() ?? 0,
      callsThisWeek: (json['callsThisWeek'] as num?)?.toInt() ?? 0,
      totalTasks: (json['totalTasks'] as num?)?.toInt() ?? 0,
      pendingTasks: (json['pendingTasks'] as num?)?.toInt() ?? 0,
      completedTasks: (json['completedTasks'] as num?)?.toInt() ?? 0,
      activeWorkflows: (json['activeWorkflows'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$SummaryDataImplToJson(_$SummaryDataImpl instance) =>
    <String, dynamic>{
      'totalLeads': instance.totalLeads,
      'leadsThisMonth': instance.leadsThisMonth,
      'leadsConverted': instance.leadsConverted,
      'totalCustomers': instance.totalCustomers,
      'totalAgents': instance.totalAgents,
      'totalConversations': instance.totalConversations,
      'openConversations': instance.openConversations,
      'messagesToday': instance.messagesToday,
      'totalCalls': instance.totalCalls,
      'callsThisWeek': instance.callsThisWeek,
      'totalTasks': instance.totalTasks,
      'pendingTasks': instance.pendingTasks,
      'completedTasks': instance.completedTasks,
      'activeWorkflows': instance.activeWorkflows,
    };

_$KpiDataImpl _$$KpiDataImplFromJson(Map<String, dynamic> json) =>
    _$KpiDataImpl(
      leadConversionRate:
          (json['leadConversionRate'] as num?)?.toDouble() ?? 0.0,
      avgResponseTimeSeconds:
          (json['avgResponseTimeSeconds'] as num?)?.toInt() ?? 0,
      agentUtilizationRate:
          (json['agentUtilizationRate'] as num?)?.toDouble() ?? 0.0,
      aiResolutionRate: (json['aiResolutionRate'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$KpiDataImplToJson(_$KpiDataImpl instance) =>
    <String, dynamic>{
      'leadConversionRate': instance.leadConversionRate,
      'avgResponseTimeSeconds': instance.avgResponseTimeSeconds,
      'agentUtilizationRate': instance.agentUtilizationRate,
      'aiResolutionRate': instance.aiResolutionRate,
    };
