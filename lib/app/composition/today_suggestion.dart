import 'package:luminous/app/composition/health_context/health_context.dart';
import 'package:luminous/app/composition/medicine/workspace.dart'
    show reminderRepositoryProvider;
import 'package:luminous/app/composition/record/record_access.dart';
import 'package:luminous/core/network/app_log.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_cached.dart'
    show doseLogRepositoryProvider;
import 'package:luminous/features/notification/data/repositories/lucent.dart'
    show notificationRepositoryProvider;
import 'package:luminous/features/settings/data/repositories/lucent.dart'
    show userSettingsRepositoryProvider;
import 'package:luminous/features/today/data/repositories/lucent.dart';
import 'package:luminous/features/today/domain/repositories/dashboard.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'today_suggestion.g.dart';

/// Composition-root glue for the today dashboard repository.
///
/// `today/data/` may not import another feature's `data/` layer, so the
/// aggregation is wired here — every dependency below is a provider that
/// exposes a domain repository interface. The data provider file re-exports
/// [todayRepositoryProvider].
@riverpod
TodayRepository todayRepository(Ref ref) {
  return LucentTodayRepository(
    fetchHealthContextSnapshot: () =>
        ref.read(healthContextSnapshotProvider.future),
    dailyRecordRepository: ref.watch(dailyRecordRepositoryProvider),
    doseLogRepository: ref.watch(doseLogRepositoryProvider),
    userSettingsRepository: ref.watch(userSettingsRepositoryProvider),
    reminderRepository: ref.watch(reminderRepositoryProvider),
    notificationRepository: ref.watch(notificationRepositoryProvider),
    talker: appLog,
  );
}
