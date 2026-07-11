class PhoneProvider {
  final String id;
  final String name;
  final String type;
  final String? credentials;
  final bool connected;
  final DateTime createdAt;

  const PhoneProvider({
    required this.id,
    required this.name,
    required this.type,
    this.credentials,
    this.connected = false,
    required this.createdAt,
  });

  factory PhoneProvider.fromJson(Map<String, dynamic> json) {
    return PhoneProvider(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      credentials: json['credentials'] as String?,
      connected: json['connected'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'credentials': credentials,
      'connected': connected,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
