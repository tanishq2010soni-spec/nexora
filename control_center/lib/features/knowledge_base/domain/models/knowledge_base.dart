import 'package:freezed_annotation/freezed_annotation.dart';

part 'knowledge_base.freezed.dart';
part 'knowledge_base.g.dart';

@freezed
class KnowledgeBase with _$KnowledgeBase {
  const factory KnowledgeBase({
    required String id,
    required String orgId,
    required String name,
    String? description,
    @Default(0) int documentCount,
    @Default(0) int totalChunks,
    @Default(0) int totalEmbeddings,
    @Default('healthy') String qdrantSyncStatus,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _KnowledgeBase;

  factory KnowledgeBase.fromJson(Map<String, dynamic> json) =>
      _$KnowledgeBaseFromJson(json);
}
