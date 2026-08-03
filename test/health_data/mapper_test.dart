import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:luminous/features/health_data/data/mappers/health_record_mapper.dart';
import 'package:luminous/features/health_data/domain/entities/health_metric.dart';
import 'package:luminous/features/record/domain/entities/record.dart';

HealthDataPoint _point({
  required HealthDataType type,
  double value = 0,
  DateTime? dateFrom,
  DateTime? dateTo,
  String? uuid,
}) {
  return HealthDataPoint(
    uuid: uuid ?? 'u-${type.name}-$value',
    value: NumericHealthValue(numericValue: value),
    type: type,
    unit: HealthDataUnit.COUNT,
    dateFrom: dateFrom ?? DateTime(2026, 7, 12, 8, 0),
    dateTo: dateTo ?? DateTime(2026, 7, 12, 8, 0),
    sourcePlatform: HealthPlatformType.appleHealth,
    sourceDeviceId: 'dev-1',
    sourceId: 'src-1',
    sourceName: 'source',
  );
}

void main() {
  const mapper = HealthRecordMapper();

  group('mapToMetrics — single data points', () {
    test('maps heart rate 1:1', () {
      final metrics = mapper.mapToMetrics([
        _point(type: HealthDataType.HEART_RATE, value: 72.0),
      ]);

      expect(metrics, hasLength(1));
      final m = metrics.first;
      expect(m.type, HealthMetricType.heartRate);
      expect(m.value, 72.0);
      expect(m.unit, 'bpm');
      expect(m.recordedAt, DateTime(2026, 7, 12, 8, 0));
    });

    test('maps steps with count unit', () {
      final metrics = mapper.mapToMetrics([
        _point(type: HealthDataType.STEPS, value: 5200),
      ]);

      expect(metrics.single.type, HealthMetricType.steps);
      expect(metrics.single.value, 5200);
      expect(metrics.single.unit, 'count');
    });

    test('maps water with liter unit', () {
      final metrics = mapper.mapToMetrics([
        _point(type: HealthDataType.WATER, value: 0.5),
      ]);

      expect(metrics.single.type, HealthMetricType.water);
      expect(metrics.single.value, 0.5);
      expect(metrics.single.unit, 'L');
    });

    test('skips unsupported data types', () {
      final metrics = mapper.mapToMetrics([
        _point(type: HealthDataType.MINDFULNESS, value: 10),
        _point(type: HealthDataType.HEART_RATE, value: 60),
      ]);

      expect(metrics, hasLength(1));
      expect(metrics.single.type, HealthMetricType.heartRate);
    });

    test('returns empty list for empty input', () {
      expect(mapper.mapToMetrics(const []), isEmpty);
    });
  });

  group('mapToMetrics — blood pressure pairing', () {
    test('pairs systolic and diastolic within 2 minutes', () {
      final metrics = mapper.mapToMetrics([
        _point(
          type: HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
          value: 120,
          dateTo: DateTime(2026, 7, 12, 8, 0),
        ),
        _point(
          type: HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
          value: 80,
          dateTo: DateTime(2026, 7, 12, 8, 1),
        ),
      ]);

      expect(metrics, hasLength(1));
      final bp = metrics.single;
      expect(bp.type, HealthMetricType.bloodPressure);
      expect(bp.value, 120);
      expect(bp.secondaryValue, 80);
      expect(bp.secondaryUnit, 'mmHg');
      expect(bp.unit, 'mmHg');
    });

    test('keeps unpaired systolic as a single reading', () {
      final metrics = mapper.mapToMetrics([
        _point(type: HealthDataType.BLOOD_PRESSURE_SYSTOLIC, value: 130),
      ]);

      expect(metrics, hasLength(1));
      expect(metrics.single.secondaryValue, isNull);
    });

    test('keeps unpaired diastolic as a single reading', () {
      final metrics = mapper.mapToMetrics([
        _point(type: HealthDataType.BLOOD_PRESSURE_DIASTOLIC, value: 85),
      ]);

      expect(metrics, hasLength(1));
      expect(metrics.single.value, 85);
      expect(metrics.single.secondaryValue, isNull);
    });

    test('does not pair readings farther than 2 minutes apart', () {
      final metrics = mapper.mapToMetrics([
        _point(
          type: HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
          value: 110,
          dateTo: DateTime(2026, 7, 12, 8, 0),
        ),
        _point(
          type: HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
          value: 70,
          dateTo: DateTime(2026, 7, 12, 8, 5),
        ),
      ]);

      expect(metrics, hasLength(2));
      expect(metrics[0].secondaryValue, isNull);
      expect(metrics[1].secondaryValue, isNull);
    });

    test('reuses each diastolic at most once', () {
      final metrics = mapper.mapToMetrics([
        _point(
          type: HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
          value: 120,
          dateTo: DateTime(2026, 7, 12, 8, 0),
        ),
        _point(
          type: HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
          value: 125,
          dateTo: DateTime(2026, 7, 12, 8, 1),
        ),
        _point(
          type: HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
          value: 80,
          dateTo: DateTime(2026, 7, 12, 8, 1),
        ),
      ]);

      expect(metrics, hasLength(2));
      final paired = metrics.where((m) => m.secondaryValue != null);
      expect(paired, hasLength(1));
      expect(paired.single.secondaryValue, 80);
    });
  });

  group('mapToMetrics — sleep merging', () {
    test('merges sleep stages from the same date into one metric', () {
      final metrics = mapper.mapToMetrics([
        _point(
          type: HealthDataType.SLEEP_ASLEEP,
          dateFrom: DateTime(2026, 7, 12, 22, 0),
          dateTo: DateTime(2026, 7, 13, 6, 0),
        ),
        _point(
          type: HealthDataType.SLEEP_DEEP,
          dateFrom: DateTime(2026, 7, 12, 23, 0),
          dateTo: DateTime(2026, 7, 13, 0, 0),
        ),
        _point(
          type: HealthDataType.SLEEP_LIGHT,
          dateFrom: DateTime(2026, 7, 13, 0, 0),
          dateTo: DateTime(2026, 7, 13, 3, 0),
        ),
        _point(
          type: HealthDataType.SLEEP_REM,
          dateFrom: DateTime(2026, 7, 13, 3, 0),
          dateTo: DateTime(2026, 7, 13, 4, 0),
        ),
        _point(
          type: HealthDataType.SLEEP_AWAKE,
          dateFrom: DateTime(2026, 7, 13, 4, 0),
          dateTo: DateTime(2026, 7, 13, 4, 10),
        ),
      ]);

      expect(metrics, hasLength(1));
      final sleep = metrics.single;
      expect(sleep.type, HealthMetricType.sleep);
      // 480 + 60 + 180 + 60 = 780; awake is not counted
      expect(sleep.value, 780);
      expect(sleep.unit, 'min');
      expect(sleep.sleepDuration, const Duration(minutes: 780));
      expect(sleep.deepMinutes, 60);
      expect(sleep.lightMinutes, 180);
      expect(sleep.remMinutes, 60);
      // recordedAt is the end of the first merged point
      expect(sleep.recordedAt, DateTime(2026, 7, 13, 6, 0));
    });

    test('drops sleep group when no countable stages', () {
      final metrics = mapper.mapToMetrics([
        _point(
          type: HealthDataType.SLEEP_AWAKE,
          dateFrom: DateTime(2026, 7, 12, 22, 0),
          dateTo: DateTime(2026, 7, 12, 22, 30),
        ),
      ]);

      expect(metrics, isEmpty);
    });
  });

  group('mapToCreateInput', () {
    test('maps heart rate to vital kind with payload', () {
      final input = mapper.mapToCreateInput(
        HealthMetric(
          type: HealthMetricType.heartRate,
          value: 72,
          unit: 'bpm',
          recordedAt: DateTime(2026, 7, 12, 8, 30),
        ),
        source: 'apple_health',
      );

      expect(input.kind, DailyRecordKind.vital);
      expect(input.occurredAt, '2026-07-12');
      expect(input.occurredTime, '08:30');
      expect(input.title, '心率');
      expect(input.value, '72');
      expect(input.unit, 'bpm');
      expect(input.source, 'apple_health');
      expect(input.payload, {
        'vitalType': 'heartRate',
        'value': 72.0,
        'unit': 'bpm',
      });
    });

    test('maps blood pressure with secondary value in payload', () {
      final input = mapper.mapToCreateInput(
        HealthMetric(
          type: HealthMetricType.bloodPressure,
          value: 120,
          unit: 'mmHg',
          recordedAt: DateTime(2026, 7, 12, 8, 30),
          secondaryValue: 80,
          secondaryUnit: 'mmHg',
        ),
        source: 'health_connect',
      );

      expect(input.kind, DailyRecordKind.vital);
      expect(input.payload, {
        'vitalType': 'bloodPressure',
        'value': 120.0,
        'unit': 'mmHg',
        'secondaryValue': 80.0,
        'secondaryUnit': 'mmHg',
      });
    });

    test('maps sleep to sleep kind with duration payload', () {
      final input = mapper.mapToCreateInput(
        HealthMetric(
          type: HealthMetricType.sleep,
          value: 480,
          unit: 'min',
          recordedAt: DateTime(2026, 7, 13, 6, 0),
          sleepDuration: const Duration(minutes: 480),
          deepMinutes: 60,
          remMinutes: 90,
        ),
        source: 'apple_health',
      );

      expect(input.kind, DailyRecordKind.sleep);
      expect(input.title, isNull);
      expect(input.value, isNull);
      expect(input.payload, {
        'durationMinutes': 480,
        'deepMinutes': 60,
        'remMinutes': 90,
      });
    });

    test('maps water with null payload', () {
      final input = mapper.mapToCreateInput(
        HealthMetric(
          type: HealthMetricType.water,
          value: 0.5,
          unit: 'L',
          recordedAt: DateTime(2026, 7, 12, 8, 30),
        ),
        source: 'apple_health',
      );

      expect(input.kind, DailyRecordKind.water);
      expect(input.title, '饮水量');
      expect(input.value, '0.50');
      expect(input.payload, isNull);
    });

    test('maps activity kinds', () {
      final steps = mapper.mapToCreateInput(
        HealthMetric(
          type: HealthMetricType.steps,
          value: 5200,
          unit: 'count',
          recordedAt: DateTime(2026, 7, 12, 8, 30),
        ),
        source: 'apple_health',
      );
      expect(steps.kind, DailyRecordKind.activity);
      expect(steps.payload, {
        'activityType': 'steps',
        'value': 5200.0,
        'unit': 'count',
      });

      final exercise = mapper.mapToCreateInput(
        HealthMetric(
          type: HealthMetricType.exerciseTime,
          value: 45,
          unit: 'min',
          recordedAt: DateTime(2026, 7, 12, 8, 30),
        ),
        source: 'apple_health',
      );
      expect(exercise.kind, DailyRecordKind.activity);
      expect(exercise.payload, {
        'activityType': 'exerciseTime',
        'value': 45.0,
        'unit': 'min',
      });
    });
  });
}
