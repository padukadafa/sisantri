import '../error/failures.dart';

/// Result pattern untuk menangani success dan failure
sealed class Result<T> {
  const Result();
}

/// Success result
final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

/// Failure result
final class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}

/// Extension untuk Result pattern
extension ResultExtension<T> on Result<T> {
  /// Check apakah result adalah success
  bool get isSuccess => this is Success<T>;

  /// Check apakah result adalah error
  bool get isError => this is Error<T>;

  /// Get data jika success, null jika error
  T? get data => switch (this) {
    Success<T>(data: final data) => data,
    Error<T>() => null,
  };

  /// Get failure jika error, null jika success
  Failure? get failure => switch (this) {
    Success<T>() => null,
    Error<T>(failure: final failure) => failure,
  };

  /// Fold result dengan callback untuk success dan error
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onError,
  }) {
    return switch (this) {
      Success<T>(data: final data) => onSuccess(data),
      Error<T>(failure: final failure) => onError(failure),
    };
  }

  /// Map data jika success
  Result<R> map<R>(R Function(T data) mapper) {
    return switch (this) {
      Success<T>(data: final data) => Success(mapper(data)),
      Error<T>(failure: final failure) => Error(failure),
    };
  }

  /// FlatMap untuk chaining operations
  Result<R> flatMap<R>(Result<R> Function(T data) mapper) {
    return switch (this) {
      Success<T>(data: final data) => mapper(data),
      Error<T>(failure: final failure) => Error(failure),
    };
  }
}
