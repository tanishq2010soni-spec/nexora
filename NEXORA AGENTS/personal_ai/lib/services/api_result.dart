class ApiResult<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  const ApiResult({this.data, this.error, required this.isSuccess});

  factory ApiResult.success(T data) => ApiResult(data: data, isSuccess: true);

  factory ApiResult.failure(String error) => ApiResult(error: error, isSuccess: false);
}
