import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/auth/session_provider.dart';

/// Auth-guard helper for use inside provider functions.
///
/// Encapsulates the auth session check pattern that was previously duplicated
/// across `mineDashboardProvider`, `reportDashboardProvider`,
/// `healthContextSnapshotProvider`, `todayDashboardProvider`, etc.
///
/// Behaviour:
/// - Session restoring → returns a never-completing [Future] (pending). The
///   caller's [AsyncValue] stays in `loading` without flashing an error.
/// - Confirmed signed out → calls [signedOutFallback] if provided; otherwise
///   throws [AuthRequiredException].
/// - Authenticated → calls [fetch] and returns its result.
///
/// This function is intentionally **not** `async` so that the
/// [AuthRequiredException] throw is synchronous when called from a
/// non-async `FutureProvider` callback. This preserves Riverpod's
/// synchronous error-state propagation.
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
}) {
  final session = ref.watch(authSessionProvider);
  if (session.isRestoring) {
    return pendingAuthSessionResolution<T>();
  }
  if (!session.canAccessProtectedData) {
    if (signedOutFallback != null) {
      return signedOutFallback();
    }
    throw const AuthRequiredException();
  }
  return fetch();
}
