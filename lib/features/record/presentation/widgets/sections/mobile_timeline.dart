import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/presentation/utils/date_time_formatters.dart';
import 'package:luminous/features/record/presentation/widgets/shared/copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordMobileTimeline extends StatefulWidget {
  const RecordMobileTimeline({
    super.key,
    required this.entries,
    required this.totalCount,
    required this.l10n,
    this.initialVisibleCount = 7,
  });

  final List<RecordTimelineEntry> entries;
  final int totalCount;
  final AppLocalizations l10n;
  final int initialVisibleCount;

  @override
  State<RecordMobileTimeline> createState() => _RecordMobileTimelineState();
}

class _RecordMobileTimelineState extends State<RecordMobileTimeline> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final hasOverflow = widget.entries.length > widget.initialVisibleCount;
    final visibleEntries = _expanded || !hasOverflow
        ? widget.entries
        : widget.entries
              .take(widget.initialVisibleCount)
              .toList(growable: false);

    return Column(
      key: const Key('record-timeline'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.l10n.recordTodayEntriesTitle(widget.totalCount),
                style: AppTypographyToken.level7
                    .display(context)
                    .copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            if (hasOverflow)
              FButton(
                key: const Key('record-timeline-toggle'),
                variant: FButtonVariant.ghost,
                size: FButtonSizeVariant.sm,
                mainAxisSize: MainAxisSize.min,
                onPress: () => setState(() => _expanded = !_expanded),
                child: Text(
                  _expanded
                      ? widget.l10n.recordTimelineCollapseAction
                      : widget.l10n.recordTimelineViewAllAction,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacingTokens.level3),
        FCard.raw(
          child: Column(
            children: [
              for (var index = 0; index < visibleEntries.length; index += 1)
                _TimelineRow(
                  index: index,
                  entry: visibleEntries[index],
                  l10n: widget.l10n,
                  isLast: index == visibleEntries.length - 1,
                ),
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

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.level4,
        vertical: AppSpacingTokens.level3,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Expanded(
            child: TimelineTile(
              alignment: TimelineAlign.start,
              isFirst: index == 0,
              isLast: isLast,
              indicatorStyle: IndicatorStyle(
                width: AppSpacingTokens.level3,
                height: AppSpacingTokens.level3,
                indicator: _TimelineDot(entry: entry),
                padding: const EdgeInsets.only(right: AppSpacingTokens.level3),
                indicatorXY: 0.0,
              ),
              beforeLineStyle: LineStyle(color: colors.border, thickness: 1),
              afterLineStyle: LineStyle(color: colors.border, thickness: 1),
              endChild: FTappable(
                key: Key('record-timeline-entry-index-$index'),
                onPress: entry.recordId != null
                    ? () => pushAuthRequiredRoute(
                        context,
                        '/record/${entry.recordId}',
                      )
                    : () => pushAuthRequiredRoute(
                        context,
                        '/record/create?date=${formatRecordDate(DateTime.now())}',
                      ),
                child: Row(
                  children: [
                    Container(
                      width: AppSpacingTokens.level8,
                      height: AppSpacingTokens.level8,
                      decoration: BoxDecoration(
                        color: entry.softColor.resolve(colors),
                        borderRadius: BorderRadius.circular(
                          AppRadiusTokens.level4,
                        ),
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
                              (AppTypographyToken.level3
                                      .body(context)
                                      .fontSize ??
                                  14) +
                              8,
                          widthFactor: 0.16,
                          radius: AppRadiusTokens.level2,
                        ),
                        child: FBadge.raw(
                          builder: (context, style) {
                            return DecoratedBox(
                              decoration: ShapeDecoration(
                                color: colors.secondary,
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
                                            color: colors.foreground,
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
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineDot extends StatelessWidget {
  const _TimelineDot({required this.entry});

  final RecordTimelineEntry entry;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: entry.accent.resolve(colors),
        shape: BoxShape.circle,
        border: Border.all(
          color: colors.background,
          width: AppSpacingTokens.level1,
        ),
      ),
      child: const SizedBox.square(dimension: AppSpacingTokens.level3),
    );
  }
}
