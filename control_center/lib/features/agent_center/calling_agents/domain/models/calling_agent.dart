import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../shared/models/agent.dart';
import '../../../shared/models/voice_config.dart';

part 'calling_agent.freezed.dart';
part 'calling_agent.g.dart';

@freezed
class CallingAgent with _$CallingAgent {
  const factory CallingAgent({
    required String id,
    required String orgId,
    required String name,
    required String systemPrompt,
    @Default('llama3') String llmModel,
    @Default(0.7) double temperature,
    required AgentStatus status,
    required VoiceConfig voiceConfig,
    List<String>? knowledgeBaseIds,
    DateTime? lastActiveAt,
    @Default(0) int totalCalls,
    @Default(0) int todayCalls,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CallingAgent;

  factory CallingAgent.fromJson(Map<String, dynamic> json) =>
      _$CallingAgentFromJson(json);
}
