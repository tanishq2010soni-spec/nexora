import '../errors/app_exception.dart';

sealed class ApiResult<T> {
  const ApiResult();
}

class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  const ApiSuccess(this.data);
}

class ApiError<T> extends ApiResult<T> {
  final AppException exception;
  const ApiError(this.exception);
}

class ApiLoading<T> extends ApiResult<T> {
  const ApiLoading();
}
