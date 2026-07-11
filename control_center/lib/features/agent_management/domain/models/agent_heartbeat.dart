class AgentHeartbeat {
  final String id;
  final String agentId;
  final String status;
  final double cpuUsage;
  final double memoryUsage;
  final int activeTasks;
  final DateTime timestamp;

  const AgentHeartbeat({
    required this.id,
    required this.agentId,
    required this.status,
    this.cpuUsage = 0.0,
    this.memoryUsage = 0.0,
    this.activeTasks = 0,
    required this.timestamp,
  });

  factory AgentHeartbeat.fromJson(Map<String, dynamic> json) => AgentHeartbeat(
    id: json['id'] as String,
    agentId: json['agent_id'] as String,
    status: json['status'] as String,
    cpuUsage: (json['cpu_usage'] as num?)?.toDouble() ?? 0.0,
    memoryUsage: (json['memory_usage'] as num?)?.toDouble() ?? 0.0,
    activeTasks: json['active_tasks'] as int? ?? 0,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'agent_id': agentId,
    'status': status,
    'cpu_usage': cpuUsage,
    'memory_usage': memoryUsage,
    'active_tasks': activeTasks,
    'timestamp': timestamp.toIso8601String(),
  };
}
