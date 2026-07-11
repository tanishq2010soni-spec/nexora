import '../enums/provider_health_status.dart';
import '../enums/provider_type.dart';

class ProviderModel {
  final String id;
  final String orgId;
  final String name;
  final ProviderType providerType;
  final String? apiKeyEncrypted;
  final String? endpointUrl;
  final bool isActive;
  final bool supportsStreaming;
  final bool supportsVision;
  final bool supportsToolCalling;
  final int contextWindow;
  final double pricingInputPer1k;
  final double pricingOutputPer1k;
  final int latencyP50Ms;
  final int latencyP95Ms;
  final String? capabilitiesJson;
  final ProviderHealthStatus healthStatus;
  final DateTime? lastHealthCheckAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProviderModel({
    required this.id,
    required this.orgId,
    required this.name,
    required this.providerType,
    this.apiKeyEncrypted,
    this.endpointUrl,
    this.isActive = true,
    this.supportsStreaming = false,
    this.supportsVision = false,
    this.supportsToolCalling = false,
    this.contextWindow = 4096,
    this.pricingInputPer1k = 0.0,
    this.pricingOutputPer1k = 0.0,
    this.latencyP50Ms = 0,
    this.latencyP95Ms = 0,
    this.capabilitiesJson,
    this.healthStatus = ProviderHealthStatus.unknown,
    this.lastHealthCheckAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) => ProviderModel(
    id: json['id'] as String,
    orgId: json['org_id'] as String,
    name: json['name'] as String,
    providerType: ProviderType.fromJson(json['provider_type'] as String),
    apiKeyEncrypted: json['api_key_encrypted'] as String?,
    endpointUrl: json['endpoint_url'] as String?,
    isActive: json['is_active'] as bool? ?? true,
    supportsStreaming: json['supports_streaming'] as bool? ?? false,
    supportsVision: json['supports_vision'] as bool? ?? false,
    supportsToolCalling: json['supports_tool_calling'] as bool? ?? false,
    contextWindow: json['context_window'] as int? ?? 4096,
    pricingInputPer1k: (json['pricing_input_per_1k'] as num?)?.toDouble() ?? 0.0,
    pricingOutputPer1k: (json['pricing_output_per_1k'] as num?)?.toDouble() ?? 0.0,
    latencyP50Ms: json['latency_p50_ms'] as int? ?? 0,
    latencyP95Ms: json['latency_p95_ms'] as int? ?? 0,
    capabilitiesJson: json['capabilities_json'] as String?,
    healthStatus: json['health_status'] != null
        ? ProviderHealthStatus.fromJson(json['health_status'] as String)
        : ProviderHealthStatus.unknown,
    lastHealthCheckAt: json['last_health_check_at'] != null
        ? DateTime.parse(json['last_health_check_at'] as String)
        : null,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'org_id': orgId,
    'name': name,
    'provider_type': providerType.toJson(),
    'api_key_encrypted': apiKeyEncrypted,
    'endpoint_url': endpointUrl,
    'is_active': isActive,
    'supports_streaming': supportsStreaming,
    'supports_vision': supportsVision,
    'supports_tool_calling': supportsToolCalling,
    'context_window': contextWindow,
    'pricing_input_per_1k': pricingInputPer1k,
    'pricing_output_per_1k': pricingOutputPer1k,
    'latency_p50_ms': latencyP50Ms,
    'latency_p95_ms': latencyP95Ms,
    'capabilities_json': capabilitiesJson,
    'health_status': healthStatus.toJson(),
    'last_health_check_at': lastHealthCheckAt?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
