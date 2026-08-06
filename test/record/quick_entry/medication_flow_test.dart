import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_remote.dart';
import 'package:luminous/features/medicine/data/datasources/reminder_remote.dart';
import 'package:luminous/features/record/presentation/quick_entry/medication_flow.dart';
import 'package:luminous/features/record/presentation/services/quick_entry_undo.dart';

void main() {
  group('MedicationQuickEntryWindow', () {
    test('contains now minus 30 minutes through now plus 2 hours', () {
      final window = MedicationQuickEntryWindow(now: DateTime(2026, 7, 28, 8));

      expect(window.contains(DateTime(2026, 7, 28, 7, 30)), isTrue);
      expect(window.contains(DateTime(2026, 7, 28, 10)), isTrue);
      expect(window.contains(DateTime(2026, 7, 28, 7, 29)), isFalse);
      expect(window.contains(DateTime(2026, 7, 28, 10, 1)), isFalse);
    });
  });

  group('MedicationQuickEntryFlow', () {
    test('zero current medicines returns add-medicine outcome', () async {
      final flow = MedicationQuickEntryFlow(
        markDose: _unexpectedMark,
        emitDataChange: (_) {},
        registerUndo: (_) {},
      );

      final outcome = await flow.handleTap(
        context: _context(),
        currentMedicines: const [],
        reminders: const [],
        todayLogs: const [],
      );

      expect(outcome.type, MedicationQuickEntryOutcomeType.noCurrentMedicines);
    });

    test(
      'one medicine with nearby pending slot marks the slot taken',
      () async {
        MedicationQuickMarkInput? marked;
        QuickEntryUndoAction? undoAction;
        final emitted = <String>[];
        final flow = MedicationQuickEntryFlow(
          markDose: (input) async {
            marked = input;
            return _doseLog(
              id: 'dose-new',
              currentMedicineId: input.currentMedicineId,
            );
          },
          emitDataChange: emitted.add,
          registerUndo: (action) => undoAction = action,
        );

        final outcome = await flow.handleTap(
          context: _context(),
          currentMedicines: [_medicine(id: 'med-1')],
          reminders: [
            _reminder(id: 'rem-1', currentMedicineId: 'med-1', hour: 8),
          ],
          todayLogs: const [],
        );

        expect(outcome.type, MedicationQuickEntryOutcomeType.recordedSingle);
        expect(marked?.currentMedicineId, 'med-1');
        expect(marked?.reminderId, 'rem-1');
        expect(marked?.scheduledTime, '08:00');
        expect(marked?.status, 'taken');
        expect(emitted, [DataChangeTopic.doseLogs]);
        expect(
          undoAction,
          const QuickEntryUndoAction.deleteDoseLog(doseLogId: 'dose-new'),
        );
      },
    );

    test(
      'one medicine without nearby slot creates a dose log at current time',
      () async {
        MedicationQuickMarkInput? marked;
        final flow = MedicationQuickEntryFlow(
          markDose: (input) async {
            marked = input;
            return _doseLog(
              id: 'dose-new',
              currentMedicineId: input.currentMedicineId,
              scheduledTime: input.scheduledTime,
            );
          },
          emitDataChange: (_) {},
          registerUndo: (_) {},
        );

        final outcome = await flow.handleTap(
          context: _context(),
          currentMedicines: [_medicine(id: 'med-1')],
          reminders: [
            _reminder(id: 'rem-1', currentMedicineId: 'med-1', hour: 13),
          ],
          todayLogs: const [],
        );

        expect(outcome.type, MedicationQuickEntryOutcomeType.recordedSingle);
        expect(marked?.currentMedicineId, 'med-1');
        expect(marked?.reminderId, isNull);
        expect(marked?.scheduledTime, '08:00');
      },
    );

    test('already taken nearby slot does not duplicate writes', () async {
      final flow = MedicationQuickEntryFlow(
        markDose: _unexpectedMark,
        emitDataChange: (_) {},
        registerUndo: (_) {},
      );

      final outcome = await flow.handleTap(
        context: _context(),
        currentMedicines: [_medicine(id: 'med-1')],
        reminders: [
          _reminder(id: 'rem-1', currentMedicineId: 'med-1', hour: 8),
        ],
        todayLogs: [
          _doseLog(
            id: 'dose-1',
            currentMedicineId: 'med-1',
            reminderId: 'rem-1',
            scheduledTime: '08:00',
            status: DoseLogStatus.taken,
          ),
        ],
      );

      expect(outcome.type, MedicationQuickEntryOutcomeType.alreadyRecorded);
    });

    test(
      'multiple medicines default-select nearby pending slots only',
      () async {
        final flow = MedicationQuickEntryFlow(
          markDose: _unexpectedMark,
          emitDataChange: (_) {},
          registerUndo: (_) {},
        );

        final outcome = await flow.handleTap(
          context: _context(),
          currentMedicines: [
            _medicine(id: 'med-1'),
            _medicine(id: 'med-2'),
          ],
          reminders: [
            _reminder(id: 'rem-1', currentMedicineId: 'med-1', hour: 8),
            _reminder(id: 'rem-2', currentMedicineId: 'med-2', hour: 13),
          ],
          todayLogs: const [],
        );

        expect(outcome.type, MedicationQuickEntryOutcomeType.needsSelection);
        expect(
          outcome.selection?.choices.map((choice) => choice.currentMedicineId),
          ['med-1', 'med-2'],
        );
        expect(outcome.selection?.defaultSelectedIds, {'med-1|rem-1|08:00'});
      },
    );

    test(
      'confirmed selection records choices without registering undo',
      () async {
        final marked = <MedicationQuickMarkInput>[];
        final emitted = <String>[];
        final undoActions = <QuickEntryUndoAction>[];
        final flow = MedicationQuickEntryFlow(
          markDose: (input) async {
            marked.add(input);
            return _doseLog(
              id: 'dose-${marked.length}',
              currentMedicineId: input.currentMedicineId,
            );
          },
          emitDataChange: emitted.add,
          registerUndo: undoActions.add,
        );

        final result = await flow.recordConfirmedSelection(
          context: _context(),
          choices: const [
            MedicationQuickChoice(
              id: 'med-1|rem-1|08:00',
              currentMedicineId: 'med-1',
              name: 'Medicine med-1',
              reminderId: 'rem-1',
              scheduledTime: '08:00',
            ),
            MedicationQuickChoice(
              id: 'med-2',
              currentMedicineId: 'med-2',
              name: 'Medicine med-2',
              scheduledTime: '08:00',
            ),
          ],
        );

        expect(marked.map((input) => input.currentMedicineId), [
          'med-1',
          'med-2',
        ]);
        expect(emitted, [DataChangeTopic.doseLogs]);
        expect(undoActions, isEmpty);
        expect(result.succeeded, hasLength(2));
        expect(result.failed, isEmpty);
      },
    );

    test(
      'failed markDose records error in result and continues processing',
      () async {
        final flow = MedicationQuickEntryFlow(
          markDose: (input) async {
            if (input.currentMedicineId == 'med-2') {
              throw Exception('network error');
            }
            return _doseLog(
              id: 'dose-1',
              currentMedicineId: input.currentMedicineId,
            );
          },
          emitDataChange: (_) {},
          registerUndo: (_) {},
        );

        final result = await flow.recordConfirmedSelection(
          context: _context(),
          choices: const [
            MedicationQuickChoice(
              id: 'med-1|rem-1|08:00',
              currentMedicineId: 'med-1',
              name: 'Medicine med-1',
              reminderId: 'rem-1',
              scheduledTime: '08:00',
            ),
            MedicationQuickChoice(
              id: 'med-2',
              currentMedicineId: 'med-2',
              name: 'Medicine med-2',
              scheduledTime: '08:00',
            ),
          ],
        );

        expect(result.succeeded, hasLength(1));
        expect(result.succeeded.first.currentMedicineId, 'med-1');
        expect(result.failed, hasLength(1));
        expect(result.failed.first.currentMedicineId, 'med-2');
        expect(result.errors, contains('med-2'));
        expect(result.errors['med-2'], contains('network error'));
      },
    );
  });
}

