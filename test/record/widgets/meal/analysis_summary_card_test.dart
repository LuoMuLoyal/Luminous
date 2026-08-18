import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/record/presentation/models/meal_analysis_view_data.dart';
import 'package:luminous/features/record/presentation/widgets/meal/analysis_summary_card.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../../helpers/test_forui_app.dart';

MealAnalysisViewData _mkData({
  String? status = 'confirmed',
  String? coverage,
  String? mealDescription,
  String? mealCommentary,
  bool isEstimate = false,
  List<MealDishViewData> recognizedDishes = const [],
  List<MealIngredientViewData> resolvedIngredients = const [],
  List<MealMatchViewData> compositionMatches = const [],
  MealNutritionViewData? nutritionEstimate,
}) {
  return MealAnalysisViewData(
    status: status,
    coverage: coverage,
    mealDescription: mealDescription,
    mealCommentary: mealCommentary,
    failureReason: null,
    isEstimate: isEstimate,
    recognizedDishes: recognizedDishes,
    resolvedIngredients: resolvedIngredients,
    compositionMatches: compositionMatches,
    nutritionEstimate: nutritionEstimate,
    inputDishes: const [],
  );
}

void main() {
  group('MealAnalysisSummaryCard', () {
    Future<void> pumpCard(
      WidgetTester tester,
      MealAnalysisViewData data, {
      VoidCallback? onConfirm,
      bool isConfirming = false,
    }) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: SingleChildScrollView(
            child: MealAnalysisSummaryCard(
              data: data,
              onConfirm: onConfirm,
              isConfirming: isConfirming,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    testWidgets('renders section title', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpCard(tester, _mkData());

      expect(find.text(l10n.recordMealAnalysisSectionTitle), findsOneWidget);
    });

    testWidgets('renders status badge', (tester) async {
      await pumpCard(tester, _mkData(status: 'analyzing'));

      expect(find.byIcon(SemanticIcons.statusPending), findsOneWidget);
    });

    testWidgets('renders meal description when non-empty', (tester) async {
      await pumpCard(tester, _mkData(mealDescription: '一顿丰盛的午餐'));

      expect(find.text('一顿丰盛的午餐'), findsOneWidget);
    });

    testWidgets('hides meal description when null', (tester) async {
      await pumpCard(tester, _mkData(mealDescription: null));

      // Section title should still be there
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(find.text(l10n.recordMealAnalysisSectionTitle), findsOneWidget);
    });

    testWidgets('renders recognized dishes section', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpCard(
        tester,
        _mkData(
          recognizedDishes: [
            const MealDishViewData(
              dishKey: 'k1',
              rawName: '西红柿炒鸡蛋',
              normalizedDishName: '番茄炒蛋',
            ),
          ],
        ),
      );

      expect(
        find.text(l10n.recordMealAnalysisRecognizedDishes),
        findsOneWidget,
      );
      expect(find.textContaining('番茄炒蛋'), findsOneWidget);
    });

    testWidgets('renders resolved ingredients section', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpCard(
        tester,
        _mkData(
          resolvedIngredients: [
            const MealIngredientViewData(
              dishKey: 'k1',
              ingredientName: '西红柿',
              matchedFoodName: '番茄',
            ),
          ],
        ),
      );

      expect(
        find.text(l10n.recordMealAnalysisResolvedIngredients),
        findsOneWidget,
      );
      expect(find.textContaining('西红柿 → 番茄'), findsOneWidget);
    });

    testWidgets('renders resolved ingredient without matched food name', (
      tester,
    ) async {
      await pumpCard(
        tester,
        _mkData(
          resolvedIngredients: [
            const MealIngredientViewData(
              dishKey: 'k1',
              ingredientName: '盐',
              matchedFoodName: null,
            ),
          ],
        ),
      );

      expect(find.textContaining('• 盐'), findsOneWidget);
    });

    testWidgets('renders composition matches section', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpCard(
        tester,
        _mkData(
          compositionMatches: [
            const MealMatchViewData(
              dishKey: 'k1',
              ingredientName: '鸡蛋',
              matchedFoodName: '鸡蛋',
              matchMethod: 'exact',
            ),
          ],
        ),
      );

      expect(
        find.text(l10n.recordMealAnalysisCompositionMatches),
        findsOneWidget,
      );
    });

    testWidgets('renders nutrition estimate section', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpCard(
        tester,
        _mkData(
          nutritionEstimate: const MealNutritionViewData(
            energyKcal: 500,
            proteinG: 20,
          ),
        ),
      );

      expect(
        find.text(l10n.recordMealAnalysisNutritionEstimate),
        findsOneWidget,
      );
      expect(
        find.textContaining(l10n.recordMealAnalysisNutritionEnergy),
        findsOneWidget,
      );
      expect(find.textContaining('500'), findsOneWidget);
    });

    testWidgets('renders protein in nutrition estimate', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpCard(
        tester,
        _mkData(
          nutritionEstimate: const MealNutritionViewData(
            energyKcal: null,
            proteinG: 15.5,
          ),
        ),
      );

      expect(
        find.textContaining(l10n.recordMealAnalysisNutritionProtein),
        findsOneWidget,
      );
      expect(find.textContaining('15.5g'), findsOneWidget);
    });

    testWidgets('renders meal commentary when non-empty', (tester) async {
      await pumpCard(
        tester,
        _mkData(mealCommentary: '  This meal is well balanced.  '),
      );

      expect(find.text('This meal is well balanced.'), findsOneWidget);
    });

    testWidgets('renders estimate disclaimer when isEstimate is true', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpCard(tester, _mkData(isEstimate: true));

      expect(
        find.text(l10n.recordMealAnalysisEstimateDisclaimer),
        findsOneWidget,
      );
    });

    testWidgets(
      'does not render estimate disclaimer when isEstimate is false',
      (tester) async {
        final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
        await pumpCard(tester, _mkData(isEstimate: false));

        expect(
          find.text(l10n.recordMealAnalysisEstimateDisclaimer),
          findsNothing,
        );
      },
    );

    testWidgets('renders multiple recognized dishes as bullet list', (
      tester,
    ) async {
      await pumpCard(
        tester,
        _mkData(
          recognizedDishes: [
            const MealDishViewData(
              dishKey: 'k1',
              rawName: 'A',
              normalizedDishName: null,
            ),
            const MealDishViewData(
              dishKey: 'k2',
              rawName: 'B',
              normalizedDishName: null,
            ),
            const MealDishViewData(
              dishKey: 'k3',
              rawName: 'C',
              normalizedDishName: null,
            ),
          ],
        ),
      );

      expect(find.textContaining('• A'), findsOneWidget);
      expect(find.textContaining('• B'), findsOneWidget);
      expect(find.textContaining('• C'), findsOneWidget);
    });

    testWidgets('uses rawName as displayName when normalizedDishName is null', (
      tester,
    ) async {
      await pumpCard(
        tester,
        _mkData(
          recognizedDishes: [
            const MealDishViewData(
              dishKey: 'k1',
              rawName: '原始菜名',
              normalizedDishName: null,
            ),
          ],
        ),
      );

      expect(find.textContaining('原始菜名'), findsOneWidget);
    });

    testWidgets('does not render confirm button when status is confirmed', (
      tester,
    ) async {
      await pumpCard(tester, _mkData(status: 'confirmed'), onConfirm: () {});

      expect(
        find.byKey(const Key('meal-analysis-confirm-action')),
        findsNothing,
      );
    });

    testWidgets(
      'renders confirm button for unconfirmed status with onConfirm',
      (tester) async {
        final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
        await pumpCard(
          tester,
          _mkData(status: 'unconfirmed'),
          onConfirm: () {},
        );

        final button = find.byKey(const Key('meal-analysis-confirm-action'));
        expect(button, findsOneWidget);
        expect(find.text(l10n.recordMealConfirmAction), findsOneWidget);
      },
    );

    testWidgets('does not render confirm button when onConfirm is null', (
      tester,
    ) async {
      await pumpCard(tester, _mkData(status: 'unconfirmed'));

      expect(
        find.byKey(const Key('meal-analysis-confirm-action')),
        findsNothing,
      );
    });

    testWidgets('disables confirm button and shows loading while confirming', (
      tester,
    ) async {
      await pumpCard(
        tester,
        _mkData(status: 'unconfirmed'),
        onConfirm: () {},
        isConfirming: true,
      );

      final button = find.byKey(const Key('meal-analysis-confirm-action'));
      expect(button, findsOneWidget);
      expect(tester.widget<FButton>(button).onPress, isNull);
      expect(find.byType(FCircularProgress), findsOneWidget);
    });

    testWidgets('invokes onConfirm when the confirm button is tapped', (
      tester,
    ) async {
      var confirmed = false;
      await pumpCard(
        tester,
        _mkData(status: 'unconfirmed'),
        onConfirm: () => confirmed = true,
      );

      await tester.tap(find.byKey(const Key('meal-analysis-confirm-action')));
      // Drain the FButton tappable animation timer before the test ends.
      await tester.pump(const Duration(milliseconds: 200));
      expect(confirmed, isTrue);
    });
  });
}
