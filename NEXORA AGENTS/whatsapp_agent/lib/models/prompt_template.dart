class PromptTemplate {
  final int id;
  final int organizationId;
  final String name;
  final String content;
  final String? category;
  final bool isDefault;
  final Map<String, dynamic>? variables;
  final DateTime createdAt;
  final DateTime updatedAt;

  PromptTemplate({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.content,
    this.category,
    this.isDefault = false,
    this.variables,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PromptTemplate.fromJson(Map<String, dynamic> json) {
    return PromptTemplate(
      id: json['id'] as int,
      organizationId: json['organization_id'] as int,
      name: json['name'] as String,
      content: json['content'] as String,
      category: json['category'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
      variables: json['variables'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'name': name,
      'content': content,
      'category': category,
      'is_default': isDefault,
      'variables': variables,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
