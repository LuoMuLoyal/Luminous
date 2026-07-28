import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/presentation/quick_entry/sleep_flow.dart';
import 'package:luminous/features/record/presentation/services/quick_entry_undo.dart';

void main() {
  group('SleepQuickEntryFlow', () {
    test('creates a sleep start fact when no open start exists', () async {
      DailyRecordCreateInput? created;
      final emitted = <String>[];
      final undoActions = <QuickEntryUndoAction>[];
      final flow = SleepQuickEntryFlow(
        createRecord: (input) async {
          created = input;
          return _record(id: 'sleep-start-1', input: input);
        },
        deleteRecord: (_) async {},
        emitDataChange: emitted.add,
        registerUndo: undoActions.add,
      );

      final outcome = await flow.handleTap(
        context: SleepQuickEntryContext(
          occurredAt: '2026-07-28',
          occurredTime: '23:15',
          now: DateTime.utc(2026, 7, 28, 15, 15),
        ),
        candidateRecords: const <DailyRecordItem>[],
      );

      expect(outcome.type, SleepQuickEntryOutcomeType.started);
      expect(created?.kind, DailyRecordKind.sleep);
      expect(created?.occurredAt, '2026-07-28');
      expect(created?.occurredTime, '23:15');
      expect(created?.payload, {
        'sleepEvent': 'start',
        'eventAt': '2026-07-28T15:15:00.000Z',
      });
      expect(emitted, [DataChangeTopic.dailyRecords]);
      expect(undoActions, [
        const QuickEntryUndoAction.deleteDailyRecord(recordId: 'sleep-start-1'),
      ]);
    });

    test('records wake fact and prepares a cross-day merge', () async {
      final created = <DailyRecordCreateInput>[];
      final flow = SleepQuickEntryFlow(
        createRecord: (input) async {
          created.add(input);
          return _record(id: 'sleep-wake-1', input: input);
        },
        deleteRecord: (_) async {},
        emitDataChange: (_) {},
        registerUndo: (_) {},
      );

      final start = _sleepStart(
        id: 'sleep-start-1',
        occurredAt: '2026-07-28',
        occurredTime: '23:15',
        eventAt: '2026-07-28T15:15:00.000Z',
      );

      final outcome = await flow.handleTap(
        context: SleepQuickEntryContext(
          occurredAt: '2026-07-29',
          occurredTime: '07:10',
          now: DateTime.utc(2026, 7, 28, 23, 10),
        ),
        candidateRecords: [start],
      );

      expect(outcome.type, SleepQuickEntryOutcomeType.wakeRecorded);
      expect(created.single.payload, {
        'sleepEvent': 'wake',
        'eventAt': '2026-07-28T23:10:00.000Z',
        'startedRecordId': 'sleep-start-1',
      });
      expect(outcome.merge?.durationMinutes, 475);
      expect(outcome.merge?.mergedInput.payload, {
        'durationMinutes': 475,
        'startAt': '2026-07-28T15:15:00.000Z',
        'endAt': '2026-07-28T23:10:00.000Z',
      });
      expect(outcome.merge?.mergedInput.occurredAt, '2026-07-29');
      expect(outcome.merge?.mergedInput.occurredTime, '07:10');
    });

    test('keeps same-day nap duration without forcing a day boundary', () {
      final merge = SleepQuickEntryFlow.buildMerge(
        context: SleepQuickEntryContext(
          occurredAt: '2026-07-28',
          occurredTime: '14:40',
          now: DateTime.utc(2026, 7, 28, 6, 40),
        ),
        startRecord: _sleepStart(
          id: 'nap-start',
          occurredAt: '2026-07-28',
          occurredTime: '13:05',
          eventAt: '2026-07-28T05:05:00.000Z',
        ),
        wakeRecord: _sleepWake(
          id: 'nap-wake',
          occurredAt: '2026-07-28',
          occurredTime: '14:40',
          eventAt: '2026-07-28T06:40:00.000Z',
          startedRecordId: 'nap-start',
        ),
      );

      expect(merge.durationMinutes, 95);
      expect(merge.mergedInput.payload?['durationMinutes'], 95);
    });

    test('returns invalid duration when wake is not after start', () async {
      final created = <DailyRecordCreateInput>[];
      final flow = SleepQuickEntryFlow(
        createRecord: (input) async {
          created.add(input);
          return _record(id: 'wake-1', input: input);
        },
        deleteRecord: (_) async {},
        emitDataChange: (_) {},
        registerUndo: (_) {},
      );

      final outcome = await flow.handleTap(
        context: SleepQuickEntryContext(
          occurredAt: '2026-07-28',
          occurredTime: '23:15',
          now: DateTime.utc(2026, 7, 28, 15, 15),
        ),
        candidateRecords: [
          _sleepStart(
            id: 'future-start',
            occurredAt: '2026-07-28',
            occurredTime: '23:20',
            eventAt: '2026-07-28T15:20:00.000Z',
          ),
        ],
      );

      expect(outcome.type, SleepQuickEntryOutcomeType.invalidDuration);
      expect(created, isEmpty);
    });

    test('asks for start selection when multiple open starts exist', () async {
      final flow = SleepQuickEntryFlow(
        createRecord: (input) async => _record(id: 'unused', input: input),
        deleteRecord: (_) async {},
        emitDataChange: (_) {},
        registerUndo: (_) {},
      );

      final starts = [
        _sleepStart(
          id: 'start-1',
          occurredAt: '2026-07-27',
          occurredTime: '23:10',
          eventAt: '2026-07-27T15:10:00.000Z',
        ),
        _sleepStart(
          id: 'start-2',
          occurredAt: '2026-07-28',
          occurredTime: '13:00',
          eventAt: '2026-07-28T05:00:00.000Z',
        ),
      ];

      final outcome = await flow.handleTap(
        context: SleepQuickEntryContext(
          occurredAt: '2026-07-28',
          occurredTime: '14:00',
          now: DateTime.utc(2026, 7, 28, 6),
        ),
        candidateRecords: starts,
      );

      expect(outcome.type, SleepQuickEntryOutcomeType.needsStartSelection);
      expect(outcome.openStarts.map((record) => record.id), [
        'start-2',
        'start-1',
      ]);
    });

    test(
      'confirmMerge creates complete record then deletes temp facts',
      () async {
        final created = <DailyRecordCreateInput>[];
        final deleted = <String>[];
        final emitted = <String>[];
        final flow = SleepQuickEntryFlow(
          createRecord: (input) async {
            created.add(input);
            return _record(id: 'merged-sleep', input: input);
          },
          deleteRecord: (recordId) async => deleted.add(recordId),
          emitDataChange: emitted.add,
          registerUndo: (_) {},
        );

        final merge = SleepQuickEntryFlow.buildMerge(
          context: SleepQuickEntryContext(
            occurredAt: '2026-07-29',
            occurredTime: '07:10',
            now: DateTime.utc(2026, 7, 28, 23, 10),
          ),
          startRecord: _sleepStart(
            id: 'sleep-start-1',
            occurredAt: '2026-07-28',
            occurredTime: '23:15',
            eventAt: '2026-07-28T15:15:00.000Z',
          ),
          wakeRecord: _sleepWake(
            id: 'sleep-wake-1',
            occurredAt: '2026-07-29',
            occurredTime: '07:10',
            eventAt: '2026-07-28T23:10:00.000Z',
            startedRecordId: 'sleep-start-1',
          ),
        );

        await flow.confirmMerge(merge);

        expect(created.single.payload?['durationMinutes'], 475);
        expect(deleted, ['sleep-start-1', 'sleep-wake-1']);
        expect(emitted, [DataChangeTopic.dailyRecords]);
      },
    );
  });
}

