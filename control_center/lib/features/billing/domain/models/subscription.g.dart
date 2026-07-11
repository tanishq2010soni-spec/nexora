// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubscriptionImpl _$$SubscriptionImplFromJson(Map<String, dynamic> json) =>
    _$SubscriptionImpl(
      id: json['id'] as String,
      orgId: json['orgId'] as String,
      planId: json['planId'] as String,
      planName: json['planName'] as String,
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble(),
      interval: json['interval'] as String,
      currentPeriodStart: json['currentPeriodStart'] == null
          ? null
          : DateTime.parse(json['currentPeriodStart'] as String),
      currentPeriodEnd: json['currentPeriodEnd'] == null
          ? null
          : DateTime.parse(json['currentPeriodEnd'] as String),
      cancelAt: json['cancelAt'] == null
          ? null
          : DateTime.parse(json['cancelAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$SubscriptionImplToJson(_$SubscriptionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orgId': instance.orgId,
      'planId': instance.planId,
      'planName': instance.planName,
      'status': instance.status,
      'amount': instance.amount,
      'interval': instance.interval,
      'currentPeriodStart': instance.currentPeriodStart?.toIso8601String(),
      'currentPeriodEnd': instance.currentPeriodEnd?.toIso8601String(),
      'cancelAt': instance.cancelAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
