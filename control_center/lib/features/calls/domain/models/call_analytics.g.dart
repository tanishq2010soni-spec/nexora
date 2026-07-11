// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_analytics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CallAnalyticsImpl _$$CallAnalyticsImplFromJson(
  Map<String, dynamic> json,
) => _$CallAnalyticsImpl(
  totalCalls: (json['totalCalls'] as num?)?.toInt() ?? 0,
  inboundCalls: (json['inboundCalls'] as num?)?.toInt() ?? 0,
  outboundCalls: (json['outboundCalls'] as num?)?.toInt() ?? 0,
  completedCalls: (json['completedCalls'] as num?)?.toInt() ?? 0,
  missedCalls: (json['missedCalls'] as num?)?.toInt() ?? 0,
  totalDurationSeconds: (json['totalDurationSeconds'] as num?)?.toInt() ?? 0,
  avgDurationSeconds: (json['avgDurationSeconds'] as num?)?.toDouble() ?? 0.0,
  answerRate: (json['answerRate'] as num?)?.toDouble() ?? 0.0,
  sentimentBreakdown:
      (json['sentimentBreakdown'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
  outcomeBreakdown:
      (json['outcomeBreakdown'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
);

Map<String, dynamic> _$$CallAnalyticsImplToJson(_$CallAnalyticsImpl instance) =>
    <String, dynamic>{
      'totalCalls': instance.totalCalls,
      'inboundCalls': instance.inboundCalls,
      'outboundCalls': instance.outboundCalls,
      'completedCalls': instance.completedCalls,
      'missedCalls': instance.missedCalls,
      'totalDurationSeconds': instance.totalDurationSeconds,
      'avgDurationSeconds': instance.avgDurationSeconds,
      'answerRate': instance.answerRate,
      'sentimentBreakdown': instance.sentimentBreakdown,
      'outcomeBreakdown': instance.outcomeBreakdown,
    };
