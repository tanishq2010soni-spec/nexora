// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$KbDocumentImpl _$$KbDocumentImplFromJson(Map<String, dynamic> json) =>
    _$KbDocumentImpl(
      id: json['id'] as String,
      knowledgeBaseId: json['knowledgeBaseId'] as String,
      filename: json['filename'] as String,
      fileType: $enumDecode(_$DocumentTypeEnumMap, json['fileType']),
      status: $enumDecode(_$DocumentStatusEnumMap, json['status']),
      chunkCount: (json['chunkCount'] as num?)?.toInt() ?? 0,
      embeddingCount: (json['embeddingCount'] as num?)?.toInt() ?? 0,
      fileSizeBytes: (json['fileSizeBytes'] as num?)?.toInt() ?? 0,
      errorMessage: json['errorMessage'] as String?,
      indexedAt: json['indexedAt'] == null
          ? null
          : DateTime.parse(json['indexedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$KbDocumentImplToJson(_$KbDocumentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'knowledgeBaseId': instance.knowledgeBaseId,
      'filename': instance.filename,
      'fileType': _$DocumentTypeEnumMap[instance.fileType]!,
      'status': _$DocumentStatusEnumMap[instance.status]!,
      'chunkCount': instance.chunkCount,
      'embeddingCount': instance.embeddingCount,
      'fileSizeBytes': instance.fileSizeBytes,
      'errorMessage': instance.errorMessage,
      'indexedAt': instance.indexedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$DocumentTypeEnumMap = {
  DocumentType.pdf: 'pdf',
  DocumentType.docx: 'docx',
  DocumentType.txt: 'txt',
  DocumentType.unknown: 'unknown',
};

const _$DocumentStatusEnumMap = {
  DocumentStatus.processing: 'processing',
  DocumentStatus.indexed: 'indexed',
  DocumentStatus.error: 'error',
  DocumentStatus.deleted: 'deleted',
};
