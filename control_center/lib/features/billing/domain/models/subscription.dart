import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription.freezed.dart';
part 'subscription.g.dart';

@freezed
class Subscription with _$Subscription {
  const factory Subscription({
    required String id,
    required String orgId,
    required String planId,
    required String planName,
    required String status,
    required double amount,
    required String interval,
    DateTime? currentPeriodStart,
    DateTime? currentPeriodEnd,
    DateTime? cancelAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Subscription;

  factory Subscription.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionFromJson(json);
}
