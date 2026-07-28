import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/presentation/quick_entry/symptom_flow.dart';
import 'package:luminous/features/record/presentation/quick_entry/water_flow.dart';
import 'package:luminous/features/record/presentation/services/quick_entry_undo.dart';

void main() {
  group('SymptomQuickEntryFlow', () {
    test(
      'single selection creates a symptom record and registers undo',
      () async {
        DailyRecordCreateInput? created;
        final emitted = <String>[];
        final undoActions = <QuickEntryUndoAction>[];
        final flow = SymptomQuickEntryFlow(
          createRecord: (input) async {
            created = input;
            return _dailyRecord(id: 'symptom-1', kind: input.kind);
          },
          emitDataChange: emitted.add,
          registerUndo: undoActions.add,
        );

        await flow.recordSingle(
          const QuickEntryRecordContext(
            occurredAt: '2026-07-28',
            occurredTime: '08:30',
          ),
          const SymptomQuickChoice(title: '头痛'),
        );

        expect(created?.kind, DailyRecordKind.symptom);
        expect(created?.title, '头痛');
        expect(created?.occurredTime, '08:30');
        expect(emitted, [DataChangeTopic.dailyRecords]);
        expect(undoActions, [
          const QuickEntryUndoAction.deleteDailyRecord(recordId: 'symptom-1'),
        ]);
      },
    );

    test(
      'batch confirmation records selected symptoms without registering undo',
      () async {
        final created = <DailyRecordCreateInput>[];
        final emitted = <String>[];
        final undoActions = <QuickEntryUndoAction>[];
        final flow = SymptomQuickEntryFlow(
          createRecord: (input) async {
            created.add(input);
            return _dailyRecord(
              id: 'symptom-${created.length}',
              kind: input.kind,
            );
          },
          emitDataChange: emitted.add,
          registerUndo: undoActions.add,
        );

        final result = await flow.recordBatch(
          const QuickEntryRecordContext(
            occurredAt: '2026-07-28',
            occurredTime: '08:30',
          ),
          const [
            SymptomQuickChoice(title: '头痛'),
            SymptomQuickChoice(title: '发热'),
          ],
        );

        expect(created, hasLength(2));
        expect(created.map((input) => input.title), ['头痛', '发热']);
        expect(emitted, [DataChangeTopic.dailyRecords]);
        expect(undoActions, isEmpty);
        expect(result.succeeded.map((choice) => choice.title), ['头痛', '发热']);
        expect(result.failed, isEmpty);
      },
    );

    test('batch confirmation reports failed selections for retry', () async {
      final created = <DailyRecordCreateInput>[];
      final emitted = <String>[];
      final flow = SymptomQuickEntryFlow(
        createRecord: (input) async {
          created.add(input);
          if (input.title == '发热') {
            throw StateError('failed');
          }
          return _dailyRecord(
            id: 'symptom-${created.length}',
            kind: input.kind,
          );
        },
        emitDataChange: emitted.add,
        registerUndo: (_) {},
      );

      final result = await flow.recordBatch(
        const QuickEntryRecordContext(
          occurredAt: '2026-07-28',
          occurredTime: '08:30',
        ),
        const [
          SymptomQuickChoice(title: '头痛'),
          SymptomQuickChoice(title: '发热'),
        ],
      );

      expect(created, hasLength(2));
      expect(emitted, [DataChangeTopic.dailyRecords]);
      expect(result.succeeded.map((choice) => choice.title), ['头痛']);
      expect(result.failed.map((choice) => choice.title), ['发热']);
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
