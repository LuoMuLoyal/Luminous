import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/medicine/presentation/widgets/reminder/delete_dialog.dart';

import '../../../../helpers/test_forui_app.dart';

void main() {
  group('showMedicineReminderDeleteDialog', () {
    testWidgets('renders title and body text', (tester) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => showMedicineReminderDeleteDialog(context),
                child: const Text('open-dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open-dialog'));
      await tester.pumpAndSettle();

      expect(find.text('删除这条提醒？'), findsOneWidget);
      expect(find.textContaining('删除后将无法恢复'), findsOneWidget);
    });

    testWidgets('renders cancel and confirm buttons', (tester) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => showMedicineReminderDeleteDialog(context),
                child: const Text('open-dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open-dialog'));
      await tester.pumpAndSettle();

      expect(find.text('取消'), findsOneWidget);
      expect(find.text('确认删除'), findsOneWidget);
    });

    testWidgets('returns false when cancel is tapped', (tester) async {
      bool? result;

      await tester.pumpWidget(
        TestForuiApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await showMedicineReminderDeleteDialog(context);
                },
                child: const Text('open-dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open-dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });

    testWidgets('returns true when confirm delete is tapped', (tester) async {
      bool? result;

      await tester.pumpWidget(
        TestForuiApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await showMedicineReminderDeleteDialog(context);
                },
                child: const Text('open-dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open-dialog'));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const Key('medicine-reminder-delete-confirm-button')),
      );
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });
  });
}
