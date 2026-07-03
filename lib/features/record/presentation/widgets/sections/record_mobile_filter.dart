import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_colors.dart';
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
    final allSelected = filters.every((filter) => filter.selected);

    return Column(
      key: const Key('record-filter-chips'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.recordFilterMobileTitle,
          style: AppTypographyToken.level7
              .display(context)
              .copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacingTokens.level3),
        Wrap(
          spacing: AppSpacingTokens.level2,
          runSpacing: AppSpacingTokens.level2,
          children: [
            _FilterChip(
              chipKey: const Key('record-filter-all'),
              label: l10n.recordFilterAllAction,
              color: AppColors.primary,
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
  final AppColors color;
  final bool selected;
  final bool locked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    final resolvedColor = color.resolve(colors);
    final foreground = selected ? resolvedColor : colors.foreground;

    return FButton.raw(
      key: chipKey,
      onPress: onTap,
      variant: FButtonVariant.outline,
      style: .delta(
        decoration: .delta([
          .all(
            .shapeDelta(
              color: selected
                  ? resolvedColor.withValues(alpha: 0.1)
                  : colors.background,
              shape: RoundedSuperellipseBorder(
                side: BorderSide(
                  color: selected ? resolvedColor : colors.border,
                ),
                borderRadius: context.theme.style.borderRadius.sm,
              ),
            ),
          ),
        ]),
        contentStyle: .delta(
          padding: .value(
            const EdgeInsets.symmetric(
              horizontal: AppSpacingTokens.level4,
              vertical: AppSpacingTokens.level2,
            ),
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypographyToken.level5
                .body(context)
                .copyWith(color: foreground, fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (locked) ...[
            const SizedBox(width: AppSpacingTokens.level2),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.secondary.withValues(alpha: 0.22),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacingTokens.level2,
                  vertical: 2,
                ),
                child: Text(
                  AppLocalizations.of(context)!.recordNotEnabledLabel,
                  style: AppTypographyToken.level3
                      .body(context)
                      .copyWith(color: colors.foreground),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
