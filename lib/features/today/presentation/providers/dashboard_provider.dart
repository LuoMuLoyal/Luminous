import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/auth/presentation/providers/session/session_provider.dart';
import 'package:luminous/features/today/data/repositories/mock_repository.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';

/// Configurable timeout for the dashboard fetch.
///
/// Defaults to 5 seconds. Override at compile time via:
///   `flutter run --dart-define=DASHBOARD_TIMEOUT_SECONDS=10`
const _todayDashboardTimeout = Duration(
  seconds: int.fromEnvironment('DASHBOARD_TIMEOUT_SECONDS', defaultValue: 5),
);

final todayDashboardProvider = FutureProvider<TodayDashboard>((ref) {
  final session = ref.watch(authSessionProvider);
  if (session.isConfirmedSignedOut) {
    return ref.watch(todayRepositoryProvider).signedOutDashboard;
  }
  if (!session.canAccessProtectedData) {
    return pendingAuthSessionResolution();
  }

  return ref
      .watch(todayRepositoryProvider)
      .fetchDashboard()
      .timeout(
        _todayDashboardTimeout,
        onTimeout: () => throw TimeoutException('today_dashboard_timeout'),
      );
});
