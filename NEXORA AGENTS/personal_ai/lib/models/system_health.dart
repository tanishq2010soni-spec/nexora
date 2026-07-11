class SystemHealth {
  final String status;
  final double uptime;
  final int activeProviders;
  final Map<String, dynamic> memoryUsage;
  final int taskCount;
  final DateTime lastHeartbeat;

  const SystemHealth({
    required this.status,
    this.uptime = 0,
    this.activeProviders = 0,
    this.memoryUsage = const {},
    this.taskCount = 0,
    required this.lastHeartbeat,
  });

  factory SystemHealth.fromJson(Map<String, dynamic> json) {
    return SystemHealth(
      status: json['status'] as String,
      uptime: (json['uptime'] as num?)?.toDouble() ?? 0,
      activeProviders: (json['active_providers'] as num?)?.toInt() ?? 0,
      memoryUsage: json['memory_usage'] as Map<String, dynamic>? ?? {},
      taskCount: (json['task_count'] as num?)?.toInt() ?? 0,
      lastHeartbeat: DateTime.parse(json['last_heartbeat'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'uptime': uptime,
    'active_providers': activeProviders,
    'memory_usage': memoryUsage,
    'task_count': taskCount,
    'last_heartbeat': lastHeartbeat.toIso8601String(),
  };
}
