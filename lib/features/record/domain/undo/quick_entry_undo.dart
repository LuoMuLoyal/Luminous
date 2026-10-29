import 'package:collection/collection.dart';

/// Emits a cross-feature invalidation topic (see [QuickEntryDataChange]).
typedef EmitDataChangeTopic = void Function(String topic);

/// Topics a quick-entry write broadcasts.
///
/// Mirrors the wire strings of `core/providers/data_change_bus.dart` so the
/// application and domain layers name them without importing `core`; the
/// provider adapters map these back onto the real constants.
abstract final class QuickEntryDataChange {
  /// Daily records were created/updated/deleted.
  static const String dailyRecords = 'dailyRecords';

  /// Medicine dose logs changed.
  static const String doseLogs = 'doseLogs';
}

typedef DeleteDailyRecord = Future<void> Function(String recordId);
typedef DeleteDoseLog = Future<void> Function(String doseLogId);
typedef UpdateDoseLogStatus =
    Future<void> Function(String doseLogId, String status);

enum QuickEntryUndoActionType {
  deleteDailyRecord,
  deleteDoseLog,
  restoreDoseLogStatus,
  batch,
}

class QuickEntryUndoAction {
  const QuickEntryUndoAction.deleteDailyRecord({required this.recordId})
    : type = QuickEntryUndoActionType.deleteDailyRecord,
      doseLogId = null,
      previousStatus = null,
      actions = const [];

  const QuickEntryUndoAction.deleteDoseLog({required this.doseLogId})
    : type = QuickEntryUndoActionType.deleteDoseLog,
      recordId = null,
      previousStatus = null,
      actions = const [];

  const QuickEntryUndoAction.restoreDoseLogStatus({
    required this.doseLogId,
    required this.previousStatus,
  }) : type = QuickEntryUndoActionType.restoreDoseLogStatus,
       recordId = null,
       actions = const [];

  const QuickEntryUndoAction.batch({required this.actions})
    : type = QuickEntryUndoActionType.batch,
      recordId = null,
      doseLogId = null,
      previousStatus = null;

  final QuickEntryUndoActionType type;
  final String? recordId;
  final String? doseLogId;
  final String? previousStatus;
  final List<QuickEntryUndoAction> actions;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is QuickEntryUndoAction &&
            other.type == type &&
            other.recordId == recordId &&
            other.doseLogId == doseLogId &&
            other.previousStatus == previousStatus &&
            const ListEquality<QuickEntryUndoAction>().equals(
              other.actions,
              actions,
            );
  }

  @override
  int get hashCode => Object.hash(
    type,
    recordId,
    doseLogId,
    previousStatus,
    const ListEquality<QuickEntryUndoAction>().hash(actions),
  );
}

class QuickEntryUndoService {
  const QuickEntryUndoService({
    required this.deleteDailyRecord,
    required this.emitDataChange,
    this.deleteDoseLog,
    this.updateDoseLogStatus,
  });

  final DeleteDailyRecord deleteDailyRecord;
  final DeleteDoseLog? deleteDoseLog;
  final UpdateDoseLogStatus? updateDoseLogStatus;
  final EmitDataChangeTopic emitDataChange;

  Future<void> undo(QuickEntryUndoAction action) async {
    switch (action.type) {
      case QuickEntryUndoActionType.deleteDailyRecord:
        await deleteDailyRecord(action.recordId!);
        emitDataChange(QuickEntryDataChange.dailyRecords);
      case QuickEntryUndoActionType.deleteDoseLog:
        final deleteDoseLog = this.deleteDoseLog;
        assert(
          deleteDoseLog != null,
          'Dose log delete undo is not configured.',
        );
        await deleteDoseLog!(action.doseLogId!);
        emitDataChange(QuickEntryDataChange.doseLogs);
      case QuickEntryUndoActionType.restoreDoseLogStatus:
        final updateDoseLogStatus = this.updateDoseLogStatus;
        assert(
          updateDoseLogStatus != null,
          'Dose log status restore undo is not configured.',
        );
        await updateDoseLogStatus!(action.doseLogId!, action.previousStatus!);
        emitDataChange(QuickEntryDataChange.doseLogs);
      case QuickEntryUndoActionType.batch:
        for (final nestedAction in action.actions.reversed) {
          await undo(nestedAction);
        }
    }
  }
}
