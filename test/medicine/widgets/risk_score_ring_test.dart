import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/presentation/widgets/risk/risk_score_ring.dart';

import '../../helpers/test_forui_app.dart';

void main() {
  group('RiskScoreRing', () {
    Future<void> pumpRing(
      WidgetTester tester, {
      required int score,
      required MedicineRiskLevel riskLevel,
      bool animate = false,
    }) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: Center(
              child: RiskScoreRing(
                score: score,
                riskLevel: riskLevel,
                animate: animate,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    testWidgets('renders score text', (tester) async {
      await pumpRing(tester, score: 72, riskLevel: MedicineRiskLevel.risk);
      expect(find.text('72'), findsOneWidget);
    });

    testWidgets('renders /100 suffix', (tester) async {
      await pumpRing(tester, score: 72, riskLevel: MedicineRiskLevel.risk);
      expect(find.text('/100'), findsOneWidget);
    });

    testWidgets('renders score 0 without crashing', (tester) async {
      await pumpRing(tester, score: 0, riskLevel: MedicineRiskLevel.safe);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('/100'), findsOneWidget);
    });

    testWidgets('renders score 100 for danger level', (tester) async {
      await pumpRing(tester, score: 100, riskLevel: MedicineRiskLevel.danger);
      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('renders with safe risk level', (tester) async {
      await pumpRing(tester, score: 10, riskLevel: MedicineRiskLevel.safe);
      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('renders with caution risk level', (tester) async {
      await pumpRing(tester, score: 40, riskLevel: MedicineRiskLevel.caution);
      expect(find.text('40'), findsOneWidget);
    });

    testWidgets('uses CustomPaint', (tester) async {
      await pumpRing(tester, score: 50, riskLevel: MedicineRiskLevel.caution);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('disables animation when animate is false', (tester) async {
      await pumpRing(
        tester,
        score: 50,
        riskLevel: MedicineRiskLevel.caution,
        animate: false,
      );
      // Without animation, the ring should still render the score.
      expect(find.text('50'), findsOneWidget);
    });
  });
}
