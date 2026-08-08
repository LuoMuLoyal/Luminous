import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/desktop_hover.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(RadiusTokens.level3),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.background,
          border: Border(
            left: BorderSide(color: entry.accent.solid(context), width: 3),
            top: BorderSide(color: colors.border),
            right: BorderSide(color: colors.border),
            bottom: BorderSide(color: colors.border),
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
                  borderRadius: BorderRadius.circular(RadiusTokens.level3),
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
                TimelineImageThumbnail(imageUrl: entry.imageUrl!, label: label),
              ] else if (entry.imagePlaceholderKey != null && !dense) ...[
                const SizedBox(width: Spacing.level4),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: SemanticColor.neutral.subtle(context),
                    borderRadius: BorderRadius.circular(RadiusTokens.level3),
                    border: Border.all(color: colors.border),
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
    return colors.mutedForeground;
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
      borderRadius: BorderRadius.circular(RadiusTokens.level3),
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
