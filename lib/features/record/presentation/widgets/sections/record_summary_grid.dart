import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/design/app_responsive_sizing.dart';
import 'package:luminous/core/widgets/common/app_icon_badge.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/shared/record_copy.dart';
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
    return FCard.raw(
      key: const Key('record-summary'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.lg),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const minTileWidth = 140.0;
            const spacing = AppSpacingTokens.sm;
            final maxColumns =
                ((constraints.maxWidth + spacing) / (minTileWidth + spacing))
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
    final textTheme = Theme.of(context).textTheme;
    final unit = item.unitKey == null ? null : recordCopy(l10n, item.unitKey!);
    final detail = item.detailKey == null
        ? null
        : recordCopy(l10n, item.detailKey!);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap == null ? null : () => onTap!(item.type),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
            border: Border.all(color: colors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppIconBadge(
                      icon: item.icon,
                      color: item.accent,
                      backgroundColor: item.softColor,
                      size: AppResponsiveSizing.scaleByWidth(
                        context,
                        fraction: 0.072,
                        minValue: 24,
                        maxValue: 32,
                      ),
                      iconSize: AppResponsiveSizing.scaleByWidth(
                        context,
                        fraction: 0.042,
                        minValue: 14,
                        maxValue: 18,
                      ),
                    ),
                    const SizedBox(width: AppSpacingTokens.sm),
                    Expanded(
                      child: Text(
                        recordCopy(l10n, item.titleKey),
                        style: textTheme.labelSmall?.copyWith(
                          color: colors.mutedForeground,
                        ),
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacingTokens.sm),
                if (item.value.isNotEmpty)
                  RichText(
                    text: TextSpan(
                      style: textTheme.headlineSmall?.copyWith(
                        color: colors.foreground,
                        fontWeight: FontWeight.w700,
                      ),
                      children: [
                        TextSpan(text: item.value),
                        if (unit != null)
                          TextSpan(
                            text: ' $unit',
                            style: textTheme.labelSmall?.copyWith(
                              color: colors.mutedForeground,
                            ),
                          ),
                      ],
                    ),
                  )
                else
                  Text(
                    detail ?? '',
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                if (detail != null && item.value.isNotEmpty) ...[
                  const SizedBox(height: AppSpacingTokens.xxs),
                  Text(
                    detail,
                    style: textTheme.labelSmall?.copyWith(color: item.accent),
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
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
