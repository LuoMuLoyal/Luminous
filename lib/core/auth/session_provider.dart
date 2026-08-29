import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/auth/session_state.dart';
import 'package:luminous/core/database/cache_constants.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/network/api.dart';
import 'package:luminous/features/auth/data/providers/auth.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';

export 'package:luminous/core/auth/session_state.dart';

class AuthSessionNotifier extends Notifier<AuthSessionState> {
  @override
  AuthSessionState build() {
    // Wire the Dio client's session-expired callback so that any unrecoverable
    // 401 (token expired, unauthorized, missing refresh token, etc.) clears the
    // UI session without waiting for the next explicit restore().
    final client = ref.read(lucentDioClientProvider);
    client.onSessionExpired = () async {
      // Don't race with restore(): its catch block already sets the final
      // signed-out state. Only clear if restore() has finished.
      if (!state.isLoading) {
        state = const AuthSessionState();
      }
    };
    return const AuthSessionState(isLoading: true);
  }

  Future<void> restore() async {
    // If we're recovering from a timeout, mark as reconnecting so the UI
    // can distinguish "first cold start" from "retry after timeout".
    final wasTimeout = state.isTimeout;
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      isTimeout: false,
      isReconnecting: wasTimeout,
    );
    final store = ref.read(lucentSessionStoreProvider);
    final refreshToken = await store.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      state = const AuthSessionState();
      return;
    }

    // Race the restore against a floor timeout. If the network is too
    // slow or unreachable, degrade to a timeout state instead of hanging
    // the UI on an indefinite skeleton.
    final result = await Future.any([
      _doRestore(refreshToken, store),
      Future<AuthSessionState>.delayed(
        sessionRestoreTimeout,
        () => const AuthSessionState(
          isAuthenticated: false,
          isTimeout: true,
          errorMessage: 'Session restore timed out',
        ),
      ),
    ]);
    state = result;
  }

  Future<AuthSessionState> _doRestore(
    String refreshToken,
    LucentSessionStore store,
  ) async {
    // Attempt a quick restore with the current access token. If that fails
    // with an auth error (expired/invalid access token), fall back to the
    // refresh flow so cold starts don't force the user to log in again.
    final fetchResult = await ref
        .read(authRepositoryProvider)
        .fetchAccount()
        .run();
    switch (fetchResult) {
      case Right(:final value):
        return AuthSessionState(
          user: value,
          isLoading: false,
          isAuthenticated: true,
        );
      case Left(:final value):
        final isAuthError =
            value.statusCode == 401 ||
            value.statusCode == 403 ||
            value.isTokenExpired ||
            value.isRefreshTokenInvalid;
        if (!isAuthError) {
          // Network connectivity errors (timeout, connection refused, etc.)
          // must NOT clear the session store — the token may still be valid
          // and the user should be able to retry once connectivity is restored.
          if (value.isNetworkConnectivityError) {
            return AuthSessionState(
              isAuthenticated: false,
              errorMessage: value.message,
            );
          }
          await store.clear();
          return AuthSessionState(
            isAuthenticated: false,
            errorMessage: value.message,
          );
        }
      // Continue with refresh below.
    }

    final refreshResult = await ref
        .read(authRepositoryProvider)
        .refreshSession(refreshToken: refreshToken)
        .run();
    switch (refreshResult) {
      case Right(:final value):
        return AuthSessionState(
          user: value.user,
          isLoading: false,
          isAuthenticated: true,
        );
      case Left(:final value):
        ref
            .read(talkerProvider)
            .error('AuthSessionNotifier.restore: failed: $value');
        // Preserve the session store for network connectivity errors so the
        // user can retry restore() once the network recovers. Auth failures
        // (e.g. AUTH_REFRESH_TOKEN_INVALID) clear the unrecoverable session.
        if (!value.isNetworkConnectivityError) {
          await store.clear();
        }
        return AuthSessionState(
          isAuthenticated: false,
          errorMessage: value.message,
        );
    }
  }

  Future<void> applySession(AuthSession session) async {
    state = AuthSessionState(
      user: session.user,
      isLoading: false,
      isAuthenticated: true,
    );
  }

  void applyUser(AuthUser user) {
    state = state.copyWith(
      user: user,
      isAuthenticated: true,
      isLoading: false,
      errorMessage: null,
    );
  }

  void clearLocalSession() {
    state = const AuthSessionState();
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await ref.read(authRepositoryProvider).logout().run();
    switch (result) {
      case Right():
        // 远程注销成功才把 UI 置为登出；本地 session 由 repository 在
        // Right 路径清空。
        state = const AuthSessionState();
      case Left(:final value):
        // 远程注销失败：保留尚未确认的本地 session，仅投影失败信息到
        // action state，不把用户误登出。
        ref
            .read(talkerProvider)
            .error('AuthSessionNotifier.logout: failed: $value');
        state = state.copyWith(isLoading: false, errorMessage: value.message);
    }
  }
}

final authSessionProvider =
    NotifierProvider<AuthSessionNotifier, AuthSessionState>(
      AuthSessionNotifier.new,
    );
