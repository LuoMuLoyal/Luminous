import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/network/client/client_providers.dart';

/// Auth-guard helper for use inside provider functions.
///
/// Encapsulates the auth session check pattern that was previously duplicated
/// across `mineDashboardProvider`, `reviewDashboardProvider`,
/// `healthContextSnapshotProvider`, `todayDashboardProvider`, etc.
///
/// Behaviour:
/// - Session restoring **with a stored session** → calls [fetch] to attempt
///   cache-first data retrieval. Cache-first repositories return cached data
///   immediately, so the UI shows local data instead of a skeleton while
///   session restore proceeds in the background. A cache-miss during restore
///   resolves through the normal fetch path (network) and degrades via the
///   caller's timeout/error handling.
/// - Session restoring **without a stored session** (fresh install) → returns
///   a never-completing future (same as the old blocking behaviour). The
///   restore resolves to signed-out almost instantly since there is no token
///   to refresh, so this path is only reached for one or two frames. Without
///   this gate, a fresh install would fire unauthenticated API requests that
///   401 and create noisy interceptor work.
/// - Session restore timed out → calls [signedOutFallback] if provided;
///   otherwise throws [AuthRequiredException].
/// - Confirmed signed out → calls [signedOutFallback] if provided; otherwise
///   throws [AuthRequiredException].
/// - Authenticated → calls [fetch] and returns its result.
///
/// Usage inside a provider:
/// ```dart
/// final mineDashboardProvider = FutureProvider<MineDashboard>((ref) {
///   return authGuarded(
///     ref: ref,
///     fetch: () async {
///       final result = await ref
///           .watch(mineRepositoryProvider)
///           .fetchDashboard()
///           .run();
///       return result.fold((failure) => throw failure, (dashboard) => dashboard);
///     },
///     signedOutFallback: () =>
///         ref.watch(mineRepositoryProvider).signedOutDashboard,
///   );
/// });
/// ```
Future<T> authGuarded<T>({
  required Ref ref,
  required Future<T> Function() fetch,
  Future<T> Function()? signedOutFallback,
}) async {
  final session = ref.watch(authSessionProvider);
  if (session.isRestoring) {
    // Offline-first: during cold-start session restore we attempt the
    // (cache-first) fetch so repositories can return local data immediately —
    // but only when a stored session actually exists. A fresh install has no
    // tokens, so `restore()` resolves to signed-out almost instantly (< 100 ms);
    // firing fetches here would only produce 401s and noisy interceptor work.
    final hasToken = await _hasStoredSession(ref);
    if (hasToken) {
      // Previous behaviour returned `pendingAuthSessionResolution<T>()` here,
      // keeping every tab in skeleton until restore finished — defeating the
      // purpose of the local cache (ADR-0006). Now we attempt the fetch so
      // cache-first repositories return cached data immediately.
      return fetch();
    }
    // No stored session — fall back to the blocking future. The restore will
    // resolve to signed-out within a frame or two.
    return pendingAuthSessionResolution<T>();
  }
  if (!session.canAccessProtectedData) {
    // Session restore timed out — degrade to fallback/error just like a
    // confirmed sign-out, but callers can check `session.isTimeout` to
    // show a "network slow" message instead of a login prompt.
    if (signedOutFallback != null) {
      return signedOutFallback();
    }
    throw const AuthRequiredException();
  }
  return fetch();
}

/// Whether a session is stored on this device (a refresh token exists).
///
/// A store read failure (e.g. platform channel unavailable in tests) is
/// treated as "no stored session" — the caller falls back to the old
/// blocking behaviour rather than firing unauthenticated requests.
Future<bool> _hasStoredSession(Ref ref) async {
  try {
    final store = ref.read(lucentSessionStoreProvider);
    return await store.readRefreshToken() != null;
  } catch (_) {
    return false;
  }
}
