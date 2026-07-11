class User {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? avatarUrl;
  final bool active;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.role = 'agent',
    this.avatarUrl,
    this.active = true,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String? ?? 'agent',
      avatarUrl: json['avatar_url'] as String?,
      active: json['active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'avatar_url': avatarUrl,
      'active': active,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
