import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/record_components.dart';
import 'package:luminous/features/record/presentation/widgets/record_dashboard_tokens.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordMobileFilter extends StatelessWidget {
  const RecordMobileFilter({
    super.key,
    required this.filters,
    required this.l10n,
    required this.typography,
    required this.surface,
    this.onFilterSelected,
  });

  final List<RecordFilter> filters;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final ValueChanged<RecordEntryType?>? onFilterSelected;

  @override
  Widget build(BuildContext context) {
    final allSelected = filters.every((filter) => filter.selected);

    return Column(
      key: const Key('record-filter-chips'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.recordFilterMobileTitle, style: typography.displaySm),
        const SizedBox(height: AppSpacingTokens.sm),
        Wrap(
          spacing: AppSpacingTokens.xs,
          runSpacing: AppSpacingTokens.xs,
          children: [
            _FilterChip(
              chipKey: const Key('record-filter-all'),
              label: l10n.recordFilterAllAction,
              color: AppColorTokens.cyanDeep,
              selected: allSelected,
              locked: false,
              typography: typography,
              surface: surface,
              onTap: onFilterSelected == null
                  ? () => showRecordToast(context, l10n.recordFilterAllAction)
                  : () => onFilterSelected!(null),
            ),
            for (final filter in filters)
              _FilterChip(
                chipKey: Key('record-filter-${filter.type.name}'),
                label: mobileFilterLabel(l10n, filter),
                color: filter.accent,
                selected: filter.selected,
                locked: filter.locked,
                typography: typography,
                surface: surface,
                onTap: filter.locked || onFilterSelected == null
                    ? () => showRecordToast(
                        context,
                        mobileFilterLabel(l10n, filter),
                      )
                    : () => onFilterSelected!(filter.type),
              ),
          ],
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.chipKey,
    required this.label,
    required this.color,
    required this.selected,
    required this.locked,
    required this.typography,
    required this.surface,
    required this.onTap,
  });

  final Key chipKey;
  final String label;
  final Color color;
  final bool selected;
  final bool locked;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? color : surface.body;

    return Material(
      key: chipKey,
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.1) : surface.canvas,
            borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
            border: Border.all(color: selected ? color : surface.hairline),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacingTokens.md,
              vertical: AppSpacingTokens.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: typography.bodySmStrong.copyWith(color: foreground),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (locked) ...[
                  const SizedBox(width: AppSpacingTokens.xs),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: surface.canvasSoft2,
                      borderRadius: BorderRadius.circular(AppRadiusTokens.sm),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacingTokens.xs,
                        vertical: 2,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.recordNotEnabledLabel,
                        style: typography.caption.copyWith(
                          color: surface.body,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
