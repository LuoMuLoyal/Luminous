import 'package:health/health.dart';
import 'package:luminous/features/health_data/domain/entities/health_metric.dart';
import 'package:luminous/features/record/domain/entities/record.dart';

/// Maps between native health plugin data types and Luminous domain models.
/// This file contains helper functions and data classes used by `HealthRecordMapper`.

/// Converts a native [HealthDataType] to a [HealthMetricType].
HealthMetricType? toMetricType(HealthDataType type) {
  return switch (type) {
    HealthDataType.HEART_RATE => HealthMetricType.heartRate,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC ||
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC => HealthMetricType.bloodPressure,
    HealthDataType.BLOOD_OXYGEN => HealthMetricType.bloodOxygen,
    HealthDataType.BLOOD_GLUCOSE => HealthMetricType.bloodGlucose,
    HealthDataType.BODY_TEMPERATURE => HealthMetricType.bodyTemperature,
    HealthDataType.WEIGHT => HealthMetricType.weight,
    HealthDataType.RESPIRATORY_RATE => HealthMetricType.respiratoryRate,
    HealthDataType.STEPS => HealthMetricType.steps,
    HealthDataType.FLIGHTS_CLIMBED => HealthMetricType.flightsClimbed,
    HealthDataType.EXERCISE_TIME => HealthMetricType.exerciseTime,
    HealthDataType.SLEEP_ASLEEP ||
    HealthDataType.SLEEP_DEEP ||
    HealthDataType.SLEEP_LIGHT ||
    HealthDataType.SLEEP_REM ||
    HealthDataType.SLEEP_AWAKE ||
    HealthDataType.SLEEP_IN_BED ||
    HealthDataType.SLEEP_SESSION ||
    HealthDataType.SLEEP_UNKNOWN ||
    HealthDataType.SLEEP_OUT_OF_BED => HealthMetricType.sleep,
    HealthDataType.HEIGHT => HealthMetricType.height,
    HealthDataType.WATER => HealthMetricType.water,
    _ => null,
  };
}

/// Extracts the numeric value from a [HealthDataPoint].
double? extractNumeric(HealthDataPoint point) {
  final value = point.value;
  return value is NumericHealthValue ? value.numericValue.toDouble() : null;
}

/// Converts a water volume to milliliters.
double? waterInMilliliters(double value, HealthDataUnit unit) {
  return switch (unit) {
    HealthDataUnit.MILLILITER => value,
    HealthDataUnit.LITER => value * 1000,
    HealthDataUnit.FLUID_OUNCE_US => value * 29.5735295625,
    HealthDataUnit.FLUID_OUNCE_IMPERIAL => value * 28.4130625,
    HealthDataUnit.CUP_US => value * 236.5882365,
    HealthDataUnit.CUP_IMPERIAL => value * 284.130625,
    HealthDataUnit.PINT_US => value * 473.176473,
    HealthDataUnit.PINT_IMPERIAL => value * 568.26125,
    _ => null,
  };
}

/// Returns the unit string for a given [HealthMetricType].
String unitForType(HealthMetricType type) {
  return switch (type) {
    HealthMetricType.heartRate => 'bpm',
    HealthMetricType.bloodPressure => 'mmHg',
    HealthMetricType.bloodOxygen => '%',
    HealthMetricType.bloodGlucose => 'mg/dL',
    HealthMetricType.bodyTemperature => '°C',
    HealthMetricType.weight => 'kg',
    HealthMetricType.respiratoryRate => 'rpm',
    HealthMetricType.steps => 'count',
    HealthMetricType.flightsClimbed => 'count',
    HealthMetricType.exerciseTime => 'min',
    HealthMetricType.sleep => 'min',
    HealthMetricType.height => 'cm',
    HealthMetricType.water => 'ml',
  };
}

/// Extracts the external ID from a [HealthDataPoint].
String? externalId(HealthDataPoint point) {
  return _pointExternalId(point);
}

/// Returns the [DailyRecordKind] for a given [HealthMetricType].
DailyRecordKind kindForMetric(HealthMetricType type) {
  return switch (type) {
    HealthMetricType.heartRate ||
    HealthMetricType.bloodPressure ||
    HealthMetricType.bloodOxygen ||
    HealthMetricType.bloodGlucose ||
    HealthMetricType.bodyTemperature ||
    HealthMetricType.weight ||
    HealthMetricType.respiratoryRate ||
    HealthMetricType.height => DailyRecordKind.vital,
    HealthMetricType.steps ||
    HealthMetricType.flightsClimbed ||
    HealthMetricType.exerciseTime => DailyRecordKind.activity,
    HealthMetricType.sleep => DailyRecordKind.sleep,
    HealthMetricType.water => DailyRecordKind.water,
  };
}

