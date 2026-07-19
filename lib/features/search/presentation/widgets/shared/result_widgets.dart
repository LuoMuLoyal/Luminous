import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/search/domain/entities/entities.dart';
import 'package:luminous/features/search/presentation/providers/medicine_search.dart';
import 'package:luminous/features/search/presentation/widgets/shared/header_widgets.dart';
import 'package:luminous/l10n/app_localizations.dart';

class SearchResultTile extends StatelessWidget {
  const SearchResultTile({
    super.key,
    required this.result,
    required this.l10n,
    this.expandedAction = false,
    this.onTap,
    this.onAddToCurrentMedicines,
  });

  final MedicineSearchResult result;
  final AppLocalizations l10n;
  final bool expandedAction;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCurrentMedicines;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    final card = FCard.raw(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    result.name,
                    style: typography.body.lg.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _SourceBadge(source: result.source, l10n: l10n),
              ],
            ),
            const SizedBox(height: Spacing.level2),
            Text(
              result.subtitle,
              style: typography.body.sm.copyWith(color: colors.mutedForeground),
            ),
            const SizedBox(height: Spacing.level1),
            Text(
              sourceRefLabel(l10n, result.source, result.id),
              style: typography.body.xs.copyWith(color: colors.mutedForeground),
            ),
            const SizedBox(height: Spacing.level4),
            Text(
              result.summary,
              style: typography.body.md.copyWith(color: colors.foreground),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: Spacing.level4),
            Wrap(
              spacing: Spacing.level3,
              runSpacing: Spacing.level3,
              children: [
                ...result.tags.map((tag) => _TagPill(label: tag)),
                _TagPill(
                  label:
                      '${l10n.medicineSearchMatchedBy}：${matchTypeLabel(l10n, result.matchType)}',
                ),
              ],
            ),
            const SizedBox(height: Spacing.level4),
            Align(
              alignment: expandedAction
                  ? Alignment.center
                  : Alignment.centerRight,
              child: SizedBox(
                width: expandedAction ? double.infinity : null,
                child: FButton(
                  onPress: onAddToCurrentMedicines,
                  child: Text(l10n.medicineSearchAddToBoxAction),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Only wrap in FTappable when an onTap callback is provided (desktop preview).
    // On mobile, the card is not tappable — the "Add to box" button is the
    // primary action, and tapping the card body has no visible result.
    return onTap != null ? FTappable(onPress: onTap, child: card) : card;
  }
}

class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.source, required this.l10n});

  final MedicineSearchSource source;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return FBadge(
      variant: FBadgeVariant.primary,
      style: .delta(
        decoration: .boxDelta(
          borderRadius: BorderRadius.circular(RadiusTokens.level2),
        ),
      ),
      child: Text(sourceLabel(l10n, source)),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return FBadge(
      variant: FBadgeVariant.primary,
      style: .delta(
        decoration: .boxDelta(
          color: SemanticColor.primary.muted(context),
          borderRadius: BorderRadius.circular(RadiusTokens.level2),
        ),
        contentStyle: .delta(labelTextStyle: .delta(color: colors.primary)),
      ),
      child: Text(label),
    );
  }
}

class PreviewPanel extends StatelessWidget {
  const PreviewPanel({super.key, required this.state, required this.l10n});

  final MedicineSearchState state;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final preview = state.detailPreview;
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return FCard.raw(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level6),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.medicineSearchPreviewTitle,
                style: typography.body.sm.copyWith(fontWeight: FontWeight.w700),
              ),
              if (preview != null) ...[
                const SizedBox(height: Spacing.level5),
                Text(
                  preview.title,
                  style: typography.body.md.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: Spacing.level4),
                if (preview.conditions.isNotEmpty) ...[
                  Text(
                    l10n.medicineSearchPreviewClinical,
                    style: typography.body.sm.copyWith(
                      color: colors.mutedForeground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: Spacing.level3),
                  ...preview.conditions.map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(bottom: Spacing.level1),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: Icon(FLucideIcons.dot, size: 12),
                          ),
                          const SizedBox(width: Spacing.level3),
                          Expanded(
                            child: Text(
                              c,
                              style: typography.body.md.copyWith(
                                color: colors.mutedForeground,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: Spacing.level4),
                if (preview.checklist.isNotEmpty) ...[
                  Text(
                    l10n.medicineSearchPreviewSafety,
                    style: typography.body.sm.copyWith(
                      color: colors.mutedForeground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: Spacing.level3),
                  ...preview.checklist.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: Spacing.level1),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            FLucideIcons.badgeCheck,
                            size: 16,
                            color: colors.primary,
                          ),
                          const SizedBox(width: Spacing.level3),
                          Expanded(
                            child: Text(item, style: typography.body.md),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
              if (preview == null)
                Padding(
                  padding: const EdgeInsets.only(top: Spacing.level5),
                  child: Text(
                    l10n.medicineSearchPreviewEmpty,
                    style: typography.body.md.copyWith(
                      color: colors.mutedForeground,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoResultTools extends StatelessWidget {
  const NoResultTools({
    super.key,
    required this.l10n,
    this.onClearQuery,
    this.onSwitchSource,
  });

  final AppLocalizations l10n;
  final VoidCallback? onClearQuery;
  final VoidCallback? onSwitchSource;

  @override
  Widget build(BuildContext context) {
    final actions = <(IconData, String, VoidCallback?)>[
      (FLucideIcons.search, l10n.medicineSearchNoResultKeyword, onClearQuery),
      (
        FLucideIcons.arrowLeftRight,
        l10n.medicineSearchNoResultSwitch,
        onSwitchSource,
      ),
    ];
    final typography = context.theme.typography;

    return FCard.raw(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level5),
        child: Column(
          children: [
            Text(
              l10n.medicineSearchNoResultTitle,
              style: typography.body.md.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: Spacing.level4),
            Row(
              children: actions
                  .map(
                    (item) => Expanded(
                      child: _NoResultAction(
                        icon: item.$1,
                        label: item.$2,
                        onTap: item.$3,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoResultAction extends StatelessWidget {
  const _NoResultAction({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return onTap != null
        ? FTappable(
            onPress: onTap,
            child: Padding(
              padding: const EdgeInsets.all(Spacing.level3),
              child: Column(
                children: [
                  Icon(icon, color: colors.primary),
                  const SizedBox(height: Spacing.level2),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: typography.body.xs,
                  ),
                ],
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(Spacing.level3),
            child: Column(
              children: [
                Icon(icon, color: colors.mutedForeground),
                const SizedBox(height: Spacing.level2),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: typography.body.xs.copyWith(
                    color: colors.mutedForeground,
                  ),
                ),
              ],
            ),
          );
  }
}

String matchTypeLabel(AppLocalizations l10n, MedicineSearchMatchType type) =>
    switch (type) {
      MedicineSearchMatchType.ingredient => l10n.medicineSearchMatchIngredient,
      MedicineSearchMatchType.name => l10n.medicineSearchMatchName,
    };

String sourceRefLabel(
  AppLocalizations l10n,
  MedicineSearchSource source,
  String id,
) => switch (source) {
  MedicineSearchSource.cn => l10n.medicineSearchSourceRefCn(id),
  MedicineSearchSource.drugbank => l10n.medicineSearchSourceRefDrugbank(id),
};
