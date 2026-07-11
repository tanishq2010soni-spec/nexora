class AuditLog {
  final String id;
  final String userId;
  final String? userName;
  final String action;
  final String resource;
  final String? resourceId;
  final String? details;
  final DateTime timestamp;

  const AuditLog({
    required this.id,
    required this.userId,
    this.userName,
    required this.action,
    required this.resource,
    this.resourceId,
    this.details,
    required this.timestamp,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String?,
      action: json['action'] as String,
      resource: json['resource'] as String,
      resourceId: json['resource_id'] as String?,
      details: json['details'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'action': action,
      'resource': resource,
      'resource_id': resourceId,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
