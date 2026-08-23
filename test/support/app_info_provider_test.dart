import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/error_code.dart';
import 'package:luminous/features/support/data/providers/resources.dart';
import 'package:luminous/features/support/data/repositories/lucent.dart';
import 'package:luminous/features/support/domain/entities/app_info.dart';
import 'package:luminous/features/support/domain/repositories/support.dart';

void main() {
  group('appInfoProvider', () {
    test('returns app info from repository', () async {
      final container = ProviderContainer(
        overrides: [
          supportRepositoryProvider.overrideWithValue(_MockSupportRepository()),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(appInfoProvider.future);

      final info = result!;
      expect(info.supportEmail, equals('support@lumos.app'));
      expect(info.latestVersion, equals('0.2.0'));
    });

    test('returns null when repository reports no metadata', () async {
      final container = ProviderContainer(
        overrides: [
          supportRepositoryProvider.overrideWithValue(_NullSupportRepository()),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(appInfoProvider.future);

      expect(result, isNull);
    });

    test('projects repository Left to AsyncValue.error', () async {
      final container = ProviderContainer(
        overrides: [
          supportRepositoryProvider.overrideWithValue(
            _FailingSupportRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Listen to keep the autoDispose provider alive and observe state changes.
      container.listen(appInfoProvider, (_, __) {}, fireImmediately: true);

      // Pump microtasks to let the future settle.
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final state = container.read(appInfoProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<LucentFailure>());
    });
  });
}

class _MockSupportRepository implements SupportRepository {
  @override
  TaskEither<LucentFailure, AppInfo?> getAppInfo() {
    return TaskEither.right(
      const AppInfo(supportEmail: 'support@lumos.app', latestVersion: '0.2.0'),
    );
  }
}

class _NullSupportRepository implements SupportRepository {
  @override
  TaskEither<LucentFailure, AppInfo?> getAppInfo() {
    return TaskEither.right(null);
  }
}

class _FailingSupportRepository implements SupportRepository {
  @override
  TaskEither<LucentFailure, AppInfo?> getAppInfo() {
    return TaskEither.left(
      LucentFailure.network(
        message: 'Network error',
        networkErrorCode: NetworkErrorCode.connectionError,
      ),
    );
  }
}
