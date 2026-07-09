import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/presentation/utils/date_time_formatters.dart';
import 'package:luminous/features/record/presentation/widgets/shared/copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordTimelinePanel extends StatelessWidget {
  const RecordTimelinePanel({
    super.key,
    required this.entries,
    required this.l10n,
    this.dense = false,
    this.onClearFilter,
  });

  final List<RecordTimelineEntry> entries;
  final AppLocalizations l10n;
  final bool dense;
  final VoidCallback? onClearFilter;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return FCard.raw(
      key: const Key('record-timeline'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.level5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.recordTimelineSectionTitle,
                    style: AppTypographyToken.level5
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
                        const SizedBox(width: AppSpacingTokens.level1),
                        Icon(
                          FLucideIcons.chevronDown,
                          size: AppSpacingTokens.level4,
                          color: colors.foreground,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacingTokens.level4),
            Column(
              children: [
                for (var index = 0; index < entries.length; index += 1)
                  _TimelineEntryRow(
                    index: index,
                    entry: entries[index],
                    l10n: l10n,
                    isLast: index == entries.length - 1,
                    dense: dense,
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
  });

  final int index;
  final RecordTimelineEntry entry;
  final AppLocalizations l10n;
  final bool isLast;
  final bool dense;

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
            style: AppTypographyToken.level3
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
              padding: const EdgeInsets.only(right: AppSpacingTokens.level3),
              indicatorXY: 0.25,
            ),
            beforeLineStyle: LineStyle(color: colors.border, thickness: 1),
            afterLineStyle: LineStyle(color: colors.border, thickness: 1),
            endChild: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : AppSpacingTokens.level4,
              ),
              child: _TimelineCard(
                entry: entry,
                index: index,
                l10n: l10n,
                dense: dense,
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
        color: entry.accent.resolve(colors),
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
  });

  final RecordTimelineEntry entry;
  final int index;
  final AppLocalizations l10n;
  final bool dense;

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

    return FTappable(
      key: Key('record-timeline-entry-index-$index'),
      onPress: entry.recordId != null
          ? () => pushAuthRequiredRoute(context, '/record/${entry.recordId}')
          : () => pushAuthRequiredRoute(
              context,
              '/record/create?date=${formatRecordDate(DateTime.now())}',
            ),
      child: FCard.raw(
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
          padding: EdgeInsets.all(
            dense ? AppSpacingTokens.level4 : AppSpacingTokens.level5,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: entry.softColor.resolve(colors),
                  borderRadius: BorderRadius.circular(AppRadiusTokens.level4),
                ),
                child: Center(
                  child: Icon(
                    entry.icon,
                    color: entry.accent.resolve(colors),
                    size: 19,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacingTokens.level4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            label,
                            style: AppTypographyToken.level3
                                .body(context)
                                .copyWith(color: colors.mutedForeground),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (entry.badgeKey != null) ...[
                          const SizedBox(width: AppSpacingTokens.level3),
                          FBadge.raw(
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
                        ],
                      ],
                    ),
                    if (value != null && value.isNotEmpty) ...[
                      const SizedBox(height: AppSpacingTokens.level2),
                      Text.rich(
                        TextSpan(
                          style: AppTypographyToken.level4
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
                                style: AppTypographyToken.level3
                                    .body(context)
                                    .copyWith(color: colors.mutedForeground),
                              ),
                          ],
                        ),
                      ),
                    ],
                    if (detail != null) ...[
                      const SizedBox(height: AppSpacingTokens.level2),
                      Text(
                        detail,
                        style: AppTypographyToken.level3
                            .body(context)
                            .copyWith(color: colors.mutedForeground),
                      ),
                    ],
                  ],
                ),
              ),
              if (entry.imageUrl != null && !dense) ...[
                const SizedBox(width: AppSpacingTokens.level4),
                _TimelineImageThumbnail(
                  imageUrl: entry.imageUrl!,
                  label: label,
                ),
              ] else if (entry.imagePlaceholderKey != null && !dense) ...[
                const SizedBox(width: AppSpacingTokens.level4),
                FCard.raw(
                  child: SizedBox(
                    width: 96,
                    height: 72,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacingTokens.level3,
                          vertical: AppSpacingTokens.level2,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              FLucideIcons.utensils,
                              size: 22,
                              color: colors.mutedForeground,
                            ),
                            const SizedBox(height: AppSpacingTokens.level1),
                            Text(
                              recordCopy(l10n, entry.imagePlaceholderKey!),
                              style: AppTypographyToken.level3
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
              const SizedBox(width: AppSpacingTokens.level3),
              Icon(_trailingIcon(), color: _trailingColor(colors), size: 18),
            ],
          ),
        ),
      ),
    );
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
      borderRadius: BorderRadius.circular(AppRadiusTokens.level3),
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
        color: colors.secondary.withValues(alpha: 0.2),
        border: Border.all(color: colors.border),
      ),
      child: Center(child: Icon(icon, color: colors.mutedForeground, size: 22)),
    );
  }
}
