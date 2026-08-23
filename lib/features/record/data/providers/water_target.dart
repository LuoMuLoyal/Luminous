import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/features/settings/data/repositories/lucent.dart';
import 'package:luminous/features/settings/domain/repositories/user_settings.dart';

/// Ml per water target count, mirroring Lucent `WATER_TARGET_ML_PER_COUNT = 250`
/// (`Lucent/src/common/helpers/metrics/water-metric.ts`). Same-source
/// conversion as Today Analysis (`waterTargetCount * 250` ml) and the Today
/// water summary (`TodayWaterSummary.waterMlPerTargetCount`).
const recordWaterMlPerCount = 250;

/// Default daily water target (glasses) used when user-settings are not yet
/// available or fail to load.
///
/// Mirrors Lucent `USER_SETTINGS_DEFAULTS.waterTargetCount = 8`
/// (`Lucent/src/modules/user-settings/constants/settings.constants.ts`), i.e.
/// 8 × 250 ml = 2000 ml — the same value the detail card previously hardcoded —
/// so the water progress card neither breaks nor disappears when settings are
/// temporarily unavailable.
const recordWaterDefaultTargetCount = 8;

/// Daily water target (glasses) for the record detail water progress card,
/// read from `user-settings.waterTargetCount`.
///
/// Consumption path follows the cross-feature import rules: the record data
/// layer reads through the settings **domain** interface
/// ([UserSettingsRepository]), wired via [userSettingsRepositoryProvider] —
/// the same pattern as the today feature's data layer
/// (`lib/features/today/data/providers/today_suggestion.dart`). The record
/// presentation layer never imports another feature's presentation providers.
/// The ml target is derived as `count × [recordWaterMlPerCount]`, matching
/// Today Analysis's same-source conversion.
///
/// Fallback: when the settings read fails or returns a non-positive count, the
/// provider returns [recordWaterDefaultTargetCount], keeping the target
/// strictly > 0 (guards against division by zero in the progress bar).
///
/// This is a deliberate best-effort degrade of a secondary display value
/// (documented product contract): the water progress card neither breaks nor
/// disappears when settings are temporarily unavailable, so the read failure
/// is only observed via [appTalker], never surfaced as a Left.
final recordWaterTargetCountProvider = FutureProvider.autoDispose<int>((
  ref,
) async {
  final repository = ref.watch(userSettingsRepositoryProvider);
  try {
    final count = (await repository.getSettings()).waterTargetCount;
    return count > 0 ? count : recordWaterDefaultTargetCount;
  } catch (e, st) {
    appTalker.warning(
      'recordWaterTargetCountProvider: settings read failed, falling back to '
      'default target $recordWaterDefaultTargetCount: $e',
      st,
    );
    return recordWaterDefaultTargetCount;
  }
});
