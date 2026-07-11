// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lead_analytics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LeadAnalyticsImpl _$$LeadAnalyticsImplFromJson(Map<String, dynamic> json) =>
    _$LeadAnalyticsImpl(
      totalLeads: (json['totalLeads'] as num?)?.toInt() ?? 0,
      qualifiedLeads: (json['qualifiedLeads'] as num?)?.toInt() ?? 0,
      wonLeads: (json['wonLeads'] as num?)?.toInt() ?? 0,
      lostLeads: (json['lostLeads'] as num?)?.toInt() ?? 0,
      conversionRate: (json['conversionRate'] as num?)?.toDouble() ?? 0.0,
      avgLeadScore: (json['avgLeadScore'] as num?)?.toDouble() ?? 0.0,
      newLeadsToday: (json['newLeadsToday'] as num?)?.toInt() ?? 0,
      qualifiedToday: (json['qualifiedToday'] as num?)?.toInt() ?? 0,
      wonToday: (json['wonToday'] as num?)?.toInt() ?? 0,
      sourceBreakdown: (json['sourceBreakdown'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      statusBreakdown: (json['statusBreakdown'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
    );

Map<String, dynamic> _$$LeadAnalyticsImplToJson(_$LeadAnalyticsImpl instance) =>
    <String, dynamic>{
      'totalLeads': instance.totalLeads,
      'qualifiedLeads': instance.qualifiedLeads,
      'wonLeads': instance.wonLeads,
      'lostLeads': instance.lostLeads,
      'conversionRate': instance.conversionRate,
      'avgLeadScore': instance.avgLeadScore,
      'newLeadsToday': instance.newLeadsToday,
      'qualifiedToday': instance.qualifiedToday,
      'wonToday': instance.wonToday,
      'sourceBreakdown': instance.sourceBreakdown,
      'statusBreakdown': instance.statusBreakdown,
    };
