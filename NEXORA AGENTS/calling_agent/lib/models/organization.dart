class Organization {
  final String id;
  final String name;
  final String? timezone;
  final String? businessHours;
  final bool recordingEnabled;
  final bool transcriptionEnabled;
  final DateTime createdAt;

  const Organization({
    required this.id,
    required this.name,
    this.timezone,
    this.businessHours,
    this.recordingEnabled = true,
    this.transcriptionEnabled = true,
    required this.createdAt,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'] as String,
      name: json['name'] as String,
      timezone: json['timezone'] as String?,
      businessHours: json['business_hours'] as String?,
      recordingEnabled: json['recording_enabled'] as bool? ?? true,
      transcriptionEnabled: json['transcription_enabled'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'timezone': timezone,
      'business_hours': businessHours,
      'recording_enabled': recordingEnabled,
      'transcription_enabled': transcriptionEnabled,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
