class AgentCapability {
  final String id;
  final String agentId;
  final String capabilityName;
  final bool enabled;
  final String? configJson;
  final DateTime createdAt;

  const AgentCapability({
    required this.id,
    required this.agentId,
    required this.capabilityName,
    this.enabled = true,
    this.configJson,
    required this.createdAt,
  });

  factory AgentCapability.fromJson(Map<String, dynamic> json) => AgentCapability(
    id: json['id'] as String,
    agentId: json['agent_id'] as String,
    capabilityName: json['capability_name'] as String,
    enabled: json['enabled'] as bool? ?? true,
    configJson: json['config_json'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'agent_id': agentId,
    'capability_name': capabilityName,
    'enabled': enabled,
    'config_json': configJson,
    'created_at': createdAt.toIso8601String(),
  };
}
