import 'package:collection/collection.dart';
import 'package:luminous/core/providers/data_change_bus.dart';

typedef DeleteDailyRecord = Future<void> Function(String recordId);
typedef DeleteDoseLog = Future<void> Function(String doseLogId);
typedef UpdateDoseLogStatus =
    Future<void> Function(String doseLogId, String status);
typedef EmitDataChange = void Function(String topic);

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
  final EmitDataChange emitDataChange;

  Future<void> undo(QuickEntryUndoAction action) async {
    switch (action.type) {
      case QuickEntryUndoActionType.deleteDailyRecord:
        await deleteDailyRecord(action.recordId!);
        emitDataChange(DataChangeTopic.dailyRecords);
      case QuickEntryUndoActionType.deleteDoseLog:
        final deleteDoseLog = this.deleteDoseLog;
        assert(
          deleteDoseLog != null,
          'Dose log delete undo is not configured.',
        );
        await deleteDoseLog!(action.doseLogId!);
        emitDataChange(DataChangeTopic.doseLogs);
      case QuickEntryUndoActionType.restoreDoseLogStatus:
        final updateDoseLogStatus = this.updateDoseLogStatus;
        assert(
          updateDoseLogStatus != null,
          'Dose log status restore undo is not configured.',
        );
        await updateDoseLogStatus!(action.doseLogId!, action.previousStatus!);
        emitDataChange(DataChangeTopic.doseLogs);
      case QuickEntryUndoActionType.batch:
        for (final nestedAction in action.actions.reversed) {
          await undo(nestedAction);
        }
    }
  }
}
