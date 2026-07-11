import 'dart:async';

import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final int maxRetries;
  static const _retryKey = 'retry_count';
  static const _retryableTypes = {
    DioExceptionType.connectionTimeout,
    DioExceptionType.sendTimeout,
    DioExceptionType.receiveTimeout,
  };

  RetryInterceptor({this.maxRetries = 3});

  bool _isRetryable(DioException e) {
    if (_retryableTypes.contains(e.type)) return true;

    if (e.type == DioExceptionType.badResponse) {
      final statusCode = e.response?.statusCode;
      return statusCode != null && statusCode >= 500;
    }

    return false;
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final retryCount = (err.requestOptions.extra[_retryKey] as int?) ?? 0;

    if (retryCount < maxRetries && _isRetryable(err)) {
      final delay = Duration(seconds: 1 << retryCount);

      err.requestOptions.extra[_retryKey] = retryCount + 1;

      await Future<void>.delayed(delay);

      try {
        final response = await Dio().fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } on DioException catch (e) {
        handler.next(e);
        return;
      }
    }

    handler.next(err);
  }
}
