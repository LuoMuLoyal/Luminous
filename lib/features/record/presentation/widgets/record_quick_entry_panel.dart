import 'package:flutter/material.dart';
import 'package:luminous/core/widgets/app_section_surface.dart';
import 'package:luminous/core/widgets/app_icon_badge.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/record_copy.dart';
import 'package:luminous/features/record/presentation/widgets/record_dashboard_tokens.dart';
import 'package:luminous/features/record/presentation/widgets/record_shared_widgets.dart';
import 'package:luminous/l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// AI input bar
// ---------------------------------------------------------------------------

class RecordAiInputBar extends StatelessWidget {
  const RecordAiInputBar({
    super.key,
    required this.l10n,
    required this.typography,
    required this.surface,
    this.onTap,
  });

  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const Key('record-ai-input'),
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: surface.canvas,
            borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
            border: Border.all(
              color: AppColorTokens.cyanDeep.withValues(alpha: 0.32),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacingTokens.md,
              vertical: AppSpacingTokens.sm,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColorTokens.gradientPreviewStart,
                  size: AppSpacingTokens.xl,
                ),
                const SizedBox(width: AppSpacingTokens.md),
                Expanded(
                  child: Text(
                    l10n.recordAiInputHint,
                    style: typography.bodyMd.copyWith(color: surface.mute),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.sm),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColorTokens.cyanDeep.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacingTokens.sm,
                      vertical: AppSpacingTokens.xxs,
                    ),
                    child: Text(
                      l10n.recordAiBadge,
                      style: typography.caption.copyWith(
                        color: AppColorTokens.cyanDeep,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.sm),
                Tooltip(
                  message: l10n.recordVoiceInputTitle,
                  child: Icon(
                    Icons.mic_none_rounded,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: AppSpacingTokens.lg,
                  ),
                ),
              ],
            ),
          ),
        ),
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
    required this.typography,
    required this.surface,
    this.onQuickAction,
  });

  final List<RecordQuickAction> actions;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final ValueChanged<RecordQuickAction>? onQuickAction;

  @override
  Widget build(BuildContext context) {
    final rows = <List<RecordQuickAction>>[];
    for (var index = 0; index < actions.length; index += 3) {
      rows.add(actions.skip(index).take(3).toList(growable: false));
    }

    return Column(
      key: const Key('record-quick-actions'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.recordQuickSectionTitle, style: typography.displaySm),
        const SizedBox(height: AppSpacingTokens.sm),
        AppSectionSurface(
          typography: typography,
          surface: surface,
          padding: EdgeInsets.zero,
          child: Column(
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
                          typography: typography,
                          surface: surface,
                          onQuickAction: onQuickAction,
                        ),
                      ),
                      if (index < rows[rowIndex].length - 1)
                        RecordShortVerticalDivider(
                          surface: surface,
                          height: AppSpacingTokens.x4l,
                        ),
                    ],
                    for (
                      var filler = rows[rowIndex].length;
                      filler < 3;
                      filler += 1
                    )
                      const Expanded(child: SizedBox.shrink()),
                  ],
                ),
                if (rowIndex < rows.length - 1)
                  RecordIndentedDivider(
                    surface: surface,
                    indent: AppSpacingTokens.md,
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

class _QuickRecordTile extends StatelessWidget {
  const _QuickRecordTile({
    required this.action,
    required this.l10n,
    required this.typography,
    required this.surface,
    this.onQuickAction,
  });

  final RecordQuickAction action;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final ValueChanged<RecordQuickAction>? onQuickAction;

  @override
  Widget build(BuildContext context) {
    final actionLabel = quickRecordLabel(l10n, action);
    final displayLabel = recordCopy(l10n, action.titleKey);
    final isLocked = action.locked;

    return Material(
      key: Key('record-quick-${action.type.name}'),
      color: Colors.transparent,
      child: InkWell(
        onTap: onQuickAction == null ? null : () => onQuickAction!(action),
        borderRadius: BorderRadius.circular(AppRadiusTokens.md),
        child: Semantics(
          button: true,
          label: isLocked
              ? '$actionLabel ${l10n.recordNotEnabledLabel}'
              : actionLabel,
          child: Opacity(
            opacity: isLocked ? 0.76 : 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacingTokens.xxs,
                vertical: AppSpacingTokens.xxs,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppIconBadge(
                    icon: action.icon,
                    color: action.accent,
                    backgroundColor: action.softColor,
                    size: AppSpacingTokens.xl,
                    iconSize: AppSpacingTokens.md,
                  ),
                  const SizedBox(height: AppSpacingTokens.xxs),
                  Text(
                    displayLabel,
                    style: typography.bodySmStrong.copyWith(
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
                      style: typography.caption.copyWith(
                        color: surface.mute,
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
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Guide row
// ---------------------------------------------------------------------------

class RecordGuideRow extends StatelessWidget {
  const RecordGuideRow({
    super.key,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return AppSectionSurface(
      key: const Key('record-guide-row'),
      typography: typography,
      surface: surface,
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: null,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacingTokens.md,
              vertical: AppSpacingTokens.sm,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: AppColorTokens.warning,
                  size: AppSpacingTokens.lg,
                ),
                const SizedBox(width: AppSpacingTokens.sm),
                Expanded(
                  child: Text(
                    l10n.recordGuideHint,
                    style: typography.bodySm.copyWith(color: surface.body),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.sm),
                Text(
                  l10n.recordGuideAction,
                  style: typography.bodySmStrong.copyWith(
                    color: AppColorTokens.link,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColorTokens.link,
                  size: AppSpacingTokens.lg,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
