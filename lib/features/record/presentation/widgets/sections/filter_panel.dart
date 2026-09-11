import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/shared/copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordFilterPanel extends StatelessWidget {
  const RecordFilterPanel({
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
    final colors = context.theme.colors;
    return FCard(
      key: const Key('record-filter-panel'),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.recordFilterSectionTitle,
                    style: context.theme.typography.body.md.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (onFilterSelected != null)
                  FButton(
                    variant: FButtonVariant.ghost,
                    size: FButtonSizeVariant.xs,
                    mainAxisSize: MainAxisSize.min,
                    onPress: () => onFilterSelected!(null),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.recordFilterSelectAll,
                          style: TextStyle(
                            color: colors.foreground,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(width: Spacing.level1),
                        Icon(
                          SemanticIcons.statusAllDone,
                          size: IconSizeTokens.sm,
                          color: colors.foreground,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: Spacing.level4),
            Column(
              children: filters
                  .map(
                    (filter) => Padding(
                      padding: const EdgeInsets.only(bottom: Spacing.level3),
                      child: FilterRow(
                        filter: filter,
                        l10n: l10n,
                        onTap: onFilterSelected == null || filter.locked
                            ? null
                            : () => onFilterSelected!(
                                filter.selected ? null : filter.type,
                              ),
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

class FilterRow extends StatelessWidget {
  const FilterRow({
    super.key,
    required this.filter,
    required this.l10n,
    this.onTap,
  });

  final RecordFilter filter;
  final AppLocalizations l10n;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    final label = recordCopy(l10n, filter.titleKey);
    final typography = context.theme.typography;

    return FTappable(
      onPress: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.level2),
        child: Row(
          children: [
            Icon(
              filter.selected
                  ? SemanticIcons.statusSuccess
                  : SemanticIcons.statusPending,
              color: filter.selected
                  ? SemanticColor.primary.solid(context)
                  : SemanticColor.neutral.solid(context),
              size: IconSizeTokens.sm,
            ),
            const SizedBox(width: Spacing.level3),
            Icon(
              filter.icon,
              color: filter.accent.solid(context),
              size: IconSizeTokens.sm,
            ),
            const SizedBox(width: Spacing.level3),
            Expanded(
              child: Text(
                label,
                style: typography.body.md.copyWith(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (filter.locked)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: SemanticColor.neutral.subtle(context),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.level3,
                    vertical: Spacing.level2,
                  ),
                  child: Text(
                    l10n.recordNotEnabledLabel,
                    style: typography.body.xs.copyWith(
                      color: colors.foreground,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
