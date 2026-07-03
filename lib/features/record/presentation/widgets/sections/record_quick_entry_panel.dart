import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_colors.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/shared/record_copy.dart';
import 'package:luminous/features/record/presentation/widgets/shared/record_dashboard_tokens.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/core/widgets/common/app_divider.dart';

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
    final textTheme = Theme.of(context).textTheme;
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
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.mutedForeground,
                    ),
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
                  style: textTheme.labelSmall?.copyWith(
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
    return Tooltip(
      message: tooltip,
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
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
    // Split into a primary 2x2 grid and a secondary 1x3 row.
    final primary = actions.take(4).toList(growable: false);
    final secondary = actions.skip(4).toList(growable: false);

    return Column(
      key: const Key('record-quick-actions'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.recordQuickSectionTitle,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacingTokens.level3),
        FCard.raw(
          child: Column(
            children: [
              _QuickRecordGrid2x2(
                actions: primary,
                l10n: l10n,
                onQuickAction: onQuickAction,
              ),
              if (secondary.isNotEmpty) ...[
                AppDivider(color: colors.border),
                _QuickRecordRow3(
                  actions: secondary,
                  l10n: l10n,
                  onQuickAction: onQuickAction,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickRecordGrid2x2 extends StatelessWidget {
  const _QuickRecordGrid2x2({
    required this.actions,
    required this.l10n,
    this.onQuickAction,
  });

  final List<RecordQuickAction> actions;
  final AppLocalizations l10n;
  final ValueChanged<RecordQuickAction>? onQuickAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final rows = <List<RecordQuickAction>>[];
    for (var index = 0; index < actions.length; index += 2) {
      rows.add(actions.skip(index).take(2).toList(growable: false));
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
                    onQuickAction: onQuickAction,
                  ),
                ),
                if (index < rows[rowIndex].length - 1)
                  _ShortVerticalDivider(
                    height: AppSpacingTokens.level9,
                    color: colors.border,
                  ),
              ],
              for (var filler = rows[rowIndex].length; filler < 2; filler += 1)
                const Expanded(child: SizedBox.shrink()),
            ],
          ),
          if (rowIndex < rows.length - 1) AppDivider(color: colors.border),
        ],
      ],
    );
  }
}

class _QuickRecordRow3 extends StatelessWidget {
  const _QuickRecordRow3({
    required this.actions,
    required this.l10n,
    this.onQuickAction,
  });

  final List<RecordQuickAction> actions;
  final AppLocalizations l10n;
  final ValueChanged<RecordQuickAction>? onQuickAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Row(
      children: [
        for (var index = 0; index < actions.length; index += 1) ...[
          Expanded(
            child: _QuickRecordTile(
              action: actions[index],
              l10n: l10n,
              onQuickAction: onQuickAction,
            ),
          ),
          if (index < actions.length - 1)
            _ShortVerticalDivider(
              height: AppSpacingTokens.level9,
              color: colors.border,
            ),
        ],
        for (var filler = actions.length; filler < 3; filler += 1)
          const Expanded(child: SizedBox.shrink()),
      ],
    );
  }
}

class _QuickRecordTile extends StatelessWidget {
  const _QuickRecordTile({
    required this.action,
    required this.l10n,
    this.onQuickAction,
  });

  final RecordQuickAction action;
  final AppLocalizations l10n;
  final ValueChanged<RecordQuickAction>? onQuickAction;

  @override
  Widget build(BuildContext context) {
    final actionLabel = quickRecordLabel(l10n, action);
    final displayLabel = recordCopy(l10n, action.titleKey);
    final isLocked = action.locked;
    final textTheme = Theme.of(context).textTheme;
    final colors = context.theme.colors;

    return FButton.raw(
      key: Key('record-quick-${action.type.name}'),
      onPress: (onQuickAction == null || isLocked)
          ? null
          : () => onQuickAction!(action),
      variant: FButtonVariant.ghost,
      style: .delta(contentStyle: .delta(padding: .value(EdgeInsets.zero))),
      child: Semantics(
        button: true,
        label: isLocked
            ? '$actionLabel ${l10n.recordNotEnabledLabel}'
            : actionLabel,
        child: Opacity(
          opacity: isLocked ? 0.76 : 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacingTokens.level1,
              vertical: AppSpacingTokens.level1,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FAvatar.raw(
                  size: AppSpacingTokens.level6,
                  style: .delta(
                    backgroundColor: action.softColor.resolve(colors),
                  ),
                  child: Icon(
                    action.icon,
                    color: action.accent.resolve(colors),
                    size: AppSpacingTokens.level4,
                  ),
                ),
                const SizedBox(height: AppSpacingTokens.level1),
                Text(
                  displayLabel,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isLocked) ...[
                  const SizedBox(height: 2),
                  Text(
                    l10n.recordNotEnabledLabel,
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.mutedForeground,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
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
    final textTheme = Theme.of(context).textTheme;
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
                style: textTheme.bodySmall?.copyWith(color: colors.foreground),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacingTokens.level3),
            Text(
              l10n.recordGuideAction,
              style: textTheme.labelLarge?.copyWith(
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

class _ShortVerticalDivider extends StatelessWidget {
  const _ShortVerticalDivider({required this.height, required this.color});

  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: AppDivider(axis: Axis.vertical, color: color),
    );
  }
}