/// Formats a [DateTime] as a date string (YYYY-MM-DD).
String formatDate(DateTime dt) =>
    '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

/// Formats a [DateTime] as a time string (HH:MM).
String formatTime(DateTime dt) =>
    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

/// Returns the fields for a given [HealthMetric] as a record.
(String? title, String? value, String? unit, Map<String, dynamic>? payload)
fieldsForMetric(HealthMetric metric) {
  Map<String, dynamic> withExternalId(Map<String, dynamic> payload) {
    final externalId = metric.externalId;
    if (externalId != null && externalId.isNotEmpty) {
      payload['externalId'] = externalId;
    }
    return payload;
  }

  return switch (metric.type) {
    HealthMetricType.heartRate => (
      '心率',
      metric.value.toStringAsFixed(0),
      metric.unit,
      withExternalId({
        'vitalType': 'heartRate',
        'value': metric.value,
        'unit': metric.unit,
      }),
    ),
    HealthMetricType.bloodPressure => (
      '血压',
      metric.value.toStringAsFixed(0),
      metric.unit,
      withExternalId({
        'vitalType': 'bloodPressure',
        'value': metric.value,
        'unit': metric.unit,
        if (metric.secondaryValue != null)
          'secondaryValue': metric.secondaryValue,
        if (metric.secondaryUnit != null) 'secondaryUnit': metric.secondaryUnit,
      }),
    ),
    HealthMetricType.bloodOxygen => (
      '血氧',
      metric.value.toStringAsFixed(1),
      metric.unit,
      withExternalId({
        'vitalType': 'bloodOxygen',
        'value': metric.value,
        'unit': metric.unit,
      }),
    ),
    HealthMetricType.bloodGlucose => (
      '血糖',
      metric.value.toStringAsFixed(1),
      metric.unit,
      withExternalId({
        'vitalType': 'bloodGlucose',
        'value': metric.value,
        'unit': metric.unit,
      }),
    ),
    HealthMetricType.bodyTemperature => (
      '体温',
      metric.value.toStringAsFixed(1),
      metric.unit,
      withExternalId({
        'vitalType': 'bodyTemperature',
        'value': metric.value,
        'unit': metric.unit,
      }),
    ),
    HealthMetricType.weight => (
      '体重',
      metric.value.toStringAsFixed(1),
      metric.unit,
      withExternalId({
        'vitalType': 'weight',
        'value': metric.value,
        'unit': metric.unit,
      }),
    ),
    HealthMetricType.respiratoryRate => (
      '呼吸频率',
      metric.value.toStringAsFixed(0),
      metric.unit,
      withExternalId({
        'vitalType': 'respiratoryRate',
        'value': metric.value,
        'unit': metric.unit,
      }),
    ),
    HealthMetricType.steps => (
      '步数',
      metric.value.toStringAsFixed(0),
      metric.unit,
      withExternalId({
        'activityType': 'steps',
        'value': metric.value,
        'unit': metric.unit,
      }),
    ),
    HealthMetricType.flightsClimbed => (
      '爬楼',
      metric.value.toStringAsFixed(0),
      metric.unit,
      withExternalId({
        'activityType': 'flightsClimbed',
        'value': metric.value,
        'unit': metric.unit,
      }),
    ),
    HealthMetricType.exerciseTime => (
      '运动时间',
      metric.value.toStringAsFixed(0),
      metric.unit,
      withExternalId({
        'activityType': 'exerciseTime',
        'value': metric.value,
        'unit': metric.unit,
      }),
    ),
    HealthMetricType.sleep => (
      null,
      null,
      null,
      withExternalId({
        if (metric.sleepType != null) 'sleepType': metric.sleepType,
        if (metric.startAt != null)
          'startedAt': metric.startAt!.toUtc().toIso8601String(),
        if (metric.endAt != null)
          'endedAt': metric.endAt!.toUtc().toIso8601String(),
        'durationMinutes':
            metric.sleepDuration?.inMinutes ?? metric.value.round(),
        if (metric.deepMinutes != null) 'deepMinutes': metric.deepMinutes,
        if (metric.lightMinutes != null) 'lightMinutes': metric.lightMinutes,
        if (metric.remMinutes != null) 'remMinutes': metric.remMinutes,
        if (metric.sleepQuality != null) 'quality': metric.sleepQuality,
      }),
    ),
    HealthMetricType.height => (
      '身高',
      metric.value.toStringAsFixed(1),
      metric.unit,
      withExternalId({
        'vitalType': 'height',
        'value': metric.value,
        'unit': metric.unit,
      }),
    ),
    HealthMetricType.water => (
      '饮水量',
      metric.value.toStringAsFixed(
        metric.value == metric.value.round() ? 0 : 2,
      ),
      metric.unit,
      metric.externalId == null ? null : {'externalId': metric.externalId},
    ),
  };
}

