class PermissionRequest {
  final String id;
  final String action;
  final Map<String, dynamic> details;
  final String status;
  final DateTime createdAt;

  const PermissionRequest({
    required this.id,
    required this.action,
    this.details = const {},
    required this.status,
    required this.createdAt,
  });

  factory PermissionRequest.fromJson(Map<String, dynamic> json) {
    return PermissionRequest(
      id: json['id'] as String,
      action: json['action'] as String,
      details: json['details'] as Map<String, dynamic>? ?? {},
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'action': action,
    'details': details,
    'status': status,
    'created_at': createdAt.toIso8601String(),
  };
}
