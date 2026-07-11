class AgentConfiguration {
  final String id;
  final String agentId;
  final String configKey;
  final String configValue;
  final String configType;

  const AgentConfiguration({
    required this.id,
    required this.agentId,
    required this.configKey,
    required this.configValue,
    required this.configType,
  });

  factory AgentConfiguration.fromJson(Map<String, dynamic> json) =>
      AgentConfiguration(
        id: json['id'] as String,
        agentId: json['agent_id'] as String,
        configKey: json['config_key'] as String,
        configValue: json['config_value'] as String,
        configType: json['config_type'] as String,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'agent_id': agentId,
    'config_key': configKey,
    'config_value': configValue,
    'config_type': configType,
  };
}
