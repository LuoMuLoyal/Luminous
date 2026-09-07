import 'package:health/health.dart';
import 'package:luminous/features/health_data/data/mappers/health_record_mapping.dart';
import 'package:luminous/features/health_data/domain/entities/health_metric.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';

/// Maps between native health plugin data types and Luminous domain models.
class HealthRecordMapper {
  const HealthRecordMapper();

  List<HealthMetric> mapToMetrics(List<HealthDataPoint> points) {
    final metrics = <HealthMetric>[];
    final sleepEpisodes = <SleepAggregator>[];
    final bpPoints = <BloodPressureDataPoint>[];

    for (final point in points) {
      final type = toMetricType(point.type);
      if (type == null) continue;

      if (type == HealthMetricType.sleep) {
        final episode = sleepEpisodes.firstWhere(
          (candidate) => candidate.overlaps(point.dateFrom, point.dateTo),
          orElse: () {
            final created = SleepAggregator(point);
            sleepEpisodes.add(created);
            return created;
          },
        );
        episode.add(point);
        continue;
      }

      final value = extractNumeric(point);
      if (value == null) continue;

      if (type == HealthMetricType.bloodPressure) {
        bpPoints.add(
          BloodPressureDataPoint(
            value: value,
            recordedAt: point.dateTo,
            isSystolic: point.type == HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
            externalId: externalId(point),
            source: point.sourcePlatform.name,
            sourceId: point.sourceId,
            sourcePlatform: point.sourcePlatform.name,
            startAt: point.dateFrom,
            endAt: point.dateTo,
          ),
        );
        continue;
      }

      final canonicalValue = type == HealthMetricType.water
          ? waterInMilliliters(value, point.unit)
          : value;
      if (canonicalValue == null) continue;
      metrics.add(_metricFromPoint(point, type, canonicalValue));
    }

    metrics.addAll(_pairBloodPressure(bpPoints));
    metrics.addAll(
      sleepEpisodes.map((episode) => episode.merge()).whereType<HealthMetric>(),
    );
    return metrics;
  }

  HealthMetric _metricFromPoint(
    HealthDataPoint point,
    HealthMetricType type,
    double value,
  ) {
    return HealthMetric(
      type: type,
      value: value,
      unit: unitForType(type),
      recordedAt: point.dateTo,
      externalId: externalId(point),
      source: point.sourcePlatform.name,
      sourceId: point.sourceId,
      sourcePlatform: point.sourcePlatform.name,
      startAt: point.dateFrom,
      endAt: point.dateTo,
    );
  }

  List<HealthMetric> _pairBloodPressure(List<BloodPressureDataPoint> points) {
    if (points.isEmpty) return [];

    final systolics = points.where((p) => p.isSystolic).toList()
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    final diastolics = points.where((p) => !p.isSystolic).toList()
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    final usedDiastolic = List<bool>.filled(diastolics.length, false);
    final result = <HealthMetric>[];

    for (final sys in systolics) {
      int? bestIdx;
      int? bestDiff;
      for (var i = 0; i < diastolics.length; i++) {
        if (usedDiastolic[i]) continue;
        final dia = diastolics[i];
        final diff = dia.recordedAt.difference(sys.recordedAt).inMinutes.abs();
        if (diff <= 2 && (bestDiff == null || diff < bestDiff)) {
          bestIdx = i;
          bestDiff = diff;
        }
      }

      final secondary = bestIdx == null ? null : diastolics[bestIdx];
      if (bestIdx != null) usedDiastolic[bestIdx] = true;
      result.add(_bloodPressureMetric(sys, secondary));
    }

    for (var i = 0; i < diastolics.length; i++) {
      if (!usedDiastolic[i]) {
        result.add(_bloodPressureMetric(diastolics[i], null));
      }
    }
    return result;
  }

  HealthMetric _bloodPressureMetric(
    BloodPressureDataPoint primary,
    BloodPressureDataPoint? secondary,
  ) {
    return HealthMetric(
      type: HealthMetricType.bloodPressure,
      value: primary.value,
      unit: 'mmHg',
      recordedAt: primary.recordedAt,
      externalId: primary.externalId,
      source: primary.source,
      sourceId: primary.sourceId,
      sourcePlatform: primary.sourcePlatform,
      startAt: primary.startAt,
      endAt: primary.endAt,
      secondaryValue: secondary?.value,
      secondaryUnit: secondary == null ? null : 'mmHg',
    );
  }

  DailyRecordCreateInput mapToCreateInput(
    HealthMetric metric, {
    required String source,
  }) {
    final kind = kindForMetric(metric.type);
    final occurredAt = formatDate(metric.recordedAt);
    final occurredTime = formatTime(metric.recordedAt);
    final (title, value, unit, payload) = fieldsForMetric(metric);

    return DailyRecordCreateInput(
      kind: kind,
      occurredAt: occurredAt,
      occurredTime: occurredTime,
      title: title,
      value: value,
      unit: unit,
      source: source,
      payload: payload,
    );
  }
}
