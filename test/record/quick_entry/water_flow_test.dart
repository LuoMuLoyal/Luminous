import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/record/application/usecases/quick_entry_undo.dart';
import 'package:luminous/features/record/application/usecases/water_quick_entry.dart';
import 'package:luminous/features/record/data/quick_entry_preferences.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';

void main() {
  group('WaterQuickEntryFlow', () {
    test('creates a water record with the default 250 ml amount', () async {
      DailyRecordCreateInput? created;
      final emitted = <String>[];
      final undoActions = <QuickEntryUndoAction>[];
      final flow = WaterQuickEntryFlow(
        createRecord: (input) async {
          created = input;
          return _dailyRecord(id: 'water-1', kind: input.kind);
        },
        emitDataChange: emitted.add,
        registerUndo: undoActions.add,
      );

      await flow.record(
        const QuickEntryRecordContext(
          occurredAt: '2026-07-28',
          occurredTime: '08:30',
        ),
        const QuickEntryPreferences(),
      );

      expect(created?.kind, DailyRecordKind.water);
      expect(created?.value, '250');
      expect(created?.unit, 'ml');
      expect(created?.occurredAt, '2026-07-28');
      expect(created?.occurredTime, '08:30');
      expect(emitted, [DataChangeTopic.dailyRecords]);
      expect(undoActions, [
        const QuickEntryUndoAction.deleteDailyRecord(recordId: 'water-1'),
      ]);
    });

    test('uses custom water default preference', () async {
      DailyRecordCreateInput? created;
      final flow = WaterQuickEntryFlow(
        createRecord: (input) async {
          created = input;
          return _dailyRecord(id: 'water-2', kind: input.kind);
        },
        emitDataChange: (_) {},
        registerUndo: (_) {},
      );

      await flow.record(
        const QuickEntryRecordContext(
          occurredAt: '2026-07-28',
          occurredTime: '08:30',
        ),
        const QuickEntryPreferences(waterDefault: QuickEntryWaterDefault.ml500),
      );

      expect(created?.value, '500');
      expect(created?.unit, 'ml');
    });

    test('does not emit or register undo when saving fails', () async {
      final emitted = <String>[];
      final undoActions = <QuickEntryUndoAction>[];
      final flow = WaterQuickEntryFlow(
        createRecord: (_) async => throw StateError('save failed'),
        emitDataChange: emitted.add,
        registerUndo: undoActions.add,
      );

      await expectLater(
        flow.record(
          const QuickEntryRecordContext(
            occurredAt: '2026-07-28',
            occurredTime: '08:30',
          ),
          const QuickEntryPreferences(),
        ),
        throwsStateError,
      );

      expect(emitted, isEmpty);
      expect(undoActions, isEmpty);
    });

    test('records a cup default with the cup unit', () async {
      DailyRecordCreateInput? created;
      final flow = WaterQuickEntryFlow(
        createRecord: (input) async {
          created = input;
          return _dailyRecord(id: 'water-3', kind: input.kind);
        },
        emitDataChange: (_) {},
        registerUndo: (_) {},
      );

      await flow.record(
        const QuickEntryRecordContext(
          occurredAt: '2026-07-28',
          occurredTime: '08:30',
        ),
        const QuickEntryPreferences(waterDefault: QuickEntryWaterDefault.cup),
      );

      expect(created?.value, '1');
      expect(created?.unit, 'cup');
    });

    test('records the custom ml amount with the ml unit', () async {
      DailyRecordCreateInput? created;
      final flow = WaterQuickEntryFlow(
        createRecord: (input) async {
          created = input;
          return _dailyRecord(id: 'water-4', kind: input.kind);
        },
        emitDataChange: (_) {},
        registerUndo: (_) {},
      );

      await flow.record(
        const QuickEntryRecordContext(
          occurredAt: '2026-07-28',
          occurredTime: '08:30',
        ),
        const QuickEntryPreferences(
          waterDefault: QuickEntryWaterDefault.custom,
          waterCustomMl: 300,
        ),
      );

      expect(created?.value, '300');
      expect(created?.unit, 'ml');
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
