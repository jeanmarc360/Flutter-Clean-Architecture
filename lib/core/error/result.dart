import 'failure.dart';

sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;

  T? get data => switch (this) {
        Success<T>(:final value) => value,
        Err<T>() => null,
      };

  Failure? get error => switch (this) {
        Err<T>(:final failure) => failure,
        Success<T>() => null,
      };
}

final class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

final class Err<T> extends Result<T> {
  final Failure failure;
  const Err(this.failure);
}
