import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/errors/lucent_failure.dart';

/// Runs [task] and returns the Right value, failing the test on Left.
Future<T> expectTaskRight<T>(TaskEither<LucentFailure, T> task) async {
  final result = await task.run();
  return result.fold(
    (failure) => fail('expected Right, got Left: $failure'),
    (value) => value,
  );
}

/// Runs [task] and returns the Left failure, failing the test on Right.
Future<LucentFailure> expectTaskLeft<T>(
  TaskEither<LucentFailure, T> task,
) async {
  final result = await task.run();
  return result.fold(
    (failure) => failure,
    (value) => fail('expected Left, got Right: $value'),
  );
}
