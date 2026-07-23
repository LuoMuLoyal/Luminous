import 'dart:async';

import 'package:luminous/core/providers/auth_guarded.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/today/data/providers/today_suggestion.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard.g.dart';

/// Configurable timeout for the dashboard fetch.
///
/// Defaults to 8 seconds. Override at compile time via:
///   `flutter run --dart-define=DASHBOARD_TIMEOUT_SECONDS=10`
const _todayDashboardTimeout = Duration(
  seconds: int.fromEnvironment('DASHBOARD_TIMEOUT_SECONDS', defaultValue: 8),
);

@Riverpod(keepAlive: true)
Future<TodayDashboard> todayDashboard(Ref ref) {
  // Watch cross-feature data change topics — when any of these change,
  // the provider automatically rebuilds.
  ref.watch(dataChangeVersionProvider(DataChangeTopic.dailyRecords));
  ref.watch(dataChangeVersionProvider(DataChangeTopic.currentMedicines));
  ref.watch(dataChangeVersionProvider(DataChangeTopic.doseLogs));
  ref.watch(dataChangeVersionProvider(DataChangeTopic.medicineReminders));
  ref.watch(dataChangeVersionProvider(DataChangeTopic.userSettings));

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
}
