enum IndexingStatus {
  pending,
  indexing,
  completed,
  failed,
  skipped;

  String toJson() => name;

  static IndexingStatus fromJson(String json) {
    return IndexingStatus.values.firstWhere(
      (e) => e.name == json,
      orElse: () => IndexingStatus.pending,
    );
  }
}
