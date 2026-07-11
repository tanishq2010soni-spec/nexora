import '../enums/model_type.dart';

class ModelRegistryEntry {
  final String id;
  final String orgId;
  final String providerId;
  final String modelId;
  final String displayName;
  final ModelType type;
  final String? version;
  final double? sizeMb;
  final String? quantization;
  final int contextWindow;
  final bool supportsVision;
  final bool supportsAudio;
  final bool supportsReasoning;
  final bool supportsCoding;
  final bool supportsEmbedding;
  final bool supportsReranking;
  final bool isActive;
  final String? metadataJson;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ModelRegistryEntry({
    required this.id,
    required this.orgId,
    required this.providerId,
    required this.modelId,
    required this.displayName,
    this.type = ModelType.remote,
    this.version,
    this.sizeMb,
    this.quantization,
    this.contextWindow = 4096,
    this.supportsVision = false,
    this.supportsAudio = false,
    this.supportsReasoning = false,
    this.supportsCoding = false,
    this.supportsEmbedding = false,
    this.supportsReranking = false,
    this.isActive = true,
    this.metadataJson,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ModelRegistryEntry.fromJson(Map<String, dynamic> json) =>
      ModelRegistryEntry(
        id: json['id'] as String,
        orgId: json['org_id'] as String,
        providerId: json['provider_id'] as String,
        modelId: json['model_id'] as String,
        displayName: json['display_name'] as String,
        type: json['type'] != null
            ? ModelType.fromJson(json['type'] as String)
            : ModelType.remote,
        version: json['version'] as String?,
        sizeMb: (json['size_mb'] as num?)?.toDouble(),
        quantization: json['quantization'] as String?,
        contextWindow: json['context_window'] as int? ?? 4096,
        supportsVision: json['supports_vision'] as bool? ?? false,
        supportsAudio: json['supports_audio'] as bool? ?? false,
        supportsReasoning: json['supports_reasoning'] as bool? ?? false,
        supportsCoding: json['supports_coding'] as bool? ?? false,
        supportsEmbedding: json['supports_embedding'] as bool? ?? false,
        supportsReranking: json['supports_reranking'] as bool? ?? false,
        isActive: json['is_active'] as bool? ?? true,
        metadataJson: json['metadata_json'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'org_id': orgId,
    'provider_id': providerId,
    'model_id': modelId,
    'display_name': displayName,
    'type': type.toJson(),
    'version': version,
    'size_mb': sizeMb,
    'quantization': quantization,
    'context_window': contextWindow,
    'supports_vision': supportsVision,
    'supports_audio': supportsAudio,
    'supports_reasoning': supportsReasoning,
    'supports_coding': supportsCoding,
    'supports_embedding': supportsEmbedding,
    'supports_reranking': supportsReranking,
    'is_active': isActive,
    'metadata_json': metadataJson,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
