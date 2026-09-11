import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/control/divider.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/sections/quick_entry/metrics.dart';
import 'package:luminous/features/record/presentation/widgets/shared/copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Responsive 3-column grid of quick-entry tiles (non-reorder mode).
class QuickRecordGrid extends StatelessWidget {
  const QuickRecordGrid({
    super.key,
    required this.actions,
    required this.l10n,
    required this.metrics,
    required this.badgeFor,
    this.onTap,
    this.onLongPress,
  });

  final List<RecordQuickAction> actions;
  final AppLocalizations l10n;
  final QuickEntryMetrics metrics;
  final String? Function(RecordQuickAction action) badgeFor;
  final ValueChanged<RecordQuickAction>? onTap;
  final ValueChanged<RecordQuickAction>? onLongPress;

  @override
  Widget build(BuildContext context) {
    final rows = <List<RecordQuickAction>>[];
    for (var index = 0; index < actions.length; index += 3) {
      rows.add(actions.skip(index).take(3).toList(growable: false));
    }

    return Column(
      children: [
        for (var rowIndex = 0; rowIndex < rows.length; rowIndex += 1) ...[
          Row(
            children: [
              for (
                var index = 0;
                index < rows[rowIndex].length;
                index += 1
              ) ...[
                Expanded(
                  child: QuickRecordTile(
                    action: rows[rowIndex][index],
                    l10n: l10n,
                    metrics: metrics,
                    badge: badgeFor(rows[rowIndex][index]),
                    onTap: onTap,
                    onLongPress: onLongPress,
                  ),
                ),
                if (index < rows[rowIndex].length - 1)
                  SizedBox(
                    height: metrics.dividerHeight,
                    child: AppDivider(
                      axis: Axis.vertical,
                      color: SemanticColor.neutral.border(context),
                    ),
                  ),
              ],
              for (var filler = rows[rowIndex].length; filler < 3; filler += 1)
                const Expanded(child: SizedBox.shrink()),
            ],
          ),
          if (rowIndex < rows.length - 1) const AppDivider(),
        ],
      ],
    );
  }
}

/// A single quick-entry tile with icon avatar, label and optional badge.
class QuickRecordTile extends StatelessWidget {
  const QuickRecordTile({
    super.key,
    required this.action,
    required this.l10n,
    required this.metrics,
    this.badge,
    this.onTap,
    this.onLongPress,
  });

  final RecordQuickAction action;
  final AppLocalizations l10n;
  final QuickEntryMetrics metrics;
  final String? badge;
  final ValueChanged<RecordQuickAction>? onTap;
  final ValueChanged<RecordQuickAction>? onLongPress;

  @override
  Widget build(BuildContext context) {
    final isLocked = action.locked;
    final displayLabel = recordCopy(l10n, action.titleKey);

    return FTappable(
      key: Key('record-quick-${action.type.name}'),
      onPress: (onTap == null || isLocked) ? null : () => onTap!(action),
      onLongPress: onLongPress == null ? null : () => onLongPress!(action),
      child: Semantics(
        button: true,
        label: isLocked
            ? '$displayLabel ${l10n.recordNotEnabledLabel}'
            : displayLabel,
        child: Opacity(
          opacity: isLocked ? 0.76 : 1,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: metrics.tileVerticalPadding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    FAvatar.raw(
                      size: metrics.avatarSize,
                      style: .delta(
                        backgroundColor: action.softColor.subtle(context),
                      ),
                      child: Icon(
                        isLocked ? SemanticIcons.statusBlocked : action.icon,
                        color: action.accent.solid(context),
                        size: Spacing.xl,
                      ),
                    ),
                    if (badge != null)
                      Positioned(
                        top: -Spacing.xs,
                        right: -Spacing.sm,
                        child: QuickBadge(text: badge!),
                      ),
                  ],
                ),
                const SizedBox(height: Spacing.sm),
                Text(
                  displayLabel,
                  style: context.theme.typography.body.md.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small pill badge overlaid on a quick-entry tile.
class QuickBadge extends StatelessWidget {
  const QuickBadge({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: SemanticColor.primary.solid(context),
        borderRadius: context.theme.style.borderRadius.pill,
        border: Border.all(color: context.theme.colors.background, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: 1,
        ),
        child: Text(
          text,
          style: context.theme.typography.body.xs3.copyWith(
            color: SemanticColor.primary.foreground(context),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// Full-width note quick-entry row below the grid.
class QuickRecordNoteButton extends StatelessWidget {
  const QuickRecordNoteButton({
    super.key,
    required this.action,
    required this.l10n,
    required this.metrics,
    this.onTap,
  });

  final RecordQuickAction action;
  final AppLocalizations l10n;
  final QuickEntryMetrics metrics;
  final ValueChanged<RecordQuickAction>? onTap;

  @override
  Widget build(BuildContext context) {
    final isLocked = action.locked;
    final label = recordCopy(l10n, action.titleKey);

    return FTappable(
      key: const Key('record-quick-note'),
      onPress: (onTap == null || isLocked) ? null : () => onTap!(action),
      child: Semantics(
        button: true,
        label: isLocked ? '$label ${l10n.recordNotEnabledLabel}' : label,
        child: Opacity(
          opacity: isLocked ? 0.76 : 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FAvatar.raw(
                  size: metrics.avatarSize,
                  style: .delta(
                    backgroundColor: action.softColor.subtle(context),
                  ),
                  child: Icon(
                    isLocked ? SemanticIcons.statusBlocked : action.icon,
                    color: action.accent.solid(context),
                    size: Spacing.xl,
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Text(
                  label,
                  style: context.theme.typography.body.md.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
