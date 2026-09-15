import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/record/presentation/models/meal_analysis_view_data.dart';

void main() {
  group('MealAnalysisViewData status', () {
    MealAnalysisViewData build(String status) => MealAnalysisViewData(
      status: status,
      failureReason: null,
      calorieRange: null,
      dishes: const [],
      items: const [],
    );

    test('exposes the three v2 statuses', () {
      expect(build('analyzing').isAnalyzing, isTrue);
      expect(build('analyzing').isAnalyzed, isFalse);
      expect(build('analyzed').isAnalyzed, isTrue);
      expect(build('analysis_failed').hasFailed, isTrue);
      expect(build('analysis_failed').isAnalyzing, isFalse);
    });

    test('headline is the first (most important) finding', () {
      const data = MealAnalysisViewData(
        status: 'analyzed',
        failureReason: null,
        calorieRange: null,
        dishes: [],
        items: [
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
      );

      expect(data.headline, '油炸偏多');
      expect(build('analyzed').headline, isNull);
    });
  });

  group('MealCalorieRangeViewData.coarseLabel', () {
    test('rounds both bounds to hundreds', () {
      const range = MealCalorieRangeViewData(
        min: 452,
        max: 748,
        bucket: 'medium',
      );
      expect(range.coarseLabel, '500–700');
    });

    test('keeps already-round bounds and clamps at zero', () {
      expect(
        const MealCalorieRangeViewData(
          min: 500,
          max: 800,
          bucket: 'medium',
        ).coarseLabel,
        '500–800',
      );
      expect(
        const MealCalorieRangeViewData(
          min: 0,
          max: 120,
          bucket: 'low',
        ).coarseLabel,
        '0–100',
      );
    });
  });

  group('MealDishViewData', () {
    test('flags user edits by source', () {
      expect(
        const MealDishViewData(name: '西兰花', source: 'user').isUserEdited,
        isTrue,
      );
      expect(
        const MealDishViewData(name: '红烧肉', source: 'model').isUserEdited,
        isFalse,
      );
      expect(
        const MealDishViewData(name: '红烧肉', source: null).isUserEdited,
        isFalse,
      );
    });
  });
}
