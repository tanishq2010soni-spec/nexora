import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../shared/models/agent.dart';

part 'agent_template.freezed.dart';
part 'agent_template.g.dart';

@freezed
class AgentTemplate with _$AgentTemplate {
  const factory AgentTemplate({
    required String id,
    required String name,
    String? description,
    required AgentPlatform platform,
    required String systemPrompt,
    @Default('llama3') String llmModel,
    @Default(0.7) double temperature,
    Map<String, dynamic>? platformConfig,
    @Default(false) bool isSystemTemplate,
    required DateTime createdAt,
  }) = _AgentTemplate;

  factory AgentTemplate.fromJson(Map<String, dynamic> json) =>
      _$AgentTemplateFromJson(json);
}
