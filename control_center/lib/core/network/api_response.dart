import 'package:dio/dio.dart';

class ApiResponse {
  final int statusCode;
  final dynamic data;
  final String? message;

  const ApiResponse({required this.statusCode, this.data, this.message});

  factory ApiResponse.fromResponse(Response response) {
    final data = response.data;
    String? message;

    if (data is Map<String, dynamic>) {
      message = data['message'] as String?;
    }

    return ApiResponse(
      statusCode: response.statusCode ?? 0,
      data: data,
      message: message,
    );
  }

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
  bool get isUnauthorized => statusCode == 401;
  bool get isClientError => statusCode >= 400 && statusCode < 500;
  bool get isServerError => statusCode >= 500;
}
