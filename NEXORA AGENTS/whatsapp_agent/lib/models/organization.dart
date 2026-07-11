class Organization {
  final int id;
  final String name;
  final String? timezone;
  final String? workingHoursStart;
  final String? workingHoursEnd;
  final String? brandColor;
  final String? logoUrl;
  final String? defaultModel;
  final double? temperature;
  final int? maxTokens;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Organization({
    required this.id,
    required this.name,
    this.timezone,
    this.workingHoursStart,
    this.workingHoursEnd,
    this.brandColor,
    this.logoUrl,
    this.defaultModel,
    this.temperature,
    this.maxTokens,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'] as int,
      name: json['name'] as String,
      timezone: json['timezone'] as String?,
      workingHoursStart: json['working_hours_start'] as String?,
      workingHoursEnd: json['working_hours_end'] as String?,
      brandColor: json['brand_color'] as String?,
      logoUrl: json['logo_url'] as String?,
      defaultModel: json['default_model'] as String?,
      temperature: (json['temperature'] as num?)?.toDouble(),
      maxTokens: json['max_tokens'] as int?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'timezone': timezone,
      'working_hours_start': workingHoursStart,
      'working_hours_end': workingHoursEnd,
      'brand_color': brandColor,
      'logo_url': logoUrl,
      'default_model': defaultModel,
      'temperature': temperature,
      'max_tokens': maxTokens,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Organization copyWith({
    String? name,
    String? timezone,
    String? workingHoursStart,
    String? workingHoursEnd,
    String? brandColor,
    String? logoUrl,
    String? defaultModel,
    double? temperature,
    int? maxTokens,
    bool? isActive,
  }) {
    return Organization(
      id: id,
      name: name ?? this.name,
      timezone: timezone ?? this.timezone,
      workingHoursStart: workingHoursStart ?? this.workingHoursStart,
      workingHoursEnd: workingHoursEnd ?? this.workingHoursEnd,
      brandColor: brandColor ?? this.brandColor,
      logoUrl: logoUrl ?? this.logoUrl,
      defaultModel: defaultModel ?? this.defaultModel,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
