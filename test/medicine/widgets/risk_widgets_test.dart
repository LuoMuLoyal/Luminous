import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/widgets/common/divider.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/presentation/widgets/risk/risk_coverage_issue_tile.dart';
import 'package:luminous/features/medicine/presentation/widgets/risk/risk_finding_tile.dart';
import 'package:luminous/features/medicine/presentation/widgets/risk/risk_metric_chip.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../helpers/test_forui_app.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('zh'));
  });

  group('MedicineRiskMetricChip', () {
    Future<void> pumpChip(WidgetTester tester) async {
      await tester.pumpWidget(
        const TestForuiApp(
          home: Scaffold(
            body: MedicineRiskMetricChip(label: '检测药品', value: '5'),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    testWidgets('renders label text', (tester) async {
      await pumpChip(tester);
      expect(find.text('检测药品'), findsOneWidget);
    });

    testWidgets('renders value text', (tester) async {
      await pumpChip(tester);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('renders FCard', (tester) async {
      await pumpChip(tester);
      expect(find.byType(FCard), findsOneWidget);
    });
  });

  group('MedicineRiskFindingTile', () {
    Future<void> pumpTile(
      WidgetTester tester, {
      required MedicineRiskFinding finding,
      bool isLast = false,
    }) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: SingleChildScrollView(
            child: MedicineRiskFindingTile(
              finding: finding,
              isLast: isLast,
              l10n: l10n,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    testWidgets('renders interaction finding title', (tester) async {
      await pumpTile(
        tester,
        finding: const MedicineRiskFinding(
          type: MedicineRiskFindingType.interaction,
          severity: MedicineRiskSeverity.high,
          context: MedicineRiskFindingContext.none,
          primaryMedicineName: '药品A',
          secondaryMedicineName: '药品B',
        ),
      );
      expect(
        find.text(l10n.medicineRiskCheckFindingTitleInteraction),
        findsOneWidget,
      );
    });

    testWidgets('renders duplicateIngredient finding title', (tester) async {
      await pumpTile(
        tester,
        finding: const MedicineRiskFinding(
          type: MedicineRiskFindingType.duplicateIngredient,
          severity: MedicineRiskSeverity.medium,
          context: MedicineRiskFindingContext.none,
          primaryMedicineName: '药品A',
          secondaryMedicineName: '药品B',
        ),
      );
      expect(
        find.text(l10n.medicineRiskCheckFindingTitleDuplicate),
        findsOneWidget,
      );
    });

    testWidgets('renders allergy finding title', (tester) async {
      await pumpTile(
        tester,
        finding: const MedicineRiskFinding(
          type: MedicineRiskFindingType.allergy,
          severity: MedicineRiskSeverity.high,
          context: MedicineRiskFindingContext.none,
          primaryMedicineName: '药品A',
          relatedLabel: '青霉素',
        ),
      );
      expect(
        find.text(l10n.medicineRiskCheckFindingTitleAllergy),
        findsOneWidget,
      );
    });

    testWidgets('renders severity badge label', (tester) async {
      await pumpTile(
        tester,
        finding: const MedicineRiskFinding(
          type: MedicineRiskFindingType.interaction,
          severity: MedicineRiskSeverity.high,
          context: MedicineRiskFindingContext.none,
          primaryMedicineName: '药品A',
        ),
      );
      expect(find.text(l10n.medicineRiskCheckSeverityHigh), findsOneWidget);
    });

    testWidgets('renders context badge for alcohol', (tester) async {
      await pumpTile(
        tester,
        finding: const MedicineRiskFinding(
          type: MedicineRiskFindingType.interaction,
          severity: MedicineRiskSeverity.high,
          context: MedicineRiskFindingContext.alcohol,
          primaryMedicineName: '药品A',
        ),
      );
      expect(find.text(l10n.medicineRiskCheckContextAlcohol), findsOneWidget);
    });

    testWidgets('does not render context badge for none', (tester) async {
      await pumpTile(
        tester,
        finding: const MedicineRiskFinding(
          type: MedicineRiskFindingType.interaction,
          severity: MedicineRiskSeverity.high,
          context: MedicineRiskFindingContext.none,
          primaryMedicineName: '药品A',
        ),
      );
      expect(find.text(l10n.medicineRiskCheckContextAlcohol), findsNothing);
    });

    testWidgets('renders evidence text when provided', (tester) async {
      await pumpTile(
        tester,
        finding: const MedicineRiskFinding(
          type: MedicineRiskFindingType.interaction,
          severity: MedicineRiskSeverity.high,
          context: MedicineRiskFindingContext.none,
          primaryMedicineName: '药品A',
          evidence: 'Custom evidence text',
        ),
      );
      expect(find.text('Custom evidence text'), findsOneWidget);
    });

    testWidgets('renders fallback evidence when null', (tester) async {
      await pumpTile(
        tester,
        finding: const MedicineRiskFinding(
          type: MedicineRiskFindingType.interaction,
          severity: MedicineRiskSeverity.high,
          context: MedicineRiskFindingContext.none,
          primaryMedicineName: '药品A',
          evidence: null,
        ),
      );
      expect(
        find.text(l10n.medicineRiskCheckFindingEvidenceFallback),
        findsOneWidget,
      );
    });

    testWidgets('renders divider when not last', (tester) async {
      await pumpTile(
        tester,
        isLast: false,
        finding: const MedicineRiskFinding(
          type: MedicineRiskFindingType.interaction,
          severity: MedicineRiskSeverity.high,
          context: MedicineRiskFindingContext.none,
          primaryMedicineName: '药品A',
        ),
      );
      expect(find.byType(AppDivider), findsOneWidget);
    });

    testWidgets('does not render divider when last', (tester) async {
      await pumpTile(
        tester,
        isLast: true,
        finding: const MedicineRiskFinding(
          type: MedicineRiskFindingType.interaction,
          severity: MedicineRiskSeverity.high,
          context: MedicineRiskFindingContext.none,
          primaryMedicineName: '药品A',
        ),
      );
      expect(find.byType(AppDivider), findsNothing);
    });
  });

  group('MedicineRiskCoverageIssueTile', () {
    Future<void> pumpTile(
      WidgetTester tester, {
      required MedicineRiskCoverageIssue issue,
      bool isLast = false,
    }) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: SingleChildScrollView(
            child: MedicineRiskCoverageIssueTile(
              issue: issue,
              isLast: isLast,
              l10n: l10n,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    testWidgets('renders medicine name', (tester) async {
      await pumpTile(
        tester,
        issue: const MedicineRiskCoverageIssue(
          medicineName: '某药品',
          reason: MedicineRiskCoverageReason.manualEntry,
        ),
      );
      expect(find.text('某药品'), findsOneWidget);
    });

    testWidgets('renders manualEntry reason label', (tester) async {
      await pumpTile(
        tester,
        issue: const MedicineRiskCoverageIssue(
          medicineName: '某药品',
          reason: MedicineRiskCoverageReason.manualEntry,
        ),
      );
      expect(
        find.text(l10n.medicineRiskCheckCoverageReasonManualEntry),
        findsOneWidget,
      );
    });

    testWidgets('renders missingSourceRef reason label', (tester) async {
      await pumpTile(
        tester,
        issue: const MedicineRiskCoverageIssue(
          medicineName: '某药品',
          reason: MedicineRiskCoverageReason.missingSourceRef,
        ),
      );
      expect(
        find.text(l10n.medicineRiskCheckCoverageReasonMissingSourceRef),
        findsOneWidget,
      );
    });

    testWidgets('renders detailUnavailable reason label', (tester) async {
      await pumpTile(
        tester,
        issue: const MedicineRiskCoverageIssue(
          medicineName: '某药品',
          reason: MedicineRiskCoverageReason.detailUnavailable,
        ),
      );
      expect(
        find.text(l10n.medicineRiskCheckCoverageReasonDetailUnavailable),
        findsOneWidget,
      );
    });

    testWidgets('renders divider when not last', (tester) async {
      await pumpTile(
        tester,
        isLast: false,
        issue: const MedicineRiskCoverageIssue(
          medicineName: '某药品',
          reason: MedicineRiskCoverageReason.manualEntry,
        ),
      );
      expect(find.byType(AppDivider), findsOneWidget);
    });

    testWidgets('does not render divider when last', (tester) async {
      await pumpTile(
        tester,
        isLast: true,
        issue: const MedicineRiskCoverageIssue(
          medicineName: '某药品',
          reason: MedicineRiskCoverageReason.manualEntry,
        ),
      );
      expect(find.byType(AppDivider), findsNothing);
    });
  });
}
