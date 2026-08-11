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
  HealthDataUnit unit = HealthDataUnit.COUNT,
  String sourceId = 'src-1',
}) {
  return HealthDataPoint(
    uuid: uuid ?? 'u-${type.name}-$value',
    value: NumericHealthValue(numericValue: value),
    type: type,
    unit: unit,
    dateFrom: dateFrom ?? DateTime(2026, 7, 12, 8, 0),
    dateTo: dateTo ?? DateTime(2026, 7, 12, 8, 0),
    sourcePlatform: HealthPlatformType.appleHealth,
    sourceDeviceId: 'dev-1',
    sourceId: sourceId,
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

    test('maps water to canonical milliliters', () {
      final metrics = mapper.mapToMetrics([
        _point(
          type: HealthDataType.WATER,
          value: 500,
          unit: HealthDataUnit.MILLILITER,
        ),
      ]);

      expect(metrics.single.type, HealthMetricType.water);
      expect(metrics.single.value, 500);
      expect(metrics.single.unit, 'ml');
    });

    test('preserves external identity, source, and interval', () {
      final from = DateTime(2026, 7, 12, 22);
      final to = DateTime(2026, 7, 13, 6);
      final metric = mapper.mapToMetrics([
        _point(
          type: HealthDataType.SLEEP_ASLEEP,
          dateFrom: from,
          dateTo: to,
          uuid: 'external-1',
        ),
      ]).single;

      expect(metric.externalId, 'external-1');
      expect(metric.sourceId, 'src-1');
      expect(metric.source, 'appleHealth');
      expect(metric.startAt, from);
      expect(metric.endAt, to);
    });

    test('uses sourceId as sleep external identity when uuid is absent', () {
      final metric = mapper.mapToMetrics([
        _point(
          type: HealthDataType.SLEEP_ASLEEP,
          uuid: '',
          sourceId: 'platform-record-1',
          dateFrom: DateTime(2026, 7, 12, 22),
          dateTo: DateTime(2026, 7, 13, 6),
        ),
      ]).single;

      expect(metric.externalId, 'platform-record-1');
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

  group('mapToMetrics — sleep episodes', () {
    test('keeps same-day sleep episodes separate', () {
      final metrics = mapper.mapToMetrics([
        _point(
          type: HealthDataType.SLEEP_ASLEEP,
          dateFrom: DateTime(2026, 7, 12, 22, 0),
          dateTo: DateTime(2026, 7, 13, 6, 0),
        ),
        _point(
          type: HealthDataType.SLEEP_ASLEEP,
          dateFrom: DateTime(2026, 7, 13, 13, 0),
          dateTo: DateTime(2026, 7, 13, 14, 0),
          uuid: 'nap-1',
        ),
      ]);

      expect(metrics, hasLength(2));
      expect(
        metrics.map((metric) => metric.startAt),
        containsAll([DateTime(2026, 7, 12, 22), DateTime(2026, 7, 13, 13)]),
      );
      expect(
        metrics.map((metric) => metric.endAt),
        containsAll([DateTime(2026, 7, 13, 6), DateTime(2026, 7, 13, 14)]),
      );
    });

    test('preserves sleep episode payload fields when creating records', () {
      final input = mapper.mapToCreateInput(
        HealthMetric(
          type: HealthMetricType.sleep,
          value: 60,
          unit: 'min',
          recordedAt: DateTime(2026, 7, 13, 14),
          source: 'health_connect',
          externalId: 'nap-1',
          startAt: DateTime(2026, 7, 13, 13),
          endAt: DateTime(2026, 7, 13, 14),
          sleepDuration: const Duration(minutes: 60),
          sleepType: 'nap',
          sleepQuality: 'good',
        ),
        source: 'health_connect',
      );

      expect(input.payload, {
        'sleepType': 'nap',
        'startedAt': '2026-07-13T05:00:00.000Z',
        'endedAt': '2026-07-13T06:00:00.000Z',
        'durationMinutes': 60,
        'quality': 'good',
        'externalId': 'nap-1',
      });
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

    test('maps canonical water ml', () {
      final input = mapper.mapToCreateInput(
        HealthMetric(
          type: HealthMetricType.water,
          value: 500,
          unit: 'ml',
          recordedAt: DateTime(2026, 7, 12, 8, 30),
        ),
        source: 'apple_health',
      );

      expect(input.kind, DailyRecordKind.water);
      expect(input.title, '饮水量');
      expect(input.value, '500');
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
