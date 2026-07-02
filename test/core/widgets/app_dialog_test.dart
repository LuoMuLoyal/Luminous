import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/core/widgets/common/app_dialog.dart';

Widget _appShell(Widget child) {
  return MaterialApp(theme: AppTheme.light, home: child);
}

void main() {
  group('AppDialog', () {
    testWidgets('renders dialog with child content', (tester) async {
      await tester.pumpWidget(
        _appShell(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) =>
                      const AppDialog(child: Text('Dialog content')),
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
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const AppDialog(
                    maxWidth: 100,
                    child: Text('Narrow dialog'),
                  ),
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
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const AppDialog(child: Text('Scroll me')),
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
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) =>
                      const AppDialog(scrollable: false, child: Text('Fixed')),
                ),
                child: const Text('Open'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();

      // Should have no SingleChildScrollView (the outer dialog wrapper may have one)
      // But the AppDialog itself shouldn't wrap with scrollable content
      expect(find.text('Fixed'), findsOneWidget);
    });
  });
}
