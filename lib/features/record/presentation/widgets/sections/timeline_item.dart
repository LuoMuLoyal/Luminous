import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/core/widgets/common/control/desktop_hover.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/presentation/utils/date_time_formatters.dart';
import 'package:luminous/features/record/presentation/widgets/sections/timeline_drag_handler.dart';
import 'package:luminous/features/record/presentation/widgets/shared/copy.dart';
import 'package:luminous/features/record/presentation/widgets/shared/timeline_drag_data.dart';
import 'package:luminous/l10n/app_localizations.dart';

class TimelineDot extends StatelessWidget {
  const TimelineDot({
    super.key,
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

class TimelineCard extends StatelessWidget {
  const TimelineCard({
    super.key,
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
        feedback: TimelineDragFeedback(
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
              Uri(
                path: '/record/create',
                queryParameters: {
                  'date': formatRecordDate(selectedDate ?? DateTime.now()),
                },
              ).toString(),
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
    final typography = context.theme.typography;
    final borderRadius = context.theme.style.borderRadius;

    return ClipRRect(
      borderRadius: borderRadius.sm,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.background,
          border: Border(
            left: BorderSide(color: entry.accent.solid(context), width: 3),
            top: BorderSide(color: SemanticColor.neutral.border(context)),
            right: BorderSide(color: SemanticColor.neutral.border(context)),
            bottom: BorderSide(color: SemanticColor.neutral.border(context)),
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
                  color: entry.softColor.muted(context),
                  borderRadius: borderRadius.sm,
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
                            style: typography.body.xs.copyWith(
                              color: SemanticColor.neutral.solid(context),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (entry.badgeKey != null) ...[
                          const SizedBox(width: Spacing.level3),
                          // 桌面端时间线列较窄：badge 参与 flex 收缩，过长时
                          // 省略号截断，避免 RenderFlex 溢出（e2e 桌面宽度回归）。
                          Flexible(
                            child: FBadge.raw(
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
                                      horizontal: Spacing.level2,
                                      vertical: Spacing.level1,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // badge 自身被外层 Flexible 限宽后，
                                        // 内部文案也要参与收缩，否则内层
                                        // Row 仍按无界宽度测量而溢出。
                                        Flexible(
                                          child: Text(
                                            recordCopy(l10n, entry.badgeKey!),
                                            style: context
                                                .theme
                                                .typography
                                                .body
                                                .xs
                                                .copyWith(
                                                  color: colors.foreground,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (value != null && value.isNotEmpty) ...[
                      const SizedBox(height: Spacing.level2),
                      Text.rich(
                        TextSpan(
                          style: typography.body.sm.copyWith(
                            color: colors.foreground,
                            fontWeight: FontWeight.w700,
                          ),
                          children: [
                            TextSpan(text: value),
                            if (unit != null)
                              TextSpan(
                                text: ' $unit',
                                style: typography.body.xs.copyWith(
                                  color: SemanticColor.neutral.solid(context),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                    if (detail != null) ...[
                      const SizedBox(height: Spacing.level2),
                      Text(
                        detail,
                        style: typography.body.xs.copyWith(
                          color: SemanticColor.neutral.solid(context),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (entry.imageUrl != null && !dense) ...[
                const SizedBox(width: Spacing.level4),
                TimelineImageThumbnail(imageUrl: entry.imageUrl!, label: label),
              ] else if (entry.imagePlaceholderKey != null && !dense) ...[
                const SizedBox(width: Spacing.level4),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: SemanticColor.neutral.subtle(context),
                    borderRadius: borderRadius.sm,
                    border: Border.all(
                      color: SemanticColor.neutral.border(context),
                    ),
                  ),
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
                              SemanticIcons.recordMeal,
                              size: 22,
                              color: SemanticColor.neutral.solid(context),
                            ),
                            const SizedBox(height: Spacing.level1),
                            Text(
                              recordCopy(l10n, entry.imagePlaceholderKey!),
                              style: typography.body.xs.copyWith(
                                color: colors.foreground,
                              ),
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
              Icon(
                _trailingIcon(),
                color: _trailingColor(colors),
                size: IconSizeTokens.level2,
              ),
            ],
          ),
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
    if (entry.trailingIcon == SemanticIcons.statusSuccess) {
      return SemanticIcons.reportAdherence;
    }
    if (entry.trailingIcon == SemanticIcons.actionNext ||
        entry.trailingIcon == null) {
      return SemanticIcons.actionNext;
    }
    return entry.trailingIcon!;
  }

  Color _trailingColor(FColors colors) {
    if (entry.trailingIcon == SemanticIcons.statusSuccess) {
      return colors.foreground;
    }
    return SemanticColor.neutral.paletteFromColors(colors).solid;
  }
}

class TimelineImageThumbnail extends StatelessWidget {
  const TimelineImageThumbnail({
    super.key,
    required this.imageUrl,
    required this.label,
  });

  final String imageUrl;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: context.theme.style.borderRadius.sm,
      child: SizedBox(
        width: 96,
        height: 72,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              const TimelineImageFallback(icon: SemanticIcons.actionImage),
          errorWidget: (context, url, error) => const TimelineImageFallback(
            icon: SemanticIcons.statusUnavailable,
          ),
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

class TimelineImageFallback extends StatelessWidget {
  const TimelineImageFallback({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: SemanticColor.neutral.subtle(context),
        border: Border.all(color: SemanticColor.neutral.border(context)),
      ),
      child: Center(
        child: Icon(
          icon,
          color: SemanticColor.neutral.solid(context),
          size: IconSizeTokens.level4,
        ),
      ),
    );
  }
}
