// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AgentSettingsImpl _$$AgentSettingsImplFromJson(Map<String, dynamic> json) =>
    _$AgentSettingsImpl(
      agentId: json['agentId'] as String,
      agentName: json['agentName'] as String,
      selectedModel: json['selectedModel'] as String? ?? 'llama3',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
      maxTokens: (json['maxTokens'] as num?)?.toInt() ?? 1024,
      streamingEnabled: json['streamingEnabled'] as bool? ?? true,
      timeoutSeconds: (json['timeoutSeconds'] as num?)?.toInt() ?? 30,
      assignedKnowledgeBaseIds:
          (json['assignedKnowledgeBaseIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      systemPrompt:
          json['systemPrompt'] as String? ?? 'You are a helpful assistant.',
      customParameters: json['customParameters'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$AgentSettingsImplToJson(_$AgentSettingsImpl instance) =>
    <String, dynamic>{
      'agentId': instance.agentId,
      'agentName': instance.agentName,
      'selectedModel': instance.selectedModel,
      'temperature': instance.temperature,
      'maxTokens': instance.maxTokens,
      'streamingEnabled': instance.streamingEnabled,
      'timeoutSeconds': instance.timeoutSeconds,
      'assignedKnowledgeBaseIds': instance.assignedKnowledgeBaseIds,
      'systemPrompt': instance.systemPrompt,
      'customParameters': instance.customParameters,
    };
