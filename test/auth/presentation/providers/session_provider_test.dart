import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/network/dio_client.dart';
import 'package:luminous/core/network/network_providers.dart';
import 'package:luminous/core/network/session_store.dart';
import 'package:luminous/features/auth/data/providers/auth.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';

import '../../test_helpers.dart';

void main() {
  late _SessionTestRemoteDataSource remote;
  late _MemorySessionStore sessionStore;
  late _CallbackCapturingDioClient dioClient;
  late ProviderContainer container;

  setUp(() {
    remote = _SessionTestRemoteDataSource();
    sessionStore = _MemorySessionStore();
    dioClient = _CallbackCapturingDioClient(
      baseUrl: 'http://localhost',
      sessionStore: sessionStore,
    );
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(remote),
        lucentSessionStoreProvider.overrideWithValue(sessionStore),
        lucentDioClientProvider.overrideWithValue(dioClient),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(dioClient.dispose);
  });

  group('AuthSessionState extensions', () {
    test('isRestoring is true when loading and not authenticated', () {
      const state = AuthSessionState(isLoading: true, isAuthenticated: false);
      expect(state.isRestoring, isTrue);
    });

    test('isRestoring is false when not loading', () {
      const state = AuthSessionState(isLoading: false, isAuthenticated: false);
      expect(state.isRestoring, isFalse);
    });

    test('isRestoring is false when authenticated', () {
      const state = AuthSessionState(isLoading: true, isAuthenticated: true);
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

  group('AuthRequiredException', () {
    test('toString returns class name', () {
      expect(const AuthRequiredException().toString(), 'AuthRequiredException');
    });
  });

  group('AuthSessionNotifier — initial build', () {
    test('starts with isLoading=true and isAuthenticated=false', () {
      final state = container.read(authSessionProvider);
      expect(state.isLoading, isTrue);
      expect(state.isAuthenticated, isFalse);
    });
  });

  group('AuthSessionNotifier — restore', () {
    test('sets signed-out state when no token is stored', () async {
      await container.read(authSessionProvider.notifier).restore();

      final state = container.read(authSessionProvider);
      expect(state.isLoading, isFalse);
      expect(state.isAuthenticated, isFalse);
      expect(state.user, isNull);
      expect(state.errorMessage, isNull);
    });

    test(
      'sets authenticated state when token is valid and fetchAccount succeeds',
      () async {
        sessionStore.tokens = const LucentSessionTokens(
          accessToken: 'valid-token',
          refreshToken: 'refresh-token',
        );

        await container.read(authSessionProvider.notifier).restore();

        final state = container.read(authSessionProvider);
        expect(state.isLoading, isFalse);
        expect(state.isAuthenticated, isTrue);
        expect(state.user, isNotNull);
        expect(state.user!.email, 'fetchAccount@example.com');
      },
    );

    test(
      'refreshes session when fetchAccount fails with an auth error and refresh succeeds',
      () async {
        sessionStore.tokens = const LucentSessionTokens(
          accessToken: 'expired-token',
          refreshToken: 'refresh-token',
        );
        remote.fetchAccountShouldFail = true;

        await container.read(authSessionProvider.notifier).restore();

        final state = container.read(authSessionProvider);
        expect(state.isLoading, isFalse);
        expect(state.isAuthenticated, isTrue);
        expect(state.user, isNotNull);
        expect(remote.refreshSessionCalled, isTrue);
      },
    );

    test(
      'clears session when fetchAccount fails with an auth error but refresh also fails',
      () async {
        sessionStore.tokens = const LucentSessionTokens(
          accessToken: 'expired-token',
          refreshToken: 'refresh-token',
        );
        remote.fetchAccountShouldFail = true;
        remote.refreshSessionShouldFail = true;

        await container.read(authSessionProvider.notifier).restore();

        final state = container.read(authSessionProvider);
        expect(state.isLoading, isFalse);
        expect(state.isAuthenticated, isFalse);
        expect(state.user, isNull);
        expect(state.errorMessage, isNotNull);
        expect(sessionStore.tokens, isNull);
      },
    );

    test(
      'clears session and sets errorMessage when fetchAccount fails with a non-auth error',
      () async {
        sessionStore.tokens = const LucentSessionTokens(
          accessToken: 'valid-token',
          refreshToken: 'refresh-token',
        );
        remote.fetchAccountShouldFail = true;
        remote.fetchAccountFailureIsAuth = false;

        await container.read(authSessionProvider.notifier).restore();

        final state = container.read(authSessionProvider);
        expect(state.isLoading, isFalse);
        expect(state.isAuthenticated, isFalse);
        expect(state.user, isNull);
        expect(state.errorMessage, isNotNull);
        // Session store should be cleared
        expect(sessionStore.tokens, isNull);
      },
    );

    test(
      'preserves session store when fetchAccount fails with a network error',
      () async {
        sessionStore.tokens = const LucentSessionTokens(
          accessToken: 'valid-token',
          refreshToken: 'refresh-token',
        );
        remote.fetchAccountShouldFail = true;
        remote.fetchAccountFailureIsNetworkError = true;

        await container.read(authSessionProvider.notifier).restore();

        final state = container.read(authSessionProvider);
        expect(state.isLoading, isFalse);
        expect(state.isAuthenticated, isFalse);
        expect(state.user, isNull);
        expect(state.errorMessage, isNotNull);
        // Session store should be preserved for network errors
        expect(sessionStore.tokens, isNotNull);
      },
    );

    test(
      'refreshes session when access token is empty but refresh token is present',
      () async {
        sessionStore.tokens = const LucentSessionTokens(
          accessToken: '',
          refreshToken: 'refresh-token',
        );
        remote.fetchAccountShouldFail = true;

        await container.read(authSessionProvider.notifier).restore();

        final state = container.read(authSessionProvider);
        expect(state.isAuthenticated, isTrue);
        expect(state.isLoading, isFalse);
        expect(remote.refreshSessionCalled, isTrue);
      },
    );
  });

  group('AuthSessionNotifier — applySession', () {
    test('sets authenticated state with user from session', () async {
      final session = testSession(
        email: 'applied@example.com',
        nickname: 'App',
      );
      await container.read(authSessionProvider.notifier).applySession(session);

      final state = container.read(authSessionProvider);
      expect(state.isAuthenticated, isTrue);
      expect(state.isLoading, isFalse);
      expect(state.user!.email, 'applied@example.com');
      expect(state.user!.nickname, 'App');
    });
  });

  group('AuthSessionNotifier — applyUser', () {
    test('updates user and sets authenticated', () {
      final user = AuthUser(
        id: 'u2',
        email: 'updated@example.com',
        nickname: 'Updated',
        avatar: null,
        emailVerifiedAt: DateTime.parse('2026-01-01T00:00:00Z'),
        createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2026-01-02T00:00:00Z'),
      );

      container.read(authSessionProvider.notifier).applyUser(user);

      final state = container.read(authSessionProvider);
      expect(state.isAuthenticated, isTrue);
      expect(state.isLoading, isFalse);
      expect(state.user!.email, 'updated@example.com');
      expect(state.errorMessage, isNull);
    });
  });

  group('AuthSessionNotifier — clearLocalSession', () {
    test('resets to default signed-out state', () {
      // First set authenticated
      final session = testSession(email: 'clear@example.com');
      container.read(authSessionProvider.notifier).applySession(session);
      expect(container.read(authSessionProvider).isAuthenticated, isTrue);

      // Then clear
      container.read(authSessionProvider.notifier).clearLocalSession();

      final state = container.read(authSessionProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.isLoading, isFalse);
      expect(state.user, isNull);
      expect(state.errorMessage, isNull);
    });
  });

  group('AuthSessionNotifier — logout', () {
    test('calls remote logout and resets to default state', () async {
      // First set authenticated
      final session = testSession(email: 'logout@example.com');
      await container.read(authSessionProvider.notifier).applySession(session);
      expect(container.read(authSessionProvider).isAuthenticated, isTrue);

      // Logout
      await container.read(authSessionProvider.notifier).logout();

      expect(remote.logoutCalled, isTrue);
      final state = container.read(authSessionProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.isLoading, isFalse);
      expect(state.user, isNull);
    });

    test('resets state even when remote logout throws', () async {
      remote.logoutShouldFail = true;
      // First set authenticated
      final session = testSession(email: 'logout@example.com');
      await container.read(authSessionProvider.notifier).applySession(session);

      // Logout should still reset state (exception propagates via finally)
      await expectLater(
        container.read(authSessionProvider.notifier).logout(),
        throwsA(isA<DioException>()),
      );

      final state = container.read(authSessionProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.isLoading, isFalse);
      expect(state.user, isNull);
    });
  });

  group('AuthSessionNotifier — onSessionExpired callback', () {
    test('clears session when not loading', () async {
      // First set authenticated
      final session = testSession(email: 'expire@example.com');
      await container.read(authSessionProvider.notifier).applySession(session);
      expect(container.read(authSessionProvider).isAuthenticated, isTrue);

      // Simulate session expired via the captured callback
      expect(dioClient.capturedOnSessionExpired, isNotNull);
      await dioClient.capturedOnSessionExpired!();

      final state = container.read(authSessionProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.isLoading, isFalse);
    });

    test(
      'does not clear session while loading (restore in progress)',
      () async {
        // The initial state has isLoading=true
        expect(container.read(authSessionProvider).isLoading, isTrue);

        // Simulate session expired during restore
        expect(dioClient.capturedOnSessionExpired, isNotNull);
        await dioClient.capturedOnSessionExpired!();

        // State should not be changed (still loading)
        expect(container.read(authSessionProvider).isLoading, isTrue);
      },
    );
  });
}

/// Fake with fetchAccount + logout + refreshSession overrides for session provider tests.
class _SessionTestRemoteDataSource extends FakeLucentAuthRepository {
  bool logoutCalled = false;
  bool logoutShouldFail = false;
  bool fetchAccountShouldFail = false;
  bool fetchAccountFailureIsAuth = true;
  bool fetchAccountFailureIsNetworkError = false;
  bool refreshSessionShouldFail = false;
  bool refreshSessionCalled = false;

  @override
  Future<AuthUser> fetchAccount() async {
    if (fetchAccountShouldFail) {
      if (fetchAccountFailureIsNetworkError) {
        throw DioException(
          requestOptions: RequestOptions(path: '/account'),
          type: DioExceptionType.connectionTimeout,
        );
      }
      throw DioException(
        requestOptions: RequestOptions(path: '/account'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/account'),
          statusCode: fetchAccountFailureIsAuth ? 401 : 500,
          data: {
            'code': fetchAccountFailureIsAuth ? 401001 : 500,
            'message': 'token已过期',
            'data': null,
          },
        ),
      );
    }
    return AuthUser(
      id: 'user-1',
      email: 'fetchAccount@example.com',
      nickname: 'Fetched',
      avatar: null,
      emailVerifiedAt: DateTime.parse('2026-01-01T00:00:00Z'),
      createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
      updatedAt: DateTime.parse('2026-01-02T00:00:00Z'),
    );
  }

  @override
  Future<AuthSession> refreshSession({required String refreshToken}) async {
    refreshSessionCalled = true;
    if (refreshSessionShouldFail) {
      throw DioException(
        requestOptions: RequestOptions(path: '/auth/refresh'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/auth/refresh'),
          statusCode: 401,
          data: {
            'code': 401003,
            'message': 'refresh token invalid',
            'data': null,
          },
        ),
      );
    }
    return AuthSession(
      user: AuthUser(
        id: 'user-1',
        email: 'refreshed@example.com',
        nickname: 'Refreshed',
        avatar: null,
        emailVerifiedAt: DateTime.parse('2026-01-01T00:00:00Z'),
        createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2026-01-02T00:00:00Z'),
      ),
      accessToken: 'new-access-token',
      refreshToken: 'new-refresh-token',
      expiresInSeconds: 3600,
    );
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
    if (logoutShouldFail) {
      throw DioException(
        requestOptions: RequestOptions(path: '/logout'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/logout'),
          statusCode: 500,
          data: {'code': 500, 'message': '服务器错误', 'data': null},
        ),
      );
    }
  }
}

/// Subclass of [LucentDioClient] that captures the [onSessionExpired]
/// callback so tests can invoke it directly.
class _CallbackCapturingDioClient extends LucentDioClient {
  _CallbackCapturingDioClient({
    required super.baseUrl,
    required super.sessionStore,
  });

  Future<void> Function()? capturedOnSessionExpired;

  @override
  set onSessionExpired(Future<void> Function()? callback) {
    capturedOnSessionExpired = callback;
    super.onSessionExpired = callback;
  }
}

class _MemorySessionStore implements LucentSessionStore {
  LucentSessionTokens? tokens;

  @override
  Future<void> clear() async {
    tokens = null;
  }

  @override
  Future<LucentSessionTokens?> read() async => tokens;

  @override
  Future<String?> readAccessToken() async => tokens?.accessToken;

  @override
  Future<String?> readRefreshToken() async => tokens?.refreshToken;

  @override
  Future<void> write(LucentSessionTokens tokens) async {
    this.tokens = tokens;
  }
}
