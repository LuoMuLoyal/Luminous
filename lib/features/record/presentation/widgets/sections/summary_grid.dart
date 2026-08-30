import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/shared/copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordSummaryGrid extends StatelessWidget {
  const RecordSummaryGrid({
    super.key,
    required this.summary,
    required this.l10n,
    this.onTypeSelected,
  });

  final RecordDaySummary summary;
  final AppLocalizations l10n;
  final ValueChanged<RecordEntryType>? onTypeSelected;

  @override
  Widget build(BuildContext context) {
    if (summary.items.isEmpty) {
      return const SizedBox.shrink();
    }

    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= Breakpoints.desktop;

    return FCard(
      key: const Key('record-summary'),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level5),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const minTileWidth = 160.0;
            const spacing = Spacing.level3;
            final maxColumns = isDesktop
                ? 4
                : ((constraints.maxWidth + spacing) / (minTileWidth + spacing))
                      .floor()
                      .clamp(1, 5);
            final tileWidth =
                (constraints.maxWidth - spacing * (maxColumns - 1)) /
                maxColumns;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: summary.items
                  .map(
                    (item) => SizedBox(
                      width: tileWidth,
                      child: _SummaryTile(
                        item: item,
                        l10n: l10n,
                        onTap: onTypeSelected,
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.item, required this.l10n, this.onTap});

  final RecordSummaryItem item;
  final AppLocalizations l10n;
  final ValueChanged<RecordEntryType>? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    final unit = item.unitKey == null ? null : recordCopy(l10n, item.unitKey!);
    final detail = item.detailKey == null
        ? null
        : recordCopy(l10n, item.detailKey!);

    return FTappable(
      onPress: onTap == null ? null : () => onTap!(item.type),
      child: FCard(
        style: .delta(
          decoration: .shapeDelta(
            color: colors.background,
            shape: RoundedSuperellipseBorder(
              side: BorderSide(color: SemanticColor.neutral.border(context)),
              borderRadius: context.theme.style.borderRadius.sm,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.level4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: item.softColor.solid(context),
                      borderRadius: context.theme.style.borderRadius.md,
                    ),
                    child: Center(
                      child: Icon(
                        item.icon,
                        color: item.accent.solid(context),
                        size: IconSizeTokens.level2,
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.level3),
                  Expanded(
                    child: Text(
                      recordCopy(l10n, item.titleKey),
                      style: context.theme.typography.body.xs.copyWith(
                        color: SemanticColor.neutral.solid(context),
                      ),
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.level3),
              if (item.value.isNotEmpty)
                RichText(
                  text: TextSpan(
                    style: context.theme.typography.display.lg.copyWith(
                      color: colors.foreground,
                      fontWeight: FontWeight.w700,
                    ),
                    children: [
                      TextSpan(text: item.value),
                      if (unit != null)
                        TextSpan(
                          text: ' $unit',
                          style: context.theme.typography.body.xs.copyWith(
                            color: SemanticColor.neutral.solid(context),
                          ),
                        ),
                    ],
                  ),
                )
              else
                Text(
                  detail ?? '',
                  style: context.theme.typography.body.md.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              if (detail != null && item.value.isNotEmpty) ...[
                const SizedBox(height: Spacing.level1),
                Text(
                  detail,
                  style: context.theme.typography.body.xs.copyWith(
                    color: item.accent.solid(context),
                  ),
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
