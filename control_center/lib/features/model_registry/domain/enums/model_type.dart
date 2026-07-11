enum ModelType {
  installed,
  remote,
  favorite,
  downloaded;

  String toJson() => name;

  static ModelType fromJson(String json) {
    return ModelType.values.firstWhere(
      (e) => e.name == json,
      orElse: () => ModelType.remote,
    );
  }
}
