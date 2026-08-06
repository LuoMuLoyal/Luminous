import 'package:collection/collection.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/medicine/domain/entities/dose_log.dart';
import 'package:luminous/features/medicine/domain/entities/reminder.dart';
import 'package:luminous/features/record/presentation/services/quick_entry_undo.dart';

typedef MarkDoseLog = Future<DoseLogItem> Function(MedicationQuickMarkInput);
typedef RegisterMedicationQuickUndo =
    void Function(QuickEntryUndoAction action);

class MedicationQuickEntryWindow {
  const MedicationQuickEntryWindow({required this.now});

  final DateTime now;

  DateTime get startsAt => now.subtract(const Duration(minutes: 30));
  DateTime get endsAt => now.add(const Duration(hours: 2));

  bool contains(DateTime value) {
    return !value.isBefore(startsAt) && !value.isAfter(endsAt);
  }
}

class MedicationQuickEntryContext {
  const MedicationQuickEntryContext({required this.date, required this.now});

  final String date;
  final DateTime now;
}

class MedicationQuickMarkInput {
  const MedicationQuickMarkInput({
    required this.currentMedicineId,
    required this.status,
    required this.date,
    this.reminderId,
    this.scheduledTime,
  });

  final String currentMedicineId;
  final String status;
  final String date;
  final String? reminderId;
  final String? scheduledTime;
}

enum MedicationQuickEntryOutcomeType {
  noCurrentMedicines,
  recordedSingle,
  needsSelection,
  alreadyRecorded,
}

class MedicationQuickEntryOutcome {
  const MedicationQuickEntryOutcome._({required this.type, this.selection});

  const MedicationQuickEntryOutcome.noCurrentMedicines()
    : this._(type: MedicationQuickEntryOutcomeType.noCurrentMedicines);

  const MedicationQuickEntryOutcome.recordedSingle()
    : this._(type: MedicationQuickEntryOutcomeType.recordedSingle);

  const MedicationQuickEntryOutcome.needsSelection(
    MedicationQuickSelection selection,
  ) : this._(
        type: MedicationQuickEntryOutcomeType.needsSelection,
        selection: selection,
      );

  const MedicationQuickEntryOutcome.alreadyRecorded()
    : this._(type: MedicationQuickEntryOutcomeType.alreadyRecorded);

  final MedicationQuickEntryOutcomeType type;
  final MedicationQuickSelection? selection;
}

class MedicationQuickSelection {
  const MedicationQuickSelection({
    required this.choices,
    required this.defaultSelectedIds,
  });

  final List<MedicationQuickChoice> choices;
  final Set<String> defaultSelectedIds;
}

class MedicationQuickBatchResult {
  const MedicationQuickBatchResult({
    required this.succeeded,
    required this.failed,
    this.errors = const {},
  });

  final List<MedicationQuickChoice> succeeded;
  final List<MedicationQuickChoice> failed;

  /// Error message per failed choice id, for UI display.
  final Map<String, String> errors;
}

class MedicationQuickChoice {
  const MedicationQuickChoice({
    required this.id,
    required this.currentMedicineId,
    required this.name,
    this.defaultSelected = false,
    this.reminderId,
    this.scheduledTime,
  });

  final String id;
  final String currentMedicineId;
  final String name;
  final bool defaultSelected;
  final String? reminderId;
  final String? scheduledTime;
}

class MedicationQuickEntryFlow {
  const MedicationQuickEntryFlow({
    required this.markDose,
    required this.emitDataChange,
    required this.registerUndo,
  });

  final MarkDoseLog markDose;
  final EmitDataChange emitDataChange;
  final RegisterMedicationQuickUndo registerUndo;

  Future<MedicationQuickEntryOutcome> handleTap({
    required MedicationQuickEntryContext context,
    required List<CurrentMedicineItem> currentMedicines,
    required List<MedicineReminderItem> reminders,
    required List<DoseLogItem> todayLogs,
    bool autoRecordSingle = true,
  }) async {
    final medicines = currentMedicines
        .where((medicine) => medicine.isCurrent)
        .toList(growable: false);
    if (medicines.isEmpty) {
      return const MedicationQuickEntryOutcome.noCurrentMedicines();
    }

    final plannedChoices = _buildChoices(
      context: context,
      medicines: medicines,
      reminders: reminders,
      todayLogs: todayLogs,
    );

    if (medicines.length > 1 || !autoRecordSingle) {
      final defaultSelectedIds = plannedChoices
          .where((choice) => choice.defaultSelected)
          .map((choice) => choice.id)
          .toSet();
      return MedicationQuickEntryOutcome.needsSelection(
        MedicationQuickSelection(
          choices: plannedChoices,
          defaultSelectedIds: defaultSelectedIds,
        ),
      );
    }

    final choice = plannedChoices.first;
    if (choice.reminderId == null && choice.scheduledTime == null) {
      await _recordChoice(context, choice, previousLog: null);
      return const MedicationQuickEntryOutcome.recordedSingle();
    }

    final previousLog = _matchingLog(choice, todayLogs);
    if (_isCompleted(previousLog)) {
      return const MedicationQuickEntryOutcome.alreadyRecorded();
    }

    await _recordChoice(context, choice, previousLog: previousLog);
    return const MedicationQuickEntryOutcome.recordedSingle();
  }

