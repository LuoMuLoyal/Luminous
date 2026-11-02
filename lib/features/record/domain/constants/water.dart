/// Ml per water target count, mirroring Lucent
/// `WATER_TARGET_ML_PER_COUNT = 250`
/// (`Lucent/src/common/helpers/metrics/water-metric.ts`).
///
/// Shared by the record water progress card and Today Analysis so both use the
/// same `waterTargetCount * 250` conversion as the backend.
library;

/// Ml per water target count.
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
