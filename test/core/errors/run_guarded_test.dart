import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/errors/app_error.dart';
import 'package:luminous/core/errors/result.dart';
import 'package:luminous/core/errors/run_guarded.dart';
import 'package:luminous/core/network/api_exception.dart';

/// Test-only provider that exposes [Ref] to the test body.
final _testRefProvider = Provider<Ref>((ref) => ref);

void main() {
  late ProviderContainer container;
  late Ref ref;

  setUp(() {
    container = ProviderContainer();
    ref = container.read(_testRefProvider);
    addTearDown(container.dispose);
  });

  group('runGuarded', () {
    test('returns Success with value when action succeeds', () async {
      final result = await runGuarded<int>(
        ref: ref,
        tag: 'test',
        action: () async => 42,
      );

      expect(result, isA<Success<int>>());
      expect(result.valueOrNull, equals(42));
      expect(result.isSuccess, isTrue);
    });

    test('returns Failure with AppError when action throws', () async {
      final result = await runGuarded<int>(
        ref: ref,
        tag: 'test-throw',
        action: () async => throw const LucentApiException(
          message: 'Token expired',
          code: 401002,
          statusCode: 401,
        ),
      );

      expect(result, isA<Failure<int>>());
      expect(result.isFailure, isTrue);
      final error = result.errorOrNull!;
      expect(error.message, equals('Token expired'));
      expect(error.kind, equals(AppErrorKind.auth));
      expect(error.code, equals(401002));
      expect(error.statusCode, equals(401));
    });

    test('maps DioException to network kind', () async {
      final result = await runGuarded<String>(
        ref: ref,
        tag: 'test-dio',
        action: () async => throw DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      expect(result, isA<Failure<String>>());
      expect(result.errorOrNull!.kind, equals(AppErrorKind.network));
      expect(result.errorOrNull!.message, equals('连接超时，请稍后再试。'));
    });

    test('maps generic Exception to unknown kind', () async {
      final result = await runGuarded<String>(
        ref: ref,
        tag: 'test-generic',
        action: () async => throw Exception('unexpected'),
      );

      expect(result, isA<Failure<String>>());
      expect(result.errorOrNull!.kind, equals(AppErrorKind.unknown));
    });

    test('preserves cause as original thrown object', () async {
      final original = StateError('boom');
      final result = await runGuarded<void>(
        ref: ref,
        tag: 'test-cause',
        action: () async => throw original,
      );

      expect(result.errorOrNull!.cause, same(original));
    });

    test('works with void return type', () async {
      final result = await runGuarded<void>(
        ref: ref,
        tag: 'test-void',
        action: () async {},
      );

      expect(result.isSuccess, isTrue);
    });

    test('fold works on result', () async {
      final successResult = await runGuarded<int>(
        ref: ref,
        tag: 'test-fold-success',
        action: () async => 10,
      );
      final value = successResult.fold(
        onSuccess: (v) => v * 2,
        onFailure: (_) => -1,
      );
      expect(value, equals(20));

      final failureResult = await runGuarded<int>(
        ref: ref,
        tag: 'test-fold-failure',
        action: () async => throw Exception('fail'),
      );
      final fallback = failureResult.fold(
        onSuccess: (v) => v,
        onFailure: (e) => e.message,
      );
      expect(fallback, equals('发生了未预期的错误。'));
    });
  });
}
