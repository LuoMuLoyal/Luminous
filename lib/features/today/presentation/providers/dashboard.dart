import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/providers/auth_guarded.dart';
import 'package:luminous/features/today/data/providers/repository.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';

/// Configurable timeout for the dashboard fetch.
///
/// Defaults to 5 seconds. Override at compile time via:
///   `flutter run --dart-define=DASHBOARD_TIMEOUT_SECONDS=10`
const _todayDashboardTimeout = Duration(
  seconds: int.fromEnvironment('DASHBOARD_TIMEOUT_SECONDS', defaultValue: 5),
);

final todayDashboardProvider = FutureProvider<TodayDashboard>((ref) {
  return authGuarded(
    ref: ref,
    fetch: () => ref
        .watch(todayRepositoryProvider)
        .fetchDashboard()
        .timeout(
          _todayDashboardTimeout,
          onTimeout: () => throw TimeoutException('today_dashboard_timeout'),
        ),
    signedOutFallback: () =>
        ref.watch(todayRepositoryProvider).signedOutDashboard,
  );
});
