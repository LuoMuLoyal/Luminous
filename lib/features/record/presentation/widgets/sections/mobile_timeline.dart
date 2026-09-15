import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/utils/date_format.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/presentation/utils/date_time_formatters.dart';
import 'package:luminous/features/record/presentation/widgets/shared/copy.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:timeline_tile/timeline_tile.dart';

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
                style: context.theme.typography.display.xl.copyWith(
                  fontWeight: FontWeight.w800,
                ),
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
        const SizedBox(height: Spacing.md),
        if (isEmpty)
          _MobileTimelineEmptyState(
            l10n: widget.l10n,
            hasActiveFilter: widget.hasActiveFilter,
            onCreate: () => pushAuthRequiredRoute(
              context,
              Uri(
                path: '/record/create',
                queryParameters: {'date': formatRecordDate(createDate)},
              ).toString(),
            ),
            onClearFilter: widget.onClearFilter,
          )
        else
          FCard(
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
    final badgeLabel = timelineBadgeLabel(l10n, entry);
    final typography = context.theme.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 44,
            child: Text(
              entry.time,
              style: typography.body.xs.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: TimelineTile(
              alignment: TimelineAlign.start,
              isFirst: index == 0,
              isLast: isLast,
              indicatorStyle: IndicatorStyle(
                width: Spacing.md,
                height: Spacing.md,
                indicator: _TimelineDot(entry: entry),
                padding: const EdgeInsets.only(right: Spacing.md),
                indicatorXY: 0.0,
              ),
              beforeLineStyle: LineStyle(
                color: SemanticColor.neutral.border(context),
                thickness: 1,
              ),
              afterLineStyle: LineStyle(
                color: SemanticColor.neutral.border(context),
                thickness: 1,
              ),
              endChild: FTappable(
                key: Key('record-timeline-entry-index-$index'),
                onPress: entry.recordId != null
                    ? () => pushAuthRequiredRoute(
                        context,
                        '/record/${entry.recordId}',
                      )
                    : () => pushAuthRequiredRoute(
                        context,
                        Uri(
                          path: '/record/create',
                          queryParameters: {
                            'date': formatRecordDate(
                              selectedDate ?? DateTime.now(),
                            ),
                          },
                        ).toString(),
                      ),
                child: Row(
                  children: [
                    Container(
                      width: Spacing.xl4,
                      height: Spacing.xl4,
                      decoration: BoxDecoration(
                        color: entry.softColor.muted(context),
                        borderRadius: context.theme.style.borderRadius.sm,
                      ),
                      child: Center(
                        child: Icon(
                          entry.icon,
                          color: entry.accent.solid(context),
                          size: Spacing.xl,
                        ),
                      ),
                    ),
                    const SizedBox(width: Spacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: typography.body.sm.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitle.isNotEmpty) ...[
                            const SizedBox(height: Spacing.xs),
                            Text(
                              subtitle,
                              style: typography.body.xs.copyWith(
                                color: SemanticColor.neutral.solid(context),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (badgeLabel != null) ...[
                      const SizedBox(width: Spacing.sm),
                      FBadge.raw(
                        builder: (context, style) {
                          return DecoratedBox(
                            decoration: ShapeDecoration(
                              color: colors.secondary,
                              shape: RoundedSuperellipseBorder(
                                borderRadius:
                                    context.theme.style.borderRadius.xs,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Spacing.sm,
                                vertical: Spacing.xs,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    badgeLabel,
                                    style: context.theme.typography.body.xs
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
                    ],
                    const SizedBox(width: Spacing.sm),
                    Icon(
                      SemanticIcons.actionNext,
                      color: SemanticColor.neutral.solid(context),
                      size: Spacing.xl,
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
        border: Border.all(color: colors.background, width: Spacing.xs),
      ),
      child: const SizedBox.square(dimension: Spacing.md),
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
    final typography = context.theme.typography;
    return FCard(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.xl2,
            vertical: Spacing.xl4,
          ),
          child: Column(
            children: [
              Icon(
                SemanticIcons.actionAdd,
                size: Spacing.xl4,
                color: SemanticColor.neutral.solid(context),
              ),
              const SizedBox(height: Spacing.lg),
              Text(
                l10n.recordTimelineEmptyTitle,
                style: typography.body.md.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                l10n.recordTimelineEmptyDescription,
                style: typography.body.xs.copyWith(
                  color: SemanticColor.neutral.solid(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.xl),
              FButton(
                variant: FButtonVariant.outline,
                size: FButtonSizeVariant.sm,
                mainAxisSize: MainAxisSize.min,
                onPress: onCreate,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      SemanticIcons.actionAdd,
                      size: IconSizeTokens.sm,
                    ),
                    const SizedBox(width: Spacing.sm),
                    Text(l10n.recordTimelineEmptyAction),
                  ],
                ),
              ),
              if (hasActiveFilter && onClearFilter != null) ...[
                const SizedBox(height: Spacing.md),
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
      ),
    );
  }
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
