import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/search/domain/entities/search_entities.dart';
import 'package:luminous/features/search/presentation/providers/search_provider.dart';
import 'package:luminous/features/search/presentation/widgets/search_header_widgets.dart';
import 'package:luminous/l10n/app_localizations.dart';

class SearchResultTile extends StatelessWidget {
  const SearchResultTile({
    super.key,
    required this.result,
    required this.l10n,
    required this.typography,
    required this.surface,
    this.expandedAction = false,
    this.onTap,
    this.onAddToCurrentMedicines,
  });
  final MedicineSearchResult result;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final bool expandedAction;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCurrentMedicines;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: surface.canvas,
          borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
          border: Border.all(color: surface.hairline),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacingTokens.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(result.name, style: typography.displaySm),
                  ),
                  _SourceBadge(source: result.source, l10n: l10n),
                ],
              ),
              const SizedBox(height: AppSpacingTokens.xs),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      result.subtitle,
                      style: typography.bodySm.copyWith(color: surface.body),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacingTokens.xxs),
              Text(
                sourceRefLabel(l10n, result.source, result.id),
                style: typography.caption.copyWith(color: surface.mute),
              ),
              const SizedBox(height: AppSpacingTokens.md),
              Text(
                result.summary,
                style: typography.bodySm.copyWith(color: surface.body),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacingTokens.md),
              Wrap(
                spacing: AppSpacingTokens.sm,
                runSpacing: AppSpacingTokens.sm,
                children: [
                  ...result.tags.map(
                    (tag) => _TagPill(label: tag, surface: surface),
                  ),
                  _TagPill(
                    label:
                        '${l10n.medicineSearchMatchedBy}：${matchTypeLabel(l10n, result.matchType)}',
                    surface: surface,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacingTokens.md),
              Align(
                alignment: expandedAction
                    ? Alignment.center
                    : Alignment.centerRight,
                child: SizedBox(
                  width: expandedAction ? double.infinity : null,
                  child: FilledButton(
                    onPressed: onAddToCurrentMedicines,
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

class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.source, required this.l10n});
  final MedicineSearchSource source;
  final AppLocalizations l10n;
  @override
  Widget build(BuildContext context) {
    final isCn = source == MedicineSearchSource.cn;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isCn ? const Color(0xFFE7F8EF) : AppColorTokens.linkSoft,
        borderRadius: BorderRadius.circular(AppRadiusTokens.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.sm,
          vertical: AppSpacingTokens.xs,
        ),
        child: Text(
          sourceLabel(l10n, source),
          style: AppTypographyTokens.mobile(
            isCn ? const Color(0xFF0E9F6E) : AppColorTokens.linkDeep,
          ).caption,
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.label, required this.surface});
  final String label;
  final AppThemeSurface surface;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: surface.linkSoft.withValues(alpha: 0.58),
      borderRadius: BorderRadius.circular(AppRadiusTokens.sm),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.sm,
        vertical: AppSpacingTokens.xs,
      ),
      child: Text(
        label,
        style: AppTypographyTokens.mobile(surface.link).caption,
      ),
    ),
  );
}

class PreviewPanel extends StatelessWidget {
  const PreviewPanel({
    super.key,
    required this.state,
    required this.l10n,
    required this.typography,
    required this.surface,
  });
  final MedicineSearchState state;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  @override
  Widget build(BuildContext context) {
    final preview = state.detailPreview;
    return DecoratedBox(
      decoration: panelDecoration(surface),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.xl),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.medicineSearchPreviewTitle,
                style: typography.bodySmStrong,
              ),
              if (preview != null) ...[
                const SizedBox(height: AppSpacingTokens.lg),
                Text(preview.title, style: typography.bodyMdStrong),
                const SizedBox(height: AppSpacingTokens.md),
                if (preview.conditions.isNotEmpty) ...[
                  Text(
                    l10n.medicineSearchPreviewClinical,
                    style: typography.bodySmStrong.copyWith(
                      color: surface.mute,
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.sm),
                  ...preview.conditions.map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacingTokens.xxs,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: Icon(Icons.circle, size: 4),
                          ),
                          const SizedBox(width: AppSpacingTokens.sm),
                          Expanded(
                            child: Text(
                              c,
                              style: typography.bodySm.copyWith(
                                color: surface.body.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacingTokens.md),
                if (preview.checklist.isNotEmpty) ...[
                  Text(
                    l10n.medicineSearchPreviewSafety,
                    style: typography.bodySmStrong.copyWith(
                      color: surface.mute,
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.sm),
                  ...preview.checklist.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacingTokens.xxs,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: surface.link,
                          ),
                          const SizedBox(width: AppSpacingTokens.sm),
                          Expanded(
                            child: Text(
                              item,
                              style: typography.bodySm.copyWith(
                                color: surface.body,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
              if (preview == null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacingTokens.lg),
                  child: Text(
                    l10n.medicineSearchPreviewEmpty,
                    style: typography.bodySm.copyWith(color: surface.mute),
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
    required this.typography,
    required this.surface,
  });
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  @override
  Widget build(BuildContext context) {
    final actions = <(IconData, String)>[
      (Icons.manage_search_rounded, l10n.medicineSearchNoResultKeyword),
      (Icons.swap_horiz_rounded, l10n.medicineSearchNoResultSwitch),
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface.canvas,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        border: Border.all(color: surface.hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.lg),
        child: Column(
          children: [
            Text(
              l10n.medicineSearchNoResultTitle,
              style: typography.bodyMdStrong,
            ),
            const SizedBox(height: AppSpacingTokens.md),
            Row(
              children: actions
                  .map(
                    (item) => Expanded(
                      child: _NoResultAction(
                        icon: item.$1,
                        label: item.$2,
                        typography: typography,
                        surface: surface,
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
  const _NoResultAction({
    required this.icon,
    required this.label,
    required this.typography,
    required this.surface,
  });
  final IconData icon;
  final String label;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(AppSpacingTokens.sm),
    child: Column(
      children: [
        Icon(icon, color: surface.link),
        const SizedBox(height: AppSpacingTokens.xs),
        Text(label, textAlign: TextAlign.center, style: typography.caption),
      ],
    ),
  );
}

BoxDecoration panelDecoration(AppThemeSurface surface) => BoxDecoration(
  color: surface.canvas,
  borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
  border: Border.all(color: surface.hairline),
  boxShadow: AppShadowTokens.level1,
);

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
