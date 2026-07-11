import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_stats.freezed.dart';
part 'dashboard_stats.g.dart';

@freezed
class DashboardStats with _$DashboardStats {
  const factory DashboardStats({
    @Default(0) int activeAgents,
    @Default(0) int messagesToday,
    @Default(0) int callsToday,
    @Default(0) int leadsGenerated,
    @Default(0) int customersManaged,
    @Default('healthy') String systemHealth,
  }) = _DashboardStats;

  factory DashboardStats.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatsFromJson(_convertKeys(json));

  static Map<String, dynamic> _convertKeys(Map<String, dynamic> json) {
    return {
      'activeAgents': json['active_agents'],
      'messagesToday': json['messages_today'],
      'callsToday': json['calls_today'],
      'leadsGenerated': json['leads_generated'],
      'customersManaged': json['customers_managed'],
      'systemHealth': json['system_health'],
    };
  }
}
