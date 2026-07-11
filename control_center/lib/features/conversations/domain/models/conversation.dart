import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation.freezed.dart';
part 'conversation.g.dart';

enum ConversationPlatform { whatsapp, calling }

enum ConversationStatus { active, resolved, pending, archived }

@freezed
class Conversation with _$Conversation {
  const factory Conversation({
    required String id,
    required String orgId,
    required String externalUserId,
    required String agentId,
    required String agentName,
    required ConversationPlatform platform,
    required ConversationStatus status,
    @Default(0) int messageCount,
    @Default(0) int callDurationSeconds,
    String? lastMessagePreview,
    DateTime? lastMessageAt,
    String? assignedTo,
    Map<String, dynamic>? metadata,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
}
