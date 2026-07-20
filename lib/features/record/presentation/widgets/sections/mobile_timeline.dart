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
import 'package:clock/clock.dart';
import 'package:luminous/core/utils/date_format_utils.dart';

class RecordMobileTimeline extends StatefulWidget {
  const RecordMobileTimeline({
    super.key,
    required this.entries,
    required this.totalCount,
    required this.l10n,
    this.selectedDate,
    this.initialVisibleCount = 7,
    this.hasActiveFilter = false,
    this.onClearFilter,
    this.onBackToToday,
  });

  final List<RecordTimelineEntry> entries;
  final int totalCount;
  final AppLocalizations l10n;
  final DateTime? selectedDate;
  final int initialVisibleCount;
  final bool hasActiveFilter;
  final VoidCallback? onClearFilter;
  final VoidCallback? onBackToToday;

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

    final isEmpty = widget.entries.isEmpty;
    final createDate = widget.selectedDate ?? DateTime.now();
    final isToday = _isSameDay(createDate, clock.now());
    final titleText = isToday
        ? widget.l10n.recordTodayEntriesTitle(widget.totalCount)
        : widget.l10n.recordDateEntriesTitle(
            formatDateLabel(createDate, Localizations.localeOf(context)),
            widget.totalCount,
          );

    return Column(
      key: const Key('record-timeline'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                titleText,
                style: TypographyToken.level7
                    .display(context)
                    .copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            if (!isToday && widget.onBackToToday != null)
              FButton(
                key: const Key('record-back-to-today'),
                variant: FButtonVariant.ghost,
                size: FButtonSizeVariant.sm,
                mainAxisSize: MainAxisSize.min,
                onPress: widget.onBackToToday,
                child: Text(
                  widget.l10n.recordBackToTodayAction,
                  style: const TextStyle(fontWeight: FontWeight.w700),
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
        const SizedBox(height: Spacing.level3),
        if (isEmpty)
          _MobileTimelineEmptyState(
            l10n: widget.l10n,
            hasActiveFilter: widget.hasActiveFilter,
            onCreate: () => pushAuthRequiredRoute(
              context,
              '/record/create?date=${formatRecordDate(createDate)}',
            ),
            onClearFilter: widget.onClearFilter,
          )
        else
          FCard.raw(
            child: Column(
              children: [
                for (var index = 0; index < visibleEntries.length; index += 1)
                  _TimelineRow(
                    index: index,
                    entry: visibleEntries[index],
                    l10n: widget.l10n,
                    isLast: index == visibleEntries.length - 1,
                    selectedDate: widget.selectedDate,
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
    this.selectedDate,
  });

  final int index;
  final RecordTimelineEntry entry;
  final AppLocalizations l10n;
  final bool isLast;
  final DateTime? selectedDate;

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
        horizontal: Spacing.level4,
        vertical: Spacing.level3,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: Spacing.level8,
            child: AppSkeletonText(
              text: entry.time,
              style: TypographyToken.level3
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
                width: Spacing.level3,
                height: Spacing.level3,
                indicator: _TimelineDot(entry: entry),
                padding: const EdgeInsets.only(right: Spacing.level3),
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
                        '/record/create?date=${formatRecordDate(selectedDate ?? DateTime.now())}',
                      ),
                child: Row(
                  children: [
                    Container(
                      width: Spacing.level8,
                      height: Spacing.level8,
                      decoration: BoxDecoration(
                        color: entry.softColor.solid(context),
                        borderRadius: BorderRadius.circular(
                          RadiusTokens.level4,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          entry.icon,
                          color: entry.accent.solid(context),
                          size: Spacing.level5,
                        ),
                      ),
                    ),
                    const SizedBox(width: Spacing.level4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppSkeletonText(
                            text: label,
                            style: TypographyToken.level4
                                .body(context)
                                .copyWith(fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            widthFactor: 0.64,
                          ),
                          if (subtitle.isNotEmpty) ...[
                            const SizedBox(height: Spacing.level1),
                            AppSkeletonText(
                              text: subtitle,
                              style: TypographyToken.level3
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
                      const SizedBox(width: Spacing.level2),
                      AppSkeletonSlot(
                        skeleton: AppInlineSkeletonBlock(
                          height:
                              (TypographyToken.level3.body(context).fontSize ??
                                  14) +
                              8,
                          widthFactor: 0.16,
                          radius: RadiusTokens.level2,
                        ),
                        child: FBadge.raw(
                          builder: (context, style) {
                            return DecoratedBox(
                              decoration: ShapeDecoration(
                                color: colors.secondary,
                                shape: RoundedSuperellipseBorder(
                                  borderRadius: BorderRadius.circular(
                                    RadiusTokens.level2,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Spacing.level2,
                                  vertical: Spacing.level1,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      recordCopy(l10n, entry.badgeKey!),
                                      style: TypographyToken.level3
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
                    const SizedBox(width: Spacing.level2),
                    Icon(
                      FLucideIcons.chevronRight,
                      color: colors.mutedForeground,
                      size: Spacing.level5,
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
        color: entry.accent.solid(context),
        shape: BoxShape.circle,
        border: Border.all(color: colors.background, width: Spacing.level1),
      ),
      child: const SizedBox.square(dimension: Spacing.level3),
    );
  }
}

class _MobileTimelineEmptyState extends StatelessWidget {
  const _MobileTimelineEmptyState({
    required this.l10n,
    required this.onCreate,
    this.hasActiveFilter = false,
    this.onClearFilter,
  });

  final AppLocalizations l10n;
  final VoidCallback onCreate;
  final bool hasActiveFilter;
  final VoidCallback? onClearFilter;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return FCard.raw(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.level6,
          vertical: Spacing.level8,
        ),
        child: Column(
          children: [
            Icon(
              FLucideIcons.filePlus2,
              size: Spacing.level8,
              color: colors.mutedForeground,
            ),
            const SizedBox(height: Spacing.level4),
            Text(
              l10n.recordTimelineEmptyTitle,
              style: TypographyToken.level5
                  .body(context)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: Spacing.level1),
            Text(
              l10n.recordTimelineEmptyDescription,
              style: TypographyToken.level3
                  .body(context)
                  .copyWith(color: colors.mutedForeground),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.level5),
            FButton(
              variant: FButtonVariant.outline,
              size: FButtonSizeVariant.sm,
              mainAxisSize: MainAxisSize.min,
              onPress: onCreate,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(FLucideIcons.plus, size: 16),
                  const SizedBox(width: Spacing.level2),
                  Text(l10n.recordTimelineEmptyAction),
                ],
              ),
            ),
            if (hasActiveFilter && onClearFilter != null) ...[
              const SizedBox(height: Spacing.level3),
              FButton(
                variant: FButtonVariant.ghost,
                size: FButtonSizeVariant.sm,
                mainAxisSize: MainAxisSize.min,
                onPress: onClearFilter,
                child: Text(l10n.recordTimelineClearFilter),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
