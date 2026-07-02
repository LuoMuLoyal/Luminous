import 'package:luminous/core/utils/type_conversion_utils.dart';
import 'package:luminous/features/record/presentation/models/meal_analysis_view_data.dart';

MealAnalysisViewData? parseMealAnalysisViewData(Map<String, dynamic>? payload) {
  if (payload == null) return null;
  final analysis = asMap(payload['mealAnalysis']);
  final input = asMap(payload['mealInput']);
  if (analysis == null && input == null) return null;

  final status = asString(analysis?['analysisStatus']);
  final coverage = asString(analysis?['coverage']);
  final recognizedDishes = _parseRecognizedDishes(analysis);
  final inputDishes = _parseInputDishes(input, analysis);
  final nutritionEstimate = _parseNutritionEstimate(
    analysis?['nutritionEstimate'],
  );

  return MealAnalysisViewData(
    status: status,
    coverage: coverage,
    mealDescription: asString(analysis?['mealDescription']),
    mealCommentary: asString(analysis?['mealCommentary']),
    failureReason: asString(analysis?['failureReason']),
    isEstimate: status == 'unconfirmed' || coverage != 'complete',
    recognizedDishes: recognizedDishes,
    resolvedIngredients: _parseResolvedIngredients(analysis),
    compositionMatches: _parseCompositionMatches(analysis),
    nutritionEstimate: nutritionEstimate?.hasAnyValue == true
        ? nutritionEstimate
        : null,
    inputDishes: inputDishes,
  );
}

List<String> parseMealDishDraftNames(Map<String, dynamic>? payload) {
  final data = parseMealAnalysisViewData(payload);
  if (data == null) return const <String>[];
  return data.inputDishes.map((item) => item.rawName).toList(growable: false);
}

List<MealDishViewData> _parseRecognizedDishes(Map<String, dynamic>? analysis) {
  final list = asList(analysis?['recognizedDishes']);
  return list
      .map(asMap)
      .whereType<Map<String, dynamic>>()
      .map((item) {
        final rawName = asString(item['rawName']);
        final normalized = asString(item['normalizedDishName']);
        final displayName = rawName ?? normalized;
        if (displayName == null) return null;
        return MealDishViewData(
          dishKey: asString(item['dishKey']),
          rawName: displayName,
          normalizedDishName: normalized,
        );
      })
      .whereType<MealDishViewData>()
      .toList(growable: false);
}

List<MealDishDraftViewData> _parseInputDishes(
  Map<String, dynamic>? input,
  Map<String, dynamic>? analysis,
) {
  final inputList = asList(input?['recognizedDishes']);
  final source = inputList.isNotEmpty
      ? inputList
      : asList(analysis?['recognizedDishes']);
  return source
      .map(asMap)
      .whereType<Map<String, dynamic>>()
      .map((item) {
        final rawName =
            asString(item['rawName']) ?? asString(item['normalizedDishName']);
        if (rawName == null) return null;
        return MealDishDraftViewData(rawName: rawName);
      })
      .whereType<MealDishDraftViewData>()
      .toList(growable: false);
}

List<MealIngredientViewData> _parseResolvedIngredients(
  Map<String, dynamic>? analysis,
) {
  final list = asList(analysis?['resolvedIngredients']);
  return list
      .map(asMap)
      .whereType<Map<String, dynamic>>()
      .map((item) {
        final ingredientName = asString(item['ingredientName']);
        if (ingredientName == null) return null;
        return MealIngredientViewData(
          dishKey: asString(item['dishKey']),
          ingredientName: ingredientName,
          matchedFoodName: asString(item['matchedFoodName']),
        );
      })
      .whereType<MealIngredientViewData>()
      .toList(growable: false);
}

List<MealMatchViewData> _parseCompositionMatches(
  Map<String, dynamic>? analysis,
) {
  final list = asList(analysis?['compositionMatches']);
  return list
      .map(asMap)
      .whereType<Map<String, dynamic>>()
      .map((item) {
        final ingredientName = asString(item['ingredientName']);
        if (ingredientName == null) return null;
        return MealMatchViewData(
          dishKey: asString(item['dishKey']),
          ingredientName: ingredientName,
          matchedFoodName: asString(item['matchedFoodName']),
          matchMethod: asString(item['matchMethod']),
        );
      })
      .whereType<MealMatchViewData>()
      .toList(growable: false);
}

MealNutritionViewData? _parseNutritionEstimate(Object? value) {
  final data = asMap(value);
  if (data == null) return null;
  return MealNutritionViewData(
    energyKcal: asNum(data['energyKcal']),
    proteinG: asNum(data['proteinG']),
  );
}
