// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AgentImpl _$$AgentImplFromJson(Map<String, dynamic> json) => _$AgentImpl(
  id: json['id'] as String,
  orgId: json['orgId'] as String,
  name: json['name'] as String,
  platform: $enumDecode(_$AgentPlatformEnumMap, json['platform']),
  systemPrompt: json['systemPrompt'] as String,
  llmModel: json['llmModel'] as String? ?? 'llama3',
  temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
  status: $enumDecode(_$AgentStatusEnumMap, json['status']),
  knowledgeBaseIds: (json['knowledgeBaseIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  lastActiveAt: json['lastActiveAt'] == null
      ? null
      : DateTime.parse(json['lastActiveAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$AgentImplToJson(_$AgentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orgId': instance.orgId,
      'name': instance.name,
      'platform': _$AgentPlatformEnumMap[instance.platform]!,
      'systemPrompt': instance.systemPrompt,
      'llmModel': instance.llmModel,
      'temperature': instance.temperature,
      'status': _$AgentStatusEnumMap[instance.status]!,
      'knowledgeBaseIds': instance.knowledgeBaseIds,
      'lastActiveAt': instance.lastActiveAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$AgentPlatformEnumMap = {
  AgentPlatform.whatsapp: 'whatsapp',
  AgentPlatform.calling: 'calling',
  AgentPlatform.web: 'web',
};

const _$AgentStatusEnumMap = {
  AgentStatus.active: 'active',
  AgentStatus.idle: 'idle',
  AgentStatus.error: 'error',
  AgentStatus.disabled: 'disabled',
};
