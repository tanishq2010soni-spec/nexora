import 'message.dart';

class Conversation {
  final int id;
  final int organizationId;
  final String? customerPhone;
  final String? customerName;
  final String? customerAvatar;
  final String status;
  final String? assignedTo;
  final String? assignedToName;
  final String? department;
  final bool isAIActive;
  final String? lastMessage;
  final int unreadCount;
  final List<String> tags;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastMessageAt;
  final List<Message>? messages;

  Conversation({
    required this.id,
    required this.organizationId,
    this.customerPhone,
    this.customerName,
    this.customerAvatar,
    this.status = 'active',
    this.assignedTo,
    this.assignedToName,
    this.department,
    this.isAIActive = true,
    this.lastMessage,
    this.unreadCount = 0,
    this.tags = const [],
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessageAt,
    this.messages,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as int,
      organizationId: json['organization_id'] as int,
      customerPhone: json['customer_phone'] as String?,
      customerName: json['customer_name'] as String?,
      customerAvatar: json['customer_avatar'] as String?,
      status: json['status'] as String? ?? 'active',
      assignedTo: json['assigned_to'] as String?,
      assignedToName: json['assigned_to_name'] as String?,
      department: json['department'] as String?,
      isAIActive: json['is_ai_active'] as bool? ?? true,
      lastMessage: json['last_message'] as String?,
      unreadCount: json['unread_count'] as int? ?? 0,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastMessageAt: json['last_message_at'] != null ? DateTime.parse(json['last_message_at'] as String) : null,
      messages: (json['messages'] as List<dynamic>?)
          ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'customer_phone': customerPhone,
      'customer_name': customerName,
      'customer_avatar': customerAvatar,
      'status': status,
      'assigned_to': assignedTo,
      'assigned_to_name': assignedToName,
      'department': department,
      'is_ai_active': isAIActive,
      'last_message': lastMessage,
      'unread_count': unreadCount,
      'tags': tags,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_message_at': lastMessageAt?.toIso8601String(),
    };
  }

  String get displayName => customerName ?? customerPhone ?? 'Unknown';

  String get initials {
    final name = displayName;
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  bool get isUnread => unreadCount > 0;

  String get lastMessageTime {
    if (lastMessageAt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(lastMessageAt!);
    if (diff.inMinutes < 1) return 'Now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${lastMessageAt!.month}/${lastMessageAt!.day}';
  }
}
