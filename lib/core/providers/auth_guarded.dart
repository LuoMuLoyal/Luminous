import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/auth/presentation/providers/session/session_provider.dart';

/// Auth-guard helper for use inside `@riverpod` annotated provider functions.
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
/// Usage inside a `@riverpod` function:
/// ```dart
/// @riverpod
/// Future<MineDashboard> mineDashboard(Ref ref) {
///   return authGuarded(
///     ref: ref,
///     fetch: () => ref.watch(mineRepositoryProvider).fetchDashboard(),
///     signedOutFallback: () => ref.watch(mineRepositoryProvider).signedOutDashboard,
///   );
/// }
/// ```
Future<T> authGuarded<T>({
  required Ref ref,
  required Future<T> Function() fetch,
  Future<T> Function()? signedOutFallback,
}) async {
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
