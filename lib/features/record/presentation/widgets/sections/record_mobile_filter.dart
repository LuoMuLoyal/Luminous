import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/shared/record_dashboard_tokens.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordMobileFilter extends StatelessWidget {
  const RecordMobileFilter({
    super.key,
    required this.filters,
    required this.l10n,
    this.onFilterSelected,
  });

  final List<RecordFilter> filters;
  final AppLocalizations l10n;
  final ValueChanged<RecordEntryType?>? onFilterSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final allSelected = filters.every((filter) => filter.selected);

    return Column(
      key: const Key('record-filter-chips'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.recordFilterMobileTitle,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        Wrap(
          spacing: AppSpacingTokens.xs,
          runSpacing: AppSpacingTokens.xs,
          children: [
            _FilterChip(
              chipKey: const Key('record-filter-all'),
              label: l10n.recordFilterAllAction,
              color: Color(0xFF0F766E),
              selected: allSelected,
              locked: false,
              onTap: onFilterSelected == null
                  ? null
                  : () => onFilterSelected!(null),
            ),
            for (final filter in filters)
              _FilterChip(
                chipKey: Key('record-filter-${filter.type.name}'),
                label: mobileFilterLabel(l10n, filter),
                color: filter.accent,
                selected: filter.selected,
                locked: filter.locked,
                onTap: filter.locked || onFilterSelected == null
                    ? null
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
    required this.onTap,
  });

  final Key chipKey;
  final String label;
  final Color color;
  final bool selected;
  final bool locked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
    final foreground = selected ? color : colors.foreground;

    return Material(
      key: chipKey,
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.1) : colors.background,
            borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
            border: Border.all(color: selected ? color : colors.border),
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
                  style: textTheme.labelLarge?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (locked) ...[
                  const SizedBox(width: AppSpacingTokens.xs),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.secondary.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(AppRadiusTokens.sm),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacingTokens.xs,
                        vertical: 2,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.recordNotEnabledLabel,
                        style: textTheme.labelSmall?.copyWith(
                          color: colors.foreground,
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
