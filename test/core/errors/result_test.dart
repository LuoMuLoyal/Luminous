import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/errors/app_error.dart';
import 'package:luminous/core/errors/result.dart';

void main() {
  group('Result.success', () {
    test('wraps value', () {
      const result = Result<int>.success(42);
      expect(result.valueOrNull, 42);
      expect(result.errorOrNull, isNull);
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
    });

    test('fold calls onSuccess', () {
      const result = Result<String>.success('hello');
      final output = result.fold(
        onSuccess: (v) => 'got: $v',
        onFailure: (_) => 'error',
      );
      expect(output, 'got: hello');
    });

    test('works with nullable value', () {
      const result = Result<int?>.success(null);
      expect(result.valueOrNull, isNull);
      expect(result.isSuccess, isTrue);
    });

    test('works with list value', () {
      final result = const Result<List<int>>.success([1, 2, 3]);
      expect(result.valueOrNull, [1, 2, 3]);
    });
  });

  group('Result.failure', () {
    test('wraps error', () {
      const error = AppError(message: 'fail', kind: AppErrorKind.server);
      final result = const Result<String>.failure(error);

      expect(result.errorOrNull, error);
      expect(result.valueOrNull, isNull);
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
    });

    test('fold calls onFailure', () {
      const error = AppError(message: 'fail');
      final result = const Result<int>.failure(error);

      final output = result.fold(
        onSuccess: (v) => 'got: $v',
        onFailure: (e) => 'error: ${e.message}',
      );
      expect(output, 'error: fail');
    });
  });

  group('Result pattern matching', () {
    test('switch on Success', () {
      const result = Result<int>.success(10);
      final message = switch (result) {
        Success(:final value) => 'ok: $value',
        Failure(:final error) => 'err: ${error.message}',
      };
      expect(message, 'ok: 10');
    });

    test('switch on Failure', () {
      const error = AppError(message: 'bad');
      final result = const Result<int>.failure(error);
      final message = switch (result) {
        Success(:final value) => 'ok: $value',
        Failure(:final error) => 'err: ${error.message}',
      };
      expect(message, 'err: bad');
    });
  });

  group('Result type inference', () {
    test('Success with custom type', () {
      const result = Result<_Custom>.success(_Custom(name: 'x'));
      expect(result.valueOrNull!.name, 'x');
    });

    test('Failure preserves error cause', () {
      const error = AppError(
        message: 'timeout',
        kind: AppErrorKind.network,
        code: 500,
        statusCode: 503,
        cause: 'connection refused',
      );
      final result = const Result<String>.failure(error);
      final err = result.errorOrNull!;
      expect(err.cause, 'connection refused');
      expect(err.kind, AppErrorKind.network);
    });
  });
}

class _Custom {
  const _Custom({required this.name});
  final String name;
}
