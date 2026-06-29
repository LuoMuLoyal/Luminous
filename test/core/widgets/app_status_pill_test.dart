import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/widgets/common/app_status_pill.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';

Widget _appShell(Widget child) {
  return MaterialApp(
    theme: ThemeData.light().copyWith(
      extensions: const <ThemeExtension<dynamic>>[AppThemeSurface.light],
    ),
    home: Scaffold(body: child),
  );
}

void main() {
  group('AppStatusPill', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        _appShell(const AppStatusPill(label: 'Active', color: Colors.green)),
      );

      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('renders icon when provided', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const AppStatusPill(
            label: 'Verified',
            color: Colors.blue,
            icon: Icons.check,
          ),
        ),
      );

      expect(find.text('Verified'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('does not render icon when omitted', (tester) async {
      await tester.pumpWidget(
        _appShell(const AppStatusPill(label: 'Basic', color: Colors.grey)),
      );

      expect(find.text('Basic'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('uses large typography when large is true', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const AppStatusPill(
            label: 'Large',
            color: Colors.orange,
            large: true,
          ),
        ),
      );

      expect(find.text('Large'), findsOneWidget);
    });

    testWidgets('accepts custom padding', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const AppStatusPill(
            label: 'Custom',
            color: Colors.purple,
            padding: EdgeInsets.all(16),
          ),
        ),
      );

      expect(find.text('Custom'), findsOneWidget);
    });

    testWidgets('renders with background transparency', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const AppStatusPill(
            label: 'Faded',
            color: Colors.red,
            backgroundAlpha: 0.5,
          ),
        ),
      );

      expect(find.text('Faded'), findsOneWidget);
    });
  });
}
