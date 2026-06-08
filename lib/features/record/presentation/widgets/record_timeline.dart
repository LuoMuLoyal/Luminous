import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_image_placeholder.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/record_components.dart';
import 'package:luminous/features/record/presentation/widgets/record_copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordTimelinePanel extends StatelessWidget {
  const RecordTimelinePanel({
    super.key,
    required this.entries,
    required this.l10n,
    required this.typography,
    required this.surface,
    this.dense = false,
  });

  final List<RecordTimelineEntry> entries;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return RecordSectionSurface(
      key: const Key('record-timeline'),
      title: l10n.recordTimelineSectionTitle,
      trailing: RecordTextAction(
        label: l10n.recordAllTypesAction,
        icon: Icons.keyboard_arrow_down_rounded,
        typography: typography,
        surface: surface,
        onTap: () => showRecordToast(context, l10n.recordAllTypesAction),
      ),
      typography: typography,
      surface: surface,
      child: Column(
        children: [
          for (var index = 0; index < entries.length; index += 1)
            _TimelineEntryRow(
              entry: entries[index],
              l10n: l10n,
              typography: typography,
              surface: surface,
              isLast: index == entries.length - 1,
              dense: dense,
            ),
        ],
      ),
    );
  }
}

class _TimelineEntryRow extends StatelessWidget {
  const _TimelineEntryRow({
    required this.entry,
    required this.l10n,
    required this.typography,
    required this.surface,
    required this.isLast,
    required this.dense,
  });

  final RecordTimelineEntry entry;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final bool isLast;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: dense ? 44 : 56,
          child: Text(
            entry.time,
            style: typography.bodySm.copyWith(color: surface.body),
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
                  border: Border.all(color: surface.canvas, width: 3),
                ),
                child: const SizedBox.square(dimension: 10),
              ),
              if (!isLast)
                SizedBox(
                  height: dense ? 88 : 104,
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
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacingTokens.md),
            child: _TimelineCard(
              entry: entry,
              l10n: l10n,
              typography: typography,
              surface: surface,
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
    required this.l10n,
    required this.typography,
    required this.surface,
    required this.dense,
  });

  final RecordTimelineEntry entry;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final label = entry.rawTitle ?? recordCopy(l10n, entry.titleKey);
    final value = entry.valueKey == null
        ? entry.value
        : recordCopy(l10n, entry.valueKey!);
    final unit = entry.unitKey == null
        ? null
        : recordCopy(l10n, entry.unitKey!);
    final detail = entry.detailKey == null
        ? null
        : recordCopy(l10n, entry.detailKey!);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (entry.recordId != null) {
            pushAuthRequiredRoute(context, '/record/${entry.recordId}');
          } else {
            showRecordToast(context, label);
          }
        },
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: surface.canvas,
            borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
            border: Border.all(color: surface.hairline),
          ),
          child: Padding(
            padding: EdgeInsets.all(
              dense ? AppSpacingTokens.md : AppSpacingTokens.lg,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RecordIconBadge(
                  icon: entry.icon,
                  color: entry.accent,
                  backgroundColor: entry.softColor,
                  size: 38,
                  iconSize: 19,
                ),
                const SizedBox(width: AppSpacingTokens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              label,
                              style: typography.bodySm.copyWith(
                                color: surface.body,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (entry.badgeKey != null) ...[
                            const SizedBox(width: AppSpacingTokens.sm),
                            RecordPill(
                              label: recordCopy(l10n, entry.badgeKey!),
                              color: entry.accent,
                              typography: typography,
                            ),
                          ],
                        ],
                      ),
                      if (value != null && value.isNotEmpty) ...[
                        const SizedBox(height: AppSpacingTokens.xs),
                        Text.rich(
                          TextSpan(
                            style: typography.bodyMdStrong.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            children: [
                              TextSpan(text: value),
                              if (unit != null)
                                TextSpan(
                                  text: ' $unit',
                                  style: typography.bodySm.copyWith(
                                    color: surface.body,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                      if (detail != null) ...[
                        const SizedBox(height: AppSpacingTokens.xs),
                        Text(
                          detail,
                          style: typography.bodySm.copyWith(
                            color: surface.body,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (entry.imageUrl != null && !dense) ...[
                  const SizedBox(width: AppSpacingTokens.md),
                  _TimelineImageThumbnail(
                    imageUrl: entry.imageUrl!,
                    label: label,
                    surface: surface,
                  ),
                ] else if (entry.imagePlaceholderKey != null && !dense) ...[
                  const SizedBox(width: AppSpacingTokens.md),
                  AppImagePlaceholder(
                    label: recordCopy(l10n, entry.imagePlaceholderKey!),
                    width: 96,
                    height: 72,
                    icon: Icons.restaurant_outlined,
                  ),
                ],
                const SizedBox(width: AppSpacingTokens.sm),
                Icon(
                  entry.trailingIcon ?? Icons.chevron_right_rounded,
                  color: _trailingColor(surface),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _trailingColor(AppThemeSurface surface) {
    if (entry.trailingIcon == Icons.check_circle_outline_rounded) {
      return const Color(0xFF159B55);
    }
    return surface.mute;
  }
}

class _TimelineImageThumbnail extends StatelessWidget {
  const _TimelineImageThumbnail({
    required this.imageUrl,
    required this.label,
    required this.surface,
  });

  final String imageUrl;
  final String label;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadiusTokens.md),
      child: SizedBox(
        width: 96,
        height: 72,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => _TimelineImageFallback(
            surface: surface,
            icon: Icons.image_outlined,
          ),
          errorWidget: (context, url, error) => _TimelineImageFallback(
            surface: surface,
            icon: Icons.broken_image_outlined,
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

class _TimelineImageFallback extends StatelessWidget {
  const _TimelineImageFallback({required this.surface, required this.icon});

  final AppThemeSurface surface;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface.canvasSoft2,
        border: Border.all(color: surface.hairline),
      ),
      child: Center(child: Icon(icon, color: surface.mute, size: 22)),
    );
  }
}
