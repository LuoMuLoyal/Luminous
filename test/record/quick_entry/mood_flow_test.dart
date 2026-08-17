import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/record/application/usecases/quick_entry_undo.dart';
import 'package:luminous/features/record/application/usecases/water_quick_entry.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/presentation/quick_entry/mood_flow.dart';

void main() {
  group('MoodQuickEntryFlow', () {
    test('single selection creates a mood record and registers undo', () async {
      DailyRecordCreateInput? created;
      final emitted = <String>[];
      final undoActions = <QuickEntryUndoAction>[];
      final flow = MoodQuickEntryFlow(
        createRecord: (input) async {
          created = input;
          return _dailyRecord(id: 'mood-1', kind: input.kind);
        },
        emitDataChange: emitted.add,
        registerUndo: undoActions.add,
      );

      await flow.recordSingle(
        const QuickEntryRecordContext(
          occurredAt: '2026-07-28',
          occurredTime: '08:30',
        ),
        const MoodQuickChoice(title: '平静'),
      );

      expect(created?.kind, DailyRecordKind.mood);
      expect(created?.title, '平静');
      expect(created?.occurredTime, '08:30');
      expect(emitted, [DataChangeTopic.dailyRecords]);
      expect(undoActions, [
        const QuickEntryUndoAction.deleteDailyRecord(recordId: 'mood-1'),
      ]);
    });
  });
}

DailyRecordItem _dailyRecord({
  required String id,
  required DailyRecordKind kind,
}) {
  return DailyRecordItem(
    id: id,
    kind: kind,
    occurredAt: '2026-07-28',
    occurredTime: '08:30',
    createdAt: '2026-07-28T08:30:00Z',
    updatedAt: '2026-07-28T08:30:00Z',
  );
}
