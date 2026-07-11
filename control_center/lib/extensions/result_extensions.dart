import '../core/network/api_result.dart';

extension ApiResultExtension<T> on ApiResult<T> {
  R when<R>({
    required R Function(T data) success,
    required R Function(dynamic error) error,
    R Function()? loading,
  }) {
    return switch (this) {
      ApiSuccess(:final data) => success(data),
      ApiError(:final exception) => error(exception),
      ApiLoading() => loading?.call() ?? error('Loading'),
    };
  }

  bool get isSuccess => this is ApiSuccess<T>;
  bool get isError => this is ApiError<T>;
  bool get isLoading => this is ApiLoading<T>;

  T? get data => switch (this) {
    ApiSuccess(:final data) => data,
    _ => null,
  };

  dynamic get exception => switch (this) {
    ApiError(:final exception) => exception,
    _ => null,
  };
}
