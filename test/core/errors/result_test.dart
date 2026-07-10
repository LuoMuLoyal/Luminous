import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/errors/app_error.dart';
import 'package:luminous/core/errors/result.dart';

void main() {
  group('Result', () {
    test('Result.success wraps value', () {
      const result = Result<int>.success(42);
      expect(result, isA<Success<int>>());
      expect(result.valueOrNull, equals(42));
      expect(result.errorOrNull, isNull);
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
    });

    test('Result.failure wraps error', () {
      const error = AppError(message: 'something went wrong');
      const result = Result<int>.failure(error);
      expect(result, isA<Failure<int>>());
      expect(result.valueOrNull, isNull);
      expect(result.errorOrNull, same(error));
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
    });

    test('fold calls onSuccess for Success', () {
      const result = Result<String>.success('hello');
      final value = result.fold(
        onSuccess: (v) => v.toUpperCase(),
        onFailure: (_) => 'fallback',
      );
      expect(value, equals('HELLO'));
    });

    test('fold calls onFailure for Failure', () {
      const result = Result<String>.failure(
        AppError(message: 'error', kind: AppErrorKind.network),
      );
      final value = result.fold(
        onSuccess: (v) => v,
        onFailure: (e) => e.message,
      );
      expect(value, equals('error'));
    });

    test('switch pattern matching works', () {
      const success = Result<int>.success(10);
      const failure = Result<int>.failure(AppError(message: 'fail'));

      final s = switch (success) {
        Success(:final value) => 'ok: $value',
        Failure(:final error) => 'err: ${error.message}',
      };
      expect(s, equals('ok: 10'));

      final f = switch (failure) {
        Success(:final value) => 'ok: $value',
        Failure(:final error) => 'err: ${error.message}',
      };
      expect(f, equals('err: fail'));
    });

    test('can hold null value in Success', () {
      const result = Result<Object?>.success(null);
      expect(result.valueOrNull, isNull);
      expect(result.isSuccess, isTrue);
    });

    test('can hold complex types', () {
      const result = Result<List<int>>.success([1, 2, 3]);
      expect(result.valueOrNull, equals([1, 2, 3]));
    });
  });

  group('AppError', () {
    test('defaults kind to unknown', () {
      const error = AppError(message: 'test');
      expect(error.kind, equals(AppErrorKind.unknown));
    });

    test('preserves all fields', () {
      const error = AppError(
        message: 'Token expired',
        kind: AppErrorKind.auth,
        code: 401002,
        statusCode: 401,
        requestId: 'req-123',
        cause: 'original exception',
      );
      expect(error.message, equals('Token expired'));
      expect(error.kind, equals(AppErrorKind.auth));
      expect(error.code, equals(401002));
      expect(error.statusCode, equals(401));
      expect(error.requestId, equals('req-123'));
      expect(error.cause, equals('original exception'));
    });

    test('toString contains key info', () {
      const error = AppError(
        message: 'fail',
        kind: AppErrorKind.server,
        code: 500001,
        statusCode: 500,
      );
      final str = error.toString();
      expect(str, contains('AppError'));
      expect(str, contains('message: fail'));
      expect(str, contains('kind: AppErrorKind.server'));
      expect(str, contains('code: 500001'));
      expect(str, contains('statusCode: 500'));
    });
  });
}
