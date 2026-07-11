import '../enums/license_type.dart';

class LicenseModel {
  final String id;
  final String orgId;
  final LicenseType licenseType;
  final int seats;
  final String? featuresJson;
  final String? usageJson;
  final bool isActive;
  final bool isTrial;
  final DateTime? trialEndsAt;
  final DateTime? expiresAt;
  final String? billingMetadataJson;
  final String? hardwareFingerprint;
  final String? activationCode;
  final DateTime? activatedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LicenseModel({
    required this.id,
    required this.orgId,
    required this.licenseType,
    this.seats = 1,
    this.featuresJson,
    this.usageJson,
    this.isActive = true,
    this.isTrial = false,
    this.trialEndsAt,
    this.expiresAt,
    this.billingMetadataJson,
    this.hardwareFingerprint,
    this.activationCode,
    this.activatedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LicenseModel.fromJson(Map<String, dynamic> json) => LicenseModel(
    id: json['id'] as String,
    orgId: json['org_id'] as String,
    licenseType: LicenseType.fromJson(json['license_type'] as String),
    seats: json['seats'] as int? ?? 1,
    featuresJson: json['features_json'] as String?,
    usageJson: json['usage_json'] as String?,
    isActive: json['is_active'] as bool? ?? true,
    isTrial: json['is_trial'] as bool? ?? false,
    trialEndsAt: json['trial_ends_at'] != null
        ? DateTime.parse(json['trial_ends_at'] as String)
        : null,
    expiresAt: json['expires_at'] != null
        ? DateTime.parse(json['expires_at'] as String)
        : null,
    billingMetadataJson: json['billing_metadata_json'] as String?,
    hardwareFingerprint: json['hardware_fingerprint'] as String?,
    activationCode: json['activation_code'] as String?,
    activatedAt: json['activated_at'] != null
        ? DateTime.parse(json['activated_at'] as String)
        : null,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'org_id': orgId,
    'license_type': licenseType.toJson(),
    'seats': seats,
    'features_json': featuresJson,
    'usage_json': usageJson,
    'is_active': isActive,
    'is_trial': isTrial,
    'trial_ends_at': trialEndsAt?.toIso8601String(),
    'expires_at': expiresAt?.toIso8601String(),
    'billing_metadata_json': billingMetadataJson,
    'hardware_fingerprint': hardwareFingerprint,
    'activation_code': activationCode,
    'activated_at': activatedAt?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
