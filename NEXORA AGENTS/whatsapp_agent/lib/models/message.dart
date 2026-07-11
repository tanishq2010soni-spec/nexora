class Message {
  final int id;
  final int conversationId;
  final String content;
  final String role;
  final String? senderName;
  final String? mediaUrl;
  final String? mediaType;
  final bool isFromAI;
  final bool isFromHuman;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.conversationId,
    required this.content,
    required this.role,
    this.senderName,
    this.mediaUrl,
    this.mediaType,
    this.isFromAI = false,
    this.isFromHuman = false,
    this.metadata,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as int,
      conversationId: json['conversation_id'] as int,
      content: json['content'] as String,
      role: json['role'] as String,
      senderName: json['sender_name'] as String?,
      mediaUrl: json['media_url'] as String?,
      mediaType: json['media_type'] as String?,
      isFromAI: json['is_from_ai'] as bool? ?? false,
      isFromHuman: json['is_from_human'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'content': content,
      'role': role,
      'sender_name': senderName,
      'media_url': mediaUrl,
      'media_type': mediaType,
      'is_from_ai': isFromAI,
      'is_from_human': isFromHuman,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isSentByUser => role == 'user';

  bool get isSentByContact => role == 'contact';

  String get displayTime {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${createdAt.month}/${createdAt.day} ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }
}
