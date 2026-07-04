import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_colors.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/widgets/common/app_divider.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/shared/record_copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// AI input bar
// ---------------------------------------------------------------------------

class RecordAiInputBar extends StatelessWidget {
  const RecordAiInputBar({
    super.key,
    required this.l10n,
    this.onTap,
    this.onMicTap,
    this.onCameraTap,
  });

  final AppLocalizations l10n;
  final VoidCallback? onTap;
  final VoidCallback? onMicTap;
  final VoidCallback? onCameraTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return FCard.raw(
      key: const Key('record-ai-input'),
      style: .delta(
        decoration: .shapeDelta(
          color: colors.background,
          shape: RoundedSuperellipseBorder(
            side: BorderSide(color: colors.primary.withValues(alpha: 0.32)),
            borderRadius: context.theme.style.borderRadius.lg,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.level4,
          vertical: AppSpacingTokens.level3,
        ),
        child: Row(
          children: [
            Icon(
              FLucideIcons.sparkles,
              color: colors.primary,
              size: AppSpacingTokens.level6,
            ),
            const SizedBox(width: AppSpacingTokens.level4),
            Expanded(
              child: FTappable(
                onPress: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacingTokens.level1,
                  ),
                  child: Text(
                    l10n.recordAiInputHint,
                    style: AppTypographyToken.level4
                        .body(context)
                        .copyWith(color: colors.mutedForeground),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacingTokens.level3),
            FBadge.raw(
              style: .delta(
                decoration: .shapeDelta(
                  color: colors.primary.withValues(alpha: 0.12),
                  shape: RoundedSuperellipseBorder(
                    borderRadius: context.theme.style.borderRadius.pill,
                  ),
                ),
              ),
              builder: (context, style) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacingTokens.level3,
                  vertical: AppSpacingTokens.level1,
                ),
                child: Text(
                  l10n.recordAiBadge,
                  style: AppTypographyToken.level3
                      .body(context)
                      .copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacingTokens.level1),
            _IconActionButton(
              tooltip: l10n.recordVoiceInputTitle,
              icon: FLucideIcons.mic,
              onTap: onMicTap,
            ),
            _IconActionButton(
              tooltip: l10n.recordOcrEntryTitle,
              icon: FLucideIcons.camera,
              onTap: onCameraTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  const _IconActionButton({
    required this.tooltip,
    required this.icon,
    this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FTooltip(
      tipBuilder: (context, controller) => Text(tooltip),
      child: FButton.icon(
        onPress: onTap,
        variant: FButtonVariant.ghost,
        size: FButtonSizeVariant.sm,
        child: Icon(icon, size: AppSpacingTokens.level5),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick record panel
// ---------------------------------------------------------------------------

class RecordQuickEntryPanel extends StatelessWidget {
  const RecordQuickEntryPanel({
    super.key,
    required this.actions,
    required this.l10n,
    this.onQuickAction,
  });

  final List<RecordQuickAction> actions;
  final AppLocalizations l10n;
  final ValueChanged<RecordQuickAction>? onQuickAction;

  @override
  Widget build(BuildContext context) {
    final noteAction = actions
        .where((action) => action.type == RecordEntryType.note)
        .firstOrNull;
    final gridActions = actions
        .where((action) => action.type != RecordEntryType.note)
        .take(6)
        .toList(growable: false);
    final metrics = _QuickRecordMetrics.resolve(context);

    return Column(
      key: const Key('record-quick-actions'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.recordQuickSectionTitle,
          style: AppTypographyToken.level7
              .display(context)
              .copyWith(fontWeight: FontWeight.w800),
        ),
        SizedBox(height: metrics.sectionGap),
        FCard.raw(
          child: Column(
            children: [
              _QuickRecordGrid(
                actions: gridActions,
                l10n: l10n,
                metrics: metrics,
                onTap: onQuickAction,
              ),
              if (noteAction != null) ...[
                const AppDivider(),
                _QuickRecordNoteButton(
                  action: noteAction,
                  l10n: l10n,
                  metrics: metrics,
                  onTap: onQuickAction,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickRecordMetrics {
  const _QuickRecordMetrics({
    required this.sectionGap,
    required this.tileVerticalPadding,
    required this.avatarSize,
    required this.notePadding,
    required this.dividerHeight,
  });

  factory _QuickRecordMetrics.resolve(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final shortEdge = math.min(size.width, size.height);
    final scale = ((shortEdge - 600) / 280).clamp(0.0, 1.0);
    return _QuickRecordMetrics(
      sectionGap: _lerpDouble(
        AppSpacingTokens.level2,
        AppSpacingTokens.level3,
        scale,
      ),
      tileVerticalPadding: _lerpDouble(
        AppSpacingTokens.level2,
        AppSpacingTokens.level4,
        scale,
      ),
      avatarSize: _lerpDouble(
        AppSpacingTokens.level5,
        AppSpacingTokens.level6,
        scale,
      ),
      notePadding: _lerpDouble(
        AppSpacingTokens.level2,
        AppSpacingTokens.level4,
        scale,
      ),
      dividerHeight: _lerpDouble(
        AppSpacingTokens.level6,
        AppSpacingTokens.level8,
        scale,
      ),
    );
  }

  final double sectionGap;
  final double tileVerticalPadding;
  final double avatarSize;
  final double notePadding;
  final double dividerHeight;
}

double _lerpDouble(double a, double b, double t) => a + (b - a) * t;

class _QuickRecordGrid extends StatelessWidget {
  const _QuickRecordGrid({
    required this.actions,
    required this.l10n,
    required this.metrics,
    this.onTap,
  });

  final List<RecordQuickAction> actions;
  final AppLocalizations l10n;
  final _QuickRecordMetrics metrics;
  final ValueChanged<RecordQuickAction>? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
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
                  child: _QuickRecordTile(
                    action: rows[rowIndex][index],
                    l10n: l10n,
                    metrics: metrics,
                    onTap: onTap,
                  ),
                ),
                if (index < rows[rowIndex].length - 1)
                  SizedBox(
                    height: metrics.dividerHeight,
                    child: AppDivider(
                      axis: Axis.vertical,
                      color: colors.border,
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

class _QuickRecordTile extends StatelessWidget {
  const _QuickRecordTile({
    required this.action,
    required this.l10n,
    required this.metrics,
    this.onTap,
  });

  final RecordQuickAction action;
  final AppLocalizations l10n;
  final _QuickRecordMetrics metrics;
  final ValueChanged<RecordQuickAction>? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final isLocked = action.locked;
    final displayLabel = recordCopy(l10n, action.titleKey);

    return FTappable(
      key: Key('record-quick-${action.type.name}'),
      onPress: (onTap == null || isLocked) ? null : () => onTap!(action),
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
                FAvatar.raw(
                  size: metrics.avatarSize,
                  style: .delta(
                    backgroundColor: action.softColor.resolve(colors),
                  ),
                  child: Icon(
                    isLocked ? FLucideIcons.lock : action.icon,
                    color: action.accent.resolve(colors),
                    size: AppSpacingTokens.level4,
                  ),
                ),
                const SizedBox(height: AppSpacingTokens.level2),
                Text(
                  displayLabel,
                  style: AppTypographyToken.level5
                      .body(context)
                      .copyWith(fontWeight: FontWeight.w700),
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

class _QuickRecordNoteButton extends StatelessWidget {
  const _QuickRecordNoteButton({
    required this.action,
    required this.l10n,
    required this.metrics,
    this.onTap,
  });

  final RecordQuickAction action;
  final AppLocalizations l10n;
  final _QuickRecordMetrics metrics;
  final ValueChanged<RecordQuickAction>? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final isLocked = action.locked;
    final label = recordCopy(l10n, action.titleKey);

    return FButton(
      key: const Key('record-quick-note'),
      onPress: (onTap == null || isLocked) ? null : () => onTap!(action),
      variant: FButtonVariant.ghost,
      mainAxisSize: MainAxisSize.max,
      style: .delta(
        decoration: .delta([
          .all(.shapeDelta(color: colors.secondary.withValues(alpha: 0.18))),
        ]),
        contentStyle: .delta(
          padding: .value(EdgeInsets.all(metrics.notePadding)),
        ),
      ),
      prefix: Icon(
        isLocked ? FLucideIcons.lock : action.icon,
        color: action.accent.resolve(colors),
      ),
      child: Text(
        label,
        style: AppTypographyToken.level5
            .body(context)
            .copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Guide row
// ---------------------------------------------------------------------------

class RecordGuideRow extends StatelessWidget {
  const RecordGuideRow({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return FCard.raw(
      key: const Key('record-guide-row'),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.level4,
          vertical: AppSpacingTokens.level3,
        ),
        child: Row(
          children: [
            Icon(
              FLucideIcons.lightbulb,
              color: context.theme.colors.primary,
              size: AppSpacingTokens.level5,
            ),
            const SizedBox(width: AppSpacingTokens.level3),
            Expanded(
              child: Text(
                l10n.recordGuideHint,
                style: AppTypographyToken.level3
                    .body(context)
                    .copyWith(color: colors.foreground),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacingTokens.level3),
            Text(
              l10n.recordGuideAction,
              style: AppTypographyToken.level5
                  .body(context)
                  .copyWith(
                    color: context.theme.colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            Icon(
              FLucideIcons.chevronRight,
              color: context.theme.colors.primary,
              size: AppSpacingTokens.level5,
            ),
          ],
        ),
      ),
    );
  }
}
