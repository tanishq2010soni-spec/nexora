import '../env/env.dart';

class ApiConstants {
  ApiConstants._();

  static String get baseUrl => Env.apiBaseUrl;
  static const String apiVersion = '/api/v1';
  static const String authPath = '/auth';
  static const String leadsPath = '/leads';
  static const String customersPath = '/customers';
  static const String chatPath = '/chat';
  static const String documentsPath = '/documents';
  static const String businessPath = '/business';
  static const String healthPath = '/health';
  static const String monitoringPath = '/monitoring';

  static String get fullBaseUrl => '$baseUrl$apiVersion';
  static String get authUrl => '$fullBaseUrl$authPath';
  static String get leadsUrl => '$fullBaseUrl$leadsPath';
  static String get customersUrl => '$fullBaseUrl$customersPath';
  static String get chatUrl => '$fullBaseUrl$chatPath';
  static String get documentsUrl => '$fullBaseUrl$documentsPath';
  static String get businessUrl => '$fullBaseUrl$businessPath';
  static String get healthUrl => '$baseUrl$healthPath';
  static String get monitoringUrl => '$fullBaseUrl$monitoringPath';
}
