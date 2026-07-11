enum ProviderType {
  openai,
  anthropic,
  google,
  azure,
  awsBedrock,
  groq,
  together,
  replicate,
  ollama,
  openRouter,
  custom;

  String toJson() => name;

  static ProviderType fromJson(String json) {
    return ProviderType.values.firstWhere(
      (e) => e.name == json,
      orElse: () => ProviderType.custom,
    );
  }
}
