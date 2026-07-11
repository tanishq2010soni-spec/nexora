class MemoryEntry {
  final String id;
  final String type;
  final String content;
  final List<String> tags;
  final double score;
  final String source;
  final DateTime createdAt;

  const MemoryEntry({
    required this.id,
    required this.type,
    required this.content,
    this.tags = const [],
    this.score = 0.0,
    required this.source,
    required this.createdAt,
  });

  factory MemoryEntry.fromJson(Map<String, dynamic> json) {
    return MemoryEntry(
      id: json['id'] as String,
      type: json['type'] as String,
      content: json['content'] as String,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      source: json['source'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'content': content,
    'tags': tags,
    'score': score,
    'source': source,
    'created_at': createdAt.toIso8601String(),
  };
}
