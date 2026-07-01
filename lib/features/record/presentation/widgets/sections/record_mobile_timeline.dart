import 'package:flutter/material.dart';
import 'package:luminous/core/widgets/common/app_section_surface.dart';
import 'package:luminous/core/widgets/common/app_status_pill.dart';
import 'package:luminous/core/widgets/common/app_icon_badge.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/shared/record_copy.dart';
import 'package:luminous/features/record/presentation/widgets/shared/record_shared_widgets.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordMobileTimeline extends StatelessWidget {
  const RecordMobileTimeline({
    super.key,
    required this.entries,
    required this.totalCount,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final List<RecordTimelineEntry> entries;
  final int totalCount;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('record-timeline'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.recordTodayEntriesTitle(totalCount),
          style: typography.displaySm,
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        AppSectionSurface(
          typography: typography,
          surface: surface,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var index = 0; index < entries.length; index += 1) ...[
                _TimelineRow(
                  index: index,
                  entry: entries[index],
                  l10n: l10n,
                  typography: typography,
                  surface: surface,
                  isLast: index == entries.length - 1,
                ),
                if (index < entries.length - 1)
                  RecordIndentedDivider(
                    surface: surface,
                    indent: AppSpacingTokens.x6l + AppSpacingTokens.md,
                    endIndent: AppSpacingTokens.md,
                  ),
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
    required this.typography,
    required this.surface,
    required this.isLast,
  });

  final int index;
  final RecordTimelineEntry entry;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
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

    return Material(
      key: entry.recordId == null
          ? null
          : Key('record-timeline-entry-${entry.recordId}'),
      color: Colors.transparent,
      child: InkWell(
        key: Key('record-timeline-entry-index-$index'),
        onTap: entry.recordId != null
            ? () => pushAuthRequiredRoute(context, '/record/${entry.recordId}')
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacingTokens.md,
            vertical: AppSpacingTokens.sm,
          ),
          child: Row(
            children: [
              SizedBox(
                width: AppSpacingTokens.x3l,
                child: AppSkeletonText(
                  text: entry.time,
                  style: typography.bodySm.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  widthFactor: 0.68,
                  maxLines: 1,
                ),
              ),
              SizedBox(
                width: AppSpacingTokens.lg,
                child: Column(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: entry.accent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: surface.canvas,
                          width: AppSpacingTokens.xxs,
                        ),
                      ),
                      child: const SizedBox.square(
                        dimension: AppSpacingTokens.sm,
                      ),
                    ),
                    if (!isLast)
                      SizedBox(
                        height: AppSpacingTokens.x3l,
                        child: VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: surface.hairline,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacingTokens.sm),
              AppIconBadge(
                icon: entry.icon,
                color: entry.accent,
                backgroundColor: entry.softColor,
                size: AppSpacingTokens.x3l,
                iconSize: AppSpacingTokens.lg,
              ),
              const SizedBox(width: AppSpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSkeletonText(
                      text: label,
                      style: typography.bodyMdStrong.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      widthFactor: 0.64,
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: AppSpacingTokens.xxs),
                      AppSkeletonText(
                        text: subtitle,
                        style: typography.bodySm.copyWith(color: surface.body),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        widthFactor: 0.78,
                      ),
                    ],
                  ],
                ),
              ),
              if (entry.badgeKey != null) ...[
                const SizedBox(width: AppSpacingTokens.xs),
                AppSkeletonSlot(
                  skeleton: AppInlineSkeletonBlock(
                    height: (typography.bodySm.fontSize ?? 14) + 8,
                    widthFactor: 0.16,
                    radius: AppRadiusTokens.sm,
                  ),
                  child: AppStatusPill(
                    label: recordCopy(l10n, entry.badgeKey!),
                    color: entry.accent,
                    typography: typography,
                  ),
                ),
              ],
              const SizedBox(width: AppSpacingTokens.xs),
              Icon(
                Icons.chevron_right_rounded,
                color: surface.mute,
                size: AppSpacingTokens.lg,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
