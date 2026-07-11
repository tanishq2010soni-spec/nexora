// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kb_statistics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$KbStatisticsImpl _$$KbStatisticsImplFromJson(Map<String, dynamic> json) =>
    _$KbStatisticsImpl(
      totalKnowledgeBases: (json['totalKnowledgeBases'] as num?)?.toInt() ?? 0,
      totalDocuments: (json['totalDocuments'] as num?)?.toInt() ?? 0,
      totalChunks: (json['totalChunks'] as num?)?.toInt() ?? 0,
      totalEmbeddings: (json['totalEmbeddings'] as num?)?.toInt() ?? 0,
      processingDocuments: (json['processingDocuments'] as num?)?.toInt() ?? 0,
      indexedDocuments: (json['indexedDocuments'] as num?)?.toInt() ?? 0,
      errorDocuments: (json['errorDocuments'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$KbStatisticsImplToJson(_$KbStatisticsImpl instance) =>
    <String, dynamic>{
      'totalKnowledgeBases': instance.totalKnowledgeBases,
      'totalDocuments': instance.totalDocuments,
      'totalChunks': instance.totalChunks,
      'totalEmbeddings': instance.totalEmbeddings,
      'processingDocuments': instance.processingDocuments,
      'indexedDocuments': instance.indexedDocuments,
      'errorDocuments': instance.errorDocuments,
    };
