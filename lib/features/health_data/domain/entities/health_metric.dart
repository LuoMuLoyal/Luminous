import 'package:freezed_annotation/freezed_annotation.dart';

part 'health_metric.freezed.dart';

/// Unified health metric types that map to both `health` plugin data types
/// and the backend `DailyRecordKind` + payload schema.
enum HealthMetricType {
  steps,
  flightsClimbed,
  exerciseTime,
  heartRate,
  bloodPressure,
  bloodOxygen,
  bloodGlucose,
  bodyTemperature,
  weight,
  respiratoryRate,
  sleep,
  height,
  water,
}

@freezed
abstract class HealthMetric with _$HealthMetric {
  const factory HealthMetric({
    required HealthMetricType type,
    required double value,
    required String unit,
    required DateTime recordedAt,
    String? externalId,
    String? source,
    String? sourceId,
    String? sourcePlatform,
    DateTime? startAt,
    DateTime? endAt,
    String? sleepType,
    double? secondaryValue,
    String? secondaryUnit,
    // sleep-specific
    Duration? sleepDuration,
    String? sleepQuality,
    int? deepMinutes,
    int? lightMinutes,
    int? remMinutes,
  }) = _HealthMetric;
}
