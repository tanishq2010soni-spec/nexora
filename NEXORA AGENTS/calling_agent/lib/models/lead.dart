class Lead {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? company;
  final String status;
  final int score;
  final String? source;
  final String? campaignId;
  final String? campaignName;
  final DateTime? lastCalledAt;
  final DateTime? nextCallAt;
  final bool dnc;
  final List<String> tags;
  final String? notes;
  final DateTime createdAt;
  final int callCount;

  const Lead({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.company,
    this.status = 'new',
    this.score = 0,
    this.source,
    this.campaignId,
    this.campaignName,
    this.lastCalledAt,
    this.nextCallAt,
    this.dnc = false,
    this.tags = const [],
    this.notes,
    required this.createdAt,
    this.callCount = 0,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      company: json['company'] as String?,
      status: json['status'] as String? ?? 'new',
      score: json['score'] as int? ?? 0,
      source: json['source'] as String?,
      campaignId: json['campaign_id'] as String?,
      campaignName: json['campaign_name'] as String?,
      lastCalledAt: json['last_called_at'] != null
          ? DateTime.parse(json['last_called_at'] as String)
          : null,
      nextCallAt: json['next_call_at'] != null
          ? DateTime.parse(json['next_call_at'] as String)
          : null,
      dnc: json['dnc'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      callCount: json['call_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'company': company,
      'status': status,
      'score': score,
      'source': source,
      'campaign_id': campaignId,
      'campaign_name': campaignName,
      'last_called_at': lastCalledAt?.toIso8601String(),
      'next_call_at': nextCallAt?.toIso8601String(),
      'dnc': dnc,
      'tags': tags,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'call_count': callCount,
    };
  }
}
