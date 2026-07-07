import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/widgets/common/app_divider.dart';

import '../../helpers/test_forui_app.dart';

Widget _appShell(Widget child) {
  return TestForuiApp(
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('AppDivider', () {
    testWidgets('renders horizontal divider with default border color', (
      tester,
    ) async {
      await tester.pumpWidget(_appShell(const AppDivider()));

      final divider = tester.widget<FDivider>(find.byType(FDivider));
      expect(divider.axis, Axis.horizontal);

      final container = tester.widget<Container>(find.byType(Container));
      final theme = tester.widget<FTheme>(find.byType(FTheme)).data;
      expect(container.color, theme.colors.border);
    });

    testWidgets('renders vertical divider', (tester) async {
      await tester.pumpWidget(_appShell(const AppDivider(axis: Axis.vertical)));

      final divider = tester.widget<FDivider>(find.byType(FDivider));
      expect(divider.axis, Axis.vertical);
    });

    testWidgets('applies custom color', (tester) async {
      await tester.pumpWidget(_appShell(const AppDivider(color: Colors.red)));

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.color, Colors.red);
    });

    testWidgets('applies custom width', (tester) async {
      await tester.pumpWidget(_appShell(const AppDivider(width: 4)));

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.minHeight, 4);
      expect(container.constraints?.maxHeight, 4);
    });
  });
}
