import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/record/application/usecases/quick_entry_undo.dart';
import 'package:luminous/features/record/data/datasources/quick_entry_preferences.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';

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
    final waterDefault = preferences.waterDefault;
    final resolved = waterDefault.resolve(customMl: preferences.waterCustomMl);
    final item = await createRecord(
      DailyRecordCreateInput(
        kind: DailyRecordKind.water,
        occurredAt: context.occurredAt,
        occurredTime: context.occurredTime,
        value: resolved.value,
        unit: resolved.unit,
      ),
    );

    emitDataChange(DataChangeTopic.dailyRecords);
    registerUndo(QuickEntryUndoAction.deleteDailyRecord(recordId: item.id));
    return item;
  }
}
