enum ProviderHealthStatus {
  healthy,
  degraded,
  down,
  unknown;

  String toJson() => name;

  static ProviderHealthStatus fromJson(String json) {
    return ProviderHealthStatus.values.firstWhere(
      (e) => e.name == json,
      orElse: () => ProviderHealthStatus.unknown,
    );
  }
}
