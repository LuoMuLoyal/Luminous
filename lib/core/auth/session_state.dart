import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/core/auth/session_snapshot.dart';
import 'package:luminous/core/database/cache_constants.dart';

part 'session_state.freezed.dart';

@freezed
abstract class AuthSessionState with _$AuthSessionState {
  const factory AuthSessionState({
    /// Feature-owned account entity.
    ///
    /// Kept on the state so feature presentations keep reading the rich
    /// `AuthUser` they have always used; core only *stores* it and never names
    /// the type, so `core_not_import_features` stays clean. Core logic reads
    /// [userSnapshot] instead.
    Object? user,

    /// Feature-free projection of [user] (see [SessionUserSnapshot]).
    ///
    /// This is what `lib/core/**` reads: the account id (push alias sync), the
    /// display name, the avatar and the email-verified flag.
    SessionUserSnapshot? userSnapshot,

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

/// The signed-in account id, or `null` when signed out.
///
/// Convenience for core callers that only need the identity (push alias sync,
/// provider invalidation) without touching the heterogeneous
/// [AuthSessionState.user].
extension AuthSessionStateIdentity on AuthSessionState {
  String? get userId => userSnapshot?.id;
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
