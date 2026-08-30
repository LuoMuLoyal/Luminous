import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/record/presentation/models/meal_analysis_view_data.dart';
import 'package:luminous/features/record/presentation/widgets/meal/analysis_status_badge.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MealAnalysisSummaryCard extends StatelessWidget {
  const MealAnalysisSummaryCard({
    super.key,
    required this.data,
    this.onConfirm,
    this.isConfirming = false,
  });

  final MealAnalysisViewData data;

  /// Called when the user confirms the analysis result. Only rendered when
  /// [data.status] is the unconfirmed state and this callback is non-null,
  /// so the card stays a pure stateless display component testable in
  /// isolation.
  final VoidCallback? onConfirm;

  /// Whether a confirm request is in flight; disables the confirm button and
  /// shows a loading indicator instead of the label.
  final bool isConfirming;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.theme.typography;
    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.recordMealAnalysisSectionTitle,
                    style: typography.body.md.copyWith(
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
            if (_nonEmpty(data.mealDescription) case final mealDesc?) ...[
              const SizedBox(height: Spacing.level3),
              Text(
                mealDesc,
                style: typography.body.xs.copyWith(
                  color: SemanticColor.neutral.solid(context),
                ),
              ),
            ],
            if (data.recognizedDishes.isNotEmpty) ...[
              const SizedBox(height: Spacing.level5),
              _SectionTitle(title: l10n.recordMealAnalysisRecognizedDishes),
              const SizedBox(height: Spacing.level2),
              ...data.recognizedDishes.map(
                (dish) => _BulletText(text: dish.displayName),
              ),
            ],
            if (data.resolvedIngredients.isNotEmpty) ...[
              const SizedBox(height: Spacing.level4),
              _SectionTitle(title: l10n.recordMealAnalysisResolvedIngredients),
              const SizedBox(height: Spacing.level2),
              ...data.resolvedIngredients.map(
                (item) => _BulletText(
                  text: item.matchedFoodName == null
                      ? item.ingredientName
                      : '${item.ingredientName} ${l10n.recordMealAnalysisMatchArrow} ${item.matchedFoodName}',
                ),
              ),
            ],
            if (data.compositionMatches.isNotEmpty) ...[
              const SizedBox(height: Spacing.level4),
              _SectionTitle(title: l10n.recordMealAnalysisCompositionMatches),
              const SizedBox(height: Spacing.level2),
              ...data.compositionMatches.map(
                (item) => _BulletText(
                  text: item.matchedFoodName == null
                      ? item.ingredientName
                      : '${item.ingredientName} ${l10n.recordMealAnalysisMatchArrow} ${item.matchedFoodName}',
                ),
              ),
            ],
            if (data.nutritionEstimate case final nutrition?) ...[
              const SizedBox(height: Spacing.level4),
              _SectionTitle(title: l10n.recordMealAnalysisNutritionEstimate),
              const SizedBox(height: Spacing.level2),
              if (nutrition.energyKcal != null)
                _BulletText(
                  text:
                      '${l10n.recordMealAnalysisNutritionEnergy}: ${nutrition.energyKcal} ${l10n.recordMealAnalysisEnergyUnit}',
                ),
              if (nutrition.proteinG != null)
                _BulletText(
                  text:
                      '${l10n.recordMealAnalysisNutritionProtein}: ${nutrition.proteinG}g',
                ),
            ],
            if (_nonEmpty(data.mealCommentary) case final commentary?) ...[
              const SizedBox(height: Spacing.level4),
              Text(
                commentary,
                style: typography.body.xs.copyWith(
                  color: SemanticColor.neutral.solid(context),
                ),
              ),
            ],
            if (data.isEstimate) ...[
              const SizedBox(height: Spacing.level4),
              Text(
                l10n.recordMealAnalysisEstimateDisclaimer,
                style: typography.body.xs.copyWith(
                  color: SemanticColor.primary.solid(context),
                ),
              ),
            ],
            if (data.status == 'unconfirmed' && onConfirm != null) ...[
              const SizedBox(height: Spacing.level5),
              Align(
                alignment: Alignment.centerLeft,
                child: FButton(
                  key: const Key('meal-analysis-confirm-action'),
                  variant: FButtonVariant.outline,
                  onPress: isConfirming ? null : onConfirm,
                  prefix: isConfirming
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: FCircularProgress(),
                        )
                      : null,
                  child: Text(l10n.recordMealConfirmAction),
                ),
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
    return Text(
      title,
      style: context.theme.typography.body.md.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _BulletText extends StatelessWidget {
  const _BulletText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.level1),
      child: Text(
        '• $text',
        style: context.theme.typography.body.xs.copyWith(
          color: SemanticColor.neutral.solid(context),
        ),
      ),
    );
  }
}

String? _nonEmpty(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}
