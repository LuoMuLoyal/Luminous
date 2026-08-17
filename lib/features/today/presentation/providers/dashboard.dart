import 'package:luminous/core/providers/auth_guarded.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/today/data/providers/today_suggestion.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard.g.dart';

@Riverpod(keepAlive: true)
Future<TodayDashboard> todayDashboard(Ref ref) {
  // Watch cross-feature data change topics — when any of these change,
  // the provider automatically rebuilds.
  ref.watch(dataChangeVersionProvider(DataChangeTopic.dailyRecords));
  ref.watch(dataChangeVersionProvider(DataChangeTopic.currentMedicines));
  ref.watch(dataChangeVersionProvider(DataChangeTopic.doseLogs));
  ref.watch(dataChangeVersionProvider(DataChangeTopic.medicineReminders));
  ref.watch(dataChangeVersionProvider(DataChangeTopic.userSettings));

  // The repository catches every upstream failure and returns a degraded
  // dashboard instead of throwing, so the page never whitescreens because of
  // a single data-source outage.
  return authGuarded(
    ref: ref,
    fetch: () => ref.watch(todayRepositoryProvider).fetchDashboard(),
    signedOutFallback: () =>
        ref.watch(todayRepositoryProvider).signedOutDashboard,
  );
}
