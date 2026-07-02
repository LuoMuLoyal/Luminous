import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/features/record/presentation/models/meal_analysis_view_data.dart';
import 'package:luminous/features/record/presentation/widgets/meal/meal_analysis_status_badge.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MealAnalysisSummaryCard extends StatelessWidget {
  const MealAnalysisSummaryCard({super.key, required this.data});

  final MealAnalysisViewData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

    return FCard.raw(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.level5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.recordMealAnalysisSectionTitle,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                MealAnalysisStatusBadge(
                  status: data.status,
                  coverage: data.coverage,
                  large: true,
                ),
              ],
            ),
            if (_nonEmpty(data.mealDescription) != null) ...[
              const SizedBox(height: AppSpacingTokens.level3),
              Text(
                data.mealDescription!,
                style: textTheme.bodySmall?.copyWith(
                  color: colors.mutedForeground,
                ),
              ),
            ],
            if (data.recognizedDishes.isNotEmpty) ...[
              const SizedBox(height: AppSpacingTokens.level5),
              _SectionTitle(title: l10n.recordMealAnalysisRecognizedDishes),
              const SizedBox(height: AppSpacingTokens.level2),
              ...data.recognizedDishes.map(
                (dish) => _BulletText(text: dish.displayName),
              ),
            ],
            if (data.resolvedIngredients.isNotEmpty) ...[
              const SizedBox(height: AppSpacingTokens.level4),
              _SectionTitle(title: l10n.recordMealAnalysisResolvedIngredients),
              const SizedBox(height: AppSpacingTokens.level2),
              ...data.resolvedIngredients.map(
                (item) => _BulletText(
                  text: item.matchedFoodName == null
                      ? item.ingredientName
                      : '${item.ingredientName} -> ${item.matchedFoodName}',
                ),
              ),
            ],
            if (data.compositionMatches.isNotEmpty) ...[
              const SizedBox(height: AppSpacingTokens.level4),
              _SectionTitle(title: l10n.recordMealAnalysisCompositionMatches),
              const SizedBox(height: AppSpacingTokens.level2),
              ...data.compositionMatches.map(
                (item) => _BulletText(
                  text: item.matchedFoodName == null
                      ? item.ingredientName
                      : '${item.ingredientName} -> ${item.matchedFoodName}',
                ),
              ),
            ],
            if (data.nutritionEstimate != null) ...[
              const SizedBox(height: AppSpacingTokens.level4),
              _SectionTitle(title: l10n.recordMealAnalysisNutritionEstimate),
              const SizedBox(height: AppSpacingTokens.level2),
              if (data.nutritionEstimate!.energyKcal != null)
                _BulletText(
                  text:
                      '${l10n.recordMealAnalysisNutritionEnergy}: ${data.nutritionEstimate!.energyKcal}',
                ),
              if (data.nutritionEstimate!.proteinG != null)
                _BulletText(
                  text:
                      '${l10n.recordMealAnalysisNutritionProtein}: ${data.nutritionEstimate!.proteinG}g',
                ),
            ],
            if (_nonEmpty(data.mealCommentary) != null) ...[
              const SizedBox(height: AppSpacingTokens.level4),
              Text(
                data.mealCommentary!,
                style: textTheme.bodySmall?.copyWith(
                  color: colors.mutedForeground,
                ),
              ),
            ],
            if (data.isEstimate) ...[
              const SizedBox(height: AppSpacingTokens.level4),
              Text(
                l10n.recordMealAnalysisEstimateDisclaimer,
                style: textTheme.labelSmall?.copyWith(color: Color(0xFFB45309)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Text(
      title,
      style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _BulletText extends StatelessWidget {
  const _BulletText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacingTokens.level1),
      child: Text(
        '• $text',
        style: textTheme.bodySmall?.copyWith(color: colors.mutedForeground),
      ),
    );
  }
}

String? _nonEmpty(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}
