import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer_analytics.freezed.dart';
part 'customer_analytics.g.dart';

@freezed
class CustomerAnalytics with _$CustomerAnalytics {
  const factory CustomerAnalytics({
    required int totalCustomers,
    required int activeCustomers,
    required int vipCustomers,
    required int churnRiskCount,
    required double averageHealthScore,
    @Default({}) Map<String, int> segmentBreakdown,
    @Default({}) Map<String, int> healthDistribution,
  }) = _CustomerAnalytics;

  factory CustomerAnalytics.fromJson(Map<String, dynamic> json) =>
      _$CustomerAnalyticsFromJson(json);
}
