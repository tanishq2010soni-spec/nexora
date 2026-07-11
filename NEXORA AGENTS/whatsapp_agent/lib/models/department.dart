class Department {
  final int id;
  final int organizationId;
  final String name;
  final String? description;
  final List<String>? assignedAgents;
  final List<String>? keywords;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Department({
    required this.id,
    required this.organizationId,
    required this.name,
    this.description,
    this.assignedAgents,
    this.keywords,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'] as int,
      organizationId: json['organization_id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      assignedAgents: (json['assigned_agents'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      keywords: (json['keywords'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'name': name,
      'description': description,
      'assigned_agents': assignedAgents,
      'keywords': keywords,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
