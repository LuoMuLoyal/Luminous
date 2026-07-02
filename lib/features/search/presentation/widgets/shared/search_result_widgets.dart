import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/features/search/domain/entities/search_entities.dart';
import 'package:luminous/features/search/presentation/providers/search_provider.dart';
import 'package:luminous/features/search/presentation/widgets/search_header_widgets.dart';
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
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadiusTokens.level4),
        child: FCard.raw(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.level5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        result.name,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _SourceBadge(source: result.source, l10n: l10n),
                  ],
                ),
                const SizedBox(height: AppSpacingTokens.level2),
                Text(
                  result.subtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.mutedForeground,
                  ),
                ),
                const SizedBox(height: AppSpacingTokens.level1),
                Text(
                  sourceRefLabel(l10n, result.source, result.id),
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.mutedForeground,
                  ),
                ),
                const SizedBox(height: AppSpacingTokens.level4),
                Text(
                  result.summary,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.foreground,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacingTokens.level4),
                Wrap(
                  spacing: AppSpacingTokens.level3,
                  runSpacing: AppSpacingTokens.level3,
                  children: [
                    ...result.tags.map((tag) => _TagPill(label: tag)),
                    _TagPill(
                      label:
                          '${l10n.medicineSearchMatchedBy}：${matchTypeLabel(l10n, result.matchType)}',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacingTokens.level4),
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
        ),
      ),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.source, required this.l10n});

  final MedicineSearchSource source;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isCn = source == MedicineSearchSource.cn;
    final color = isCn ? const Color(0xFF0E9F6E) : Color(0xFF166534);
    final background = isCn ? const Color(0xFFE7F8EF) : Color(0xFFDCFCE7);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadiusTokens.level2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.level3,
          vertical: AppSpacingTokens.level2,
        ),
        child: Text(
          sourceLabel(l10n, source),
          style: textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadiusTokens.level2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.level3,
          vertical: AppSpacingTokens.level2,
        ),
        child: Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
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
    final textTheme = Theme.of(context).textTheme;

    return FCard.raw(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.level6),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.medicineSearchPreviewTitle,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (preview != null) ...[
                const SizedBox(height: AppSpacingTokens.level5),
                Text(
                  preview.title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacingTokens.level4),
                if (preview.conditions.isNotEmpty) ...[
                  Text(
                    l10n.medicineSearchPreviewClinical,
                    style: textTheme.labelLarge?.copyWith(
                      color: colors.mutedForeground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.level3),
                  ...preview.conditions.map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacingTokens.level1,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: Icon(FLucideIcons.dot, size: 12),
                          ),
                          const SizedBox(width: AppSpacingTokens.level3),
                          Expanded(
                            child: Text(
                              c,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colors.mutedForeground,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacingTokens.level4),
                if (preview.checklist.isNotEmpty) ...[
                  Text(
                    l10n.medicineSearchPreviewSafety,
                    style: textTheme.labelLarge?.copyWith(
                      color: colors.mutedForeground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.level3),
                  ...preview.checklist.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacingTokens.level1,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            FLucideIcons.badgeCheck,
                            size: 16,
                            color: colors.primary,
                          ),
                          const SizedBox(width: AppSpacingTokens.level3),
                          Expanded(
                            child: Text(item, style: textTheme.bodyMedium),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
              if (preview == null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacingTokens.level5),
                  child: Text(
                    l10n.medicineSearchPreviewEmpty,
                    style: textTheme.bodyMedium?.copyWith(
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
  const NoResultTools({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final actions = <(IconData, String)>[
      (FLucideIcons.search, l10n.medicineSearchNoResultKeyword),
      (FLucideIcons.arrowLeftRight, l10n.medicineSearchNoResultSwitch),
    ];
    final textTheme = Theme.of(context).textTheme;

    return FCard.raw(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.level5),
        child: Column(
          children: [
            Text(
              l10n.medicineSearchNoResultTitle,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacingTokens.level4),
            Row(
              children: actions
                  .map(
                    (item) => Expanded(
                      child: _NoResultAction(icon: item.$1, label: item.$2),
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
  const _NoResultAction({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacingTokens.level3),
      child: Column(
        children: [
          Icon(icon, color: colors.primary),
          const SizedBox(height: AppSpacingTokens.level2),
          Text(label, textAlign: TextAlign.center, style: textTheme.labelSmall),
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
