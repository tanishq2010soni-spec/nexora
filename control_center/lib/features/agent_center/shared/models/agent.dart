import 'package:freezed_annotation/freezed_annotation.dart';

part 'agent.freezed.dart';
part 'agent.g.dart';

enum AgentPlatform { whatsapp, calling, web }

enum AgentStatus { active, idle, error, disabled }

@freezed
class Agent with _$Agent {
  const factory Agent({
    required String id,
    required String orgId,
    required String name,
    required AgentPlatform platform,
    required String systemPrompt,
    @Default('llama3') String llmModel,
    @Default(0.7) double temperature,
    required AgentStatus status,
    List<String>? knowledgeBaseIds,
    DateTime? lastActiveAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Agent;

  factory Agent.fromJson(Map<String, dynamic> json) => _$AgentFromJson(json);
}
