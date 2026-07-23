import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_cached.dart';
import 'package:luminous/features/medicine/data/datasources/reminder_remote.dart';
import 'package:luminous/features/medicine/data/providers/workspace.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/settings/data/repositories/lucent.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';
import 'package:luminous/features/today/domain/repositories/dashboard.dart';

/// Lucent-backed [TodayRepository] that merges real health-context and
/// daily-record signals with static mock sections for unsupported surfaces.
class LucentTodayRepository implements TodayRepository {
  LucentTodayRepository({required this.ref});

  final Ref ref;

  @override
  Future<TodayDashboard> fetchDashboard() async {
    final snapshot = await ref.read(healthContextSnapshotProvider.future);
    final medicines = snapshot.currentMedicines
        .where((medicine) => medicine.isCurrent)
        .toList(growable: false);

    // Resolve the user's preferred water target; fall back to the default if
    // settings are temporarily unavailable so the overview still renders.
    final waterTargetCount = await _waterTargetCount();

    // Fetch daily record summary for today
    final today = clock.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final Map<String, num> recordCounts = {};
    final Map<String, String?> recordLatest = {};
    Map<String, dynamic>? sleepPayload;
    try {
      final summary = await ref
          .read(dailyRecordRepositoryProvider)
          .fetchSummary(dateStr);
      for (final s in summary.summaries) {
        recordCounts[s.kind.name] = s.count;
        recordLatest[s.kind.name] = s.latest?.value;
        if (s.kind.name == 'sleep') {
          sleepPayload = s.latest?.payload;
        }
      }
    } catch (e) {
      ref
          .read(talkerProvider)
          .error('LucentTodayRepository: fetchSummary failed: $e');
    }

    final waterCount = (recordCounts['water'] ?? 0).toInt();
    final completedMedicineIds = <String>{};
    try {
      final doseLogs = await ref
          .read(cachedDoseLogDataSourceProvider)
          .fetchForDate(dateStr);
      for (final log in doseLogs) {
        final medicineId = log.currentMedicineId;
        if (medicineId != null &&
            (log.status == DoseLogStatus.taken ||
                log.status == DoseLogStatus.skipped)) {
          completedMedicineIds.add(medicineId);
        }
      }
    } catch (e) {
      ref
          .read(talkerProvider)
          .error('LucentTodayRepository: dose logs failed: $e');
    }
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

    return TodayDashboard(
      user: TodayUserSnapshot(
        moment: todayDayMomentFromHour(today.hour),
        hasUnreadNotifications: false,
        updatedAtLabel: _formatTimeLabel(today),
      ),
      water: TodayWaterSummary(
        completedCount: waterCount,
        targetCount: waterTargetCount,
      ),
      medication: TodayMedicationSummary(
        medicineCount: todayMedicineCount,
        pendingCount: pendingMedicines.length,
        nextDoseTimeLabel: nextReminder?.timeLabel ?? '--',
        nextMedicine: TodayMedicationKind.atorvastatin,
        nextMedicineName: nextMedicineName,
      ),
      vitals: [
        TodayVitalSummary(
          type: TodayVitalType.heartRate,
          valueLabel: recordLatest['vital'] ?? '--',
        ),
        const TodayVitalSummary(
          type: TodayVitalType.bloodPressure,
          valueLabel: '--',
        ),
        TodayVitalSummary(
          type: TodayVitalType.sleep,
          valueLabel: _formatSleepLabel(sleepPayload),
        ),
        // Deferred by Product_Vision MVP: keep lightweight mood data in the
        // repository for future self-check-ins, but do not surface it as a
        // formal mental-health module in Today.
        TodayVitalSummary(
          type: TodayVitalType.mood,
          valueLabel: recordLatest['mood'] ?? '--',
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

  /// Reads the authenticated user's water target from settings.
  ///
  /// Falls back to [TodayDashboard.defaultWaterTargetCount] if the settings
  /// endpoint fails, so a network blip does not break the overview.
  Future<int> _waterTargetCount() async {
    try {
      final settings = await ref
          .read(userSettingsRepositoryProvider)
          .getSettings();
      return settings.waterTargetCount;
    } catch (e) {
      ref
          .read(talkerProvider)
          .error('LucentTodayRepository._waterTargetCount: failed: $e');
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
    try {
      final reminders = await ref
          .read(medicineReminderRemoteDataSourceProvider)
          .fetchActive();
      return reminders
          .where((reminder) {
            final medicineId = reminder.currentMedicineId;
            return medicineId != null &&
                allMedicineIds.contains(medicineId) &&
                reminder.matchesDate(today);
          })
          .map((reminder) => reminder.currentMedicineId!)
          .toSet();
    } catch (e) {
      ref
          .read(talkerProvider)
          .error(
            'LucentTodayRepository._todayScheduledMedicineIds: failed: $e',
          );
      return {};
    }
  }

  Future<MedicineReminderItem?> _nextReminderFor(
    DateTime today,
    Set<String> pendingMedicineIds,
  ) async {
    if (pendingMedicineIds.isEmpty) return null;
    try {
      final reminders = await ref
          .read(medicineReminderRemoteDataSourceProvider)
          .fetchActive();
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
    } catch (e) {
      ref
          .read(talkerProvider)
          .error('LucentTodayRepository._nextReminderFor: failed: $e');
      return null;
    }
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

  static String _formatTimeLabel(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Future<TodayDashboard> get signedOutDashboard =>
      Future.value(TodayDashboard.signedOut());
}
