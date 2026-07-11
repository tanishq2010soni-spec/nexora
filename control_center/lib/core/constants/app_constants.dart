class AppConstants {
  AppConstants._();

  static const String appName = 'Nexora Control Center';
  static const int maxRetries = 3;
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration refreshThreshold = Duration(seconds: 30);
}
