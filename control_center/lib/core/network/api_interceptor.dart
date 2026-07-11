import 'dart:developer';

import 'package:dio/dio.dart';

import '../errors/error_handler.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log('REQUEST[${options.method}] => PATH: ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log(
      'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final appException = ErrorHandler.fromDio(err);
    log(
      'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path} | ${appException.message}',
    );
    handler.next(err);
  }
}
