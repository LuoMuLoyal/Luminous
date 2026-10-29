import 'package:luminous/core/network/app_log.dart';
import 'package:luminous/features/record/domain/constants/water.dart';
import 'package:luminous/features/settings/data/repositories/lucent.dart';
import 'package:luminous/features/settings/domain/repositories/user_settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'record_water_target.g.dart';

/// Composition-root glue for the record water target.
///
/// `record/data/` may not import `settings/data/`; the provider that reads the
/// user-settings repository is composed here and re-exported from the record
/// data provider file.

/// Daily water target (glasses) for the record detail water progress card,
/// read from `user-settings.waterTargetCount`.
///
/// Fallback: when the settings read fails or returns a non-positive count, the
/// provider returns [recordWaterDefaultTargetCount], keeping the target
/// strictly > 0 (guards against division by zero in the progress bar).
///
/// This is a deliberate best-effort degrade of a secondary display value
/// (documented product contract): the water progress card neither breaks nor
/// disappears when settings are temporarily unavailable, so the read failure
/// is only observed via [appLog], never surfaced as a Left.
@Riverpod(keepAlive: true)
Future<int> recordWaterTargetCount(Ref ref) async {
  final UserSettingsRepository repository = ref.watch(
    userSettingsRepositoryProvider,
  );
  try {
    final result = await repository.getSettings().run();
    final count = result.fold(
      (failure) {
        appLog.warning(
          'recordWaterTargetCountProvider: settings read failed, falling '
          'back to default target $recordWaterDefaultTargetCount: $failure',
        );
        return recordWaterDefaultTargetCount;
      },
      (settings) => settings.waterTargetCount > 0
          ? settings.waterTargetCount
          : recordWaterDefaultTargetCount,
    );
    return count;
  } catch (e, st) {
    appLog.warning(
      'recordWaterTargetCountProvider: settings read failed, falling back to '
      'default target $recordWaterDefaultTargetCount: $e',
      st,
    );
    return recordWaterDefaultTargetCount;
  }
}
