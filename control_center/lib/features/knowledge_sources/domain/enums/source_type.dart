enum SourceType {
  web,
  file,
  database,
  api,
  s3,
  gcs,
  confluence,
  notion,
  sharepoint,
  slack,
  discord,
  custom;

  String toJson() => name;

  static SourceType fromJson(String json) {
    return SourceType.values.firstWhere(
      (e) => e.name == json,
      orElse: () => SourceType.custom,
    );
  }
}
