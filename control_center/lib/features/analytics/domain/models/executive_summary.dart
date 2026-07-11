import 'package:freezed_annotation/freezed_annotation.dart';

part 'executive_summary.freezed.dart';
part 'executive_summary.g.dart';

@freezed
class ExecutiveSummary with _$ExecutiveSummary {
  const factory ExecutiveSummary({
    required SummaryData summary,
    required KpiData kpis,
  }) = _ExecutiveSummary;

  factory ExecutiveSummary.fromJson(Map<String, dynamic> json) =>
      _$ExecutiveSummaryFromJson(json);
}

@freezed
class SummaryData with _$SummaryData {
  const factory SummaryData({
    @Default(0) int totalLeads,
    @Default(0) int leadsThisMonth,
    @Default(0) int leadsConverted,
    @Default(0) int totalCustomers,
    @Default(0) int totalAgents,
    @Default(0) int totalConversations,
    @Default(0) int openConversations,
    @Default(0) int messagesToday,
    @Default(0) int totalCalls,
    @Default(0) int callsThisWeek,
    @Default(0) int totalTasks,
    @Default(0) int pendingTasks,
    @Default(0) int completedTasks,
    @Default(0) int activeWorkflows,
  }) = _SummaryData;

  factory SummaryData.fromJson(Map<String, dynamic> json) =>
      _$SummaryDataFromJson(json);
}

@freezed
class KpiData with _$KpiData {
  const factory KpiData({
    @Default(0.0) double leadConversionRate,
    @Default(0) int avgResponseTimeSeconds,
    @Default(0.0) double agentUtilizationRate,
    @Default(0.0) double aiResolutionRate,
  }) = _KpiData;

  factory KpiData.fromJson(Map<String, dynamic> json) =>
      _$KpiDataFromJson(json);
}
