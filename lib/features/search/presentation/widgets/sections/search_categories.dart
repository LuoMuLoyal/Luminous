import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/features/search/domain/entities/search_entities.dart';
import 'package:luminous/l10n/app_localizations.dart';

class Categories extends StatelessWidget {
  const Categories({
    super.key,
    required this.categories,
    required this.l10n,
    this.onCategorySelected,
  });
  final List<MedicineSearchCategory> categories;
  final AppLocalizations l10n;
  final ValueChanged<MedicineSearchCategory>? onCategorySelected;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.medicineSearchCategoryTitle,
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacingTokens.level4),
        Row(
          children: categories
              .map(
                (category) => Expanded(
                  child: _CategoryItem(
                    category: category,
                    l10n: l10n,
                    onTap: () => onCategorySelected?.call(category),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({required this.category, required this.l10n, this.onTap});
  final MedicineSearchCategory category;
  final AppLocalizations l10n;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap:
            onTap ??
            () => AppToast.show(context, categoryLabel(l10n, category.type)),
        borderRadius: BorderRadius.circular(AppRadiusTokens.level4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.level2),
          child: Column(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: category.softColor.withValues(alpha: 0.74),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacingTokens.level3),
                  child: Icon(category.icon, color: category.accent),
                ),
              ),
              const SizedBox(height: AppSpacingTokens.level3),
              Text(
                categoryLabel(l10n, category.type),
                style: textTheme.labelSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String categoryLabel(
  AppLocalizations l10n,
  MedicineSearchCategoryType type,
) => switch (type) {
  MedicineSearchCategoryType.painFever => l10n.medicineSearchCategoryPainFever,
  MedicineSearchCategoryType.coldCough => l10n.medicineSearchCategoryColdCough,
  MedicineSearchCategoryType.stomach => l10n.medicineSearchCategoryStomach,
  MedicineSearchCategoryType.supplement =>
    l10n.medicineSearchCategorySupplement,
  MedicineSearchCategoryType.chronic => l10n.medicineSearchCategoryChronic,
};
