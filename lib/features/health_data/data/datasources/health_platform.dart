import 'dart:io' show Platform;

import 'package:health/health.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/features/health_data/domain/entities/health_metric.dart';
import 'package:luminous/features/health_data/domain/entities/health_permission.dart';

/// Wraps the `health` plugin API for reading health data from iOS HealthKit
/// and Android Health Connect.
///
/// This datasource only interacts with the native health plugin. All business
/// logic (mapping, dedup, sync) belongs in the repository.
class HealthPlatformDataSource {
  HealthPlatformDataSource({Health? health}) : _health = health ?? Health();

  final Health _health;
  bool _configured = false;

  /// Whether the native health platform is available.
  ///
  /// iOS: always true (HealthKit is built-in).
  /// Android: depends on Health Connect SDK status.
  /// Desktop/Web: always false.
  bool get isPlatformAvailable {
    if (!Platform.isIOS && !Platform.isAndroid) return false;
    if (Platform.isAndroid) {
      return _health.healthConnectSdkStatus ==
          HealthConnectSdkStatus.sdkAvailable;
    }
    return true;
  }

  /// Lazy-configure the health plugin on first use.
  Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  /// Map [HealthMetricType] to the `health` plugin's [HealthDataType]s.
  ///
  /// Some metric types (e.g. bloodPressure, sleep) map to multiple
  /// [HealthDataType]s that need to be fetched and merged.
  List<HealthDataType> _toHealthDataTypes(HealthMetricType type) {
    return switch (type) {
      HealthMetricType.heartRate => [HealthDataType.HEART_RATE],
      HealthMetricType.bloodPressure => [
        HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
        HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
      ],
      HealthMetricType.bloodOxygen => [HealthDataType.BLOOD_OXYGEN],
      HealthMetricType.bloodGlucose => [HealthDataType.BLOOD_GLUCOSE],
      HealthMetricType.bodyTemperature => [HealthDataType.BODY_TEMPERATURE],
      HealthMetricType.weight => [HealthDataType.WEIGHT],
      HealthMetricType.respiratoryRate => [HealthDataType.RESPIRATORY_RATE],
      HealthMetricType.steps => [HealthDataType.STEPS],
      HealthMetricType.flightsClimbed => [HealthDataType.FLIGHTS_CLIMBED],
      HealthMetricType.exerciseTime => [HealthDataType.EXERCISE_TIME],
      HealthMetricType.sleep => [
        HealthDataType.SLEEP_ASLEEP,
        HealthDataType.SLEEP_DEEP,
        HealthDataType.SLEEP_LIGHT,
        HealthDataType.SLEEP_REM,
      ],
      HealthMetricType.height => [HealthDataType.HEIGHT],
      HealthMetricType.water => [HealthDataType.WATER],
    };
  }

  /// Request read permissions for the given metric types.
  Future<HealthPermissionStatus> requestPermissions(
    Set<HealthMetricType> types,
  ) async {
    if (!isPlatformAvailable) return HealthPermissionStatus.notAvailable;

    await _ensureConfigured();

    final dataTypes = <HealthDataType>[];
    for (final type in types) {
      for (final dt in _toHealthDataTypes(type)) {
        if (_health.isDataTypeAvailable(dt)) {
          dataTypes.add(dt);
        }
      }
    }

    if (dataTypes.isEmpty) return HealthPermissionStatus.notAvailable;

    final permissions = dataTypes.map((_) => HealthDataAccess.READ).toList();

    try {
      final granted = await _health.requestAuthorization(
        dataTypes,
        permissions: permissions,
      );
      return granted
          ? HealthPermissionStatus.granted
          : HealthPermissionStatus.denied;
    } catch (e) {
      appTalker.error('HealthPlatform: requestAuthorization failed: $e');
      return HealthPermissionStatus.denied;
    }
  }

  /// Get currently authorized metric types.
  Future<Set<HealthMetricType>> getAuthorizedTypes(
    Set<HealthMetricType> types,
  ) async {
    if (!isPlatformAvailable) return {};

    await _ensureConfigured();

    final authorized = <HealthMetricType>{};
    for (final type in types) {
      final dataTypes = _toHealthDataTypes(type);
      final permissions = dataTypes.map((_) => HealthDataAccess.READ).toList();

      try {
        final hasPermission = await _health.hasPermissions(
          dataTypes,
          permissions: permissions,
        );
        if (hasPermission == true) {
          authorized.add(type);
        }
      } catch (e) {
        appTalker.error('HealthPlatform: hasPermissions failed for $type: $e');
        // skip types that fail permission check
      }
    }

    return authorized;
  }

  /// Fetch raw health data points from the native platform.
  Future<List<HealthDataPoint>> fetchDataPoints({
    required Set<HealthMetricType> types,
    required DateTime start,
    required DateTime end,
  }) async {
    if (!isPlatformAvailable) return [];

    await _ensureConfigured();

    final dataTypes = <HealthDataType>[];
    for (final type in types) {
      for (final dt in _toHealthDataTypes(type)) {
        if (_health.isDataTypeAvailable(dt)) {
          dataTypes.add(dt);
        }
      }
    }

    if (dataTypes.isEmpty) return [];

    try {
      final points = await _health.getHealthDataFromTypes(
        startTime: start,
        endTime: end,
        types: dataTypes,
      );
      return _health.removeDuplicates(points);
    } catch (e) {
      appTalker.error('HealthPlatform: getHealthDataFromTypes failed: $e');
      return [];
    }
  }

  /// Efficiently fetch total step count for an interval.
  Future<int?> getTotalSteps({
    required DateTime start,
    required DateTime end,
  }) async {
    if (!isPlatformAvailable) return null;

    await _ensureConfigured();

    try {
      return await _health.getTotalStepsInInterval(start, end);
    } catch (e) {
      appTalker.error('HealthPlatform: getTotalStepsInInterval failed: $e');
      return null;
    }
  }
}
