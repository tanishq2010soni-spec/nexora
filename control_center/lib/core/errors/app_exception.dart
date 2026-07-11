sealed class AppException implements Exception {
  final String message;
  final int? statusCode;
  const AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class AuthException extends AppException {
  const AuthException(super.message, {super.statusCode});
}

class ValidationException extends AppException {
  final Map<String, String> fieldErrors;
  const ValidationException(
    super.message, {
    required this.fieldErrors,
    super.statusCode,
  });
}

class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode});
}

class TimeoutException extends AppException {
  const TimeoutException(super.message);
}

class RateLimitException extends AppException {
  const RateLimitException(super.message);
}

class UnknownException extends AppException {
  const UnknownException(super.message);
}
