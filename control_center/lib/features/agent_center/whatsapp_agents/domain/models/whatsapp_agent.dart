import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/models/agent.dart';
import '../../../shared/models/whatsapp_config.dart';

part 'whatsapp_agent.freezed.dart';
part 'whatsapp_agent.g.dart';

@freezed
class WhatsAppAgent with _$WhatsAppAgent {
  const factory WhatsAppAgent({
    required String id,
    required String orgId,
    required String name,
    required String systemPrompt,
    @Default('llama3') String llmModel,
    @Default(0.7) double temperature,
    required AgentStatus status,
    required WhatsAppConfig config,
    List<String>? knowledgeBaseIds,
    DateTime? lastActiveAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _WhatsAppAgent;

  factory WhatsAppAgent.fromJson(Map<String, dynamic> json) =>
      _$WhatsAppAgentFromJson(json);
}
