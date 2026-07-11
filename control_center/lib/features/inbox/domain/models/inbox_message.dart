import 'package:freezed_annotation/freezed_annotation.dart';

part 'inbox_message.freezed.dart';
part 'inbox_message.g.dart';

enum MessageSenderType { user, bot, agent, system }

@freezed
class InboxMessage with _$InboxMessage {
  const factory InboxMessage({
    required String id,
    required String conversationId,
    required MessageSenderType senderType,
    required String content,
    required String channel,
    String? attachmentUrl,
    String? attachmentType,
    @Default(false) bool isRead,
    String? platformMessageId,
    required DateTime createdAt,
  }) = _InboxMessage;

  factory InboxMessage.fromJson(Map<String, dynamic> json) =>
      _$InboxMessageFromJson(json);
}
