import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';

import '../../helpers/test_forui_app.dart';

Widget _appShell({required double width, required Widget child}) {
  return TestForuiApp(
    home: MediaQuery(
      data: MediaQueryData(size: Size(width, 800)),
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  group('ResponsiveContentFrame', () {
    testWidgets('applies default horizontal padding', (tester) async {
      const width = AppBreakpoints.mobile - 100;
      await tester.pumpWidget(
        _appShell(
          width: width,
          child: const ResponsiveContentFrame(child: Text('Content')),
        ),
      );

      final padding = tester.widget<Padding>(
        find.ancestor(of: find.byType(Center), matching: find.byType(Padding)),
      );
      final layout = AppLayoutTokens.resolve(width);
      expect(
        padding.padding,
        EdgeInsets.symmetric(horizontal: layout.pageHorizontalPadding),
      );
    });

    testWidgets('limits max width on desktop', (tester) async {
      const width = AppBreakpoints.desktop + 100.0;
      await tester.pumpWidget(
        _appShell(
          width: width,
          child: const ResponsiveContentFrame(child: Text('Content')),
        ),
      );

      final constrainedBox = tester.widget<ConstrainedBox>(
        find.descendant(
          of: find.byType(ResponsiveContentFrame),
          matching: find.byType(ConstrainedBox),
        ),
      );
      final layout = AppLayoutTokens.resolve(width);
      expect(constrainedBox.constraints.maxWidth, layout.maxContentWidth);
    });

    testWidgets('does not limit max width below desktop breakpoint', (
      tester,
    ) async {
      final width = AppBreakpoints.mobile.toDouble();
      await tester.pumpWidget(
        _appShell(
          width: width,
          child: const ResponsiveContentFrame(child: Text('Content')),
        ),
      );

      final constrainedBox = tester.widget<ConstrainedBox>(
        find.descendant(
          of: find.byType(ResponsiveContentFrame),
          matching: find.byType(ConstrainedBox),
        ),
      );
      expect(constrainedBox.constraints.maxWidth, double.infinity);
    });

    testWidgets('applies custom padding when provided', (tester) async {
      await tester.pumpWidget(
        _appShell(
          width: 400,
          child: const ResponsiveContentFrame(
            padding: EdgeInsets.all(32),
            child: Text('Content'),
          ),
        ),
      );

      final padding = tester.widget<Padding>(
        find.ancestor(of: find.byType(Center), matching: find.byType(Padding)),
      );
      expect(padding.padding, const EdgeInsets.all(32));
    });

    testWidgets('expand wraps content in SizedBox.expand', (tester) async {
      await tester.pumpWidget(
        _appShell(
          width: 400,
          child: const ResponsiveContentFrame(
            expand: true,
            child: Text('Content'),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(ResponsiveContentFrame),
          matching: find.byType(SizedBox),
        ),
        findsOneWidget,
      );
    });
  });
}
