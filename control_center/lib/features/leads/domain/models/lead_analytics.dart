import 'package:freezed_annotation/freezed_annotation.dart';

part 'lead_analytics.freezed.dart';
part 'lead_analytics.g.dart';

@freezed
class LeadAnalytics with _$LeadAnalytics {
  const factory LeadAnalytics({
    @Default(0) int totalLeads,
    @Default(0) int qualifiedLeads,
    @Default(0) int wonLeads,
    @Default(0) int lostLeads,
    @Default(0.0) double conversionRate,
    @Default(0.0) double avgLeadScore,
    @Default(0) int newLeadsToday,
    @Default(0) int qualifiedToday,
    @Default(0) int wonToday,
    Map<String, int>? sourceBreakdown,
    Map<String, int>? statusBreakdown,
  }) = _LeadAnalytics;

  factory LeadAnalytics.fromJson(Map<String, dynamic> json) =>
      _$LeadAnalyticsFromJson(json);
}
