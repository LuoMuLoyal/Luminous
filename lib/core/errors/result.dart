import 'error.dart';

/// A lightweight discriminated union representing the outcome of an
/// operation that can either succeed or fail.
///
/// Designed to work with Dart 3's sealed class / pattern matching:
///
/// ```dart
/// final result = await runGuarded(ref: ref, tag: '...', action: ...);
/// switch (result) {
///   case Success(:final value):
///     // use value
///   case Failure(:final error):
///     // handle error, dispatch on error.kind
/// }
/// ```
///
/// Or via [fold]:
///
/// ```dart
/// final message = result.fold(
///   onSuccess: (data) => 'Got $data',
///   onFailure: (error) => error.message,
/// );
/// ```
sealed class Result<T> {
  const Result();

  /// Creates a successful result wrapping [value].
  const factory Result.success(T value) = Success<T>;

  /// Creates a failed result wrapping [error].
  const factory Result.failure(AppError error) = Failure<T>;

  /// Pattern-matches on the result, invoking [onSuccess] or [onFailure].
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(AppError error) onFailure,
  });

  /// Returns the success value, or `null` if this is a [Failure].
  T? get valueOrNull;

  /// Returns the error, or `null` if this is a [Success].
  AppError? get errorOrNull;

  /// Whether this is a [Success].
  bool get isSuccess;

  /// Whether this is a [Failure].
  bool get isFailure;
}

/// Successful result containing a value of type [T].
final class Success<T> extends Result<T> {
  const Success(this.value);

  /// The wrapped success value.
  final T value;

  @override
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(AppError error) onFailure,
  }) => onSuccess(value);

  @override
  T? get valueOrNull => value;

  @override
  AppError? get errorOrNull => null;

  @override
  bool get isSuccess => true;

  @override
  bool get isFailure => false;
}

/// Failed result containing an [AppError].
final class Failure<T> extends Result<T> {
  const Failure(this.error);

  /// The wrapped error.
  final AppError error;

  @override
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(AppError error) onFailure,
  }) => onFailure(error);

  @override
  T? get valueOrNull => null;

  @override
  AppError? get errorOrNull => error;

  @override
  bool get isSuccess => false;

  @override
  bool get isFailure => true;
}
