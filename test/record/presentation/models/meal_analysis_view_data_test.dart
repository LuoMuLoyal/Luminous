import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/record/presentation/models/meal_analysis_view_data.dart';

void main() {
  // ── MealDishViewData.displayName ──────────────────────────────
  group('MealDishViewData.displayName', () {
    test('returns normalizedDishName when it is non-null', () {
      const data = MealDishViewData(
        dishKey: 'd1',
        rawName: 'Raw Name',
        normalizedDishName: 'Normalized',
      );
      expect(data.displayName, 'Normalized');
    });

    test('returns rawName when normalizedDishName is null', () {
      const data = MealDishViewData(
        dishKey: 'd1',
        rawName: 'Raw Name',
        normalizedDishName: null,
      );
      expect(data.displayName, 'Raw Name');
    });

    test('returns rawName when normalizedDishName is empty string', () {
      // displayName uses ?? so empty string is non-null → returns ''
      const data = MealDishViewData(
        dishKey: 'd1',
        rawName: 'Raw Name',
        normalizedDishName: '',
      );
      expect(data.displayName, '');
    });
  });

  // ── MealNutritionViewData.hasAnyValue ─────────────────────────
  group('MealNutritionViewData.hasAnyValue', () {
    test('returns false when both energyKcal and proteinG are null', () {
      const data = MealNutritionViewData(energyKcal: null, proteinG: null);
      expect(data.hasAnyValue, isFalse);
    });

    test('returns true when only energyKcal is non-null', () {
      const data = MealNutritionViewData(energyKcal: 250, proteinG: null);
      expect(data.hasAnyValue, isTrue);
    });

    test('returns true when only proteinG is non-null', () {
      const data = MealNutritionViewData(energyKcal: null, proteinG: 10);
      expect(data.hasAnyValue, isTrue);
    });

    test('returns true when both are non-null', () {
      const data = MealNutritionViewData(energyKcal: 500, proteinG: 20);
      expect(data.hasAnyValue, isTrue);
    });

    test('returns true when energyKcal is zero (non-null)', () {
      const data = MealNutritionViewData(energyKcal: 0, proteinG: null);
      expect(data.hasAnyValue, isTrue);
    });

    test('returns true when proteinG is zero (non-null)', () {
      const data = MealNutritionViewData(energyKcal: null, proteinG: 0);
      expect(data.hasAnyValue, isTrue);
    });
  });

  // ── MealAnalysisViewData construction ─────────────────────────
  group('MealAnalysisViewData', () {
    test('can be constructed with all nullable fields null', () {
      const data = MealAnalysisViewData(
        status: null,
        coverage: null,
        mealDescription: null,
        mealCommentary: null,
        failureReason: null,
        isEstimate: false,
        recognizedDishes: [],
        resolvedIngredients: [],
        compositionMatches: [],
        nutritionEstimate: null,
        inputDishes: [],
      );
      expect(data.status, isNull);
      expect(data.coverage, isNull);
      expect(data.mealDescription, isNull);
      expect(data.mealCommentary, isNull);
      expect(data.failureReason, isNull);
      expect(data.isEstimate, isFalse);
      expect(data.recognizedDishes, isEmpty);
      expect(data.resolvedIngredients, isEmpty);
      expect(data.compositionMatches, isEmpty);
      expect(data.nutritionEstimate, isNull);
      expect(data.inputDishes, isEmpty);
    });

    test('can be constructed with all fields populated', () {
      const dish = MealDishViewData(
        dishKey: 'd1',
        rawName: 'Chicken',
        normalizedDishName: 'Grilled Chicken',
      );
      const ingredient = MealIngredientViewData(
        dishKey: 'd1',
        ingredientName: 'Salt',
        matchedFoodName: 'Sodium Chloride',
      );
      const match = MealMatchViewData(
        dishKey: 'd1',
        ingredientName: 'Salt',
        matchedFoodName: 'Sodium Chloride',
        matchMethod: 'exact',
      );
      const nutrition = MealNutritionViewData(energyKcal: 300, proteinG: 25);
      const draft = MealDishDraftViewData(rawName: 'Chicken');

      const data = MealAnalysisViewData(
        status: 'confirmed',
        coverage: 'complete',
        mealDescription: 'Grilled chicken with rice',
        mealCommentary: 'Balanced meal',
        failureReason: null,
        isEstimate: false,
        recognizedDishes: [dish],
        resolvedIngredients: [ingredient],
        compositionMatches: [match],
        nutritionEstimate: nutrition,
        inputDishes: [draft],
      );

      expect(data.status, 'confirmed');
      expect(data.coverage, 'complete');
      expect(data.mealDescription, 'Grilled chicken with rice');
      expect(data.mealCommentary, 'Balanced meal');
      expect(data.failureReason, isNull);
      expect(data.isEstimate, isFalse);
      expect(data.recognizedDishes, hasLength(1));
      expect(data.recognizedDishes.first.displayName, 'Grilled Chicken');
      expect(data.resolvedIngredients, hasLength(1));
      expect(data.resolvedIngredients.first.ingredientName, 'Salt');
      expect(data.compositionMatches, hasLength(1));
      expect(data.compositionMatches.first.matchMethod, 'exact');
      expect(data.nutritionEstimate, isNotNull);
      expect(data.nutritionEstimate!.hasAnyValue, isTrue);
      expect(data.inputDishes, hasLength(1));
      expect(data.inputDishes.first.rawName, 'Chicken');
    });
  });

  // ── MealDishDraftViewData ─────────────────────────────────────
  group('MealDishDraftViewData', () {
    test('stores rawName correctly', () {
      const draft = MealDishDraftViewData(rawName: 'Test Dish');
      expect(draft.rawName, 'Test Dish');
    });

    test('stores empty string rawName', () {
      const draft = MealDishDraftViewData(rawName: '');
      expect(draft.rawName, '');
    });
  });
}
