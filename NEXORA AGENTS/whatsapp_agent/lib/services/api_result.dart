class ApiResult<T> {
  final T? data;
  final String? error;
  final int? statusCode;
  final bool isSuccess;

  ApiResult._({
    this.data,
    this.error,
    this.statusCode,
    required this.isSuccess,
  });

  factory ApiResult.ok(T data, {int? statusCode}) {
    return ApiResult._(
      data: data,
      isSuccess: true,
      statusCode: statusCode,
    );
  }

  factory ApiResult.fail(String error, {int? statusCode}) {
    return ApiResult._(
      error: error,
      isSuccess: false,
      statusCode: statusCode,
    );
  }

  T getOrThrow() {
    if (data != null) return data as T;
    throw Exception(error ?? 'Unknown error');
  }

  T? getOrNull() => data;

  T getOrDefault(T defaultValue) => data ?? defaultValue;
}
