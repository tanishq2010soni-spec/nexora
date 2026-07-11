class Message {
  final String id;
  final String content;
  final String role;
  final DateTime timestamp;
  final String type;
  final Map<String, dynamic> metadata;

  const Message({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.type = 'text',
    this.metadata = const {},
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      content: json['content'] as String,
      role: json['role'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: json['type'] as String? ?? 'text',
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'role': role,
    'timestamp': timestamp.toIso8601String(),
    'type': type,
    'metadata': metadata,
  };
}
