// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_analytics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CustomerAnalyticsImpl _$$CustomerAnalyticsImplFromJson(
  Map<String, dynamic> json,
) => _$CustomerAnalyticsImpl(
  totalCustomers: (json['totalCustomers'] as num).toInt(),
  activeCustomers: (json['activeCustomers'] as num).toInt(),
  vipCustomers: (json['vipCustomers'] as num).toInt(),
  churnRiskCount: (json['churnRiskCount'] as num).toInt(),
  averageHealthScore: (json['averageHealthScore'] as num).toDouble(),
  segmentBreakdown:
      (json['segmentBreakdown'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
  healthDistribution:
      (json['healthDistribution'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
);

Map<String, dynamic> _$$CustomerAnalyticsImplToJson(
  _$CustomerAnalyticsImpl instance,
) => <String, dynamic>{
  'totalCustomers': instance.totalCustomers,
  'activeCustomers': instance.activeCustomers,
  'vipCustomers': instance.vipCustomers,
  'churnRiskCount': instance.churnRiskCount,
  'averageHealthScore': instance.averageHealthScore,
  'segmentBreakdown': instance.segmentBreakdown,
  'healthDistribution': instance.healthDistribution,
};
