import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/record/presentation/models/meal_analysis_view_data.dart';
import 'package:luminous/features/record/presentation/utils/meal_analysis_payload_parser.dart';

void main() {
  group('parseMealAnalysisViewData', () {
    test('returns null for null payload', () {
      expect(parseMealAnalysisViewData(null), isNull);
    });

    test('returns null for empty map', () {
      expect(parseMealAnalysisViewData({}), isNull);
    });

    test('returns null when both analysis and input are null', () {
      expect(
        parseMealAnalysisViewData({'mealAnalysis': null, 'mealInput': null}),
        isNull,
      );
    });

    test('parses complete payload with all fields', () {
      final result = parseMealAnalysisViewData({
        'mealAnalysis': {
          'analysisStatus': 'confirmed',
          'coverage': 'complete',
          'mealDescription': 'Rice with chicken',
          'mealCommentary': 'Balanced meal',
          'failureReason': null,
          'recognizedDishes': [
            {
              'dishKey': 'd1',
              'rawName': 'Chicken Rice',
              'normalizedDishName': 'chicken_rice',
            },
          ],
          'resolvedIngredients': [
            {
              'dishKey': 'd1',
              'ingredientName': 'Chicken',
              'matchedFoodName': 'Chicken breast',
            },
          ],
          'compositionMatches': [
            {
              'dishKey': 'd1',
              'ingredientName': 'Rice',
              'matchedFoodName': 'White rice',
              'matchMethod': 'exact',
            },
          ],
          'nutritionEstimate': {'energyKcal': 520, 'proteinG': 25},
        },
        'mealInput': {
          'recognizedDishes': [
            {'rawName': 'Chicken Rice'},
          ],
        },
      });

      expect(result, isNotNull);
      expect(result!.status, 'confirmed');
      expect(result.coverage, 'complete');
      expect(result.mealDescription, 'Rice with chicken');
      expect(result.mealCommentary, 'Balanced meal');
      expect(result.failureReason, isNull);
      expect(result.isEstimate, isFalse);

      // Recognized dishes
      expect(result.recognizedDishes.length, 1);
      expect(result.recognizedDishes.first.dishKey, 'd1');
      expect(result.recognizedDishes.first.rawName, 'Chicken Rice');
      expect(result.recognizedDishes.first.normalizedDishName, 'chicken_rice');
      expect(result.recognizedDishes.first.displayName, 'chicken_rice');

      // Resolved ingredients
      expect(result.resolvedIngredients.length, 1);
      expect(result.resolvedIngredients.first.dishKey, 'd1');
      expect(result.resolvedIngredients.first.ingredientName, 'Chicken');
      expect(
        result.resolvedIngredients.first.matchedFoodName,
        'Chicken breast',
      );

      // Composition matches
      expect(result.compositionMatches.length, 1);
      expect(result.compositionMatches.first.ingredientName, 'Rice');
      expect(result.compositionMatches.first.matchedFoodName, 'White rice');
      expect(result.compositionMatches.first.matchMethod, 'exact');

      // Nutrition estimate
      expect(result.nutritionEstimate, isNotNull);
      expect(result.nutritionEstimate!.energyKcal, 520);
      expect(result.nutritionEstimate!.proteinG, 25);

      // Input dishes
      expect(result.inputDishes.length, 1);
      expect(result.inputDishes.first.rawName, 'Chicken Rice');
    });

    test('isEstimate is true when status is unconfirmed', () {
      final result = parseMealAnalysisViewData({
        'mealAnalysis': {
          'analysisStatus': 'unconfirmed',
          'coverage': 'complete',
        },
      });

      expect(result!.isEstimate, isTrue);
    });

    test('isEstimate is true when coverage is not complete', () {
      final result = parseMealAnalysisViewData({
        'mealAnalysis': {'analysisStatus': 'confirmed', 'coverage': 'partial'},
      });

      expect(result!.isEstimate, isTrue);
    });

    test(
      'isEstimate is true when both status and coverage indicate estimate',
      () {
        final result = parseMealAnalysisViewData({
          'mealAnalysis': {
            'analysisStatus': 'unconfirmed',
            'coverage': 'partial',
          },
        });

        expect(result!.isEstimate, isTrue);
      },
    );

    test(
      'isEstimate is false when status is confirmed and coverage is complete',
      () {
        final result = parseMealAnalysisViewData({
          'mealAnalysis': {
            'analysisStatus': 'confirmed',
            'coverage': 'complete',
          },
        });

        expect(result!.isEstimate, isFalse);
      },
    );

    test('filters out nutritionEstimate with no values', () {
      final result = parseMealAnalysisViewData({
        'mealAnalysis': {
          'nutritionEstimate': {'energyKcal': null, 'proteinG': null},
        },
      });

      expect(result!.nutritionEstimate, isNull);
    });

    test('keeps nutritionEstimate when at least one value is present', () {
      final result = parseMealAnalysisViewData({
        'mealAnalysis': {
          'nutritionEstimate': {'energyKcal': 300, 'proteinG': null},
        },
      });

      expect(result!.nutritionEstimate, isNotNull);
      expect(result.nutritionEstimate!.energyKcal, 300);
      expect(result.nutritionEstimate!.proteinG, isNull);
    });

    test(
      'filters out recognized dishes without rawName or normalizedDishName',
      () {
        final result = parseMealAnalysisViewData({
          'mealAnalysis': {
            'recognizedDishes': [
              {'dishKey': 'd1'}, // no rawName or normalizedDishName
              {'dishKey': 'd2', 'rawName': 'Valid Dish'},
              {'normalizedDishName': 'normalized_only'},
            ],
          },
        });

        expect(result!.recognizedDishes.length, 2);
        expect(result.recognizedDishes[0].rawName, 'Valid Dish');
        expect(result.recognizedDishes[1].rawName, 'normalized_only');
      },
    );

    test('uses rawName as displayName when normalizedDishName is absent', () {
      final result = parseMealAnalysisViewData({
        'mealAnalysis': {
          'recognizedDishes': [
            {'rawName': 'Raw Dish Name'},
          ],
        },
      });

      expect(result!.recognizedDishes.first.rawName, 'Raw Dish Name');
      expect(result.recognizedDishes.first.normalizedDishName, isNull);
      expect(result.recognizedDishes.first.displayName, 'Raw Dish Name');
    });

    test('parses input dishes from mealInput when present', () {
      final result = parseMealAnalysisViewData({
        'mealInput': {
          'recognizedDishes': [
            {'rawName': 'Input Dish 1'},
            {'normalizedDishName': 'Input Dish 2'},
          ],
        },
      });

      expect(result!.inputDishes.length, 2);
      expect(result.inputDishes[0].rawName, 'Input Dish 1');
      expect(result.inputDishes[1].rawName, 'Input Dish 2');
    });

    test(
      'falls back to analysis recognizedDishes when input list is empty',
      () {
        final result = parseMealAnalysisViewData({
          'mealAnalysis': {
            'recognizedDishes': [
              {'rawName': 'From Analysis'},
            ],
          },
          'mealInput': {'recognizedDishes': []},
        });

        expect(result!.inputDishes.length, 1);
        expect(result.inputDishes.first.rawName, 'From Analysis');
      },
    );

    test(
      'falls back to analysis recognizedDishes when input has no recognizedDishes',
      () {
        final result = parseMealAnalysisViewData({
          'mealAnalysis': {
            'recognizedDishes': [
              {'normalizedDishName': 'Analysis Dish'},
            ],
          },
          'mealInput': {},
        });

        expect(result!.inputDishes.length, 1);
        expect(result.inputDishes.first.rawName, 'Analysis Dish');
      },
    );

    test('filters out input dishes without rawName and normalizedDishName', () {
      final result = parseMealAnalysisViewData({
        'mealInput': {
          'recognizedDishes': [
            {'dishKey': 'd1'}, // no rawName or normalizedDishName
            {'rawName': 'Valid'},
          ],
        },
      });

      expect(result!.inputDishes.length, 1);
      expect(result.inputDishes.first.rawName, 'Valid');
    });

    test('filters out resolved ingredients without ingredientName', () {
      final result = parseMealAnalysisViewData({
        'mealAnalysis': {
          'resolvedIngredients': [
            {'dishKey': 'd1'}, // no ingredientName
            {'ingredientName': 'Salt', 'matchedFoodName': 'Table salt'},
          ],
        },
      });

      expect(result!.resolvedIngredients.length, 1);
      expect(result.resolvedIngredients.first.ingredientName, 'Salt');
      expect(result.resolvedIngredients.first.matchedFoodName, 'Table salt');
    });

    test('filters out composition matches without ingredientName', () {
      final result = parseMealAnalysisViewData({
        'mealAnalysis': {
          'compositionMatches': [
            {'dishKey': 'd1'}, // no ingredientName
            {
              'ingredientName': 'Sugar',
              'matchedFoodName': 'White sugar',
              'matchMethod': 'fuzzy',
            },
          ],
        },
      });

      expect(result!.compositionMatches.length, 1);
      expect(result.compositionMatches.first.ingredientName, 'Sugar');
      expect(result.compositionMatches.first.matchMethod, 'fuzzy');
    });

    test('returns empty lists when array fields are missing', () {
      final result = parseMealAnalysisViewData({
        'mealAnalysis': {'analysisStatus': 'confirmed'},
      });

      expect(result!.recognizedDishes, isEmpty);
      expect(result.resolvedIngredients, isEmpty);
      expect(result.compositionMatches, isEmpty);
      expect(result.inputDishes, isEmpty);
      expect(result.nutritionEstimate, isNull);
    });

    test('parses payload with only mealInput (no mealAnalysis)', () {
      final result = parseMealAnalysisViewData({
        'mealInput': {
          'recognizedDishes': [
            {'rawName': 'Input Only Dish'},
          ],
        },
      });

      expect(result, isNotNull);
      expect(result!.status, isNull);
      expect(result.coverage, isNull);
      expect(result.inputDishes.length, 1);
      expect(result.inputDishes.first.rawName, 'Input Only Dish');
    });

    test('handles non-map entries in arrays gracefully', () {
      final result = parseMealAnalysisViewData({
        'mealAnalysis': {
          'recognizedDishes': [
            'not a map',
            null,
            {'rawName': 'Valid'},
          ],
        },
      });

      expect(result!.recognizedDishes.length, 1);
      expect(result.recognizedDishes.first.rawName, 'Valid');
    });
  });

  group('parseMealDishDraftNames', () {
    test('returns empty list for null payload', () {
      expect(parseMealDishDraftNames(null), isEmpty);
    });

    test('returns empty list when no recognizedDishes', () {
      expect(parseMealDishDraftNames({}), isEmpty);
    });

    test('returns raw names from input dishes', () {
      final result = parseMealDishDraftNames({
        'mealInput': {
          'recognizedDishes': [
            {'rawName': 'Dish A'},
            {'normalizedDishName': 'Dish B'},
          ],
        },
      });

      expect(result, ['Dish A', 'Dish B']);
    });

    test('falls back to analysis recognizedDishes', () {
      final result = parseMealDishDraftNames({
        'mealAnalysis': {
          'recognizedDishes': [
            {'rawName': 'Analysis Dish'},
          ],
        },
      });

      expect(result, ['Analysis Dish']);
    });
  });

  group('MealNutritionViewData.hasAnyValue', () {
    test('returns false when both values are null', () {
      const data = MealNutritionViewData(energyKcal: null, proteinG: null);
      expect(data.hasAnyValue, isFalse);
    });

    test('returns true when energyKcal is present', () {
      const data = MealNutritionViewData(energyKcal: 100, proteinG: null);
      expect(data.hasAnyValue, isTrue);
    });

    test('returns true when proteinG is present', () {
      const data = MealNutritionViewData(energyKcal: null, proteinG: 20);
      expect(data.hasAnyValue, isTrue);
    });

    test('returns true when both values are present', () {
      const data = MealNutritionViewData(energyKcal: 100, proteinG: 20);
      expect(data.hasAnyValue, isTrue);
    });
  });

  group('MealDishViewData.displayName', () {
    test('returns normalizedDishName when available', () {
      const dish = MealDishViewData(
        dishKey: 'd1',
        rawName: 'raw',
        normalizedDishName: 'normalized',
      );
      expect(dish.displayName, 'normalized');
    });

    test('returns rawName when normalizedDishName is null', () {
      const dish = MealDishViewData(
        dishKey: 'd1',
        rawName: 'raw',
        normalizedDishName: null,
      );
      expect(dish.displayName, 'raw');
    });
  });
}
