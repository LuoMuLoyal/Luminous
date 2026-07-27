import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/network/api.dart';
import 'package:luminous/features/auth/data/providers/auth.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';

part 'session.freezed.dart';

@freezed
abstract class AuthSessionState with _$AuthSessionState {
  const factory AuthSessionState({
    AuthUser? user,
    @Default(false) bool isLoading,
    @Default(false) bool isAuthenticated,
    String? errorMessage,
  }) = _AuthSessionState;
}

extension AuthSessionStateStatus on AuthSessionState {
  bool get isRestoring => isLoading && !isAuthenticated;

  bool get isConfirmedSignedOut => !isLoading && !isAuthenticated;

  bool get canAccessProtectedData => !isLoading && isAuthenticated;
}

class AuthRequiredException implements Exception {
  const AuthRequiredException();

  @override
  String toString() => 'AuthRequiredException';
}

Future<T> pendingAuthSessionResolution<T>() => Completer<T>().future;

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
    state = state.copyWith(isLoading: true, errorMessage: null);
    final store = ref.read(lucentSessionStoreProvider);
    try {
      final refreshToken = await store.readRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        state = const AuthSessionState();
        return;
      }

      // Attempt a quick restore with the current access token. If that fails
      // with an auth error (expired/invalid access token), fall back to the
      // refresh flow so cold starts don't force the user to log in again.
      try {
        final user = await ref.read(authRepositoryProvider).fetchAccount();
        state = AuthSessionState(
          user: user,
          isLoading: false,
          isAuthenticated: true,
        );
        return;
      } catch (error) {
        final apiError = LucentErrorMapper.fromObject(error);
        final isAuthError =
            apiError.statusCode == 401 ||
            apiError.statusCode == 403 ||
            apiError.isTokenExpired ||
            apiError.isRefreshTokenInvalid;
        if (!isAuthError) {
          // Network connectivity errors (timeout, connection refused, etc.)
          // must NOT clear the session store — the token may still be valid
          // and the user should be able to retry once connectivity is restored.
          if (apiError.isNetworkConnectivityError) {
            state = AuthSessionState(
              isAuthenticated: false,
              errorMessage: apiError.message,
            );
            return;
          }
          await store.clear();
          state = AuthSessionState(
            isAuthenticated: false,
            errorMessage: apiError.message,
          );
          return;
        }
        // Continue with refresh below.
      }

      final session = await ref
          .read(authRepositoryProvider)
          .refreshSession(refreshToken: refreshToken);
      state = AuthSessionState(
        user: session.user,
        isLoading: false,
        isAuthenticated: true,
      );
    } catch (error) {
      ref
          .read(talkerProvider)
          .error('AuthSessionNotifier.restore: failed: $error');
      final apiError = LucentErrorMapper.fromObject(error);
      // Preserve the session store for network connectivity errors so the
      // user can retry restore() once the network recovers.
      if (!apiError.isNetworkConnectivityError) {
        await store.clear();
      }
      state = AuthSessionState(
        isAuthenticated: false,
        errorMessage: apiError.message,
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
    try {
      await ref.read(authRepositoryProvider).logout();
    } finally {
      state = const AuthSessionState();
    }
  }
}

final authSessionProvider =
    NotifierProvider<AuthSessionNotifier, AuthSessionState>(
      AuthSessionNotifier.new,
    );
