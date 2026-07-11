enum LogLevel { debug, info, warn, error, fatal }

class AgentLog {
  final String id;
  final String agentId;
  final LogLevel level;
  final String message;
  final String? metadataJson;
  final DateTime createdAt;

  const AgentLog({
    required this.id,
    required this.agentId,
    required this.level,
    required this.message,
    this.metadataJson,
    required this.createdAt,
  });

  factory AgentLog.fromJson(Map<String, dynamic> json) => AgentLog(
    id: json['id'] as String,
    agentId: json['agent_id'] as String,
    level: LogLevel.values.firstWhere(
      (e) => e.name == json['level'] as String,
      orElse: () => LogLevel.info,
    ),
    message: json['message'] as String,
    metadataJson: json['metadata_json'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'agent_id': agentId,
    'level': level.name,
    'message': message,
    'metadata_json': metadataJson,
    'created_at': createdAt.toIso8601String(),
  };
}
