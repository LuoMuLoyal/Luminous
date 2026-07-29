import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_cached.dart';
import 'package:luminous/features/medicine/data/providers/workspace.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/settings/data/repositories/lucent.dart';
import 'package:luminous/features/today/data/repositories/lucent.dart';
import 'package:luminous/features/today/domain/repositories/dashboard.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'today_suggestion.g.dart';

@riverpod
TodayRepository todayRepository(Ref ref) {
  return LucentTodayRepository(
    fetchHealthContextSnapshot: () =>
        ref.read(healthContextSnapshotProvider.future),
    dailyRecordRepository: ref.watch(dailyRecordRepositoryProvider),
    doseLogRepository: ref.watch(doseLogRepositoryProvider),
    userSettingsRepository: ref.watch(userSettingsRepositoryProvider),
    reminderRepository: ref.watch(reminderRepositoryProvider),
    talker: ref.watch(talkerProvider),
  );
}
