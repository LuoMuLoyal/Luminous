import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/presentation/widgets/risk/red_flag.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../helpers/test_forui_app.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('zh'));
  });

  group('RiskRedFlagItem', () {
    Future<void> pumpItem(
      WidgetTester tester, {
      required RedFlagAlert alert,
    }) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: SingleChildScrollView(
            child: RiskRedFlagItem(alert: alert, l10n: l10n),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    testWidgets('renders severeAllergy alert text with allergen', (
      tester,
    ) async {
      await pumpItem(
        tester,
        alert: const RedFlagAlert(
          rule: RedFlagRule.severeAllergy,
          primaryMedicineName: '阿莫西林',
          relatedLabel: '青霉素',
        ),
      );
      expect(
        find.text(l10n.medicineRiskCheckRedFlagSevereAllergy('阿莫西林', '青霉素')),
        findsOneWidget,
      );
    });

    testWidgets('renders severeAllergy alert text without allergen', (
      tester,
    ) async {
      await pumpItem(
        tester,
        alert: const RedFlagAlert(
          rule: RedFlagRule.severeAllergy,
          primaryMedicineName: '阿莫西林',
        ),
      );
      expect(
        find.text(l10n.medicineRiskCheckRedFlagSevereAllergyGeneric('阿莫西林')),
        findsOneWidget,
      );
    });

    testWidgets('renders informationGap alert text', (tester) async {
      await pumpItem(
        tester,
        alert: const RedFlagAlert(
          rule: RedFlagRule.informationGap,
          primaryMedicineName: '未知药品',
        ),
      );
      expect(
        find.text(l10n.medicineRiskCheckRedFlagInformationGap('未知药品')),
        findsOneWidget,
      );
    });

    testWidgets('renders action text for severeAllergy', (tester) async {
      await pumpItem(
        tester,
        alert: const RedFlagAlert(
          rule: RedFlagRule.severeAllergy,
          primaryMedicineName: '阿莫西林',
          relatedLabel: '青霉素',
        ),
      );
      expect(
        find.text(l10n.medicineRiskCheckRedFlagActionSevereAllergy),
        findsOneWidget,
      );
    });

    testWidgets('renders action text for informationGap', (tester) async {
      await pumpItem(
        tester,
        alert: const RedFlagAlert(
          rule: RedFlagRule.informationGap,
          primaryMedicineName: '未知药品',
        ),
      );
      expect(
        find.text(l10n.medicineRiskCheckRedFlagActionInformationGap),
        findsOneWidget,
      );
    });
  });

  group('RiskRedFlagSection', () {
    Future<void> pumpSection(
      WidgetTester tester, {
      required List<RedFlagAlert> alerts,
    }) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: SingleChildScrollView(
            child: RiskRedFlagSection(alerts: alerts, l10n: l10n),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    testWidgets('renders section title', (tester) async {
      await pumpSection(
        tester,
        alerts: [
          const RedFlagAlert(
            rule: RedFlagRule.severeAllergy,
            primaryMedicineName: '药品A',
            relatedLabel: '青霉素',
          ),
        ],
      );
      expect(
        find.text(l10n.medicineRiskCheckRedFlagBannerTitle),
        findsOneWidget,
      );
    });

    testWidgets('renders multiple alert items', (tester) async {
      await pumpSection(
        tester,
        alerts: [
          const RedFlagAlert(
            rule: RedFlagRule.severeAllergy,
            primaryMedicineName: '药品A',
            relatedLabel: '青霉素',
          ),
          const RedFlagAlert(
            rule: RedFlagRule.informationGap,
            primaryMedicineName: '药品B',
          ),
        ],
      );
      expect(find.byType(RiskRedFlagItem), findsNWidgets(2));
    });

    testWidgets('renders zero items for empty list', (tester) async {
      await pumpSection(tester, alerts: const []);
      // Title still renders, but no items.
      expect(
        find.text(l10n.medicineRiskCheckRedFlagBannerTitle),
        findsOneWidget,
      );
      expect(find.byType(RiskRedFlagItem), findsNothing);
    });
  });
}
