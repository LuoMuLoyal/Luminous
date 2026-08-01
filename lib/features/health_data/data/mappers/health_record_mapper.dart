import 'package:health/health.dart';
import 'package:luminous/features/health_data/domain/entities/health_metric.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';

/// Maps between native health plugin data types and Luminous domain models.
///
/// Responsibilities:
/// - `HealthDataPoint` → `HealthMetric` (with sleep merging + BP pairing)
/// - `HealthMetric` → `DailyRecordCreateInput` (with payload + source)
class HealthRecordMapper {
  const HealthRecordMapper();

  /// Convert a list of [HealthDataPoint]s to [HealthMetric]s.
  ///
  /// Non-sleep, non-BP data points map 1:1. Sleep data points
  /// (SLEEP_ASLEEP, SLEEP_DEEP, SLEEP_LIGHT, SLEEP_REM) from the same
  /// date are merged into a single [HealthMetric] with per-stage minute
  /// breakdowns. Blood pressure systolic/diastolic data points are
  /// paired by time proximity using their original [HealthDataType].
  List<HealthMetric> mapToMetrics(List<HealthDataPoint> points) {
    final nonSleep = <HealthMetric>[];
    final sleepByDate = <String, _SleepAggregator>{};
    final bpPoints = <_BloodPressureDataPoint>[];

    for (final point in points) {
      final type = _toMetricType(point.type);
      if (type == null) continue;

      if (type == HealthMetricType.sleep) {
        final dateKey = _dateKey(point.dateTo);
        sleepByDate.putIfAbsent(dateKey, _SleepAggregator.new);
        sleepByDate[dateKey]!.add(point);
      } else if (type == HealthMetricType.bloodPressure) {
        final value = _extractNumeric(point);
        if (value == null) continue;
        bpPoints.add(
          _BloodPressureDataPoint(
            value: value,
            recordedAt: point.dateTo,
            isSystolic: point.type == HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
          ),
        );
      } else {
        final value = _extractNumeric(point);
        if (value == null) continue;
        nonSleep.add(
          HealthMetric(
            type: type,
            value: value,
            unit: _unitForType(type),
            recordedAt: point.dateTo,
            secondaryValue: _extractSecondaryValue(type, point),
            secondaryUnit: _secondaryUnitForType(type),
          ),
        );
      }
    }

    // Pair blood pressure systolic/diastolic using original type info
    nonSleep.addAll(_pairBloodPressure(bpPoints));

    // Merge sleep aggregators into metrics
    for (final entry in sleepByDate.entries) {
      final merged = entry.value.merge();
      if (merged != null) nonSleep.add(merged);
    }

    return nonSleep;
  }

  /// Pair blood pressure systolic/diastolic data points.
  ///
  /// Uses the original [HealthDataType] to distinguish systolic from
  /// diastolic, preventing value swaps when both data points share the
  /// same timestamp. Each systolic is matched with the nearest unused
  /// diastolic within a 2-minute window.
  List<HealthMetric> _pairBloodPressure(List<_BloodPressureDataPoint> points) {
    if (points.isEmpty) return [];

    final systolics = points.where((p) => p.isSystolic).toList()
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    final diastolics = points.where((p) => !p.isSystolic).toList()
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    final usedDiastolic = List<bool>.filled(diastolics.length, false);
    final result = <HealthMetric>[];

    for (final sys in systolics) {
      // Find the nearest unused diastolic within 2 minutes
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

      if (bestIdx != null) {
        usedDiastolic[bestIdx] = true;
        result.add(
          HealthMetric(
            type: HealthMetricType.bloodPressure,
            value: sys.value,
            unit: 'mmHg',
            recordedAt: sys.recordedAt,
            secondaryValue: diastolics[bestIdx].value,
            secondaryUnit: 'mmHg',
          ),
        );
      } else {
        // No pair found — keep as single reading
        result.add(
          HealthMetric(
            type: HealthMetricType.bloodPressure,
            value: sys.value,
            unit: 'mmHg',
            recordedAt: sys.recordedAt,
          ),
        );
      }
    }

    // Add unpaired diastolics as single readings
    for (var i = 0; i < diastolics.length; i++) {
      if (!usedDiastolic[i]) {
        result.add(
          HealthMetric(
            type: HealthMetricType.bloodPressure,
            value: diastolics[i].value,
            unit: 'mmHg',
            recordedAt: diastolics[i].recordedAt,
          ),
        );
      }
    }

    return result;
  }

