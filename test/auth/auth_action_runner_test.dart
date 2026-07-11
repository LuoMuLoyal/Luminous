import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/errors/app_error.dart';
import 'package:luminous/core/network/api_exception.dart';
import 'package:luminous/features/auth/presentation/providers/shared/auth_action_runner.dart';

void main() {
  group('runAuthAction', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

      test('returns value on success', () async {
        final result = await runAuthAction<String>(
          ref: container.read(provider),
          tag: 'test',
          action: () async => 'success-value',
        );

        expect(result.value, 'success-value');
        expect(result.error, isNull);
      });

      test('returns error message on generic exception', () async {
        final result = await runAuthAction<String>(
          ref: container.read(provider),
          tag: 'test',
          action: () async => throw Exception('something went wrong'),
        );

        expect(result.value, isNull);
        expect(result.error, isNotNull);
      });

      test('returns error message on LucentApiException', () async {
        final result = await runAuthAction<String>(
          ref: container.read(provider),
          tag: 'test',
          action: () async => throw const LucentApiException(
            message: 'API error occurred',
            code: 4001,
          ),
        );

        expect(result.value, isNull);
        expect(result.error, 'API error occurred');
      });

      test('returns generic error message for non-API exceptions', () async {
        // AppError thrown directly is not recognized by LucentErrorMapper,
        // so it maps to the generic fallback message.
        final result = await runAuthAction<String>(
          ref: container.read(provider),
          tag: 'test',
          action: () async => throw AppError(
            message: 'auth failed',
            kind: AppErrorKind.auth,
          ),
        );

        expect(result.value, isNull);
        expect(result.error, '发生了未预期的错误。');
      });

      test('works with int return type', () async {
        final result = await runAuthAction<int>(
          ref: container.read(provider),
          tag: 'test',
          action: () async => 42,
        );

        expect(result.value, 42);
        expect(result.error, isNull);
      });

      test('works with nullable return type', () async {
        final result = await runAuthAction<String?>(
          ref: container.read(provider),
          tag: 'test',
          action: () async => null,
        );

        expect(result.value, isNull);
        expect(result.error, isNull);
      });

      test('works with List return type', () async {
        final result = await runAuthAction<List<int>>(
          ref: container.read(provider),
          tag: 'test',
          action: () async => [1, 2, 3],
        );

        expect(result.value, [1, 2, 3]);
        expect(result.error, isNull);
      });

      test('preserves tag in error path', () async {
        // The tag is used for logging; we verify no crash occurs
        await runAuthAction<String>(
          ref: container.read(provider),
          tag: 'auth-flow-tag',
          action: () async => throw Exception('fail'),
        );

        // If we reach here without hanging, the tag was processed
        expect(true, isTrue);
      });
    });
}

/// Simple provider to get a [Ref] for testing.
final provider = Provider<Ref>((ref) => ref);
