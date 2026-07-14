import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/features/mine/domain/entities/dashboard.dart';
import 'package:luminous/core/widgets/common/divider.dart';
import 'package:luminous/features/mine/presentation/widgets/sections/completeness_notice.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../helpers/test_forui_app.dart';

MineProfileSnapshot _profile({
  bool basicInfoCompleted = true,
  int allergyCount = 1,
  int currentMedicineCount = 1,
}) {
  return MineProfileSnapshot(
    age: 30,
    heightCm: 170.0,
    allergyCount: allergyCount,
    conditionCount: 0,
    currentMedicineCount: currentMedicineCount,
    basicInfoCompleted: basicInfoCompleted,
  );
}

void main() {
  Future<void> pumpNotice(
    WidgetTester tester,
    MineProfileSnapshot profile,
  ) async {
    await tester.pumpWidget(
      TestForuiApp(
        home: SingleChildScrollView(
          child: MineCompletenessNotice(profile: profile),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  group('MineCompletenessNotice', () {
    testWidgets('renders nothing when profile is complete', (tester) async {
      await pumpNotice(tester, _profile());

      expect(find.byType(MineCompletenessNotice), findsOneWidget);
      expect(find.byType(SizedBox), findsWidgets);
      // No gap rows rendered
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(find.text(l10n.mineCompletenessGapBasicInfo), findsNothing);
      expect(find.text(l10n.mineCompletenessGapAllergy), findsNothing);
      expect(find.text(l10n.mineCompletenessGapMedicine), findsNothing);
    });

    testWidgets('renders basicInfo gap when not completed', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpNotice(tester, _profile(basicInfoCompleted: false));

      expect(find.text(l10n.mineCompletenessGapTitle), findsOneWidget);
      expect(find.text(l10n.mineCompletenessGapBasicInfo), findsOneWidget);
    });

    testWidgets('renders allergy gap when count is zero', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpNotice(tester, _profile(allergyCount: 0));

      expect(find.text(l10n.mineCompletenessGapAllergy), findsOneWidget);
    });

    testWidgets('renders medicine gap when count is zero', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpNotice(tester, _profile(currentMedicineCount: 0));

      expect(find.text(l10n.mineCompletenessGapMedicine), findsOneWidget);
    });

    testWidgets('renders all three gaps when everything is missing', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpNotice(
        tester,
        _profile(
          basicInfoCompleted: false,
          allergyCount: 0,
          currentMedicineCount: 0,
        ),
      );

      expect(find.text(l10n.mineCompletenessGapBasicInfo), findsOneWidget);
      expect(find.text(l10n.mineCompletenessGapAllergy), findsOneWidget);
      expect(find.text(l10n.mineCompletenessGapMedicine), findsOneWidget);
    });

    testWidgets('renders section title', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpNotice(tester, _profile(basicInfoCompleted: false));

      expect(find.text(l10n.mineCompletenessGapTitle), findsOneWidget);
    });

    testWidgets('renders subtitle', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpNotice(tester, _profile(basicInfoCompleted: false));

      expect(find.text(l10n.mineCompletenessGapSubtitle), findsOneWidget);
    });

    testWidgets('renders action label for each gap', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpNotice(
        tester,
        _profile(basicInfoCompleted: false, allergyCount: 0),
      );

      // Each gap row has an action label
      expect(find.text(l10n.mineCompletenessGapAction), findsNWidgets(2));
    });

    testWidgets('renders alert icon', (tester) async {
      await pumpNotice(tester, _profile(basicInfoCompleted: false));

      expect(find.byIcon(FLucideIcons.circleAlert), findsOneWidget);
    });

    testWidgets('renders basicInfo icon (badge)', (tester) async {
      await pumpNotice(tester, _profile(basicInfoCompleted: false));

      expect(find.byIcon(FLucideIcons.badge), findsOneWidget);
    });

    testWidgets('renders allergy icon (droplets)', (tester) async {
      await pumpNotice(tester, _profile(allergyCount: 0));

      expect(find.byIcon(FLucideIcons.droplets), findsOneWidget);
    });

    testWidgets('renders medicine icon (pill)', (tester) async {
      await pumpNotice(tester, _profile(currentMedicineCount: 0));

      expect(find.byIcon(FLucideIcons.pill), findsOneWidget);
    });

    testWidgets('renders FCard', (tester) async {
      await pumpNotice(tester, _profile(basicInfoCompleted: false));

      expect(find.byType(FCard), findsOneWidget);
    });

    testWidgets('renders tappable rows for each gap', (tester) async {
      await pumpNotice(
        tester,
        _profile(basicInfoCompleted: false, allergyCount: 0),
      );

      // Each gap row has a GestureDetector (FTappable uses GestureDetector internally)
      expect(find.byIcon(FLucideIcons.badge), findsOneWidget);
      expect(find.byIcon(FLucideIcons.droplets), findsOneWidget);
    });

    testWidgets('renders AppDivider between gaps', (tester) async {
      await pumpNotice(
        tester,
        _profile(basicInfoCompleted: false, allergyCount: 0),
      );

      expect(find.byType(AppDivider), findsOneWidget);
    });
  });
}
