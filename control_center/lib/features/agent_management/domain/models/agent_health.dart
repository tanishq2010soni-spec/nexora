enum AgentHealthStatus { healthy, degraded, down, unknown }

class AgentHealth {
  final String id;
  final String agentId;
  final AgentHealthStatus status;
  final DateTime? lastHeartbeatAt;
  final String? errorMessage;
  final int? latencyMs;

  const AgentHealth({
    required this.id,
    required this.agentId,
    required this.status,
    this.lastHeartbeatAt,
    this.errorMessage,
    this.latencyMs,
  });

  factory AgentHealth.fromJson(Map<String, dynamic> json) => AgentHealth(
    id: json['id'] as String,
    agentId: json['agent_id'] as String,
    status: AgentHealthStatus.values.firstWhere(
      (e) => e.name == json['status'] as String,
      orElse: () => AgentHealthStatus.unknown,
    ),
    lastHeartbeatAt: json['last_heartbeat_at'] != null
        ? DateTime.parse(json['last_heartbeat_at'] as String)
        : null,
    errorMessage: json['error_message'] as String?,
    latencyMs: json['latency_ms'] as int?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'agent_id': agentId,
    'status': status.name,
    'last_heartbeat_at': lastHeartbeatAt?.toIso8601String(),
    'error_message': errorMessage,
    'latency_ms': latencyMs,
  };
}
