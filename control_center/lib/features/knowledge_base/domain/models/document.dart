import 'package:freezed_annotation/freezed_annotation.dart';

part 'document.freezed.dart';
part 'document.g.dart';

enum DocumentStatus { processing, indexed, error, deleted }

enum DocumentType { pdf, docx, txt, unknown }

@freezed
class KbDocument with _$KbDocument {
  const factory KbDocument({
    required String id,
    required String knowledgeBaseId,
    required String filename,
    required DocumentType fileType,
    required DocumentStatus status,
    @Default(0) int chunkCount,
    @Default(0) int embeddingCount,
    @Default(0) int fileSizeBytes,
    String? errorMessage,
    DateTime? indexedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _KbDocument;

  factory KbDocument.fromJson(Map<String, dynamic> json) =>
      _$KbDocumentFromJson(json);
}
