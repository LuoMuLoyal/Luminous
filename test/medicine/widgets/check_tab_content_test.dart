import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/presentation/widgets/risk/check_tab_content.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../helpers/test_forui_app.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('zh'));
  });

  MedicineRiskCheckRecord buildRecord({
    MedicineRiskCheckResult? result,
    MedicineRiskCheckType checkType = MedicineRiskCheckType.static_,
    int riskScore = 50,
    MedicineRiskLevel riskLevel = MedicineRiskLevel.caution,
    bool stale = false,
  }) {
    return MedicineRiskCheckRecord(
      checkType: checkType,
      result: result ?? const MedicineRiskCheckResult(),
      riskScore: riskScore,
      riskLevel: riskLevel,
      stale: stale,
      createdAt: DateTime(2026, 7, 28, 10, 0),
      updatedAt: DateTime(2026, 7, 28, 10, 0),
    );
  }

  Future<void> pumpContent(
    WidgetTester tester, {
    MedicineRiskCheckRecord? record,
    MedicineRiskCheckType checkType = MedicineRiskCheckType.static_,
    bool llmUnavailable = false,
    bool isRunning = false,
  }) async {
    await tester.pumpWidget(
      TestForuiApp(
        home: SingleChildScrollView(
          child: CheckTabContent(
            record: record,
            checkType: checkType,
            l10n: l10n,
            onRunCheck: () {},
            isRunning: isRunning,
            llmUnavailable: llmUnavailable,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  group('CheckTabContent — null record states', () {
    testWidgets('static null record shows never-checked state', (tester) async {
      await pumpContent(
        tester,
        record: null,
        checkType: MedicineRiskCheckType.static_,
      );
      expect(find.text(l10n.medicineRiskCheckNeverChecked), findsOneWidget);
    });

    testWidgets('LLM null record shows LLM empty state', (tester) async {
      await pumpContent(
        tester,
        record: null,
        checkType: MedicineRiskCheckType.llm,
      );
      expect(find.text(l10n.medicineRiskCheckLlmEmptyTitle), findsOneWidget);
    });

    testWidgets('LLM unavailable shows unavailable state', (tester) async {
      await pumpContent(
        tester,
        record: null,
        checkType: MedicineRiskCheckType.llm,
        llmUnavailable: true,
      );
      expect(find.text(l10n.medicineRiskCheckLlmUnavailable), findsOneWidget);
    });
  });

  group('CheckTabContent — with record', () {
    testWidgets('renders risk score for safe result', (tester) async {
      await pumpContent(
        tester,
        record: buildRecord(
          riskScore: 10,
          riskLevel: MedicineRiskLevel.safe,
          result: const MedicineRiskCheckResult(
            currentMedicineCount: 3,
            checkedMedicineCount: 3,
          ),
        ),
      );
      expect(find.text('10'), findsOneWidget);
      expect(find.text(l10n.medicineRiskLevelSafe), findsOneWidget);
    });

    testWidgets(
      'renders safe state card when no findings and no coverage gaps',
      (tester) async {
        await pumpContent(
          tester,
          record: buildRecord(
            result: const MedicineRiskCheckResult(
              currentMedicineCount: 3,
              checkedMedicineCount: 3,
              findings: [],
              coverageIssues: [],
            ),
          ),
        );
        expect(
          find.text(l10n.medicineRiskCheckTierConfirmedSafe),
          findsOneWidget,
        );
      },
    );

    testWidgets('renders findings when present', (tester) async {
      await pumpContent(
        tester,
        record: buildRecord(
          riskLevel: MedicineRiskLevel.risk,
          result: const MedicineRiskCheckResult(
            currentMedicineCount: 2,
            checkedMedicineCount: 2,
            findings: [
              MedicineRiskFinding(
                type: MedicineRiskFindingType.interaction,
                severity: MedicineRiskSeverity.high,
                context: MedicineRiskFindingContext.none,
                primaryMedicineName: '药品A',
                secondaryMedicineName: '药品B',
              ),
            ],
          ),
        ),
      );
      // Both medicineRiskCheckFindingsLabel and medicineRiskCheckFindingsTitle
      // resolve to "风险提示" in zh, so the text appears in both the metric
      // grid label and the section title.
      expect(find.text(l10n.medicineRiskCheckFindingsTitle), findsWidgets);
      expect(
        find.text(l10n.medicineRiskCheckFindingTitleInteraction),
        findsOneWidget,
      );
    });

    testWidgets('renders coverage issues when present', (tester) async {
      await pumpContent(
        tester,
        record: buildRecord(
          result: const MedicineRiskCheckResult(
            currentMedicineCount: 2,
            checkedMedicineCount: 1,
            coverageIssues: [
              MedicineRiskCoverageIssue(
                medicineName: '某药品',
                reason: MedicineRiskCoverageReason.manualEntry,
              ),
            ],
          ),
        ),
      );
      expect(find.text(l10n.medicineRiskCheckCoverageTitle), findsOneWidget);
      expect(find.text('某药品'), findsOneWidget);
    });

    testWidgets('renders red flags when present', (tester) async {
      await pumpContent(
        tester,
        record: buildRecord(
          riskLevel: MedicineRiskLevel.danger,
          result: const MedicineRiskCheckResult(
            redFlags: [
              RedFlagAlert(
                rule: RedFlagRule.severeAllergy,
                primaryMedicineName: '阿莫西林',
                relatedLabel: '青霉素',
              ),
            ],
          ),
        ),
      );
      expect(
        find.text(l10n.medicineRiskCheckRedFlagBannerTitle),
        findsOneWidget,
      );
    });

    testWidgets('renders overall recommendation for LLM', (tester) async {
      await pumpContent(
        tester,
        checkType: MedicineRiskCheckType.llm,
        record: buildRecord(
          checkType: MedicineRiskCheckType.llm,
          result: const MedicineRiskCheckResult(
            overallRecommendation: '建议咨询医生',
          ),
        ),
      );
      expect(find.text(l10n.medicineRiskOverallRecommendation), findsOneWidget);
      expect(find.text('建议咨询医生'), findsOneWidget);
    });

    testWidgets('renders stale banner for stale LLM record', (tester) async {
      await pumpContent(
        tester,
        checkType: MedicineRiskCheckType.llm,
        record: buildRecord(checkType: MedicineRiskCheckType.llm, stale: true),
      );
      expect(find.text(l10n.medicineRiskCheckStaleBanner), findsOneWidget);
    });

    testWidgets('does not render safe card when findings exist', (
      tester,
    ) async {
      await pumpContent(
        tester,
        record: buildRecord(
          result: const MedicineRiskCheckResult(
            findings: [
              MedicineRiskFinding(
                type: MedicineRiskFindingType.interaction,
                severity: MedicineRiskSeverity.high,
                context: MedicineRiskFindingContext.none,
                primaryMedicineName: '药品A',
              ),
            ],
          ),
        ),
      );
      expect(find.text(l10n.medicineRiskCheckTierConfirmedSafe), findsNothing);
    });

    testWidgets('shows run button in tab header when not running', (
      tester,
    ) async {
      await pumpContent(tester, record: buildRecord(), isRunning: false);
      expect(find.text(l10n.medicineRiskCheckRunStatic), findsOneWidget);
    });
  });
}
