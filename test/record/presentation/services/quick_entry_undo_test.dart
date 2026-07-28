import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/record/presentation/services/quick_entry_undo.dart';

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
  });
}
