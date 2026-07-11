class Customer {
  final int id;
  final int organizationId;
  final String name;
  final String? phone;
  final String? email;
  final String? tier;
  final double totalSpent;
  final int totalConversations;
  final DateTime? lastContactAt;
  final List<String> tags;
  final Map<String, dynamic>? customFields;
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer({
    required this.id,
    required this.organizationId,
    required this.name,
    this.phone,
    this.email,
    this.tier,
    this.totalSpent = 0,
    this.totalConversations = 0,
    this.lastContactAt,
    this.tags = const [],
    this.customFields,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as int,
      organizationId: json['organization_id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      tier: json['tier'] as String?,
      totalSpent: (json['total_spent'] as num?)?.toDouble() ?? 0,
      totalConversations: json['total_conversations'] as int? ?? 0,
      lastContactAt: json['last_contact_at'] != null
          ? DateTime.parse(json['last_contact_at'] as String)
          : null,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      customFields: json['custom_fields'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'name': name,
      'phone': phone,
      'email': email,
      'tier': tier,
      'total_spent': totalSpent,
      'total_conversations': totalConversations,
      'last_contact_at': lastContactAt?.toIso8601String(),
      'tags': tags,
      'custom_fields': customFields,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