  /// Convert a [HealthMetric] to a [DailyRecordCreateInput].
  ///
  /// The [source] parameter sets the record source field
  /// (e.g. "apple_health" or "health_connect").
  DailyRecordCreateInput mapToCreateInput(
    HealthMetric metric, {
    required String source,
  }) {
    final kind = _kindForMetric(metric.type);
    final occurredAt = _formatDate(metric.recordedAt);
    final occurredTime = _formatTime(metric.recordedAt);

    final (title, value, unit, payload) = _fieldsForMetric(metric);

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

  // -- type mapping --

  HealthMetricType? _toMetricType(HealthDataType type) {
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

  // -- value extraction --

  double? _extractNumeric(HealthDataPoint point) {
    final value = point.value;
    if (value is NumericHealthValue) {
      return value.numericValue.toDouble();
    }
    return null;
  }

  double? _extractSecondaryValue(HealthMetricType type, HealthDataPoint point) {
    // Blood pressure secondary value (diastolic) is handled at the
    // repository level by pairing systolic/diastolic data points.
    // For individual data points, the secondary value is not extracted here.
    return null;
  }

  // -- unit mapping --

  String _unitForType(HealthMetricType type) {
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
      HealthMetricType.water => 'L',
    };
  }

  String? _secondaryUnitForType(HealthMetricType type) {
    return switch (type) {
      HealthMetricType.bloodPressure => 'mmHg',
      _ => null,
    };
  }

  // -- kind + payload mapping --

  DailyRecordKind _kindForMetric(HealthMetricType type) {
    return switch (type) {
      HealthMetricType.heartRate ||
      HealthMetricType.bloodPressure ||
      HealthMetricType.bloodOxygen ||
      HealthMetricType.bloodGlucose ||
      HealthMetricType.bodyTemperature ||
      HealthMetricType.weight ||
      HealthMetricType.respiratoryRate => DailyRecordKind.vital,
      HealthMetricType.steps ||
      HealthMetricType.flightsClimbed ||
      HealthMetricType.exerciseTime => DailyRecordKind.activity,
      HealthMetricType.sleep => DailyRecordKind.sleep,
      HealthMetricType.water => DailyRecordKind.water,
      HealthMetricType.height => DailyRecordKind.vital,
    };
  }

  (String? title, String? value, String? unit, Map<String, dynamic>? payload)
  _fieldsForMetric(HealthMetric metric) {
    return switch (metric.type) {
      HealthMetricType.heartRate => (
        '心率',
        metric.value.toStringAsFixed(0),
        metric.unit,
        {'vitalType': 'heartRate', 'value': metric.value, 'unit': metric.unit},
      ),
      HealthMetricType.bloodPressure => (
        '血压',
        metric.value.toStringAsFixed(0),
        metric.unit,
        {
          'vitalType': 'bloodPressure',
          'value': metric.value,
          'unit': metric.unit,
          if (metric.secondaryValue != null)
            'secondaryValue': metric.secondaryValue,
          if (metric.secondaryUnit != null)
            'secondaryUnit': metric.secondaryUnit,
        },
      ),
      HealthMetricType.bloodOxygen => (
        '血氧',
        metric.value.toStringAsFixed(1),
        metric.unit,
        {
          'vitalType': 'bloodOxygen',
          'value': metric.value,
          'unit': metric.unit,
        },
      ),
      HealthMetricType.bloodGlucose => (
        '血糖',
        metric.value.toStringAsFixed(1),
        metric.unit,
        {
          'vitalType': 'bloodGlucose',
          'value': metric.value,
          'unit': metric.unit,
        },
      ),
      HealthMetricType.bodyTemperature => (
        '体温',
        metric.value.toStringAsFixed(1),
        metric.unit,
        {
          'vitalType': 'bodyTemperature',
          'value': metric.value,
          'unit': metric.unit,
        },
      ),
      HealthMetricType.weight => (
        '体重',
        metric.value.toStringAsFixed(1),
        metric.unit,
        {'vitalType': 'weight', 'value': metric.value, 'unit': metric.unit},
      ),
      HealthMetricType.respiratoryRate => (
        '呼吸频率',
        metric.value.toStringAsFixed(0),
        metric.unit,
        {
          'vitalType': 'respiratoryRate',
          'value': metric.value,
          'unit': metric.unit,
        },
      ),
      HealthMetricType.steps => (
        '步数',
        metric.value.toStringAsFixed(0),
        metric.unit,
        {'activityType': 'steps', 'value': metric.value, 'unit': metric.unit},
      ),
      HealthMetricType.flightsClimbed => (
        '爬楼',
        metric.value.toStringAsFixed(0),
        metric.unit,
        {
          'activityType': 'flightsClimbed',
          'value': metric.value,
          'unit': metric.unit,
        },
      ),
      HealthMetricType.exerciseTime => (
        '运动时间',
        metric.value.toStringAsFixed(0),
        metric.unit,
        {
          'activityType': 'exerciseTime',
          'value': metric.value,
          'unit': metric.unit,
        },
      ),
      HealthMetricType.sleep => (
        null,
        null,
        null,
        {
          'durationMinutes': metric.sleepDuration?.inMinutes ?? 0,
          if (metric.deepMinutes != null) 'deepMinutes': metric.deepMinutes,
          if (metric.lightMinutes != null) 'lightMinutes': metric.lightMinutes,
          if (metric.remMinutes != null) 'remMinutes': metric.remMinutes,
          if (metric.sleepQuality != null) 'quality': metric.sleepQuality,
        },
      ),
      HealthMetricType.height => (
        '身高',
        metric.value.toStringAsFixed(1),
        metric.unit,
        {'vitalType': 'height', 'value': metric.value, 'unit': metric.unit},
      ),
      HealthMetricType.water => (
        '饮水量',
        metric.value.toStringAsFixed(2),
        metric.unit,
        null,
      ),
    };
  }

  // -- date/time formatting --

  String _formatDate(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}'
        '-${dt.month.toString().padLeft(2, '0')}'
        '-${dt.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}'
        ':${dt.minute.toString().padLeft(2, '0')}';
  }

