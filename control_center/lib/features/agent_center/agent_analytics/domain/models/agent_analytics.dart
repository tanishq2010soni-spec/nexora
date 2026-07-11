import 'package:freezed_annotation/freezed_annotation.dart';

part 'agent_analytics.freezed.dart';
part 'agent_analytics.g.dart';

@freezed
class AgentAnalytics with _$AgentAnalytics {
  const factory AgentAnalytics({
    required String agentId,
    required String agentName,
    @Default(0) int totalMessages,
    @Default(0) int todayMessages,
    @Default(0) int totalCalls,
    @Default(0) int todayCalls,
    @Default(0.0) double successRate,
    @Default(0.0) double avgResponseTimeMs,
    @Default(0) int totalLeads,
    @Default(0) int todayLeads,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) = _AgentAnalytics;

  factory AgentAnalytics.fromJson(Map<String, dynamic> json) =>
      _$AgentAnalyticsFromJson(json);
}
