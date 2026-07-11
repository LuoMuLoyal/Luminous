import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/shell/presentation/deferred_content.dart';

import '../helpers/test_forui_app.dart';

void main() {
  group('ShellDeferredContent', () {
    testWidgets('shows placeholder on first frame, child on next',
        (tester) async {
      await tester.pumpWidget(
        const TestForuiApp(
          home: ShellDeferredContent(
            placeholder: SizedBox(key: Key('placeholder')),
            child: SizedBox(key: Key('child')),
          ),
        ),
      );

      // First frame — placeholder is visible
      expect(find.byKey(const Key('placeholder')), findsOneWidget);
      expect(find.byKey(const Key('child')), findsNothing);

      // Pump next frame — post-frame callback fires
      await tester.pump();

      // Child is now visible, placeholder is gone
      expect(find.byKey(const Key('child')), findsOneWidget);
      expect(find.byKey(const Key('placeholder')), findsNothing);
    });

    testWidgets('shows default placeholder when no placeholder provided',
        (tester) async {
      await tester.pumpWidget(
        const TestForuiApp(
          home: ShellDeferredContent(
            child: SizedBox(key: Key('child')),
          ),
        ),
      );

      // Default placeholder skeleton should be visible
      expect(find.byKey(const Key('child')), findsNothing);
      expect(find.byType(ColoredBox), findsWidgets);

      await tester.pump();
      expect(find.byKey(const Key('child')), findsOneWidget);
    });

    testWidgets('child remains visible after rebuilds', (tester) async {
      await tester.pumpWidget(
        const TestForuiApp(
          home: ShellDeferredContent(
            child: SizedBox(key: Key('child')),
          ),
        ),
      );

      await tester.pump();
      expect(find.byKey(const Key('child')), findsOneWidget);

      // Trigger rebuild
      await tester.pump();
      expect(find.byKey(const Key('child')), findsOneWidget);
    });
  });
}
