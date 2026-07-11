import 'package:freezed_annotation/freezed_annotation.dart';

part 'call_analytics.freezed.dart';
part 'call_analytics.g.dart';

@freezed
class CallAnalytics with _$CallAnalytics {
  const factory CallAnalytics({
    @Default(0) int totalCalls,
    @Default(0) int inboundCalls,
    @Default(0) int outboundCalls,
    @Default(0) int completedCalls,
    @Default(0) int missedCalls,
    @Default(0) int totalDurationSeconds,
    @Default(0.0) double avgDurationSeconds,
    @Default(0.0) double answerRate,
    @Default({}) Map<String, int> sentimentBreakdown,
    @Default({}) Map<String, int> outcomeBreakdown,
  }) = _CallAnalytics;

  factory CallAnalytics.fromJson(Map<String, dynamic> json) =>
      _$CallAnalyticsFromJson(json);
}
