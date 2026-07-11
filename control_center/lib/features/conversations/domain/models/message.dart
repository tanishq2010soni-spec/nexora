import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
part 'message.g.dart';

enum MessageRole { user, assistant, system }

enum MessageType { text, image, audio, file }

@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    required String conversationId,
    required MessageRole role,
    required MessageType type,
    required String content,
    @Default(0) int tokenCount,
    DateTime? createdAt,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}
