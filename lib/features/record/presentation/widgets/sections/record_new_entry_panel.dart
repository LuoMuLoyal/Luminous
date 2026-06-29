import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_section_surface.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/shared/record_copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordNewEntryPanel extends StatelessWidget {
  const RecordNewEntryPanel({
    super.key,
    required this.actions,
    required this.l10n,
    required this.typography,
    required this.surface,
    this.onNewEntry,
    this.onQuickAction,
  });

  final List<RecordQuickAction> actions;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final VoidCallback? onNewEntry;
  final ValueChanged<RecordQuickAction>? onQuickAction;

  @override
  Widget build(BuildContext context) {
    return AppSectionSurface(
      key: const Key('record-new-entry-panel'),
      title: l10n.recordNewEntrySectionTitle,
      typography: typography,
      surface: surface,
      child: Column(
        children: [
          Wrap(
            spacing: AppSpacingTokens.sm,
            runSpacing: AppSpacingTokens.sm,
            children: actions
                .take(7)
                .map(
                  (action) => _NewEntryChip(
                    action: action,
                    l10n: l10n,
                    typography: typography,
                    onTap: onQuickAction,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacingTokens.md),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onNewEntry,
              borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: surface.canvasSoft,
                  borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
                  border: Border.all(color: surface.hairline),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacingTokens.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.mic_none_rounded,
                        color: AppColorTokens.accent,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacingTokens.sm),
                      Flexible(
                        child: Text(
                          l10n.recordVoiceAction,
                          style: typography.bodySmStrong.copyWith(
                            color: AppColorTokens.accent,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewEntryChip extends StatelessWidget {
  const _NewEntryChip({
    required this.action,
    required this.l10n,
    required this.typography,
    this.onTap,
  });

  final RecordQuickAction action;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final ValueChanged<RecordQuickAction>? onTap;

  @override
  Widget build(BuildContext context) {
    final label = recordCopy(l10n, action.titleKey);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap == null ? null : () => onTap!(action),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: action.softColor.withValues(alpha: 0.68),
            borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacingTokens.sm,
              vertical: AppSpacingTokens.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(action.icon, color: action.accent, size: 16),
                const SizedBox(width: AppSpacingTokens.xs),
                Text(
                  label,
                  style: typography.caption.copyWith(
                    color: action.accent,
                    fontWeight: FontWeight.w600,
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
