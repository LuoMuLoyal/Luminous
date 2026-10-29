import 'package:luminous/core/providers/instrumentation/data_change_bus.dart';
import 'package:luminous/features/record/domain/undo/quick_entry_undo.dart';
import 'package:luminous/features/record/data/datasources/quick_entry_preferences.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/quick_entry_preferences.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/undo/quick_entry_undo.dart';

typedef CreateDailyRecord =
    Future<DailyRecordItem> Function(DailyRecordCreateInput input);
typedef RegisterQuickEntryUndo = void Function(QuickEntryUndoAction action);

/// The record-identifying half of a quick-entry write (wire-formatted date and
/// time).
class QuickEntryRecordContext {
  const QuickEntryRecordContext({
    required this.occurredAt,
    required this.occurredTime,
  });

  final String occurredAt;
  final String occurredTime;
}

/// Logs one water record from the quick-entry surface.
///
/// Pure orchestration: resolve the configured amount → create the record →
/// broadcast the change → hand the undo command back to the caller. No UI, no
/// providers — dependencies arrive as constructor arguments. Shared by the
/// record page and the Today quick actions so both write identically.
class WaterQuickEntryFlow {
  const WaterQuickEntryFlow({
    required this.createRecord,
    required this.emitDataChange,
    required this.registerUndo,
  });

  final CreateDailyRecord createRecord;
  final EmitDataChangeTopic emitDataChange;
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

    emitDataChange(QuickEntryDataChange.dailyRecords);
    registerUndo(QuickEntryUndoAction.deleteDailyRecord(recordId: item.id));
    return item;
  }
}