MedicationQuickEntryContext _context() {
  return MedicationQuickEntryContext(
    date: '2026-07-28',
    now: DateTime(2026, 7, 28, 8),
  );
}

Future<DoseLogItem> _unexpectedMark(MedicationQuickMarkInput input) {
  throw StateError('unexpected mark call');
}

CurrentMedicineItem _medicine({required String id}) {
  return CurrentMedicineItem(
    id: id,
    source: 'manual',
    sourceRefId: null,
    displayName: 'Medicine $id',
    strengthText: '10mg',
    doseText: '1 tablet',
    route: null,
    startedAt: null,
    endedAt: null,
    isCurrent: true,
    note: null,
    createdAt: '2026-07-28T08:00:00Z',
    updatedAt: '2026-07-28T08:00:00Z',
  );
}

MedicineReminderItem _reminder({
  required String id,
  required String currentMedicineId,
  required int hour,
}) {
  return MedicineReminderItem(
    id: id,
    currentMedicineId: currentMedicineId,
    scheduledHour: hour,
    scheduledMinute: 0,
    isActive: true,
    createdAt: '2026-07-28T08:00:00Z',
    updatedAt: '2026-07-28T08:00:00Z',
  );
}

DoseLogItem _doseLog({
  required String id,
  required String currentMedicineId,
  String? reminderId,
  String? scheduledTime,
  DoseLogStatus status = DoseLogStatus.taken,
}) {
  return DoseLogItem(
    id: id,
    currentMedicineId: currentMedicineId,
    reminderId: reminderId,
    status: status,
    scheduledFor: '2026-07-28',
    scheduledTime: scheduledTime,
    createdAt: '2026-07-28T08:00:00Z',
    updatedAt: '2026-07-28T08:00:00Z',
  );
}
