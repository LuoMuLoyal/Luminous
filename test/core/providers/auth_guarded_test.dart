import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/network/client/client_providers.dart';
import 'package:luminous/core/network/client/session_store.dart';
import 'package:luminous/core/providers/auth_guarded.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('authGuarded', () {
    test('calls fetch when authenticated', () async {
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(
            () => _FakeSessionNotifier(
              const AuthSessionState(isLoading: false, isAuthenticated: true),
            ),
          ),
        ],
      );

      final result = await container.read(_testFetchProvider.future);

      expect(result, 'success');

      container.dispose();
    });

    test(
      'throws AuthRequiredException when signed out and no fallback',
      () async {
        final container = ProviderContainer(
          overrides: [
            authSessionProvider.overrideWith(
              () => _FakeSessionNotifier(
                const AuthSessionState(
                  isLoading: false,
                  isAuthenticated: false,
                ),
              ),
            ),
          ],
        );

        // authGuarded is async, so the thrown exception settles into the
        // provider's error state on the next microtask.
        container.read(_testNoFallbackProvider);
        await Future<void>.delayed(const Duration(milliseconds: 50));
        final value = container.read(_testNoFallbackProvider);
        expect(value.hasError, isTrue);
        expect(value.error, isA<AuthRequiredException>());

        container.dispose();
      },
    );

    test('calls signedOutFallback when signed out', () async {
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(
            () => _FakeSessionNotifier(
              const AuthSessionState(isLoading: false, isAuthenticated: false),
            ),
          ),
        ],
      );

      final result = await container.read(_testWithFallbackProvider.future);

      expect(result, 'fallback');

      container.dispose();
    });

    test('fetches during session restore with stored session', () async {
      final sessionStore = MemorySessionStore();
      // Simulate a returning user with stored tokens.
      await sessionStore.write(
        const LucentSessionTokens(
          accessToken: 'access',
          refreshToken: 'refresh',
        ),
      );

      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(
            () => _FakeSessionNotifier(
              const AuthSessionState(isLoading: true, isAuthenticated: false),
            ),
          ),
          lucentSessionStoreProvider.overrideWithValue(sessionStore),
        ],
      );

      // During restore authGuarded attempts the fetch when a stored session
      // exists so cache-first repositories return local data immediately.
      final result = await container.read(_testFetchProvider.future);

      expect(result, 'success');

      container.dispose();
    });

    test('stays pending during restore without stored session', () async {
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(
            () => _FakeSessionNotifier(
              const AuthSessionState(isLoading: true, isAuthenticated: false),
            ),
          ),
        ],
      );

      // No session store override: SecureLucentSessionStore may or may not
      // have tokens in the test env — the defensive catch in _hasStoredSession
      // treats a store-read failure as "no stored session" and falls back to
      // the old blocking future.
      final future = container.read(_testFetchProvider.future);
      bool completed = false;
      unawaited(future.whenComplete(() => completed = true));

      await Future.delayed(const Duration(milliseconds: 100));

      expect(completed, isFalse);

      container.dispose();
    });

    test('treats a throwing session store as no stored session', () async {
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(
            () => _FakeSessionNotifier(
              const AuthSessionState(isLoading: true, isAuthenticated: false),
            ),
          ),
          lucentSessionStoreProvider.overrideWithValue(
            _ThrowingSessionStore('platform channel unavailable'),
          ),
        ],
      );

      // 读失败仍然保守回退成"无会话"（保持既有语义），但也必须留下日志——
      // 静默吞掉会把"store 注册错/通道坏了"这类真问题伪装成"用户没登录"。
      final future = container.read(_testFetchProvider.future);
      bool completed = false;
      unawaited(future.whenComplete(() => completed = true));

      await Future.delayed(const Duration(milliseconds: 100));

      expect(completed, isFalse);

      container.dispose();
    });

    test('propagates fetch errors', () async {
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(
            () => _FakeSessionNotifier(
              const AuthSessionState(isLoading: false, isAuthenticated: true),
            ),
          ),
        ],
      );

      // Trigger the provider and wait for the async error
      container.read(_testErrorFetchProvider);
      await Future.delayed(const Duration(milliseconds: 50));
      final value = container.read(_testErrorFetchProvider);
      expect(value.hasError, isTrue);

      container.dispose();
    });

    test('propagates signedOutFallback errors', () async {
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(
            () => _FakeSessionNotifier(
              const AuthSessionState(isLoading: false, isAuthenticated: false),
            ),
          ),
        ],
      );

      // Trigger the provider and wait for the async error
      container.read(_testErrorFallbackProvider);
      await Future.delayed(const Duration(milliseconds: 50));
      final value = container.read(_testErrorFallbackProvider);
      expect(value.hasError, isTrue);

      container.dispose();
    });

    test('works with nullable return type', () async {
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(
            () => _FakeSessionNotifier(
              const AuthSessionState(isLoading: false, isAuthenticated: true),
            ),
          ),
        ],
      );

      final result = await container.read(_testNullableProvider.future);

      expect(result, isNull);

      container.dispose();
    });

    test('works with int return type', () async {
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(
            () => _FakeSessionNotifier(
              const AuthSessionState(isLoading: false, isAuthenticated: true),
            ),
          ),
        ],
      );

      final result = await container.read(_testIntProvider.future);

      expect(result, 42);

      container.dispose();
    });

    test('works with List return type', () async {
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(
            () => _FakeSessionNotifier(
              const AuthSessionState(isLoading: false, isAuthenticated: true),
            ),
          ),
        ],
      );

      final result = await container.read(_testListProvider.future);

      expect(result, ['a', 'b', 'c']);

      container.dispose();
    });
  });

  group('AuthRequiredException', () {
    test('toString returns class name', () {
      const exception = AuthRequiredException();
      expect(exception.toString(), 'AuthRequiredException');
    });

    test('is an Exception', () {
      const exception = AuthRequiredException();
      expect(exception, isA<Exception>());
    });
  });

  group('AuthSessionStateStatus extensions', () {
    test('isRestoring is true when loading and not authenticated', () {
      const state = AuthSessionState(isLoading: true, isAuthenticated: false);
      expect(state.isRestoring, isTrue);
    });

    test('isRestoring is false when loading and authenticated', () {
      const state = AuthSessionState(isLoading: true, isAuthenticated: true);
      expect(state.isRestoring, isFalse);
    });

    test('isRestoring is false when not loading', () {
      const state = AuthSessionState(isLoading: false, isAuthenticated: false);
      expect(state.isRestoring, isFalse);
    });

    test(
      'isConfirmedSignedOut is true when not loading and not authenticated',
      () {
        const state = AuthSessionState(
          isLoading: false,
          isAuthenticated: false,
        );
        expect(state.isConfirmedSignedOut, isTrue);
      },
    );

    test('isConfirmedSignedOut is false when loading', () {
      const state = AuthSessionState(isLoading: true, isAuthenticated: false);
      expect(state.isConfirmedSignedOut, isFalse);
    });

    test('isConfirmedSignedOut is false when authenticated', () {
      const state = AuthSessionState(isLoading: false, isAuthenticated: true);
      expect(state.isConfirmedSignedOut, isFalse);
    });

    test(
      'canAccessProtectedData is true when not loading and authenticated',
      () {
        const state = AuthSessionState(isLoading: false, isAuthenticated: true);
        expect(state.canAccessProtectedData, isTrue);
      },
    );

    test('canAccessProtectedData is false when loading', () {
      const state = AuthSessionState(isLoading: true, isAuthenticated: true);
      expect(state.canAccessProtectedData, isFalse);
    });

    test('canAccessProtectedData is false when not authenticated', () {
      const state = AuthSessionState(isLoading: false, isAuthenticated: false);
      expect(state.canAccessProtectedData, isFalse);
    });
  });
}

