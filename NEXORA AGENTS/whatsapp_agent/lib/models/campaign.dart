class Campaign {
  final int id;
  final int organizationId;
  final String name;
  final String? message;
  final String type;
  final String status;
  final int totalRecipients;
  final int sentCount;
  final int deliveredCount;
  final int readCount;
  final int failedCount;
  final DateTime? scheduledAt;
  final DateTime? sentAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Campaign({
    required this.id,
    required this.organizationId,
    required this.name,
    this.message,
    this.type = 'broadcast',
    this.status = 'draft',
    this.totalRecipients = 0,
    this.sentCount = 0,
    this.deliveredCount = 0,
    this.readCount = 0,
    this.failedCount = 0,
    this.scheduledAt,
    this.sentAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'] as int,
      organizationId: json['organization_id'] as int,
      name: json['name'] as String,
      message: json['message'] as String?,
      type: json['type'] as String? ?? 'broadcast',
      status: json['status'] as String? ?? 'draft',
      totalRecipients: json['total_recipients'] as int? ?? 0,
      sentCount: json['sent_count'] as int? ?? 0,
      deliveredCount: json['delivered_count'] as int? ?? 0,
      readCount: json['read_count'] as int? ?? 0,
      failedCount: json['failed_count'] as int? ?? 0,
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.parse(json['scheduled_at'] as String)
          : null,
      sentAt: json['sent_at'] != null
          ? DateTime.parse(json['sent_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'name': name,
      'message': message,
      'type': type,
      'status': status,
      'total_recipients': totalRecipients,
      'sent_count': sentCount,
      'delivered_count': deliveredCount,
      'read_count': readCount,
      'failed_count': failedCount,
      'scheduled_at': scheduledAt?.toIso8601String(),
      'sent_at': sentAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get typeLabel {
    switch (type) {
      case 'broadcast':
        return 'Broadcast';
      case 'drip':
        return 'Drip';
      case 'triggered':
        return 'Triggered';
      default:
        return type;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'draft':
        return 'Draft';
      case 'scheduled':
        return 'Scheduled';
      case 'sending':
        return 'Sending';
      case 'sent':
        return 'Sent';
      case 'completed':
        return 'Completed';
      case 'paused':
        return 'Paused';
      case 'failed':
        return 'Failed';
      default:
        return status;
    }
  }

  double get deliveryRate =>
      totalRecipients > 0 ? deliveredCount / totalRecipients * 100 : 0;
}
