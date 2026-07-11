import 'package:freezed_annotation/freezed_annotation.dart';
part 'search_index.freezed.dart';

enum SearchModule {
  agent,
  lead,
  customer,
  conversation,
  knowledgeBase,
  document,
  setting,
}

@freezed
class SearchEntry with _$SearchEntry {
  const factory SearchEntry({
    required String id,
    required SearchModule module,
    required String title,
    String? subtitle,
    required String route,
    Map<String, dynamic>? metadata,
    @Default(0.0) double relevanceScore,
  }) = _SearchEntry;
}
