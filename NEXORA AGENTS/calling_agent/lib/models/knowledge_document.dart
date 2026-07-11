class KnowledgeDocument {
  final String id;
  final String title;
  final String content;
  final String category;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  const KnowledgeDocument({
    required this.id,
    required this.title,
    required this.content,
    this.category = 'general',
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory KnowledgeDocument.fromJson(Map<String, dynamic> json) {
    return KnowledgeDocument(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String? ?? 'general',
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
