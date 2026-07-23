import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/providers/auth_guarded.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';

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

        // authGuarded throws synchronously; the provider should be in error state
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

    test('stays pending when session is restoring', () async {
      final container = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(
            () => _FakeSessionNotifier(
              const AuthSessionState(isLoading: true, isAuthenticated: false),
            ),
          ),
        ],
      );

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
