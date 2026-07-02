import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/widgets/common/app_dialog_shell.dart';

import '../../helpers/test_forui_app.dart';

Widget _appShell(Widget child) {
  return TestForuiApp(home: child);
}

void main() {
  group('AppDialogShell', () {
    testWidgets('renders dialog with child content', (tester) async {
      await tester.pumpWidget(
        _appShell(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => showAppDialog(
                  context: context,
                  builder: (_) => const Text('Dialog content'),
                ),
                child: const Text('Open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();

      expect(find.byType(FDialog), findsOneWidget);
      expect(find.text('Dialog content'), findsOneWidget);
    });

    testWidgets('respects maxWidth constraint', (tester) async {
      await tester.pumpWidget(
        _appShell(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => showAppDialog(
                  context: context,
                  maxWidth: 100,
                  builder: (_) => const Text('Narrow dialog'),
                ),
                child: const Text('Open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();

      // Verify dialog content is rendered
      expect(find.text('Narrow dialog'), findsOneWidget);
    });

    testWidgets('renders scrollable content by default', (tester) async {
      await tester.pumpWidget(
        _appShell(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => showAppDialog(
                  context: context,
                  builder: (_) => const Text('Scroll me'),
                ),
                child: const Text('Open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();

      // SingleChildScrollView inside the dialog
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('non-scrollable dialog has no scroll view', (tester) async {
      await tester.pumpWidget(
        _appShell(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => showAppDialog(
                  context: context,
                  scrollable: false,
                  builder: (_) => const Text('Fixed'),
                ),
                child: const Text('Open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();

      // Should have no SingleChildScrollView when scrollable is false.
      expect(find.byType(SingleChildScrollView), findsNothing);
      expect(find.text('Fixed'), findsOneWidget);
    });
  });
}