  Future<MedicationQuickBatchResult> recordConfirmedSelection({
    required MedicationQuickEntryContext context,
    required List<MedicationQuickChoice> choices,
  }) async {
    final succeeded = <MedicationQuickChoice>[];
    final failed = <MedicationQuickChoice>[];

    final errors = <String, String>{};

    for (final choice in choices) {
      try {
        await markDose(
          MedicationQuickMarkInput(
            currentMedicineId: choice.currentMedicineId,
            status: 'taken',
            date: context.date,
            reminderId: choice.reminderId,
            scheduledTime: choice.scheduledTime,
          ),
        );
        succeeded.add(choice);
      } catch (e, st) {
        appTalker.error(
          'MedicationQuickEntry: markDose failed for "${choice.name}" '
          '(medicineId=${choice.currentMedicineId}): $e',
          st,
        );
        failed.add(choice);
        errors[choice.id] = e.toString();
      }
    }

    if (succeeded.isNotEmpty) {
      emitDataChange(DataChangeTopic.doseLogs);
    }

    return MedicationQuickBatchResult(
      succeeded: succeeded,
      failed: failed,
      errors: errors,
    );
  }

  Future<DoseLogItem> _recordChoice(
    MedicationQuickEntryContext context,
    MedicationQuickChoice choice, {
    required DoseLogItem? previousLog,
  }) async {
    final item = await markDose(
      MedicationQuickMarkInput(
        currentMedicineId: choice.currentMedicineId,
        status: 'taken',
        date: context.date,
        reminderId: choice.reminderId,
        scheduledTime: choice.scheduledTime,
      ),
    );
    emitDataChange(DataChangeTopic.doseLogs);
    if (previousLog == null) {
      registerUndo(QuickEntryUndoAction.deleteDoseLog(doseLogId: item.id));
    } else {
      registerUndo(
        QuickEntryUndoAction.restoreDoseLogStatus(
          doseLogId: previousLog.id,
          previousStatus: previousLog.status.name,
        ),
      );
    }
    return item;
  }

  List<MedicationQuickChoice> _buildChoices({
    required MedicationQuickEntryContext context,
    required List<CurrentMedicineItem> medicines,
    required List<MedicineReminderItem> reminders,
    required List<DoseLogItem> todayLogs,
  }) {
    final window = MedicationQuickEntryWindow(now: context.now);
    return [
      for (final medicine in medicines)
        _choiceForMedicine(
          context: context,
          medicine: medicine,
          reminders: reminders,
          todayLogs: todayLogs,
          window: window,
        ),
    ];
  }

  MedicationQuickChoice _choiceForMedicine({
    required MedicationQuickEntryContext context,
    required CurrentMedicineItem medicine,
    required List<MedicineReminderItem> reminders,
    required List<DoseLogItem> todayLogs,
    required MedicationQuickEntryWindow window,
  }) {
    final nearbyReminders = reminders
        .where(
          (reminder) =>
              reminder.currentMedicineId == medicine.id &&
              reminder.isActive &&
              reminder.matchesDate(context.now) &&
              window.contains(_dateTimeFor(context.date, reminder.timeLabel)),
        )
        .toList(growable: false);

    final nearbyPendingReminder = nearbyReminders.firstWhereOrNull((reminder) {
      final choice = _choiceFromReminder(medicine, reminder);
      return !_isCompleted(_matchingLog(choice, todayLogs));
    });
    if (nearbyPendingReminder != null) {
      return _choiceFromReminder(
        medicine,
        nearbyPendingReminder,
        defaultSelected: true,
      );
    }

    final completedNearbyReminder = nearbyReminders.firstWhereOrNull((
      reminder,
    ) {
      final choice = _choiceFromReminder(medicine, reminder);
      return _isCompleted(_matchingLog(choice, todayLogs));
    });
    if (completedNearbyReminder != null) {
      return _choiceFromReminder(medicine, completedNearbyReminder);
    }

    return MedicationQuickChoice(
      id: medicine.id,
      currentMedicineId: medicine.id,
      name: medicine.displayName,
      scheduledTime: _formatTime(context.now),
    );
  }

  MedicationQuickChoice _choiceFromReminder(
    CurrentMedicineItem medicine,
    MedicineReminderItem reminder, {
    bool defaultSelected = false,
  }) {
    return MedicationQuickChoice(
      id: '${medicine.id}|${reminder.id}|${reminder.timeLabel}',
      currentMedicineId: medicine.id,
      name: medicine.displayName,
      defaultSelected: defaultSelected,
      reminderId: reminder.id,
      scheduledTime: reminder.timeLabel,
    );
  }

  DoseLogItem? _matchingLog(
    MedicationQuickChoice choice,
    List<DoseLogItem> logs,
  ) {
    return logs.firstWhereOrNull((log) {
      if (log.currentMedicineId != choice.currentMedicineId) return false;
      final reminderMatches =
          choice.reminderId != null && log.reminderId == choice.reminderId;
      final timeMatches =
          choice.scheduledTime != null &&
          log.scheduledTime == choice.scheduledTime;
      if (choice.reminderId != null) {
        return reminderMatches && timeMatches;
      }
      return log.reminderId == null;
    });
  }

  bool _isCompleted(DoseLogItem? log) {
    return log?.status == DoseLogStatus.taken ||
        log?.status == DoseLogStatus.skipped;
  }

  DateTime _dateTimeFor(String date, String time) {
    final parsedDate = DateTime.parse(date);
    final parts = time.split(':').map(int.parse).toList(growable: false);
    return DateTime(
      parsedDate.year,
      parsedDate.month,
      parsedDate.day,
      parts[0],
      parts[1],
    );
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
