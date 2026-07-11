import '../enums/indexing_status.dart';
import '../enums/source_type.dart';

class KnowledgeSource {
  final String id;
  final String orgId;
  final String kbId;
  final SourceType sourceType;
  final String name;
  final String? configJson;
  final IndexingStatus indexingStatus;
  final DateTime? lastIndexedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const KnowledgeSource({
    required this.id,
    required this.orgId,
    required this.kbId,
    required this.sourceType,
    required this.name,
    this.configJson,
    this.indexingStatus = IndexingStatus.pending,
    this.lastIndexedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory KnowledgeSource.fromJson(Map<String, dynamic> json) => KnowledgeSource(
    id: json['id'] as String,
    orgId: json['org_id'] as String,
    kbId: json['kb_id'] as String,
    sourceType: SourceType.fromJson(json['source_type'] as String),
    name: json['name'] as String,
    configJson: json['config_json'] as String?,
    indexingStatus: json['indexing_status'] != null
        ? IndexingStatus.fromJson(json['indexing_status'] as String)
        : IndexingStatus.pending,
    lastIndexedAt: json['last_indexed_at'] != null
        ? DateTime.parse(json['last_indexed_at'] as String)
        : null,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'org_id': orgId,
    'kb_id': kbId,
    'source_type': sourceType.toJson(),
    'name': name,
    'config_json': configJson,
    'indexing_status': indexingStatus.toJson(),
    'last_indexed_at': lastIndexedAt?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
