// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AgentTemplateImpl _$$AgentTemplateImplFromJson(Map<String, dynamic> json) =>
    _$AgentTemplateImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      platform: $enumDecode(_$AgentPlatformEnumMap, json['platform']),
      systemPrompt: json['systemPrompt'] as String,
      llmModel: json['llmModel'] as String? ?? 'llama3',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
      platformConfig: json['platformConfig'] as Map<String, dynamic>?,
      isSystemTemplate: json['isSystemTemplate'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$AgentTemplateImplToJson(_$AgentTemplateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'platform': _$AgentPlatformEnumMap[instance.platform]!,
      'systemPrompt': instance.systemPrompt,
      'llmModel': instance.llmModel,
      'temperature': instance.temperature,
      'platformConfig': instance.platformConfig,
      'isSystemTemplate': instance.isSystemTemplate,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$AgentPlatformEnumMap = {
  AgentPlatform.whatsapp: 'whatsapp',
  AgentPlatform.calling: 'calling',
  AgentPlatform.web: 'web',
};
