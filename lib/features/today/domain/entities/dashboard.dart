import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard.freezed.dart';

TodayDayMoment todayDayMomentFromHour(int hour) {
  if (hour < 12) return TodayDayMoment.morning;
  if (hour < 18) return TodayDayMoment.afternoon;
  return TodayDayMoment.evening;
}

enum TodayDayMoment { morning, afternoon, evening }

// Deferred by Product_Vision MVP: keep the lightweight mood vital type because
// future self-check-ins may use it, but do not surface it as a formal
// mental-health module in Today.
enum TodayVitalType { heartRate, bloodPressure, sleep, mood }

enum TodayMealSuggestionType { highProteinBalancedLunch }

enum TodayEnvironmentSignalType { pollen, uv }

enum TodayEnvironmentLevel { low, medium, high }

enum TodayLumiSuggestionType { pollenProtection }

enum TodayObservedMetricState { observed, unknown, degraded }

enum TodayObservedMetricCoverage { sufficient, partial, none }

enum TodayObservedMetricSource { manual, healthPlatform, reminderPlan, derived }

class TodayObservedMetric {
  const TodayObservedMetric({
    required this.value,
    required this.state,
    required this.coverage,
    required this.sources,
    required this.observedCount,
    required this.expectedCount,
    required this.windowStart,
    required this.windowEnd,
  });

  final double? value;
  final TodayObservedMetricState state;
  final TodayObservedMetricCoverage coverage;
  final List<TodayObservedMetricSource> sources;
  final int observedCount;
  final int? expectedCount;
  final String windowStart;
  final String windowEnd;
}

@freezed
abstract class TodayDashboard with _$TodayDashboard {
  const factory TodayDashboard({
    required TodayUserSnapshot user,
    required TodayWaterSummary water,
    required TodayMedicationSummary medication,
    required List<TodayVitalSummary> vitals,
    required TodayMealSuggestion mealSuggestion,
    // Deferred by Product_Vision MVP: keep environment signals because Lucent has
    // a useful reference-data contract, but do not surface it until a concrete
    // Today or Mine product job is ready.
    required TodayEnvironmentSummary environment,
    required TodayLumiSuggestion lumiSuggestion,
  }) = _TodayDashboard;

  /// Default daily water target used when no user preference is available.
  ///
  /// We use 0 instead of a made-up number like 8 so that empty / signed-out
  /// states show `0/0` rather than a fake goal.
  static const defaultWaterTargetCount = 0;

  /// A minimal dashboard for signed-out users with no real or mock data.
  ///
  /// The day moment is derived from the current device hour so the preview
  /// greeting matches the time of day instead of always showing "早上好".
  static TodayDashboard signedOut() => TodayDashboard(
    user: TodayUserSnapshot(
      moment: todayDayMomentFromHour(DateTime.now().hour),
      hasUnreadNotifications: false,
      updatedAtLabel: '--',
    ),
    water: const TodayWaterSummary(
      completedCount: 0,
      targetCount: defaultWaterTargetCount,
    ),
    medication: const TodayMedicationSummary(
      medicineCount: 0,
      pendingCount: 0,
      nextDoseTimeLabel: '--',
    ),
    vitals: <TodayVitalSummary>[],
    mealSuggestion: const TodayMealSuggestion(
      type: TodayMealSuggestionType.highProteinBalancedLunch,
    ),
    environment: const TodayEnvironmentSummary(
      signals: <TodayEnvironmentSignal>[],
    ),
    lumiSuggestion: const TodayLumiSuggestion(
      type: TodayLumiSuggestionType.pollenProtection,
    ),
  );
}

@freezed
abstract class TodayUserSnapshot with _$TodayUserSnapshot {
  const factory TodayUserSnapshot({
    required TodayDayMoment moment,
    required bool hasUnreadNotifications,
    required String updatedAtLabel,
  }) = _TodayUserSnapshot;
}

@freezed
abstract class TodayWaterSummary with _$TodayWaterSummary {
  const TodayWaterSummary._();

  const factory TodayWaterSummary({
    required int completedCount,
    required int targetCount,
    TodayObservedMetric? observedMetric,
  }) = _TodayWaterSummary;

  static const waterMlPerTargetCount = 250;

  int get targetMl => targetCount * waterMlPerTargetCount;

  double? get observedMl {
    final metric = observedMetric;
    if (metric?.state != TodayObservedMetricState.observed) return null;
    return metric?.value;
  }

  int get remainingCount {
    final remaining = targetCount - completedCount;
    return remaining < 0 ? 0 : remaining;
  }

  double get progress {
    if (observedMetric != null && observedMl == null) return 0.0;
    final ml = observedMl;
    if (ml != null) {
      if (targetMl <= 0) return 0.0;
      return (ml / targetMl).clamp(0, 1).toDouble();
    }
    if (targetCount <= 0) return 0.0;
    final ratio = completedCount / targetCount;
    return ratio.clamp(0, 1).toDouble();
  }
}

@freezed
abstract class TodayMedicationSummary with _$TodayMedicationSummary {
  const factory TodayMedicationSummary({
    required int medicineCount,
    required int pendingCount,
    required String nextDoseTimeLabel,
    String? nextMedicineName,
    TodayObservedMetric? observedMetric,
  }) = _TodayMedicationSummary;
}

@freezed
abstract class TodayVitalSummary with _$TodayVitalSummary {
  const factory TodayVitalSummary({
    required TodayVitalType type,
    required String valueLabel,
    TodayObservedMetric? observedMetric,
  }) = _TodayVitalSummary;
}

@freezed
abstract class TodayMealSuggestion with _$TodayMealSuggestion {
  const factory TodayMealSuggestion({required TodayMealSuggestionType type}) =
      _TodayMealSuggestion;
}

@freezed
abstract class TodayEnvironmentSummary with _$TodayEnvironmentSummary {
  const factory TodayEnvironmentSummary({
    required List<TodayEnvironmentSignal> signals,
  }) = _TodayEnvironmentSummary;
}

@freezed
abstract class TodayEnvironmentSignal with _$TodayEnvironmentSignal {
  const factory TodayEnvironmentSignal({
    required TodayEnvironmentSignalType type,
    required TodayEnvironmentLevel level,
  }) = _TodayEnvironmentSignal;
}

@freezed
abstract class TodayLumiSuggestion with _$TodayLumiSuggestion {
  const factory TodayLumiSuggestion({required TodayLumiSuggestionType type}) =
      _TodayLumiSuggestion;
}
