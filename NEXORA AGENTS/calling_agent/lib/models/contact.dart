class Contact {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? company;
  final String? title;
  final String? notes;
  final int totalCalls;
  final DateTime? lastContactAt;
  final DateTime createdAt;

  const Contact({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.company,
    this.title,
    this.notes,
    this.totalCalls = 0,
    this.lastContactAt,
    required this.createdAt,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      company: json['company'] as String?,
      title: json['title'] as String?,
      notes: json['notes'] as String?,
      totalCalls: json['total_calls'] as int? ?? 0,
      lastContactAt: json['last_contact_at'] != null
          ? DateTime.parse(json['last_contact_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'company': company,
      'title': title,
      'notes': notes,
      'total_calls': totalCalls,
      'last_contact_at': lastContactAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
