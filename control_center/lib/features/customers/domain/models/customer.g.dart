// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CustomerImpl _$$CustomerImplFromJson(Map<String, dynamic> json) =>
    _$CustomerImpl(
      id: json['id'] as String,
      orgId: json['orgId'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      company: json['company'] as String?,
      jobTitle: json['jobTitle'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      segment:
          $enumDecodeNullable(_$CustomerSegmentEnumMap, json['segment']) ??
          CustomerSegment.newCustomer,
      healthScore: (json['healthScore'] as num?)?.toInt() ?? 0,
      engagementScore: (json['engagementScore'] as num?)?.toInt() ?? 0,
      retentionScore: (json['retentionScore'] as num?)?.toInt() ?? 0,
      satisfactionScore: (json['satisfactionScore'] as num?)?.toInt() ?? 0,
      revenueScore: (json['revenueScore'] as num?)?.toInt() ?? 0,
      assignedTo: json['assignedTo'] as String?,
      assignedToName: json['assignedToName'] as String?,
      leadId: json['leadId'] as String?,
      totalInteractions: (json['totalInteractions'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      preferences: json['preferences'] as Map<String, dynamic>?,
      memory: json['memory'] as Map<String, dynamic>?,
      lastInteractionAt: json['lastInteractionAt'] == null
          ? null
          : DateTime.parse(json['lastInteractionAt'] as String),
      lastPurchaseAt: json['lastPurchaseAt'] == null
          ? null
          : DateTime.parse(json['lastPurchaseAt'] as String),
      churnedAt: json['churnedAt'] == null
          ? null
          : DateTime.parse(json['churnedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$CustomerImplToJson(_$CustomerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orgId': instance.orgId,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'company': instance.company,
      'jobTitle': instance.jobTitle,
      'avatarUrl': instance.avatarUrl,
      'segment': _$CustomerSegmentEnumMap[instance.segment]!,
      'healthScore': instance.healthScore,
      'engagementScore': instance.engagementScore,
      'retentionScore': instance.retentionScore,
      'satisfactionScore': instance.satisfactionScore,
      'revenueScore': instance.revenueScore,
      'assignedTo': instance.assignedTo,
      'assignedToName': instance.assignedToName,
      'leadId': instance.leadId,
      'totalInteractions': instance.totalInteractions,
      'totalRevenue': instance.totalRevenue,
      'tags': instance.tags,
      'preferences': instance.preferences,
      'memory': instance.memory,
      'lastInteractionAt': instance.lastInteractionAt?.toIso8601String(),
      'lastPurchaseAt': instance.lastPurchaseAt?.toIso8601String(),
      'churnedAt': instance.churnedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$CustomerSegmentEnumMap = {
  CustomerSegment.newCustomer: 'newCustomer',
  CustomerSegment.active: 'active',
  CustomerSegment.vip: 'vip',
  CustomerSegment.atRisk: 'atRisk',
  CustomerSegment.churned: 'churned',
};
