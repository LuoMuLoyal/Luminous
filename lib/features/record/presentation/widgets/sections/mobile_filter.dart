import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/shared/dashboard_tokens.dart';
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
    final activeFilter = filters.where((f) => f.selected && !f.locked).toList();

    // Header: title or active-filter indicator.
    final header = allSelected
        ? Text(
            l10n.recordFilterMobileTitle,
            style: TypographyToken.level7
                .display(context)
                .copyWith(fontWeight: FontWeight.w800),
          )
        : Row(
            children: [
              Text(
                l10n.recordFilterActiveLabel(
                  activeFilter
                      .map((f) => mobileFilterLabel(l10n, f))
                      .join(' · '),
                ),
                style: TypographyToken.level7
                    .display(context)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              if (onFilterSelected != null)
                FButton(
                  variant: FButtonVariant.ghost,
                  size: FButtonSizeVariant.xs,
                  mainAxisSize: MainAxisSize.min,
                  onPress: () => onFilterSelected!(null),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        FLucideIcons.x,
                        size: Spacing.level4,
                        color: context.theme.colors.mutedForeground,
                      ),
                      const SizedBox(width: Spacing.level1),
                      Text(
                        l10n.recordFilterClearAction,
                        style: TextStyle(
                          color: context.theme.colors.mutedForeground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );

    return Column(
      key: const Key('record-filter-chips'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        const SizedBox(height: Spacing.level3),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: filters.length + (allSelected ? 0 : 1),
            separatorBuilder: (_, __) => const SizedBox(width: Spacing.level2),
            itemBuilder: (context, index) {
              // When a filter is active, prepend a "全部" chip.
              if (!allSelected && index == 0) {
                return _FilterChip(
                  chipKey: const Key('record-filter-all'),
                  label: l10n.recordFilterAllAction,
                  icon: null,
                  selected: false,
                  onTap: onFilterSelected == null
                      ? null
                      : () => onFilterSelected!(null),
                );
              }
              final filterIndex = allSelected ? index : index - 1;
              final filter = filters[filterIndex];
              return _FilterChip(
                chipKey: Key('record-filter-${filter.type.name}'),
                label: mobileFilterLabel(l10n, filter),
                icon: filter.icon,
                selected: filter.selected,
                onTap: filter.locked || onFilterSelected == null
                    ? null
                    : () => onFilterSelected!(filter.type),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.chipKey,
    required this.label,
    required this.icon,
    required this.selected,
    this.onTap,
  });

  final Key chipKey;
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fontSize = context.theme.typography.body.xs.fontSize;
    return FButton(
      key: chipKey,
      onPress: onTap,
      variant: FButtonVariant.outline,
      selected: selected,
      size: FButtonSizeVariant.xs,
      mainAxisSize: MainAxisSize.min,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: fontSize,
              // Let FButton's IconTheme/DefaultTextStyle provide the correct
              // contrast color based on the button's selected state.
            ),
            const SizedBox(width: Spacing.level1),
          ],
          Text(label, style: TextStyle(fontSize: fontSize)),
        ],
      ),
    );
  }
}
