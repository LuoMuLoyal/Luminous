import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/widgets/common/app_icon_badge.dart';
import 'package:luminous/core/widgets/common/app_image_placeholder.dart';
import 'package:luminous/core/widgets/common/app_status_pill.dart';
import 'package:luminous/core/widgets/common/app_text_action.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/shared/record_copy.dart';
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (onClearFilter != null)
                  AppTextAction(
                    label: l10n.recordAllTypesAction,
                    icon: FLucideIcons.chevronDown,
                    onTap: onClearFilter!,
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
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: dense ? 44 : 56,
          child: Text(
            entry.time,
            style: textTheme.bodySmall?.copyWith(color: colors.mutedForeground),
          ),
        ),
        SizedBox(
          width: 20,
          child: Column(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: entry.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.background, width: 3),
                ),
                child: const SizedBox.square(dimension: 10),
              ),
              if (!isLast)
                SizedBox(
                  height: dense ? 88 : 104,
                  child: VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: colors.border,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacingTokens.level3),
        Expanded(
          child: Padding(
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
      ],
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
    final textTheme = Theme.of(context).textTheme;
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
      key: entry.recordId == null
          ? null
          : Key('record-timeline-entry-${entry.recordId}'),
      onPress: entry.recordId != null
          ? () => pushAuthRequiredRoute(context, '/record/${entry.recordId}')
          : null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(AppRadiusTokens.level4),
          border: Border.all(color: colors.border),
        ),
        child: Padding(
          padding: EdgeInsets.all(
            dense ? AppSpacingTokens.level4 : AppSpacingTokens.level5,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppIconBadge(
                icon: entry.icon,
                color: entry.accent,
                backgroundColor: entry.softColor,
                size: 38,
                iconSize: 19,
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
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.mutedForeground,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (entry.badgeKey != null) ...[
                          const SizedBox(width: AppSpacingTokens.level3),
                          AppStatusPill(
                            label: recordCopy(l10n, entry.badgeKey!),
                            color: entry.accent,
                          ),
                        ],
                      ],
                    ),
                    if (value != null && value.isNotEmpty) ...[
                      const SizedBox(height: AppSpacingTokens.level2),
                      Text.rich(
                        TextSpan(
                          style: textTheme.titleSmall?.copyWith(
                            color: colors.foreground,
                            fontWeight: FontWeight.w700,
                          ),
                          children: [
                            TextSpan(text: value),
                            if (unit != null)
                              TextSpan(
                                text: ' $unit',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colors.mutedForeground,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                    if (detail != null) ...[
                      const SizedBox(height: AppSpacingTokens.level2),
                      Text(
                        detail,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.mutedForeground,
                        ),
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
                AppImagePlaceholder(
                  label: recordCopy(l10n, entry.imagePlaceholderKey!),
                  width: 96,
                  height: 72,
                  icon: FLucideIcons.utensils,
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
    if (entry.trailingIcon == Icons.check_circle_outline_rounded) {
      return FLucideIcons.badgeCheck;
    }
    if (entry.trailingIcon == Icons.chevron_right_rounded ||
        entry.trailingIcon == null) {
      return FLucideIcons.chevronRight;
    }
    return entry.trailingIcon!;
  }

  Color _trailingColor(FColors colors) {
    if (entry.trailingIcon == Icons.check_circle_outline_rounded) {
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
