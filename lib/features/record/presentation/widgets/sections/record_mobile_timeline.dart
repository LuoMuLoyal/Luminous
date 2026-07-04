import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_colors.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/shared/record_copy.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/core/widgets/common/app_divider.dart';

class RecordMobileTimeline extends StatelessWidget {
  const RecordMobileTimeline({
    super.key,
    required this.entries,
    required this.totalCount,
    required this.l10n,
  });

  final List<RecordTimelineEntry> entries;
  final int totalCount;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('record-timeline'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.recordTodayEntriesTitle(totalCount),
          style: AppTypographyToken.level7
              .display(context)
              .copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacingTokens.level3),
        FCard.raw(
          child: Column(
            children: [
              for (var index = 0; index < entries.length; index += 1) ...[
                _TimelineRow(
                  index: index,
                  entry: entries[index],
                  l10n: l10n,
                  isLast: index == entries.length - 1,
                ),
                if (index < entries.length - 1) const AppDivider(),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.index,
    required this.entry,
    required this.l10n,
    required this.isLast,
  });

  final int index;
  final RecordTimelineEntry entry;
  final AppLocalizations l10n;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    final label = entry.rawTitle ?? recordCopy(l10n, entry.titleKey);
    final value = entry.valueKey == null
        ? entry.value
        : recordCopy(l10n, entry.valueKey!);
    final unit = entry.unitKey == null
        ? null
        : recordCopy(l10n, entry.unitKey!);
    final detail =
        entry.rawDetail ??
        (entry.detailKey == null ? null : recordCopy(l10n, entry.detailKey!));
    final subtitle = [
      if (value != null && value.isNotEmpty)
        unit == null ? value : '$value $unit',
      if (detail != null && detail.isNotEmpty) detail,
    ].join(' · ');

    return FTappable(
      key: entry.recordId == null
          ? null
          : Key('record-timeline-entry-${entry.recordId}'),
      onPress: entry.recordId != null
          ? () => pushAuthRequiredRoute(context, '/record/${entry.recordId}')
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.level4,
          vertical: AppSpacingTokens.level3,
        ),
        child: Row(
          children: [
            SizedBox(
              width: AppSpacingTokens.level8,
              child: AppSkeletonText(
                text: entry.time,
                style: AppTypographyToken.level3
                    .body(context)
                    .copyWith(color: colors.mutedForeground),
                widthFactor: 0.68,
                maxLines: 1,
              ),
            ),
            SizedBox(
              width: AppSpacingTokens.level5,
              child: Column(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: entry.accent.resolve(colors),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.background,
                        width: AppSpacingTokens.level1,
                      ),
                    ),
                    child: const SizedBox.square(
                      dimension: AppSpacingTokens.level3,
                    ),
                  ),
                  if (!isLast)
                    const SizedBox(
                      height: AppSpacingTokens.level8,
                      child: AppDivider(axis: Axis.vertical),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacingTokens.level3),
            Container(
              width: AppSpacingTokens.level8,
              height: AppSpacingTokens.level8,
              decoration: BoxDecoration(
                color: entry.softColor.resolve(colors),
                borderRadius: BorderRadius.circular(AppRadiusTokens.level4),
              ),
              child: Center(
                child: Icon(
                  entry.icon,
                  color: entry.accent.resolve(colors),
                  size: AppSpacingTokens.level5,
                ),
              ),
            ),
            const SizedBox(width: AppSpacingTokens.level4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSkeletonText(
                    text: label,
                    style: AppTypographyToken.level4
                        .body(context)
                        .copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    widthFactor: 0.64,
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: AppSpacingTokens.level1),
                    AppSkeletonText(
                      text: subtitle,
                      style: AppTypographyToken.level3
                          .body(context)
                          .copyWith(color: colors.mutedForeground),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      widthFactor: 0.78,
                    ),
                  ],
                ],
              ),
            ),
            if (entry.badgeKey != null) ...[
              const SizedBox(width: AppSpacingTokens.level2),
              AppSkeletonSlot(
                skeleton: AppInlineSkeletonBlock(
                  height:
                      (AppTypographyToken.level3.body(context).fontSize ?? 14) +
                      8,
                  widthFactor: 0.16,
                  radius: AppRadiusTokens.level2,
                ),
                child: FBadge.raw(
                  builder: (context, style) {
                    final resolvedColor = entry.accent.resolve(colors);
                    final foreground = 0.12 > 0.5
                        ? colors.primaryForeground
                        : resolvedColor;
                    return DecoratedBox(
                      decoration: ShapeDecoration(
                        color: resolvedColor.withValues(alpha: 0.12),
                        shape: RoundedSuperellipseBorder(
                          borderRadius: BorderRadius.circular(
                            AppRadiusTokens.level2,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacingTokens.level2,
                          vertical: AppSpacingTokens.level1,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              recordCopy(l10n, entry.badgeKey!),
                              style: AppTypographyToken.level3
                                  .body(context)
                                  .copyWith(
                                    color: foreground,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(width: AppSpacingTokens.level2),
            Icon(
              FLucideIcons.chevronRight,
              color: colors.mutedForeground,
              size: AppSpacingTokens.level5,
            ),
          ],
        ),
      ),
    );
  }
}
