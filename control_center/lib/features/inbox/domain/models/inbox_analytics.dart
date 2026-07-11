import 'package:freezed_annotation/freezed_annotation.dart';

part 'inbox_analytics.freezed.dart';
part 'inbox_analytics.g.dart';

@freezed
class InboxAnalytics with _$InboxAnalytics {
  const factory InboxAnalytics({
    @Default(0) int totalConversations,
    @Default(0) int openConversations,
    @Default(0) int closedConversations,
    @Default(0) int aiMode,
    @Default(0) int humanMode,
    @Default(0) int messagesToday,
    @Default(<String, int>{}) Map<String, int> channelBreakdown,
    @Default(0.0) double aiResolutionRate,
    @Default(0.0) double humanResolutionRate,
  }) = _InboxAnalytics;

  factory InboxAnalytics.fromJson(Map<String, dynamic> json) =>
      _$InboxAnalyticsFromJson(json);
}
