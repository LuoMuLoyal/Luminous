class MealAnalysisViewData {
  const MealAnalysisViewData({
    required this.status,
    required this.coverage,
    required this.mealDescription,
    required this.mealCommentary,
    required this.failureReason,
    required this.isEstimate,
    required this.recognizedDishes,
    required this.resolvedIngredients,
    required this.compositionMatches,
    required this.nutritionEstimate,
    required this.inputDishes,
  });

  final String? status;
  final String? coverage;
  final String? mealDescription;
  final String? mealCommentary;
  final String? failureReason;
  final bool isEstimate;
  final List<MealDishViewData> recognizedDishes;
  final List<MealIngredientViewData> resolvedIngredients;
  final List<MealMatchViewData> compositionMatches;
  final MealNutritionViewData? nutritionEstimate;
  final List<MealDishDraftViewData> inputDishes;
}

class MealDishViewData {
  const MealDishViewData({
    required this.dishKey,
    required this.rawName,
    required this.normalizedDishName,
  });

  final String? dishKey;
  final String rawName;
  final String? normalizedDishName;

  String get displayName => normalizedDishName ?? rawName;
}

class MealIngredientViewData {
  const MealIngredientViewData({
    required this.dishKey,
    required this.ingredientName,
    required this.matchedFoodName,
  });

  final String? dishKey;
  final String ingredientName;
  final String? matchedFoodName;
}

class MealMatchViewData {
  const MealMatchViewData({
    required this.dishKey,
    required this.ingredientName,
    required this.matchedFoodName,
    required this.matchMethod,
  });

  final String? dishKey;
  final String ingredientName;
  final String? matchedFoodName;
  final String? matchMethod;
}

class MealNutritionViewData {
  const MealNutritionViewData({
    required this.energyKcal,
    required this.proteinG,
  });

  final num? energyKcal;
  final num? proteinG;

  bool get hasAnyValue => energyKcal != null || proteinG != null;
}

class MealDishDraftViewData {
  const MealDishDraftViewData({required this.rawName});

  final String rawName;
}
