import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/record/data/quick_entry_preferences.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/presentation/services/quick_entry_undo.dart';

typedef CreateDailyRecord =
    Future<DailyRecordItem> Function(DailyRecordCreateInput input);
typedef RegisterQuickEntryUndo = void Function(QuickEntryUndoAction action);

class QuickEntryRecordContext {
  const QuickEntryRecordContext({
    required this.occurredAt,
    required this.occurredTime,
  });

  final String occurredAt;
  final String occurredTime;
}

class WaterQuickEntryFlow {
  const WaterQuickEntryFlow({
    required this.createRecord,
    required this.emitDataChange,
    required this.registerUndo,
  });

  final CreateDailyRecord createRecord;
  final EmitDataChange emitDataChange;
  final RegisterQuickEntryUndo registerUndo;

  Future<DailyRecordItem> record(
    QuickEntryRecordContext context,
    QuickEntryPreferences preferences,
  ) async {
    final amountMl = preferences.waterDefaultAmountMl;
    final item = await createRecord(
      DailyRecordCreateInput(
        kind: DailyRecordKind.water,
        occurredAt: context.occurredAt,
        occurredTime: context.occurredTime,
        value: amountMl.toString(),
        unit: 'ml',
      ),
    );

    emitDataChange(DataChangeTopic.dailyRecords);
    registerUndo(QuickEntryUndoAction.deleteDailyRecord(recordId: item.id));
    return item;
  }
}
