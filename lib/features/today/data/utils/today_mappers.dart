import 'package:luminous/features/medicine/domain/entities/reminder.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';

/// Creates a [TodayObservedMetric] from raw values.
///
/// When [observed] is true and [value] is non-null, the metric is marked as
/// observed with sufficient coverage. Otherwise it is marked as unknown with
/// no coverage.
TodayObservedMetric observedMetric({
  required double? value,
  required bool observed,
  required int observedCount,
  required String date,
}) {
  final hasValue = observed && value != null;
  return TodayObservedMetric(
    value: hasValue ? value : null,
    state: hasValue
        ? TodayObservedMetricState.observed
        : TodayObservedMetricState.unknown,
    coverage: hasValue
        ? TodayObservedMetricCoverage.sufficient
        : TodayObservedMetricCoverage.none,
    sources: hasValue ? const [TodayObservedMetricSource.manual] : const [],
    observedCount: hasValue ? observedCount : 0,
    expectedCount: null,
    windowStart: date,
    windowEnd: date,
  );
}

/// Creates a degraded [TodayObservedMetric] for the given [date].
///
/// Used when the upstream data source is temporarily unavailable.
TodayObservedMetric degradedObservedMetric(String date) {
  return TodayObservedMetric(
    value: null,
    state: TodayObservedMetricState.degraded,
    coverage: TodayObservedMetricCoverage.none,
    sources: const [],
    observedCount: 0,
    expectedCount: null,
    windowStart: date,
    windowEnd: date,
  );
}

/// Formats a sleep duration from a payload map into a human-readable label.
///
/// Returns `'--'` if the payload is null or missing valid duration data.
String formatSleepLabel(Map<String, dynamic>? payload) {
  if (payload == null) return '--';
  final durationMinutes = payload['durationMinutes'];
  if (durationMinutes is! num || durationMinutes <= 0) return '--';
  final hours = (durationMinutes / 60).toStringAsFixed(1);
  return '${hours}h';
}

/// Extracts sleep hours from a payload map.
///
/// Returns `null` if the payload is null or missing valid duration data.
double? sleepHours(Map<String, dynamic>? payload) {
  final durationMinutes = payload?['durationMinutes'];
  if (durationMinutes is! num || durationMinutes <= 0) return null;
  return durationMinutes.toDouble() / 60;
}

/// Creates an unknown [TodayObservedMetric] for the given [date].
TodayObservedMetric unknownObservedMetric(String date) {
  return TodayObservedMetric(
    value: null,
    state: TodayObservedMetricState.unknown,
    coverage: TodayObservedMetricCoverage.none,
    sources: const [],
    observedCount: 0,
    expectedCount: null,
    windowStart: date,
    windowEnd: date,
  );
}

/// Creates a [TodayObservedMetric] for water intake from daily records.
///
/// Aggregates total ml from records with 'ml' unit and positive parseable values.
TodayObservedMetric waterObservedMetric(
  List<DailyRecordItem> records, {
  required num total,
  required String date,
}) {
  var totalMl = 0.0;
  var observedCount = 0;
  var unobservableCount = 0;

  for (final record in records) {
    final value = double.tryParse(record.value ?? '');
    if (record.unit?.trim().toLowerCase() == 'ml' &&
        value != null &&
        value.isFinite &&
        value >= 0) {
      totalMl += value;
      observedCount += 1;
    } else {
      unobservableCount += 1;
    }
  }

  final truncated = total > records.length;
  final coverage = observedCount == 0
      ? TodayObservedMetricCoverage.none
      : unobservableCount > 0 || truncated
      ? TodayObservedMetricCoverage.partial
      : TodayObservedMetricCoverage.sufficient;

  return TodayObservedMetric(
    value: observedCount == 0 ? null : totalMl,
    state: observedCount == 0
        ? TodayObservedMetricState.unknown
        : TodayObservedMetricState.observed,
    coverage: coverage,
    sources: observedCount == 0
        ? const []
        : const [TodayObservedMetricSource.manual],
    observedCount: observedCount,
    expectedCount: null,
    windowStart: date,
    windowEnd: date,
  );
}

/// Formats a [DateTime] into a time label (HH:mm).
String formatTimeLabel(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

/// Compares two [MedicineReminderItem]s by scheduled time.
///
/// Returns negative if [left] is earlier, positive if later, 0 if equal.
int compareReminderTime(MedicineReminderItem left, MedicineReminderItem right) {
  final hour = left.scheduledHour.compareTo(right.scheduledHour);
  if (hour != 0) return hour;
  return left.scheduledMinute.compareTo(right.scheduledMinute);
}

/// Immutable holder for the latest heart-rate and blood-pressure readouts.
///
/// Created from the day's `vital` daily records so that the Today vitals row
/// reads real observed values instead of static placeholders.
final class VitalReadout {
  const VitalReadout({
    this.heartRateMetric,
    this.bloodPressureMetric,
    this.heartRateLabel = '--',
    this.bloodPressureLabel = '--',
  });

  factory VitalReadout.degraded({required String date}) {
    return VitalReadout(
      heartRateMetric: degradedObservedMetric(date),
      bloodPressureMetric: degradedObservedMetric(date),
    );
  }

  factory VitalReadout.fromRecords(
    List<DailyRecordItem> records, {
    required String date,
  }) {
    if (records.isEmpty) {
      return const VitalReadout();
    }

    final sorted = List<DailyRecordItem>.from(records)
      ..sort((a, b) {
        final ta = a.occurredTime ?? a.occurredAt;
        final tb = b.occurredTime ?? b.occurredAt;
        return tb.compareTo(ta);
      });

    TodayObservedMetric? heartRateMetric;
    TodayObservedMetric? bloodPressureMetric;
    var heartRateLabel = '--';
    var bloodPressureLabel = '--';

    for (final record in sorted) {
      final payload = record.payload;
      final vitalType = payload?['vitalType'] as String?;
      final value = double.tryParse(record.value ?? '');
      final unit = record.unit?.trim();

      if (vitalType == 'heartRate' && heartRateMetric == null) {
        final observed = value != null;
        heartRateMetric = observedMetric(
          value: value,
          observed: observed,
          observedCount: observed ? 1 : 0,
          date: date,
        );
        heartRateLabel = observed
            ? '${value.round()} ${unit ?? ''}'.trim()
            : '--';
      }

      if (vitalType == 'bloodPressure' && bloodPressureMetric == null) {
        final secondaryValue = payload?['secondaryValue'];
        final observed = value != null && secondaryValue is num;
        bloodPressureMetric = observedMetric(
          value: value,
          observed: observed,
          observedCount: observed ? 1 : 0,
          date: date,
        );
        bloodPressureLabel = observed
            ? '${value.round()}/${secondaryValue.round()} ${unit ?? ''}'.trim()
            : '--';
      }

      if (heartRateMetric != null && bloodPressureMetric != null) {
        break;
      }
    }

    return VitalReadout(
      heartRateMetric: heartRateMetric,
      bloodPressureMetric: bloodPressureMetric,
      heartRateLabel: heartRateLabel,
      bloodPressureLabel: bloodPressureLabel,
    );
  }

  final TodayObservedMetric? heartRateMetric;
  final TodayObservedMetric? bloodPressureMetric;
  final String heartRateLabel;
  final String bloodPressureLabel;
}