/// Helper function to extract external ID from a [HealthDataPoint].
String? _pointExternalId(HealthDataPoint point) {
  final uuid = point.uuid.trim();
  if (uuid.isNotEmpty) return uuid;
  final sourceId = point.sourceId.trim();
  return sourceId.isEmpty ? null : sourceId;
}

/// Data class for blood pressure data points.
class BloodPressureDataPoint {
  BloodPressureDataPoint({
    required this.value,
    required this.recordedAt,
    required this.isSystolic,
    required this.externalId,
    required this.source,
    required this.sourceId,
    required this.sourcePlatform,
    required this.startAt,
    required this.endAt,
  });

  final double value;
  final DateTime recordedAt;
  final bool isSystolic;
  final String? externalId;
  final String? source;
  final String? sourceId;
  final String? sourcePlatform;
  final DateTime? startAt;
  final DateTime? endAt;
}

/// Aggregates sleep data points into a single [HealthMetric].
class SleepAggregator {
  SleepAggregator(HealthDataPoint first)
    : _start = first.dateFrom,
      _end = first.dateTo,
      _externalId = _pointExternalId(first),
      _source = first.sourcePlatform.name,
      _sourceId = first.sourceId,
      _sourcePlatform = first.sourcePlatform.name;

  DateTime? _start;
  DateTime? _end;
  int _totalMinutes = 0;
  int _deepMinutes = 0;
  int _lightMinutes = 0;
  int _remMinutes = 0;
  final String? _externalId;
  final String? _source;
  final String? _sourceId;
  final String? _sourcePlatform;

  /// Checks if the given time range overlaps with the current aggregator.
  bool overlaps(DateTime start, DateTime end) {
    final currentStart = _start;
    final currentEnd = _end;
    return currentStart != null &&
        currentEnd != null &&
        !start.isAfter(currentEnd) &&
        !end.isBefore(currentStart);
  }

  /// Adds a [HealthDataPoint] to the aggregator.
  void add(HealthDataPoint point) {
    final minutes = point.dateTo.difference(point.dateFrom).inMinutes;
    if (minutes <= 0) return;
    if (_start == null || point.dateFrom.isBefore(_start!)) {
      _start = point.dateFrom;
    }
    if (_end == null || point.dateTo.isAfter(_end!)) _end = point.dateTo;

    switch (point.type) {
      case HealthDataType.SLEEP_ASLEEP:
      case HealthDataType.SLEEP_IN_BED:
      case HealthDataType.SLEEP_SESSION:
      case HealthDataType.SLEEP_UNKNOWN:
      case HealthDataType.SLEEP_OUT_OF_BED:
        _totalMinutes += minutes;
      case HealthDataType.SLEEP_DEEP:
        _deepMinutes += minutes;
        _totalMinutes += minutes;
      case HealthDataType.SLEEP_LIGHT:
        _lightMinutes += minutes;
        _totalMinutes += minutes;
      case HealthDataType.SLEEP_REM:
        _remMinutes += minutes;
        _totalMinutes += minutes;
      case HealthDataType.SLEEP_AWAKE:
      case HealthDataType.SLEEP_AWAKE_IN_BED:
        break;
      default:
        break;
    }
  }

  /// Merges the aggregated data into a single [HealthMetric].
  HealthMetric? merge() {
    if (_totalMinutes <= 0 || _start == null || _end == null) return null;
    return HealthMetric(
      type: HealthMetricType.sleep,
      value: _totalMinutes.toDouble(),
      unit: 'min',
      recordedAt: _end!,
      externalId: _externalId,
      source: _source,
      sourceId: _sourceId,
      sourcePlatform: _sourcePlatform,
      startAt: _start,
      endAt: _end,
      sleepType: _end!.difference(_start!).inMinutes <= 180
          ? 'nap'
          : 'nightSleep',
      sleepDuration: Duration(minutes: _totalMinutes),
      deepMinutes: _deepMinutes == 0 ? null : _deepMinutes,
      lightMinutes: _lightMinutes == 0 ? null : _lightMinutes,
      remMinutes: _remMinutes == 0 ? null : _remMinutes,
    );
  }
}