/// A simple session notifier that returns a fixed state.
class _FakeSessionNotifier extends AuthSessionNotifier {
  _FakeSessionNotifier(this._initialState);
  final AuthSessionState _initialState;

  @override
  AuthSessionState build() => _initialState;

  @override
  Future<void> restore() async {}

  @override
  Future<void> applySession(AuthSession session) async {}

  @override
  void applyUser(AuthUser user) {}

  @override
  void clearLocalSession() {}

  @override
  Future<void> logout() async {}
}

/// A session store whose reads always throw, standing in for an unavailable
/// platform channel.
class _ThrowingSessionStore implements LucentSessionStore {
  _ThrowingSessionStore(this.message);

  final String message;

  @override
  Future<String?> readRefreshToken() async => throw StateError(message);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Test providers that use authGuarded

final _testFetchProvider = FutureProvider<String>((ref) {
  return authGuarded(ref: ref, fetch: () async => 'success');
});

final _testNoFallbackProvider = FutureProvider<String>((ref) {
  return authGuarded(ref: ref, fetch: () async => 'should not reach');
});

final _testWithFallbackProvider = FutureProvider<String>((ref) {
  return authGuarded(
    ref: ref,
    fetch: () async => 'should not reach',
    signedOutFallback: () async => 'fallback',
  );
});

final _testErrorFetchProvider = FutureProvider<String>((ref) {
  return authGuarded(
    ref: ref,
    fetch: () async => throw Exception('Fetch failed'),
  );
});

final _testErrorFallbackProvider = FutureProvider<String>((ref) {
  return authGuarded(
    ref: ref,
    fetch: () async => 'should not reach',
    signedOutFallback: () async => throw Exception('Fallback failed'),
  );
});

final _testNullableProvider = FutureProvider<String?>((ref) {
  return authGuarded<String?>(ref: ref, fetch: () async => null);
});

final _testIntProvider = FutureProvider<int>((ref) {
  return authGuarded<int>(ref: ref, fetch: () async => 42);
});

final _testListProvider = FutureProvider<List<String>>((ref) {
  return authGuarded<List<String>>(
    ref: ref,
    fetch: () async => ['a', 'b', 'c'],
  );
});
