import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation_analytics.freezed.dart';
part 'conversation_analytics.g.dart';

@freezed
class ConversationAnalytics with _$ConversationAnalytics {
  const factory ConversationAnalytics({
    @Default(0) int messagesToday,
    @Default(0) int callsToday,
    @Default(0) int activeConversations,
    @Default(0) double resolutionRate,
    @Default(0.0) double avgResponseTimeMs,
    @Default(0) int totalConversations,
    @Default(0) int resolvedToday,
    @Default(0) int pendingConversations,
  }) = _ConversationAnalytics;

  factory ConversationAnalytics.fromJson(Map<String, dynamic> json) =>
      _$ConversationAnalyticsFromJson(json);
}
