import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_colors.dart';
import 'package:luminous/core/widgets/common/app_status_pill.dart';

import '../../helpers/test_forui_app.dart';

Widget _appShell(Widget child) {
  return TestForuiApp(home: Scaffold(body: child));
}

void main() {
  group('AppStatusPill', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const AppStatusPill(label: 'Active', color: AppColors.primary),
        ),
      );

      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('renders icon when provided', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const AppStatusPill(
            label: 'Verified',
            color: AppColors.secondary,
            icon: Icons.check,
          ),
        ),
      );

      expect(find.text('Verified'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('does not render icon when omitted', (tester) async {
      await tester.pumpWidget(
        _appShell(const AppStatusPill(label: 'Basic', color: AppColors.muted)),
      );

      expect(find.text('Basic'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('uses large typography when large is true', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const AppStatusPill(
            label: 'Large',
            color: AppColors.destructive,
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
            color: AppColors.background,
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
            color: AppColors.foreground,
            backgroundAlpha: 0.5,
          ),
        ),
      );

      expect(find.text('Faded'), findsOneWidget);
    });
  });
}
