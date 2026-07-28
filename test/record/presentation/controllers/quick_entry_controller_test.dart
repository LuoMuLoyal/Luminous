import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/presentation/controllers/quick_entry.dart';

void main() {
  group('QuickEntryController', () {
    test('delegates tap action to executor', () async {
      final calls = <RecordEntryType>[];
      final controller = QuickEntryController(
        execute: (context) async => calls.add(context.action.type),
      );

      await controller.handleTap(
        QuickEntryActionContext(
          action: RecordDashboard.signedOut(DateTime(2026, 7, 28)).quickActions
              .firstWhere((action) => action.type == RecordEntryType.water),
        ),
      );

      expect(calls, [RecordEntryType.water]);
    });
  });
}