DailyRecordItem _sleepStart({
  required String id,
  required String occurredAt,
  required String occurredTime,
  required String eventAt,
}) {
  return DailyRecordItem(
    id: id,
    kind: DailyRecordKind.sleep,
    occurredAt: occurredAt,
    occurredTime: occurredTime,
    payload: {'sleepEvent': 'start', 'eventAt': eventAt},
    createdAt: eventAt,
    updatedAt: eventAt,
  );
}

DailyRecordItem _sleepWake({
  required String id,
  required String occurredAt,
  required String occurredTime,
  required String eventAt,
  required String startedRecordId,
}) {
  return DailyRecordItem(
    id: id,
    kind: DailyRecordKind.sleep,
    occurredAt: occurredAt,
    occurredTime: occurredTime,
    payload: {
      'sleepEvent': 'wake',
      'eventAt': eventAt,
      'startedRecordId': startedRecordId,
    },
    createdAt: eventAt,
    updatedAt: eventAt,
  );
}

DailyRecordItem _record({
  required String id,
  required DailyRecordCreateInput input,
}) {
  return DailyRecordItem(
    id: id,
    kind: input.kind,
    occurredAt: input.occurredAt,
    occurredTime: input.occurredTime,
    title: input.title,
    value: input.value,
    unit: input.unit,
    note: input.note,
    payload: input.payload,
    createdAt: '2026-07-28T00:00:00.000Z',
    updatedAt: '2026-07-28T00:00:00.000Z',
  );
}
