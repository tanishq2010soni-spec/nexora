class AgentVersion {
  final String id;
  final String agentId;
  final String version;
  final String? description;
  final String? configJson;
  final DateTime createdAt;

  const AgentVersion({
    required this.id,
    required this.agentId,
    required this.version,
    this.description,
    this.configJson,
    required this.createdAt,
  });

  factory AgentVersion.fromJson(Map<String, dynamic> json) => AgentVersion(
    id: json['id'] as String,
    agentId: json['agent_id'] as String,
    version: json['version'] as String,
    description: json['description'] as String?,
    configJson: json['config_json'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'agent_id': agentId,
    'version': version,
    'description': description,
    'config_json': configJson,
    'created_at': createdAt.toIso8601String(),
  };
}
