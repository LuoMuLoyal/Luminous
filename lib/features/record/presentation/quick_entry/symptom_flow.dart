import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/record/application/usecases/quick_entry_undo.dart';
import 'package:luminous/features/record/application/usecases/water_quick_entry.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';

class SymptomQuickChoice {
  const SymptomQuickChoice({
    required this.title,
    this.value,
    this.note,
    this.payload,
  });

  final String title;
  final String? value;
  final String? note;
  final Map<String, dynamic>? payload;
}

class SymptomQuickEntryFlow {
  const SymptomQuickEntryFlow({
    required this.createRecord,
    required this.emitDataChange,
    required this.registerUndo,
  });

  final CreateDailyRecord createRecord;
  final EmitDataChange emitDataChange;
  final RegisterQuickEntryUndo registerUndo;

  Future<DailyRecordItem> recordSingle(
    QuickEntryRecordContext context,
    SymptomQuickChoice choice,
  ) async {
    final item = await createRecord(
      DailyRecordCreateInput(
        kind: DailyRecordKind.symptom,
        occurredAt: context.occurredAt,
        occurredTime: context.occurredTime,
        title: choice.title,
        value: choice.value,
        note: choice.note,
        payload: choice.payload,
      ),
    );

    emitDataChange(DataChangeTopic.dailyRecords);
    registerUndo(QuickEntryUndoAction.deleteDailyRecord(recordId: item.id));
    return item;
  }

  Future<SymptomQuickBatchResult> recordBatch(
    QuickEntryRecordContext context,
    List<SymptomQuickChoice> choices,
  ) async {
    final succeeded = <SymptomQuickChoice>[];
    final failed = <SymptomQuickChoice>[];

    for (final choice in choices) {
      try {
        await createRecord(
          DailyRecordCreateInput(
            kind: DailyRecordKind.symptom,
            occurredAt: context.occurredAt,
            occurredTime: context.occurredTime,
            title: choice.title,
            value: choice.value,
            note: choice.note,
            payload: choice.payload,
          ),
        );
        succeeded.add(choice);
      } catch (e, st) {
        appTalker.error(
          'SymptomQuickEntry: createRecord failed for "${choice.title}": $e',
          st,
        );
        failed.add(choice);
      }
    }

    if (succeeded.isNotEmpty) {
      emitDataChange(DataChangeTopic.dailyRecords);
    }

    return SymptomQuickBatchResult(succeeded: succeeded, failed: failed);
  }
}

class SymptomQuickBatchResult {
  const SymptomQuickBatchResult({
    required this.succeeded,
    required this.failed,
  });

  final List<SymptomQuickChoice> succeeded;
  final List<SymptomQuickChoice> failed;
}
