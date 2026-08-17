import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/record/application/usecases/quick_entry_undo.dart';

void main() {
  group('QuickEntryUndoService', () {
    test(
      'undo deletes the created daily record and emits dailyRecords change',
      () async {
        final deleted = <String>[];
        final emitted = <String>[];
        final service = QuickEntryUndoService(
          deleteDailyRecord: (id) async => deleted.add(id),
          emitDataChange: emitted.add,
        );

        await service.undo(
          const QuickEntryUndoAction.deleteDailyRecord(recordId: 'water-1'),
        );

        expect(deleted, ['water-1']);
        expect(emitted, [DataChangeTopic.dailyRecords]);
      },
    );

    test(
      'undo deletes the created dose log and emits doseLogs change',
      () async {
        final deleted = <String>[];
        final emitted = <String>[];
        final service = QuickEntryUndoService(
          deleteDailyRecord: (_) async {},
          deleteDoseLog: (id) async => deleted.add(id),
          emitDataChange: emitted.add,
        );

        await service.undo(
          const QuickEntryUndoAction.deleteDoseLog(doseLogId: 'dose-1'),
        );

        expect(deleted, ['dose-1']);
        expect(emitted, [DataChangeTopic.doseLogs]);
      },
    );

    test(
      'undo restores previous dose log status and emits doseLogs change',
      () async {
        final restored = <String, String>{};
        final emitted = <String>[];
        final service = QuickEntryUndoService(
          deleteDailyRecord: (_) async {},
          updateDoseLogStatus: (id, status) async => restored[id] = status,
          emitDataChange: emitted.add,
        );

        await service.undo(
          const QuickEntryUndoAction.restoreDoseLogStatus(
            doseLogId: 'dose-1',
            previousStatus: 'planned',
          ),
        );

        expect(restored, {'dose-1': 'planned'});
        expect(emitted, [DataChangeTopic.doseLogs]);
      },
    );

    test('undo processes a batch of dose log actions', () async {
      final deleted = <String>[];
      final emitted = <String>[];
      final service = QuickEntryUndoService(
        deleteDailyRecord: (_) async {},
        deleteDoseLog: (id) async => deleted.add(id),
        emitDataChange: emitted.add,
      );

      await service.undo(
        const QuickEntryUndoAction.batch(
          actions: [
            QuickEntryUndoAction.deleteDoseLog(doseLogId: 'dose-1'),
            QuickEntryUndoAction.deleteDoseLog(doseLogId: 'dose-2'),
          ],
        ),
      );

      expect(deleted, ['dose-2', 'dose-1']);
      expect(emitted, [DataChangeTopic.doseLogs, DataChangeTopic.doseLogs]);
    });
  });
}
