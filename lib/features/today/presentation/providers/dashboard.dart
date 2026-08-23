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
  ref.watch(dataChangeVersionProvider(DataChangeTopic.healthEvents));

  // The repository degrades specific metrics on known upstream failures
  // (degraded dashboard is product behaviour); a Left here means an
  // unexpected error and is projected to AsyncValue.error.
  return authGuarded(
    ref: ref,
    fetch: () async {
      final result = await ref
          .watch(todayRepositoryProvider)
          .fetchDashboard()
          .run();
      return result.fold((failure) => throw failure, (dashboard) => dashboard);
    },
    signedOutFallback: () =>
        ref.watch(todayRepositoryProvider).signedOutDashboard,
  );
}
