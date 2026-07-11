import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/errors/app_error.dart';
import 'package:luminous/core/errors/result.dart';
import 'package:luminous/core/errors/run_guarded.dart';
import 'package:luminous/core/network/api_exception.dart';

void main() {
  group('runGuarded — success path', () {
    test('returns Result.success with value', () async {
      final result = await runGuarded<String>(
        ref: null,
        tag: 'test',
        action: () async => 'hello',
      );

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, 'hello');
    });

    test('returns Result.success with int', () async {
      final result = await runGuarded<int>(
        ref: null,
        tag: 'test',
        action: () async => 42,
      );

      expect(result.valueOrNull, 42);
    });

    test('returns Result.success with null value', () async {
      final result = await runGuarded<String?>(
        ref: null,
        tag: 'test',
        action: () async => null,
      );

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, isNull);
    });

    test('works with Ref from ProviderContainer', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = await container.read(_testSuccessProvider.future);

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, 'from-ref');
    });
  });

  group('runGuarded — error path', () {
    test('returns Result.failure on generic exception', () async {
      final result = await runGuarded<String>(
        ref: null,
        tag: 'test',
        action: () async => throw Exception('boom'),
      );

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isNotNull);
      expect(result.errorOrNull!.kind, AppErrorKind.unknown);
      expect(result.errorOrNull!.message, isNotEmpty);
    });

    test('returns Result.failure on LucentApiException', () async {
      final result = await runGuarded<String>(
        ref: null,
        tag: 'test',
        action: () async => throw const LucentApiException(
          message: 'token expired',
          code: 401002,
          statusCode: 401,
        ),
      );

      expect(result.isFailure, isTrue);
      final error = result.errorOrNull!;
      expect(error.message, 'token expired');
      expect(error.code, 401002);
      expect(error.statusCode, 401);
      expect(error.kind, AppErrorKind.auth);
    });

    test('preserves cause in AppError', () async {
      final original = StateError('state error');
      final result = await runGuarded<String>(
        ref: null,
        tag: 'test',
        action: () async => throw original,
      );

      expect(result.errorOrNull!.cause, original);
    });
  });

  group('runGuarded — ref handling', () {
    test('falls back to appTalker when ref is null', () async {
      final result = await runGuarded<String>(
        ref: null,
        tag: 'null-ref',
        action: () async => 'ok',
      );

      expect(result.isSuccess, isTrue);
    });

    test(
      'falls back to appTalker when ref is neither Ref nor WidgetRef',
      () async {
        final result = await runGuarded<String>(
          ref: 'not-a-ref',
          tag: 'string-ref',
          action: () async => 'ok',
        );

        expect(result.isSuccess, isTrue);
      },
    );

    test('works with Ref from provider', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final result = await container.read(_testErrorProvider.future);

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull!.message, 'planned failure');
    });
  });
}

final _testSuccessProvider = FutureProvider<Result<String>>((ref) {
  return runGuarded<String>(
    ref: ref,
    tag: 'test-success',
    action: () async => 'from-ref',
  );
});

final _testErrorProvider = FutureProvider<Result<String>>((ref) {
  return runGuarded<String>(
    ref: ref,
    tag: 'test-error',
    action: () async =>
        throw const LucentApiException(message: 'planned failure'),
  );
});
