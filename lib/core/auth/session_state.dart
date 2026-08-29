import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/core/database/cache_constants.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';

part 'session_state.freezed.dart';

@freezed
abstract class AuthSessionState with _$AuthSessionState {
  const factory AuthSessionState({
    AuthUser? user,
    @Default(false) bool isLoading,
    @Default(false) bool isAuthenticated,
    String? errorMessage,

    /// True when session restore timed out and the user is in a
    /// "network may recover" state — the UI shows a retry banner
    /// ([ConnectivityBanner]) and allows manual re-trigger of
    /// [AuthSessionNotifier.restore].
    @Default(false) bool isTimeout,

    /// True while [AuthSessionNotifier.restore] is actively retrying
    /// after a timeout. Distinct from [isLoading] (which covers the
    /// initial cold-start restore) — [isReconnecting] specifically
    /// signals "recovering from a known timeout state".
    @Default(false) bool isReconnecting,
  }) = _AuthSessionState;
}

extension AuthSessionStateStatus on AuthSessionState {
  bool get isRestoring => isLoading && !isAuthenticated;

  bool get isConfirmedSignedOut => !isLoading && !isAuthenticated;

  bool get canAccessProtectedData => !isLoading && isAuthenticated;
}

/// Timeout duration for session restore. Declared here so that callers
/// can use the same constant without importing cache_constants directly.
const Duration kSessionRestoreTimeout = sessionRestoreTimeout;

class AuthRequiredException implements Exception {
  const AuthRequiredException();

  @override
  String toString() => 'AuthRequiredException';
}

Future<T> pendingAuthSessionResolution<T>() => Completer<T>().future;
