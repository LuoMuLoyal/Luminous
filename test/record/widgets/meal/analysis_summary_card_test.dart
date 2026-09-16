import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/features/record/presentation/models/meal_analysis_view_data.dart';
import 'package:luminous/features/record/presentation/widgets/meal/analysis_summary_card.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../../helpers/test_forui_app.dart';

MealAnalysisViewData _mkData({
  String? status = 'analyzed',
  String? failureReason,
  MealCalorieRangeViewData? calorieRange = const MealCalorieRangeViewData(
    min: 520,
    max: 780,
    bucket: 'medium',
  ),
  List<MealDishViewData> dishes = const [
    MealDishViewData(name: '红烧肉', source: 'model'),
    MealDishViewData(name: '青菜', source: 'user'),
  ],
  List<MealInsightViewData> items = const [
    MealInsightViewData(
      rank: 1,
      kind: 'fried',
      polarity: 'watch',
      headline: '油炸偏多',
      detail: '午饭油炸食品摄入偏多',
    ),
    MealInsightViewData(
      rank: 2,
      kind: 'vegetable',
      polarity: 'good',
      headline: '蔬菜丰富',
      detail: '蔬菜种类丰富',
    ),
  ],
}) {
  return MealAnalysisViewData(
    status: status,
    failureReason: failureReason,
    calorieRange: calorieRange,
    dishes: dishes,
    items: items,
  );
}

void main() {
  group('MealAnalysisSummaryCard', () {
    Future<void> pumpCard(
      WidgetTester tester,
      MealAnalysisViewData data, {
      VoidCallback? onRetry,
      bool isRetrying = false,
    }) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: SingleChildScrollView(
            child: MealAnalysisSummaryCard(
              data: data,
              onRetry: onRetry,
              isRetrying: isRetrying,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    testWidgets('renders the section title and status badge', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpCard(tester, _mkData());

      expect(find.text(l10n.recordMealAnalysisSectionTitle), findsOneWidget);
      expect(find.text(l10n.recordMealAnalysisStatusAnalyzed), findsOneWidget);
      expect(find.byType(FBadge), findsOneWidget);
    });

    testWidgets('renders the calorie interval without a single value', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpCard(tester, _mkData());

      expect(
        find.text(l10n.recordMealAnalysisCalorieRangeTitle),
        findsOneWidget,
      );
      expect(find.text('520–780 kcal'), findsOneWidget);
    });

    testWidgets('renders every finding in order with its detail', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpCard(tester, _mkData());

      expect(find.text(l10n.recordMealAnalysisInsightsTitle), findsOneWidget);
      expect(find.text('油炸偏多'), findsOneWidget);
      expect(find.text('午饭油炸食品摄入偏多'), findsOneWidget);
      expect(find.text('蔬菜丰富'), findsOneWidget);
      expect(find.text('蔬菜种类丰富'), findsOneWidget);
    });

    testWidgets('renders the editable dish list and its hint', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpCard(tester, _mkData());

      expect(find.text(l10n.recordMealAnalysisDishesTitle), findsOneWidget);
      expect(find.text('红烧肉'), findsOneWidget);
      expect(find.text('青菜'), findsOneWidget);
      expect(find.text(l10n.recordMealAnalysisDishesHint), findsOneWidget);
    });

    testWidgets('hides the interval, findings and dishes when analyzing', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpCard(
        tester,
        _mkData(
          status: 'analyzing',
          calorieRange: null,
          dishes: const [],
          items: const [],
        ),
      );

      expect(find.text(l10n.recordMealAnalysisAnalyzingHint), findsOneWidget);
      expect(find.text(l10n.recordMealAnalysisInsightsTitle), findsNothing);
      expect(find.text(l10n.recordMealAnalysisDishesTitle), findsNothing);
    });

    testWidgets('shows the localized failure copy and the retry action', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpCard(
        tester,
        _mkData(
          status: 'analysis_failed',
          failureReason: 'model_timeout',
          calorieRange: null,
          dishes: const [],
          items: const [],
        ),
        onRetry: () {},
      );

      expect(
        find.text(l10n.recordMealAnalysisFailureModelTimeout),
        findsOneWidget,
      );
      expect(find.text(l10n.recordMealAnalysisRetryAction), findsOneWidget);
      expect(
        find.byKey(const Key('meal-analysis-retry-action')),
        findsOneWidget,
      );
    });

    testWidgets('maps every failure reason code to its own copy', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      final cases = {
        'image_count_invalid': l10n.recordMealAnalysisFailureImageCount,
        'vision_unavailable': l10n.recordMealAnalysisFailureVisionUnavailable,
        'model_failed': l10n.recordMealAnalysisFailureModelFailed,
        'model_timeout': l10n.recordMealAnalysisFailureModelTimeout,
        'job_lost': l10n.recordMealAnalysisFailureJobLost,
        'invalid_output': l10n.recordMealAnalysisFailureInvalidOutput,
      };

      for (final entry in cases.entries) {
        await pumpCard(
          tester,
          _mkData(
            status: 'analysis_failed',
            failureReason: entry.key,
            calorieRange: null,
            dishes: const [],
            items: const [],
          ),
          onRetry: () {},
        );
        expect(find.text(entry.value), findsOneWidget);
      }
    });

    testWidgets('falls back to the generic copy for an unknown reason code', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpCard(
        tester,
        _mkData(
          status: 'analysis_failed',
          failureReason: 'something_new',
          calorieRange: null,
          dishes: const [],
          items: const [],
        ),
        onRetry: () {},
      );

      expect(
        find.text(l10n.recordMealAnalysisFailureModelFailed),
        findsOneWidget,
      );
    });

    testWidgets('hides the retry action while no callback is provided', (
      tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpCard(
        tester,
        _mkData(
          status: 'analysis_failed',
          failureReason: 'model_failed',
          calorieRange: null,
          dishes: const [],
          items: const [],
        ),
      );

      expect(find.text(l10n.recordMealAnalysisRetryAction), findsNothing);
    });

    testWidgets('disables the retry action while a retry is in flight', (
      tester,
    ) async {
      await pumpCard(
        tester,
        _mkData(
          status: 'analysis_failed',
          failureReason: 'model_failed',
          calorieRange: null,
          dishes: const [],
          items: const [],
        ),
        onRetry: () {},
        isRetrying: true,
      );

      final button = find.byKey(const Key('meal-analysis-retry-action'));
      expect(button, findsOneWidget);
      expect(tester.widget<FButton>(button).onPress, isNull);
      expect(find.byType(FCircularProgress), findsOneWidget);
    });

    testWidgets('invokes onRetry when the retry action is tapped', (
      tester,
    ) async {
      var retried = 0;
      await pumpCard(
        tester,
        _mkData(
          status: 'analysis_failed',
          failureReason: 'model_failed',
          calorieRange: null,
          dishes: const [],
          items: const [],
        ),
        onRetry: () => retried += 1,
      );

      await tester.ensureVisible(
        find.byKey(const Key('meal-analysis-retry-action')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('meal-analysis-retry-action')));
      // Drain the FButton tappable animation timer before the test ends.
      await tester.pump(const Duration(milliseconds: 200));

      expect(retried, 1);
    });
  });
}
