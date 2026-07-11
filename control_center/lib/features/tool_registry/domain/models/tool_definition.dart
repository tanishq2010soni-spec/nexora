class ToolDefinition {
  final String id;
  final String orgId;
  final String name;
  final String displayName;
  final String? description;
  final String version;
  final String? category;
  final String? permissionsJson;
  final bool isEnabled;
  final String healthStatus;
  final String? configJson;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ToolDefinition({
    required this.id,
    required this.orgId,
    required this.name,
    required this.displayName,
    this.description,
    this.version = '1.0.0',
    this.category,
    this.permissionsJson,
    this.isEnabled = true,
    this.healthStatus = 'healthy',
    this.configJson,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ToolDefinition.fromJson(Map<String, dynamic> json) => ToolDefinition(
    id: json['id'] as String,
    orgId: json['org_id'] as String,
    name: json['name'] as String,
    displayName: json['display_name'] as String,
    description: json['description'] as String?,
    version: json['version'] as String? ?? '1.0.0',
    category: json['category'] as String?,
    permissionsJson: json['permissions_json'] as String?,
    isEnabled: json['is_enabled'] as bool? ?? true,
    healthStatus: json['health_status'] as String? ?? 'healthy',
    configJson: json['config_json'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'org_id': orgId,
    'name': name,
    'display_name': displayName,
    'description': description,
    'version': version,
    'category': category,
    'permissions_json': permissionsJson,
    'is_enabled': isEnabled,
    'health_status': healthStatus,
    'config_json': configJson,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
