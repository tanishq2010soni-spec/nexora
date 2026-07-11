import 'package:freezed_annotation/freezed_annotation.dart';

part 'kb_statistics.freezed.dart';
part 'kb_statistics.g.dart';

@freezed
class KbStatistics with _$KbStatistics {
  const factory KbStatistics({
    @Default(0) int totalKnowledgeBases,
    @Default(0) int totalDocuments,
    @Default(0) int totalChunks,
    @Default(0) int totalEmbeddings,
    @Default(0) int processingDocuments,
    @Default(0) int indexedDocuments,
    @Default(0) int errorDocuments,
  }) = _KbStatistics;

  factory KbStatistics.fromJson(Map<String, dynamic> json) =>
      _$KbStatisticsFromJson(json);
}
