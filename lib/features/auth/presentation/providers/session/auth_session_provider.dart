import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/core/network/lucent_api.dart';
import 'package:luminous/features/auth/data/providers/auth_data_providers.dart';
import 'package:luminous/features/auth/domain/entities/auth_session.dart';

part 'auth_session_provider.freezed.dart';

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
    return const AuthSessionState(isLoading: true);
  }

  Future<void> restore() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final token = await ref.read(lucentDioClientProvider).readAccessToken();
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
      final apiError = LucentErrorMapper.fromObject(error);
      await ref.read(lucentDioClientProvider).clearSession();
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
