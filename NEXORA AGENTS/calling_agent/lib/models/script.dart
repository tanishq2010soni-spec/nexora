class Script {
  final String id;
  final String name;
  final String type;
  final String? content;
  final String version;
  final bool active;
  final List<String> sections;
  final List<String> variables;
  final DateTime updatedAt;
  final DateTime createdAt;

  const Script({
    required this.id,
    required this.name,
    required this.type,
    this.content,
    this.version = '1.0',
    this.active = false,
    this.sections = const [],
    this.variables = const [],
    required this.updatedAt,
    required this.createdAt,
  });

  factory Script.fromJson(Map<String, dynamic> json) {
    return Script(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      content: json['content'] as String?,
      version: json['version'] as String? ?? '1.0',
      active: json['active'] as bool? ?? false,
      sections: (json['sections'] as List<dynamic>?)?.cast<String>() ?? [],
      variables: (json['variables'] as List<dynamic>?)?.cast<String>() ?? [],
      updatedAt: DateTime.parse(json['updated_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'content': content,
      'version': version,
      'active': active,
      'sections': sections,
      'variables': variables,
      'updated_at': updatedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
