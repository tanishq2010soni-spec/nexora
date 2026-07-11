class AuditLog {
  final int id;
  final int organizationId;
  final int? userId;
  final String? userName;
  final String action;
  final String resourceType;
  final int? resourceId;
  final Map<String, dynamic>? details;
  final String? ipAddress;
  final DateTime createdAt;

  AuditLog({
    required this.id,
    required this.organizationId,
    this.userId,
    this.userName,
    required this.action,
    required this.resourceType,
    this.resourceId,
    this.details,
    this.ipAddress,
    required this.createdAt,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id'] as int,
      organizationId: json['organization_id'] as int,
      userId: json['user_id'] as int?,
      userName: json['user_name'] as String?,
      action: json['action'] as String,
      resourceType: json['resource_type'] as String,
      resourceId: json['resource_id'] as int?,
      details: json['details'] as Map<String, dynamic>?,
      ipAddress: json['ip_address'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'user_id': userId,
      'user_name': userName,
      'action': action,
      'resource_type': resourceType,
      'resource_id': resourceId,
      'details': details,
      'ip_address': ipAddress,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get actionLabel {
    switch (action) {
      case 'create':
        return 'Create';
      case 'update':
        return 'Update';
      case 'delete':
        return 'Delete';
      case 'login':
        return 'Login';
      case 'logout':
        return 'Logout';
      case 'send_message':
        return 'Send Message';
      case 'handoff':
        return 'Handoff';
      case 'assign':
        return 'Assign';
      default:
        return action;
    }
  }
}
