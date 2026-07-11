class PluginModel {
  final String id;
  final String orgId;
  final String name;
  final String displayName;
  final String? description;
  final String version;
  final String? manifestJson;
  final String? permissionsJson;
  final String? dependenciesJson;
  final String? hooksJson;
  final bool isEnabled;
  final String healthStatus;
  final String? category;
  final String? marketplaceMetadataJson;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PluginModel({
    required this.id,
    required this.orgId,
    required this.name,
    required this.displayName,
    this.description,
    this.version = '1.0.0',
    this.manifestJson,
    this.permissionsJson,
    this.dependenciesJson,
    this.hooksJson,
    this.isEnabled = true,
    this.healthStatus = 'healthy',
    this.category,
    this.marketplaceMetadataJson,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PluginModel.fromJson(Map<String, dynamic> json) => PluginModel(
    id: json['id'] as String,
    orgId: json['org_id'] as String,
    name: json['name'] as String,
    displayName: json['display_name'] as String,
    description: json['description'] as String?,
    version: json['version'] as String? ?? '1.0.0',
    manifestJson: json['manifest_json'] as String?,
    permissionsJson: json['permissions_json'] as String?,
    dependenciesJson: json['dependencies_json'] as String?,
    hooksJson: json['hooks_json'] as String?,
    isEnabled: json['is_enabled'] as bool? ?? true,
    healthStatus: json['health_status'] as String? ?? 'healthy',
    category: json['category'] as String?,
    marketplaceMetadataJson: json['marketplace_metadata_json'] as String?,
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
    'manifest_json': manifestJson,
    'permissions_json': permissionsJson,
    'dependencies_json': dependenciesJson,
    'hooks_json': hooksJson,
    'is_enabled': isEnabled,
    'health_status': healthStatus,
    'category': category,
    'marketplace_metadata_json': marketplaceMetadataJson,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
