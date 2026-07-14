import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/features/record/presentation/widgets/shared/components.dart';

import '../../../helpers/test_forui_app.dart';

void main() {
  group('RecordHeaderActionChip', () {
    Future<void> pumpChip(
      WidgetTester tester, {
      bool emphasized = false,
      bool iconOnly = false,
    }) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: RecordHeaderActionChip(
              label: 'Test',
              icon: FLucideIcons.plus,
              onTap: () {},
              emphasized: emphasized,
              iconOnly: iconOnly,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    testWidgets('renders label text when not iconOnly', (tester) async {
      await pumpChip(tester);
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('does not render label text when iconOnly', (tester) async {
      await pumpChip(tester, iconOnly: true);
      expect(find.text('Test'), findsNothing);
    });

    testWidgets('renders icon', (tester) async {
      await pumpChip(tester);
      expect(find.byIcon(FLucideIcons.plus), findsOneWidget);
    });

    testWidgets('renders FButton', (tester) async {
      await pumpChip(tester);
      expect(find.byType(FButton), findsOneWidget);
    });

    testWidgets('renders FTooltip', (tester) async {
      await pumpChip(tester);
      expect(find.byType(FTooltip), findsOneWidget);
    });

    testWidgets('calls onTap when pressed', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: RecordHeaderActionChip(
              label: 'Tap',
              icon: FLucideIcons.plus,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.byType(FButton));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });

  group('RecordLineChart', () {
    Future<void> pumpChart(
      WidgetTester tester, {
      List<double> points = const [1.0, 2.0, 3.0],
      List<double> secondaryPoints = const [],
      Color? secondaryColor,
    }) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: RecordLineChart(
              points: points,
              color: Colors.blue,
              gridColor: Colors.grey,
              secondaryPoints: secondaryPoints,
              secondaryColor: secondaryColor,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    testWidgets('renders LineChart', (tester) async {
      await pumpChart(tester);
      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('renders with custom height', (tester) async {
      await tester.pumpWidget(
        const TestForuiApp(
          home: Scaffold(
            body: RecordLineChart(
              points: [1.0, 2.0],
              color: Colors.blue,
              gridColor: Colors.grey,
              height: 200,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.height, 200);
    });

    testWidgets('renders with secondary line', (tester) async {
      await pumpChart(
        tester,
        secondaryPoints: [0.5, 1.5],
        secondaryColor: Colors.red,
      );
      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('renders with empty points without crashing', (tester) async {
      await pumpChart(tester, points: []);
      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('renders RepaintBoundary', (tester) async {
      await pumpChart(tester);
      expect(find.byType(RepaintBoundary), findsWidgets);
    });
  });

  group('RecordBarChart', () {
    Future<void> pumpChart(
      WidgetTester tester, {
      List<double> values = const [0.5, 0.8, 0.3],
    }) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: RecordBarChart(
              values: values,
              color: Colors.blue,
              gridColor: Colors.grey,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    testWidgets('renders BarChart', (tester) async {
      await pumpChart(tester);
      expect(find.byType(BarChart), findsOneWidget);
    });

    testWidgets('renders with custom height', (tester) async {
      await tester.pumpWidget(
        const TestForuiApp(
          home: Scaffold(
            body: RecordBarChart(
              values: [0.5],
              color: Colors.blue,
              gridColor: Colors.grey,
              height: 150,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.height, 150);
    });

    testWidgets('renders with empty values without crashing', (tester) async {
      await pumpChart(tester, values: []);
      expect(find.byType(BarChart), findsOneWidget);
    });

    testWidgets('renders with single value', (tester) async {
      await pumpChart(tester, values: [0.7]);
      expect(find.byType(BarChart), findsOneWidget);
    });

    testWidgets('clamps values above 1.0', (tester) async {
      await pumpChart(tester, values: [1.5, 0.3]);
      expect(find.byType(BarChart), findsOneWidget);
    });
  });
}
