import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/shared/copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Compact floating feedback widget shown while dragging a timeline card.
///
/// Renders a small card with the entry icon and title so the user can see
/// what they're dragging. The [maxWidth] prevents the feedback from
/// spanning the entire screen on wide monitors.
class TimelineDragFeedback extends StatelessWidget {
  const TimelineDragFeedback({
    super.key,
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
            borderRadius: context.theme.style.borderRadius.md,
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
                Icon(
                  entry.icon,
                  color: entry.accent.solid(context),
                  size: IconSizeTokens.level2,
                ),
                const SizedBox(width: Spacing.level3),
                Flexible(
                  child: Text(
                    label,
                    style: context.theme.typography.body.xs.copyWith(
                      color: colors.foreground,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: Spacing.level3),
                Icon(
                  SemanticIcons.actionCalendar,
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
