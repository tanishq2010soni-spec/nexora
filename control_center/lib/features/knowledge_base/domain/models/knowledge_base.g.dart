// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'knowledge_base.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$KnowledgeBaseImpl _$$KnowledgeBaseImplFromJson(Map<String, dynamic> json) =>
    _$KnowledgeBaseImpl(
      id: json['id'] as String,
      orgId: json['orgId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      documentCount: (json['documentCount'] as num?)?.toInt() ?? 0,
      totalChunks: (json['totalChunks'] as num?)?.toInt() ?? 0,
      totalEmbeddings: (json['totalEmbeddings'] as num?)?.toInt() ?? 0,
      qdrantSyncStatus: json['qdrantSyncStatus'] as String? ?? 'healthy',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$KnowledgeBaseImplToJson(_$KnowledgeBaseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orgId': instance.orgId,
      'name': instance.name,
      'description': instance.description,
      'documentCount': instance.documentCount,
      'totalChunks': instance.totalChunks,
      'totalEmbeddings': instance.totalEmbeddings,
      'qdrantSyncStatus': instance.qdrantSyncStatus,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
