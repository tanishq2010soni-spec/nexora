import 'package:freezed_annotation/freezed_annotation.dart';

part 'inbox_conversation.freezed.dart';
part 'inbox_conversation.g.dart';

enum InboxChannel { whatsapp, instagram, facebook, website }

enum InboxStatus { open, closed, pending }

enum TakeoverMode { ai, human }

@freezed
class InboxConversation with _$InboxConversation {
  const factory InboxConversation({
    required String id,
    required String orgId,
    required String customerId,
    required InboxChannel channel,
    required String platformUserId,
    required String customerName,
    String? customerPhone,
    String? customerEmail,
    String? lastMessage,
    @Default(0) int unreadCount,
    required InboxStatus status,
    String? assignedTo,
    String? assignedToName,
    required TakeoverMode takeoverMode,
    @Default(0) int messageCount,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _InboxConversation;

  factory InboxConversation.fromJson(Map<String, dynamic> json) =>
      _$InboxConversationFromJson(json);
}
