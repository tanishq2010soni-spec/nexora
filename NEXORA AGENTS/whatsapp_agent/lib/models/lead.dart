class Lead {
  final int id;
  final int organizationId;
  final String name;
  final String? phone;
  final String? email;
  final String? source;
  final String status;
  final String stage;
  final double score;
  final String? assignedTo;
  final String? assignedToName;
  final String? notes;
  final Map<String, dynamic>? customFields;
  final List<Map<String, dynamic>>? timeline;
  final DateTime createdAt;
  final DateTime updatedAt;

  Lead({
    required this.id,
    required this.organizationId,
    required this.name,
    this.phone,
    this.email,
    this.source,
    this.status = 'new',
    this.stage = 'new',
    this.score = 0,
    this.assignedTo,
    this.assignedToName,
    this.notes,
    this.customFields,
    this.timeline,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['id'] as int,
      organizationId: json['organization_id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      source: json['source'] as String?,
      status: json['status'] as String? ?? 'new',
      stage: json['stage'] as String? ?? 'new',
      score: (json['score'] as num?)?.toDouble() ?? 0,
      assignedTo: json['assigned_to'] as String?,
      assignedToName: json['assigned_to_name'] as String?,
      notes: json['notes'] as String?,
      customFields: json['custom_fields'] as Map<String, dynamic>?,
      timeline: (json['timeline'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
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
      'source': source,
      'status': status,
      'stage': stage,
      'score': score,
      'assigned_to': assignedTo,
      'assigned_to_name': assignedToName,
      'notes': notes,
      'custom_fields': customFields,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get statusLabel {
    switch (status) {
      case 'new':
        return 'New';
      case 'contacted':
        return 'Contacted';
      case 'qualified':
        return 'Qualified';
      case 'proposal':
        return 'Proposal';
      case 'negotiation':
        return 'Negotiation';
      case 'won':
        return 'Won';
      case 'lost':
        return 'Lost';
      default:
        return status;
    }
  }

  String get scoreLabel {
    if (score >= 80) return 'Hot';
    if (score >= 50) return 'Warm';
    return 'Cold';
  }

  static const List<String> stages = [
    'new',
    'contacted',
    'qualified',
    'proposal',
    'negotiation',
    'won',
    'lost',
  ];
}
