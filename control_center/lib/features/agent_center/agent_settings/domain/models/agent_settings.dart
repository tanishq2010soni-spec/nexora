import 'package:freezed_annotation/freezed_annotation.dart';

part 'agent_settings.freezed.dart';
part 'agent_settings.g.dart';

@freezed
class AgentSettings with _$AgentSettings {
  const factory AgentSettings({
    required String agentId,
    required String agentName,
    @Default('llama3') String selectedModel,
    @Default(0.7) double temperature,
    @Default(1024) int maxTokens,
    @Default(true) bool streamingEnabled,
    @Default(30) int timeoutSeconds,
    List<String>? assignedKnowledgeBaseIds,
    @Default('You are a helpful assistant.') String systemPrompt,
    Map<String, dynamic>? customParameters,
  }) = _AgentSettings;

  factory AgentSettings.fromJson(Map<String, dynamic> json) =>
      _$AgentSettingsFromJson(json);
}
