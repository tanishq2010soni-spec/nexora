// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DashboardStatsImpl _$$DashboardStatsImplFromJson(Map<String, dynamic> json) =>
    _$DashboardStatsImpl(
      activeAgents: (json['activeAgents'] as num?)?.toInt() ?? 0,
      messagesToday: (json['messagesToday'] as num?)?.toInt() ?? 0,
      callsToday: (json['callsToday'] as num?)?.toInt() ?? 0,
      leadsGenerated: (json['leadsGenerated'] as num?)?.toInt() ?? 0,
      customersManaged: (json['customersManaged'] as num?)?.toInt() ?? 0,
      systemHealth: json['systemHealth'] as String? ?? 'healthy',
    );

Map<String, dynamic> _$$DashboardStatsImplToJson(
  _$DashboardStatsImpl instance,
) => <String, dynamic>{
  'activeAgents': instance.activeAgents,
  'messagesToday': instance.messagesToday,
  'callsToday': instance.callsToday,
  'leadsGenerated': instance.leadsGenerated,
  'customersManaged': instance.customersManaged,
  'systemHealth': instance.systemHealth,
};
