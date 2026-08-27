import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/error_mapper.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/medicine/domain/entities/dose_log.dart';
import 'package:luminous/features/medicine/domain/entities/reminder.dart';
import 'package:luminous/features/medicine/domain/repositories/dose_log.dart';
import 'package:luminous/features/medicine/domain/repositories/reminder.dart';
import 'package:luminous/features/notification/domain/repositories/notification.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/repositories/daily.dart';
import 'package:luminous/features/settings/domain/repositories/user_settings.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:luminous/features/today/domain/repositories/dashboard.dart';
import 'package:talker_flutter/talker_flutter.dart';

TodayObservedMetric _observedMetric({
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

TodayObservedMetric _degradedObservedMetric(String date) {
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

/// Lucent-backed [TodayRepository] that merges real health-context and
/// daily-record signals with static mock sections for unsupported surfaces.
class LucentTodayRepository implements TodayRepository {
  LucentTodayRepository({
    required this.fetchHealthContextSnapshot,
    required this.dailyRecordRepository,
    required this.doseLogRepository,
    required this.userSettingsRepository,
    required this.reminderRepository,
    required this.notificationRepository,
    required this.talker,
  });

  /// Lazily fetches the current health-context snapshot.
  ///
  /// Passed as a callback so each [fetchDashboard] call reads the latest
  /// pending future, preserving the original behaviour where the snapshot
  /// is resolved at call time (not construction time).
  final Future<HealthContextSnapshot> Function() fetchHealthContextSnapshot;
  final DailyRecordRepository dailyRecordRepository;
  final DoseLogRepository doseLogRepository;
  final UserSettingsRepository userSettingsRepository;
  final ReminderRepository reminderRepository;
  final NotificationRepository notificationRepository;
  final Talker talker;

  @override
  TaskEither<LucentFailure, TodayDashboard> fetchDashboard() {
    return TaskEither.tryCatch(
      _buildDashboard,
      (error, stackTrace) => LucentErrorMapper.fromObject(error),
    );
  }

  /// Builds the merged dashboard.
  ///
  /// Known upstream failures are caught inside and degrade the affected
  /// metrics (degraded dashboard is the product behaviour); only unexpected
  /// errors escape and become a Left at the repository boundary.
  Future<TodayDashboard> _buildDashboard() async {
    final today = clock.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    HealthContextSnapshot snapshot;
    try {
      snapshot = await fetchHealthContextSnapshot();
    } catch (e) {
      talker.warning(
        'LucentTodayRepository: health context snapshot failed: $e',
      );
      final hasUnreadNotifications = await _unreadNotificationsFlag();
      return _degradedDashboard(
        today,
        dateStr,
        hasUnreadNotifications: hasUnreadNotifications,
      );
    }

    final medicines = snapshot.currentMedicines
        .where((medicine) => medicine.isCurrent)
        .toList(growable: false);

    // Resolve the user's preferred water target; fall back to the default if
    // settings are temporarily unavailable so the overview still renders.
    final waterTargetCount = await _waterTargetCount();

    // Fetch daily record summary for today
    final Map<String, num> recordCounts = {};
    final Map<String, String?> recordLatest = {};
    final Map<String, Map<String, dynamic>?> recordPayloads = {};
    var waterMetric = _unknownObservedMetric(dateStr);
    Map<String, dynamic>? sleepPayload;
    var summaryFailed = false;
    final summaryResult = await dailyRecordRepository
        .fetchSummary(dateStr)
        .run();
    summaryResult.fold(
      (failure) {
        talker.error('LucentTodayRepository: fetchSummary failed: $failure');
        summaryFailed = true;
        recordCounts.clear();
        recordLatest.clear();
        recordPayloads.clear();
      },
      (summary) {
        for (final s in summary.summaries) {
          recordCounts[s.kind.name] = s.count;
          recordLatest[s.kind.name] = s.latest?.value;
          recordPayloads[s.kind.name] = s.latest?.payload;
          if (s.kind.name == 'sleep') {
            sleepPayload = s.latest?.payload;
          }
        }
      },
    );

    final waterResult = await dailyRecordRepository
        .fetchRecords(
          dateStr,
          kind: DailyRecordKind.water.name,
          page: 1,
          pageSize: 100,
        )
        .run();
    waterResult.fold(
      (failure) {
        talker.error(
          'LucentTodayRepository: fetch water records failed: $failure',
        );
        waterMetric = _degradedObservedMetric(dateStr);
      },
      (waterRecords) {
        waterMetric = _waterObservedMetric(
          waterRecords.items,
          total: waterRecords.total,
          date: dateStr,
        );
      },
    );

    var vitalReadout = const _VitalReadout();
    final vitalResult = await dailyRecordRepository
        .fetchRecords(
          dateStr,
          kind: DailyRecordKind.vital.name,
          page: 1,
          pageSize: 50,
        )
        .run();
    vitalResult.fold(
      (failure) {
        talker.error(
          'LucentTodayRepository: fetch vital records failed: $failure',
        );
        vitalReadout = _VitalReadout.degraded(date: dateStr);
      },
      (vitalRecords) {
        vitalReadout = _VitalReadout.fromRecords(
          vitalRecords.items,
          date: dateStr,
        );
      },
    );

    final waterCount = (recordCounts['water'] ?? 0).toInt();
    final completedMedicineIds = <String>{};
    TodayObservedMetric? medicationObservedMetric;
    final doseLogsResult = await doseLogRepository.fetchForDate(dateStr).run();
    doseLogsResult.fold(
      (failure) {
        talker.error('LucentTodayRepository: dose logs failed: $failure');
        medicationObservedMetric = _degradedObservedMetric(dateStr);
      },
      (doseLogs) {
        for (final log in doseLogs) {
          final medicineId = log.currentMedicineId;
          if (medicineId != null &&
              (log.status == DoseLogStatus.taken ||
                  log.status == DoseLogStatus.skipped)) {
            completedMedicineIds.add(medicineId);
          }
        }
      },
    );
    final pendingMedicines = medicines
        .where((m) => m.isCurrent && !completedMedicineIds.contains(m.id))
        .toList();

    // Determine which medicines have at least one reminder scheduled for
    // today. This is the correct denominator for the medication overview —
    // "X/Y meds" should mean "X of Y medicines due today", not "X of all
    // medicines in the cabinet".
    final todayScheduledMedicineIds = await _todayScheduledMedicineIds(
      today,
      medicines.map((m) => m.id).toSet(),
    );
    // If no reminders exist at all, fall back to all current medicines so
    // the overview still shows something meaningful.
    final todayMedicineCount = todayScheduledMedicineIds.isNotEmpty
        ? todayScheduledMedicineIds.length
        : medicines.length;

    final nextReminder = await _nextReminderFor(
      today,
      pendingMedicines.map((medicine) => medicine.id).toSet(),
    );
    final nextReminderMedicineId = nextReminder?.currentMedicineId;
    final nextMedicine = nextReminderMedicineId == null
        ? null
        : pendingMedicines
              .where((medicine) => medicine.id == nextReminderMedicineId)
              .firstOrNull;
    final fallbackMedicine = pendingMedicines.isNotEmpty
        ? pendingMedicines.first
        : (medicines.isNotEmpty ? medicines.first : null);
    final nextMedicineName =
        nextMedicine?.displayName ?? fallbackMedicine?.displayName;
    final hasUnreadNotifications = await _unreadNotificationsFlag();

    return TodayDashboard(
      user: TodayUserSnapshot(
        moment: todayDayMomentFromHour(today.hour),
        hasUnreadNotifications: hasUnreadNotifications,
        updatedAtLabel: _formatTimeLabel(today),
      ),
      water: TodayWaterSummary(
        completedCount: waterCount,
        targetCount: waterTargetCount,
        observedMetric: waterMetric,
      ),
      medication: TodayMedicationSummary(
        medicineCount: todayMedicineCount,
        pendingCount: pendingMedicines.length,
        nextDoseTimeLabel: nextReminder?.timeLabel ?? '--',
        nextMedicineName: nextMedicineName,
        observedMetric: medicationObservedMetric,
      ),
      vitals: [
        TodayVitalSummary(
          type: TodayVitalType.heartRate,
          valueLabel: vitalReadout.heartRateLabel,
          observedMetric: summaryFailed
              ? _degradedObservedMetric(dateStr)
              : vitalReadout.heartRateMetric,
        ),
        TodayVitalSummary(
          type: TodayVitalType.bloodPressure,
          valueLabel: vitalReadout.bloodPressureLabel,
          observedMetric: summaryFailed
              ? _degradedObservedMetric(dateStr)
              : vitalReadout.bloodPressureMetric,
        ),
        TodayVitalSummary(
          type: TodayVitalType.sleep,
          valueLabel: _formatSleepLabel(sleepPayload),
          observedMetric: summaryFailed
              ? _degradedObservedMetric(dateStr)
              : _observedMetric(
                  value: _sleepHours(recordPayloads['sleep']),
                  observed: sleepPayload != null,
                  observedCount: sleepPayload == null ? 0 : 1,
                  date: dateStr,
                ),
        ),
        // Deferred by Product_Vision MVP: keep lightweight mood data in the
        // repository for future self-check-ins, but do not surface it as a
        // formal mental-health module in Today.
        TodayVitalSummary(
          type: TodayVitalType.mood,
          valueLabel: recordLatest['mood'] ?? '--',
          observedMetric: summaryFailed
              ? _degradedObservedMetric(dateStr)
              : _observedMetric(
                  value: null,
                  observed: recordLatest['mood'] != null,
                  observedCount: recordLatest['mood'] == null ? 0 : 1,
                  date: dateStr,
                ),
        ),
      ],
      mealSuggestion: _staticMealSuggestion,
      environment: _staticEnvironment,
      lumiSuggestion: _staticLumiSuggestion,
    );
  }

  static const _staticMealSuggestion = TodayMealSuggestion(
    type: TodayMealSuggestionType.highProteinBalancedLunch,
  );

  // Deferred by Product_Vision MVP: keep environment signals because Lucent has
  // a useful reference-data contract, but do not surface it until a concrete
  // Today or Mine product job is ready.
  static const _staticEnvironment = TodayEnvironmentSummary(
    signals: <TodayEnvironmentSignal>[
      TodayEnvironmentSignal(
        type: TodayEnvironmentSignalType.pollen,
        level: TodayEnvironmentLevel.high,
      ),
      TodayEnvironmentSignal(
        type: TodayEnvironmentSignalType.uv,
        level: TodayEnvironmentLevel.medium,
      ),
    ],
  );

  static const _staticLumiSuggestion = TodayLumiSuggestion(
    type: TodayLumiSuggestionType.pollenProtection,
  );

  /// Returns a fully-degraded dashboard used when the health-context snapshot
  /// is unavailable. Every metric that has a real upstream source is marked
  /// [TodayObservedMetricState.degraded] so the UI can render "Temporarily
  /// unavailable" instead of a misleading 0 or `--`.
  TodayDashboard _degradedDashboard(
    DateTime today,
    String dateStr, {
    bool hasUnreadNotifications = false,
  }) {
    return TodayDashboard(
      user: TodayUserSnapshot(
        moment: todayDayMomentFromHour(today.hour),
        hasUnreadNotifications: hasUnreadNotifications,
        updatedAtLabel: _formatTimeLabel(today),
      ),
      water: TodayWaterSummary(
        completedCount: 0,
        targetCount: TodayDashboard.defaultWaterTargetCount,
        observedMetric: _degradedObservedMetric(dateStr),
      ),
      medication: TodayMedicationSummary(
        medicineCount: 0,
        pendingCount: 0,
        nextDoseTimeLabel: '--',
        observedMetric: _degradedObservedMetric(dateStr),
      ),
      vitals: [
        TodayVitalSummary(
          type: TodayVitalType.heartRate,
          valueLabel: '--',
          observedMetric: _degradedObservedMetric(dateStr),
        ),
        TodayVitalSummary(
          type: TodayVitalType.bloodPressure,
          valueLabel: '--',
          observedMetric: _degradedObservedMetric(dateStr),
        ),
        TodayVitalSummary(
          type: TodayVitalType.sleep,
          valueLabel: '--',
          observedMetric: _degradedObservedMetric(dateStr),
        ),
        TodayVitalSummary(
          type: TodayVitalType.mood,
          valueLabel: '--',
          observedMetric: _degradedObservedMetric(dateStr),
        ),
      ],
      mealSuggestion: _staticMealSuggestion,
      environment: _staticEnvironment,
      lumiSuggestion: _staticLumiSuggestion,
    );
  }

  /// Reads the authenticated user's water target from settings.
  ///
  /// Falls back to [TodayDashboard.defaultWaterTargetCount] if the settings
  /// endpoint fails, so a network blip does not break the overview.
  Future<int> _waterTargetCount() async {
    try {
      final result = await userSettingsRepository.getSettings().run();
      final targetCount = result.fold((failure) {
        talker.error(
          'LucentTodayRepository._waterTargetCount: failed: $failure',
        );
        return TodayDashboard.defaultWaterTargetCount;
      }, (settings) => settings.waterTargetCount);
      return targetCount;
    } catch (e) {
      talker.error('LucentTodayRepository._waterTargetCount: failed: $e');
      return TodayDashboard.defaultWaterTargetCount;
    }
  }

  /// Returns the set of medicine IDs that have at least one active
  /// reminder matching [today].
  ///
  /// Used to compute the correct denominator for the medication overview —
  /// only medicines with a reminder scheduled for today should be counted
  /// as "due today".
  Future<Set<String>> _todayScheduledMedicineIds(
    DateTime today,
    Set<String> allMedicineIds,
  ) async {
    if (allMedicineIds.isEmpty) return {};
    final remindersResult = await reminderRepository.fetchActive().run();
    return remindersResult.fold(
      (failure) {
        talker.error(
          'LucentTodayRepository._todayScheduledMedicineIds: failed: '
          '$failure',
        );
        return <String>{};
      },
      (reminders) {
        return reminders
            .where((reminder) {
              final medicineId = reminder.currentMedicineId;
              return medicineId != null &&
                  allMedicineIds.contains(medicineId) &&
                  reminder.matchesDate(today);
            })
            .map((reminder) => reminder.currentMedicineId!)
            .toSet();
      },
    );
  }

  Future<MedicineReminderItem?> _nextReminderFor(
    DateTime today,
    Set<String> pendingMedicineIds,
  ) async {
    if (pendingMedicineIds.isEmpty) return null;
    final remindersResult = await reminderRepository.fetchActive().run();
    return remindersResult.fold(
      (failure) {
        talker.error(
          'LucentTodayRepository._nextReminderFor: failed: $failure',
        );
        return null;
      },
      (reminders) {
        final todayReminders =
            reminders
                .where((reminder) {
                  final medicineId = reminder.currentMedicineId;
                  return medicineId != null &&
                      pendingMedicineIds.contains(medicineId) &&
                      reminder.matchesDate(today);
                })
                .toList(growable: false)
              ..sort(_compareReminderTime);
        return todayReminders.firstOrNull;
      },
    );
  }

  static int _compareReminderTime(
    MedicineReminderItem left,
    MedicineReminderItem right,
  ) {
    final hour = left.scheduledHour.compareTo(right.scheduledHour);
    if (hour != 0) return hour;
    return left.scheduledMinute.compareTo(right.scheduledMinute);
  }

  static String _formatSleepLabel(Map<String, dynamic>? payload) {
    if (payload == null) return '--';
    final durationMinutes = payload['durationMinutes'];
    if (durationMinutes is! num || durationMinutes <= 0) return '--';
    final hours = (durationMinutes / 60).toStringAsFixed(1);
    return '${hours}h';
  }

  static double? _sleepHours(Map<String, dynamic>? payload) {
    final durationMinutes = payload?['durationMinutes'];
    if (durationMinutes is! num || durationMinutes <= 0) return null;
    return durationMinutes.toDouble() / 60;
  }

  static TodayObservedMetric _unknownObservedMetric(String date) {
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

  static TodayObservedMetric _waterObservedMetric(
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

  static String _formatTimeLabel(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<bool> _unreadNotificationsFlag() async {
    try {
      final result = await notificationRepository.getUnreadCount().run();
      final hasUnread = result.fold((failure) {
        talker.warning('LucentTodayRepository: unread count failed: $failure');
        return false;
      }, (count) => count > 0);
      return hasUnread;
    } catch (e) {
      // 协议异常（非 problem+json 错误体）逃逸 .run()：未读徽章属轮询类
      // best-effort 展示，与 Left 一样降级为无未读并记录（water target 同款
      // 合同），不打断 dashboard。
      talker.warning('LucentTodayRepository: unread count protocol error: $e');
      return false;
    }
  }

  @override
  Future<TodayDashboard> get signedOutDashboard =>
      Future.value(TodayDashboard.signedOut());
}

/// Immutable holder for the latest heart-rate and blood-pressure readouts.
///
/// Created from the day's `vital` daily records so that the Today vitals row
/// reads real observed values instead of static placeholders.
final class _VitalReadout {
  const _VitalReadout({
    this.heartRateMetric,
    this.bloodPressureMetric,
    this.heartRateLabel = '--',
    this.bloodPressureLabel = '--',
  });

  factory _VitalReadout.degraded({required String date}) {
    return _VitalReadout(
      heartRateMetric: _degradedObservedMetric(date),
      bloodPressureMetric: _degradedObservedMetric(date),
    );
  }

  factory _VitalReadout.fromRecords(
    List<DailyRecordItem> records, {
    required String date,
  }) {
    if (records.isEmpty) {
      return const _VitalReadout();
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
        heartRateMetric = _observedMetric(
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
        bloodPressureMetric = _observedMetric(
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

    return _VitalReadout(
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
