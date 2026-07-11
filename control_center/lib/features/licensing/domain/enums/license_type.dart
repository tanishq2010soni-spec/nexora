enum LicenseType {
  community,
  professional,
  enterprise,
  educational,
  trial,
  custom;

  String toJson() => name;

  static LicenseType fromJson(String json) {
    return LicenseType.values.firstWhere(
      (e) => e.name == json,
      orElse: () => LicenseType.community,
    );
  }
}
