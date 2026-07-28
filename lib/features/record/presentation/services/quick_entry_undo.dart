import 'package:luminous/core/providers/data_change_bus.dart';

typedef DeleteDailyRecord = Future<void> Function(String recordId);
typedef EmitDataChange = void Function(String topic);

enum QuickEntryUndoActionType { deleteDailyRecord }

class QuickEntryUndoAction {
  const QuickEntryUndoAction.deleteDailyRecord({required this.recordId})
    : type = QuickEntryUndoActionType.deleteDailyRecord;

  final QuickEntryUndoActionType type;
  final String recordId;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is QuickEntryUndoAction &&
            other.type == type &&
            other.recordId == recordId;
  }

  @override
  int get hashCode => Object.hash(type, recordId);
}

class QuickEntryUndoService {
  const QuickEntryUndoService({
    required this.deleteDailyRecord,
    required this.emitDataChange,
  });

  final DeleteDailyRecord deleteDailyRecord;
  final EmitDataChange emitDataChange;

  Future<void> undo(QuickEntryUndoAction action) async {
    switch (action.type) {
      case QuickEntryUndoActionType.deleteDailyRecord:
        await deleteDailyRecord(action.recordId);
        emitDataChange(DataChangeTopic.dailyRecords);
    }
  }
}
