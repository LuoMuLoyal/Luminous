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
    final undoActions = <QuickEntryUndoAction>[];

    for (final choice in choices) {
      try {
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
        succeeded.add(choice);
        // 批量落库的每条都记一个撤销动作，供调用方合成一次「撤销」。
        undoActions.add(
          QuickEntryUndoAction.deleteDailyRecord(recordId: item.id),
        );
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

    return SymptomQuickBatchResult(
      succeeded: succeeded,
      failed: failed,
      undoActions: undoActions,
    );
  }
}

class SymptomQuickBatchResult {
  const SymptomQuickBatchResult({
    required this.succeeded,
    required this.failed,
    this.undoActions = const [],
  });

  final List<SymptomQuickChoice> succeeded;
  final List<SymptomQuickChoice> failed;

  /// 成功落库各条对应的撤销动作（失败项不含在内）。
  final List<QuickEntryUndoAction> undoActions;

  /// 一次「撤销」把本批全部回滚；全部失败时返回 null。
  QuickEntryUndoAction? get batchUndo => undoActions.isEmpty
      ? null
      : QuickEntryUndoAction.batch(actions: undoActions);
}
