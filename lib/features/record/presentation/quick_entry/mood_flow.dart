import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/presentation/quick_entry/water_flow.dart';
import 'package:luminous/features/record/presentation/services/quick_entry_undo.dart';

class MoodQuickChoice {
  const MoodQuickChoice({required this.title});

  final String title;
}

class MoodQuickEntryFlow {
  const MoodQuickEntryFlow({
    required this.createRecord,
    required this.emitDataChange,
    required this.registerUndo,
  });

  final CreateDailyRecord createRecord;
  final EmitDataChange emitDataChange;
  final RegisterQuickEntryUndo registerUndo;

  Future<DailyRecordItem> recordSingle(
    QuickEntryRecordContext context,
    MoodQuickChoice choice,
  ) async {
    final item = await createRecord(
      DailyRecordCreateInput(
        kind: DailyRecordKind.mood,
        occurredAt: context.occurredAt,
        occurredTime: context.occurredTime,
        title: choice.title,
      ),
    );

    emitDataChange(DataChangeTopic.dailyRecords);
    registerUndo(QuickEntryUndoAction.deleteDailyRecord(recordId: item.id));
    return item;
  }
}
