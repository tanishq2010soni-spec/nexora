class WhatsAppAccount {
  final int id;
  final int organizationId;
  final String phoneNumber;
  final String? name;
  final String status;
  final bool isConnected;
  final String? qrCode;
  final DateTime? lastSyncAt;
  final Map<String, dynamic>? config;
  final DateTime createdAt;
  final DateTime updatedAt;

  WhatsAppAccount({
    required this.id,
    required this.organizationId,
    required this.phoneNumber,
    this.name,
    this.status = 'disconnected',
    this.isConnected = false,
    this.qrCode,
    this.lastSyncAt,
    this.config,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WhatsAppAccount.fromJson(Map<String, dynamic> json) {
    return WhatsAppAccount(
      id: json['id'] as int,
      organizationId: json['organization_id'] as int,
      phoneNumber: json['phone_number'] as String,
      name: json['name'] as String?,
      status: json['status'] as String? ?? 'disconnected',
      isConnected: json['is_connected'] as bool? ?? false,
      qrCode: json['qr_code'] as String?,
      lastSyncAt: json['last_sync_at'] != null
          ? DateTime.parse(json['last_sync_at'] as String)
          : null,
      config: json['config'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'phone_number': phoneNumber,
      'name': name,
      'status': status,
      'is_connected': isConnected,
      'qr_code': qrCode,
      'last_sync_at': lastSyncAt?.toIso8601String(),
      'config': config,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get displayName => name ?? phoneNumber;

  String get statusLabel {
    switch (status) {
      case 'connected':
        return 'Connected';
      case 'disconnected':
        return 'Disconnected';
      case 'connecting':
        return 'Connecting';
      case 'error':
        return 'Error';
      case 'timeout':
        return 'Timeout';
      default:
        return status;
    }
  }
}
