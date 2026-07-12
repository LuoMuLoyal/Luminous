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
    try {
      final token = await ref
          .read(lucentSessionStoreProvider)
          .readAccessToken();
      if (token == null || token.isEmpty) {
        state = const AuthSessionState();
        return;
      }

      final user = await ref.read(authRemoteDataSourceProvider).fetchAccount();
      state = AuthSessionState(
        user: user,
        isLoading: false,
        isAuthenticated: true,
      );
    } catch (error) {
      ref
          .read(talkerProvider)
          .error('AuthSessionNotifier.restore: failed: $error');
      final apiError = LucentErrorMapper.fromObject(error);
      await ref.read(lucentSessionStoreProvider).clear();
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
      await ref.read(authRemoteDataSourceProvider).logout();
    } finally {
      state = const AuthSessionState();
    }
  }
}

final authSessionProvider =
    NotifierProvider<AuthSessionNotifier, AuthSessionState>(
      AuthSessionNotifier.new,
    );
