import 'package:dio/dio.dart';

import 'app_exception.dart';

class ErrorHandler {
  const ErrorHandler._();

  static AppException fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(e.message ?? 'Request timed out');
      case DioExceptionType.connectionError:
        return NetworkException(e.message ?? 'Connection error');
      case DioExceptionType.badResponse:
        return _handleBadResponse(e);
      case DioExceptionType.cancel:
        return NetworkException('Request was cancelled');
      case DioExceptionType.unknown:
        return UnknownException(e.message ?? 'Unknown error');
      case DioExceptionType.badCertificate:
        return NetworkException('Bad certificate');
    }
  }

  static AppException _handleBadResponse(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    final message = switch (data) {
      Map<String, dynamic> map => map['message'] as String? ?? 'Server error',
      String s => s,
      _ => 'Server error',
    };

    if (statusCode != null && statusCode == 401) {
      return AuthException(message, statusCode: statusCode);
    }

    if (statusCode != null && statusCode == 429) {
      return RateLimitException(message);
    }

    if (statusCode != null && statusCode >= 400 && statusCode < 500) {
      if (data is Map<String, dynamic> && data.containsKey('errors')) {
        final errors = (data['errors'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, value.toString()),
        );
        return ValidationException(
          message,
          fieldErrors: errors,
          statusCode: statusCode,
        );
      }
      return ServerException(message, statusCode: statusCode);
    }

    if (statusCode != null && statusCode >= 500) {
      return ServerException(message, statusCode: statusCode);
    }

    return ServerException(message, statusCode: statusCode);
  }
}
