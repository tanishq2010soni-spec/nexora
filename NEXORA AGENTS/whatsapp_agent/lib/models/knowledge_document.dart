class KnowledgeDocument {
  final int id;
  final int organizationId;
  final String title;
  final String? content;
  final String? documentType;
  final List<String> tags;
  final bool isIndexed;
  final String? sourceUrl;
  final int chunkCount;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  KnowledgeDocument({
    required this.id,
    required this.organizationId,
    required this.title,
    this.content,
    this.documentType,
    this.tags = const [],
    this.isIndexed = false,
    this.sourceUrl,
    this.chunkCount = 0,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory KnowledgeDocument.fromJson(Map<String, dynamic> json) {
    return KnowledgeDocument(
      id: json['id'] as int,
      organizationId: json['organization_id'] as int,
      title: json['title'] as String,
      content: json['content'] as String?,
      documentType: json['document_type'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      isIndexed: json['is_indexed'] as bool? ?? false,
      sourceUrl: json['source_url'] as String?,
      chunkCount: json['chunk_count'] as int? ?? 0,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'title': title,
      'content': content,
      'document_type': documentType,
      'tags': tags,
      'is_indexed': isIndexed,
      'source_url': sourceUrl,
      'chunk_count': chunkCount,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get typeLabel {
    switch (documentType) {
      case 'pdf':
        return 'PDF';
      case 'text':
        return 'Text';
      case 'csv':
        return 'CSV';
      case 'url':
        return 'URL';
      case 'manual':
        return 'Manual';
      default:
        return documentType ?? 'Unknown';
    }
  }
}
