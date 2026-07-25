import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/desktop_hover.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/presentation/utils/date_time_formatters.dart';
import 'package:luminous/features/record/presentation/widgets/shared/copy.dart';
import 'package:luminous/features/record/presentation/widgets/shared/timeline_drag_data.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:timeline_tile/timeline_tile.dart';

class RecordTimelinePanel extends StatelessWidget {
  const RecordTimelinePanel({
    super.key,
    required this.entries,
    required this.l10n,
    this.dense = false,
    this.onClearFilter,
    this.selectedDate,
    this.onRecordDateChange,
  });

  final List<RecordTimelineEntry> entries;
  final AppLocalizations l10n;
  final bool dense;
  final VoidCallback? onClearFilter;
  final DateTime? selectedDate;

  /// Called when the user drags a timeline card onto a calendar day.
  /// Receives the record ID and the new target date.
  /// Only invoked on desktop layouts; mobile uses tap-to-navigate.
  final void Function(String recordId, DateTime newDate)? onRecordDateChange;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return FCard(
      key: const Key('record-timeline'),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.recordTimelineSectionTitle,
                    style: TypographyToken.level5
                        .body(context)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                if (onClearFilter != null)
                  FButton(
                    variant: FButtonVariant.ghost,
                    size: FButtonSizeVariant.xs,
                    mainAxisSize: MainAxisSize.min,
                    onPress: onClearFilter!,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.recordAllTypesAction,
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
                          FLucideIcons.chevronDown,
                          size: Spacing.level4,
                          color: colors.foreground,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: Spacing.level4),
            if (entries.isEmpty)
              _DesktopTimelineEmptyState(
                l10n: l10n,
                onClearFilter: onClearFilter,
                onCreate: () => pushAuthRequiredRoute(
                  context,
                  '/record/create?date=${formatRecordDate(selectedDate ?? DateTime.now())}',
                ),
              )
            else
              Column(
                children: [
                  for (var index = 0; index < entries.length; index += 1)
                    _TimelineEntryRow(
                      index: index,
                      entry: entries[index],
                      l10n: l10n,
                      isLast: index == entries.length - 1,
                      dense: dense,
                      selectedDate: selectedDate,
                      onRecordDateChange: onRecordDateChange,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _TimelineEntryRow extends StatelessWidget {
  const _TimelineEntryRow({
    required this.index,
    required this.entry,
    required this.l10n,
    required this.isLast,
    required this.dense,
    this.selectedDate,
    this.onRecordDateChange,
  });

  final int index;
  final RecordTimelineEntry entry;
  final AppLocalizations l10n;
  final bool isLast;
  final bool dense;
  final DateTime? selectedDate;
  final void Function(String recordId, DateTime newDate)? onRecordDateChange;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: dense ? 44 : 56,
          child: Text(
            entry.time,
            style: TypographyToken.level3
                .body(context)
                .copyWith(color: colors.mutedForeground),
          ),
        ),
        Expanded(
          child: TimelineTile(
            alignment: TimelineAlign.start,
            isFirst: index == 0,
            isLast: isLast,
            indicatorStyle: IndicatorStyle(
              width: 10,
              height: 10,
              indicator: _TimelineDot(entry: entry, size: 10, borderWidth: 3),
              padding: const EdgeInsets.only(right: Spacing.level3),
              indicatorXY: 0.25,
            ),
            beforeLineStyle: LineStyle(color: colors.border, thickness: 1),
            afterLineStyle: LineStyle(color: colors.border, thickness: 1),
            endChild: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : Spacing.level4),
              child: _TimelineCard(
                entry: entry,
                index: index,
                l10n: l10n,
                dense: dense,
                selectedDate: selectedDate,
                onRecordDateChange: onRecordDateChange,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelineDot extends StatelessWidget {
  const _TimelineDot({
    required this.entry,
    required this.size,
    required this.borderWidth,
  });

  final RecordTimelineEntry entry;
  final double size;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: entry.accent.solid(context),
        shape: BoxShape.circle,
        border: Border.all(color: colors.background, width: borderWidth),
      ),
      child: SizedBox.square(dimension: size),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({
    required this.entry,
    required this.index,
    required this.l10n,
    required this.dense,
    this.selectedDate,
    this.onRecordDateChange,
  });

  final RecordTimelineEntry entry;
  final int index;
  final AppLocalizations l10n;
  final bool dense;
  final DateTime? selectedDate;
  final void Function(String recordId, DateTime newDate)? onRecordDateChange;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= Breakpoints.desktop;
    final canDrag =
        isDesktop && entry.recordId != null && onRecordDateChange != null;

    final cardWidget = _buildCard(context);

    if (!canDrag) {
      return FContextMenu.tiles(
        // ignore: sort_child_properties_last
        child: _buildTappable(context, cardWidget),
        menu: _buildContextMenu(context),
      );
    }

    return FContextMenu.tiles(
      // ignore: sort_child_properties_last
      child: Draggable<TimelineDragData>(
        data: TimelineDragData(recordId: entry.recordId!, entry: entry),
        affinity: Axis.vertical,
        feedback: _DragFeedback(
          entry: entry,
          l10n: l10n,
          maxWidth: width * 0.4,
        ),
        childWhenDragging: Opacity(opacity: 0.4, child: cardWidget),
        child: _buildTappable(context, cardWidget),
      ),
      menu: _buildContextMenu(context),
    );
  }

  Widget _buildTappable(BuildContext context, Widget child) {
    return FTappable(
      key: Key('record-timeline-entry-index-$index'),
      onPress: entry.recordId != null
          ? () => pushAuthRequiredRoute(context, '/record/${entry.recordId}')
          : () => pushAuthRequiredRoute(
              context,
              '/record/create?date=${formatRecordDate(selectedDate ?? DateTime.now())}',
            ),
      child: DesktopHoverCard(child: child),
    );
  }

  Widget _buildCard(BuildContext context) {
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

    return FCard(
      style: .delta(
        decoration: .shapeDelta(
          color: colors.background,
          shape: RoundedSuperellipseBorder(
            side: BorderSide(color: colors.border),
            borderRadius: context.theme.style.borderRadius.lg,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(dense ? Spacing.level4 : Spacing.level5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: entry.softColor.solid(context),
                borderRadius: BorderRadius.circular(RadiusTokens.level4),
              ),
              child: Center(
                child: Icon(
                  entry.icon,
                  color: entry.accent.solid(context),
                  size: 19,
                ),
              ),
            ),
            const SizedBox(width: Spacing.level4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          label,
                          style: TypographyToken.level3
                              .body(context)
                              .copyWith(color: colors.mutedForeground),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (entry.badgeKey != null) ...[
                        const SizedBox(width: Spacing.level3),
                        FBadge.raw(
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
                      ],
                    ],
                  ),
                  if (value != null && value.isNotEmpty) ...[
                    const SizedBox(height: Spacing.level2),
                    Text.rich(
                      TextSpan(
                        style: TypographyToken.level4
                            .body(context)
                            .copyWith(
                              color: colors.foreground,
                              fontWeight: FontWeight.w700,
                            ),
                        children: [
                          TextSpan(text: value),
                          if (unit != null)
                            TextSpan(
                              text: ' $unit',
                              style: TypographyToken.level3
                                  .body(context)
                                  .copyWith(color: colors.mutedForeground),
                            ),
                        ],
                      ),
                    ),
                  ],
                  if (detail != null) ...[
                    const SizedBox(height: Spacing.level2),
                    Text(
                      detail,
                      style: TypographyToken.level3
                          .body(context)
                          .copyWith(color: colors.mutedForeground),
                    ),
                  ],
                ],
              ),
            ),
            if (entry.imageUrl != null && !dense) ...[
              const SizedBox(width: Spacing.level4),
              _TimelineImageThumbnail(imageUrl: entry.imageUrl!, label: label),
            ] else if (entry.imagePlaceholderKey != null && !dense) ...[
              const SizedBox(width: Spacing.level4),
              FCard(
                child: SizedBox(
                  width: 96,
                  height: 72,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.level3,
                        vertical: Spacing.level2,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            FLucideIcons.utensils,
                            size: 22,
                            color: colors.mutedForeground,
                          ),
                          const SizedBox(height: Spacing.level1),
                          Text(
                            recordCopy(l10n, entry.imagePlaceholderKey!),
                            style: TypographyToken.level3
                                .body(context)
                                .copyWith(color: colors.foreground),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(width: Spacing.level3),
            Icon(_trailingIcon(), color: _trailingColor(colors), size: 18),
          ],
        ),
      ),
    );
  }

  List<FTileGroup> _buildContextMenu(BuildContext context) {
    return [
      FTileGroup(
        children: [
          FTile(
            title: Text(l10n.recordDetailTitle),
            onPress: entry.recordId != null
                ? () => pushAuthRequiredRoute(
                    context,
                    '/record/${entry.recordId}',
                  )
                : null,
          ),
          FTile(
            title: Text(l10n.recordEditAction),
            onPress: entry.recordId != null
                ? () => pushAuthRequiredRoute(
                    context,
                    '/record/${entry.recordId}?edit=true',
                  )
                : null,
          ),
        ],
      ),
    ];
  }

  IconData _trailingIcon() {
    if (entry.trailingIcon == FLucideIcons.checkCircle2) {
      return FLucideIcons.badgeCheck;
    }
    if (entry.trailingIcon == FLucideIcons.chevronRight ||
        entry.trailingIcon == null) {
      return FLucideIcons.chevronRight;
    }
    return entry.trailingIcon!;
  }

  Color _trailingColor(FColors colors) {
    if (entry.trailingIcon == FLucideIcons.checkCircle2) {
      return colors.foreground;
    }
    return colors.mutedForeground;
  }
}

class _TimelineImageThumbnail extends StatelessWidget {
  const _TimelineImageThumbnail({required this.imageUrl, required this.label});

  final String imageUrl;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(RadiusTokens.level3),
      child: SizedBox(
        width: 96,
        height: 72,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              const _TimelineImageFallback(icon: FLucideIcons.image),
          errorWidget: (context, url, error) =>
              const _TimelineImageFallback(icon: FLucideIcons.imageOff),
          imageBuilder: (context, provider) => Semantics(
            label: label,
            image: true,
            child: Image(image: provider, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}

class _TimelineImageFallback extends StatelessWidget {
  const _TimelineImageFallback({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: SemanticColor.neutral.subtle(context),
        border: Border.all(color: colors.border),
      ),
      child: Center(
        child: Icon(
          icon,
          color: colors.mutedForeground,
          size: IconSizeTokens.level4,
        ),
      ),
    );
  }
}

/// Compact floating feedback widget shown while dragging a timeline card.
///
/// Renders a small card with the entry icon and title so the user can see
/// what they're dragging. The [maxWidth] prevents the feedback from
/// spanning the entire screen on wide monitors.
class _DragFeedback extends StatelessWidget {
  const _DragFeedback({
    required this.entry,
    required this.l10n,
    required this.maxWidth,
  });

  final RecordTimelineEntry entry;
  final AppLocalizations l10n;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final label = entry.rawTitle ?? recordCopy(l10n, entry.titleKey);

    return Material(
      color: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(RadiusTokens.level4),
            border: Border.all(
              color: SemanticColor.primary.borderStrong(context),
            ),
            boxShadow: ElevationTokens.raised(colors),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.level4,
              vertical: Spacing.level3,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(entry.icon, color: entry.accent.solid(context), size: 18),
                const SizedBox(width: Spacing.level3),
                Flexible(
                  child: Text(
                    label,
                    style: TypographyToken.level3
                        .body(context)
                        .copyWith(color: colors.foreground),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: Spacing.level3),
                Icon(
                  FLucideIcons.calendarDays,
                  color: colors.mutedForeground,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopTimelineEmptyState extends StatelessWidget {
  const _DesktopTimelineEmptyState({
    required this.l10n,
    this.onClearFilter,
    required this.onCreate,
  });

  final AppLocalizations l10n;
  final VoidCallback? onClearFilter;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.level4,
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
          Wrap(
            spacing: Spacing.level3,
            runSpacing: Spacing.level2,
            alignment: WrapAlignment.center,
            children: [
              FButton(
                variant: FButtonVariant.primary,
                size: FButtonSizeVariant.sm,
                mainAxisSize: MainAxisSize.min,
                onPress: onCreate,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(FLucideIcons.plus, size: IconSizeTokens.level2),
                    const SizedBox(width: Spacing.level2),
                    Text(l10n.recordTimelineEmptyAction),
                  ],
                ),
              ),
              if (onClearFilter != null)
                FButton(
                  variant: FButtonVariant.ghost,
                  size: FButtonSizeVariant.sm,
                  mainAxisSize: MainAxisSize.min,
                  onPress: onClearFilter,
                  child: Text(l10n.recordTimelineClearFilter),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
