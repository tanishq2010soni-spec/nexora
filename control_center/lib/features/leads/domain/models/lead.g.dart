// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lead.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LeadImpl _$$LeadImplFromJson(Map<String, dynamic> json) => _$LeadImpl(
  id: json['id'] as String,
  orgId: json['orgId'] as String,
  name: json['name'] as String,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  company: json['company'] as String?,
  jobTitle: json['jobTitle'] as String?,
  status:
      $enumDecodeNullable(_$LeadStatusEnumMap, json['status']) ??
      LeadStatus.newLead,
  source:
      $enumDecodeNullable(_$LeadSourceEnumMap, json['source']) ??
      LeadSource.manual,
  assignedTo: json['assignedTo'] as String?,
  assignedToName: json['assignedToName'] as String?,
  aiScore: (json['aiScore'] as num?)?.toInt() ?? 0,
  intentScore: (json['intentScore'] as num?)?.toInt() ?? 0,
  budgetScore: (json['budgetScore'] as num?)?.toInt() ?? 0,
  engagementScore: (json['engagementScore'] as num?)?.toInt() ?? 0,
  notes: json['notes'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
  conversationId: json['conversationId'] as String?,
  lastContactedAt: json['lastContactedAt'] == null
      ? null
      : DateTime.parse(json['lastContactedAt'] as String),
  qualifiedAt: json['qualifiedAt'] == null
      ? null
      : DateTime.parse(json['qualifiedAt'] as String),
  wonAt: json['wonAt'] == null ? null : DateTime.parse(json['wonAt'] as String),
  lostAt: json['lostAt'] == null
      ? null
      : DateTime.parse(json['lostAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$LeadImplToJson(_$LeadImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orgId': instance.orgId,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'company': instance.company,
      'jobTitle': instance.jobTitle,
      'status': _$LeadStatusEnumMap[instance.status]!,
      'source': _$LeadSourceEnumMap[instance.source]!,
      'assignedTo': instance.assignedTo,
      'assignedToName': instance.assignedToName,
      'aiScore': instance.aiScore,
      'intentScore': instance.intentScore,
      'budgetScore': instance.budgetScore,
      'engagementScore': instance.engagementScore,
      'notes': instance.notes,
      'metadata': instance.metadata,
      'conversationId': instance.conversationId,
      'lastContactedAt': instance.lastContactedAt?.toIso8601String(),
      'qualifiedAt': instance.qualifiedAt?.toIso8601String(),
      'wonAt': instance.wonAt?.toIso8601String(),
      'lostAt': instance.lostAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$LeadStatusEnumMap = {
  LeadStatus.newLead: 'newLead',
  LeadStatus.contacted: 'contacted',
  LeadStatus.qualified: 'qualified',
  LeadStatus.proposalSent: 'proposalSent',
  LeadStatus.negotiation: 'negotiation',
  LeadStatus.won: 'won',
  LeadStatus.lost: 'lost',
};

const _$LeadSourceEnumMap = {
  LeadSource.whatsapp: 'whatsapp',
  LeadSource.callingAgent: 'callingAgent',
  LeadSource.website: 'website',
  LeadSource.manual: 'manual',
  LeadSource.import: 'import',
};
