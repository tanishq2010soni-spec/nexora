// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calling_agent.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CallingAgentImpl _$$CallingAgentImplFromJson(Map<String, dynamic> json) =>
    _$CallingAgentImpl(
      id: json['id'] as String,
      orgId: json['orgId'] as String,
      name: json['name'] as String,
      systemPrompt: json['systemPrompt'] as String,
      llmModel: json['llmModel'] as String? ?? 'llama3',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
      status: $enumDecode(_$AgentStatusEnumMap, json['status']),
      voiceConfig: VoiceConfig.fromJson(
        json['voiceConfig'] as Map<String, dynamic>,
      ),
      knowledgeBaseIds: (json['knowledgeBaseIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      lastActiveAt: json['lastActiveAt'] == null
          ? null
          : DateTime.parse(json['lastActiveAt'] as String),
      totalCalls: (json['totalCalls'] as num?)?.toInt() ?? 0,
      todayCalls: (json['todayCalls'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$CallingAgentImplToJson(_$CallingAgentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orgId': instance.orgId,
      'name': instance.name,
      'systemPrompt': instance.systemPrompt,
      'llmModel': instance.llmModel,
      'temperature': instance.temperature,
      'status': _$AgentStatusEnumMap[instance.status]!,
      'voiceConfig': instance.voiceConfig,
      'knowledgeBaseIds': instance.knowledgeBaseIds,
      'lastActiveAt': instance.lastActiveAt?.toIso8601String(),
      'totalCalls': instance.totalCalls,
      'todayCalls': instance.todayCalls,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$AgentStatusEnumMap = {
  AgentStatus.active: 'active',
  AgentStatus.idle: 'idle',
  AgentStatus.error: 'error',
  AgentStatus.disabled: 'disabled',
};