  String _dateKey(DateTime dt) => _formatDate(dt);
}

/// Temporary holder for blood pressure data points during pairing.
///
/// Preserves the original [HealthDataType] distinction (systolic vs
/// diastolic) so the mapper can pair correctly even when both data
/// points share the same timestamp.
class _BloodPressureDataPoint {
  _BloodPressureDataPoint({
    required this.value,
    required this.recordedAt,
    required this.isSystolic,
  });

  final double value;
  final DateTime recordedAt;
  final bool isSystolic;
}

/// Aggregates sleep data points from the same date into a single [HealthMetric].
class _SleepAggregator {
  DateTime? _end;
  int? _totalMinutes;
  int? _deepMinutes;
  int? _lightMinutes;
  int? _remMinutes;
  DateTime? _start;

  void add(HealthDataPoint point) {
    final minutes = _extractMinutes(point);
    if (minutes == null) return;

    _end ??= point.dateTo;
    if (point.dateFrom.isBefore(_start ?? point.dateFrom)) {
      _start = point.dateFrom;
    }

    switch (point.type) {
      case HealthDataType.SLEEP_ASLEEP:
      case HealthDataType.SLEEP_IN_BED:
      case HealthDataType.SLEEP_SESSION:
      case HealthDataType.SLEEP_UNKNOWN:
      case HealthDataType.SLEEP_OUT_OF_BED:
        _totalMinutes = (_totalMinutes ?? 0) + minutes;
      case HealthDataType.SLEEP_DEEP:
        _deepMinutes = (_deepMinutes ?? 0) + minutes;
        _totalMinutes = (_totalMinutes ?? 0) + minutes;
      case HealthDataType.SLEEP_LIGHT:
        _lightMinutes = (_lightMinutes ?? 0) + minutes;
        _totalMinutes = (_totalMinutes ?? 0) + minutes;
      case HealthDataType.SLEEP_REM:
        _remMinutes = (_remMinutes ?? 0) + minutes;
        _totalMinutes = (_totalMinutes ?? 0) + minutes;
      case HealthDataType.SLEEP_AWAKE:
      case HealthDataType.SLEEP_AWAKE_IN_BED:
        // awake time is not counted in total sleep
        break;
      default:
        break;
    }
  }

  HealthMetric? merge() {
    final total = _totalMinutes;
    if (total == null || total <= 0) return null;

    return HealthMetric(
      type: HealthMetricType.sleep,
      value: total.toDouble(),
      unit: 'min',
      recordedAt: _end ?? DateTime.now(),
      sleepDuration: Duration(minutes: total),
      deepMinutes: _deepMinutes,
      lightMinutes: _lightMinutes,
      remMinutes: _remMinutes,
    );
  }

  int? _extractMinutes(HealthDataPoint point) {
    final value = point.value;
    if (value is NumericHealthValue) {
      return value.numericValue.toInt();
    }
    return null;
  }
}
