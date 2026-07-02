import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/shared/record_copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordNewEntryPanel extends StatelessWidget {
  const RecordNewEntryPanel({
    super.key,
    required this.actions,
    required this.l10n,
    this.onNewEntry,
    this.onQuickAction,
  });

  final List<RecordQuickAction> actions;
  final AppLocalizations l10n;
  final VoidCallback? onNewEntry;
  final ValueChanged<RecordQuickAction>? onQuickAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
    return FCard.raw(
      key: const Key('record-new-entry-panel'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.recordNewEntrySectionTitle,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacingTokens.md),
            Wrap(
              spacing: AppSpacingTokens.sm,
              runSpacing: AppSpacingTokens.sm,
              children: actions
                  .take(7)
                  .map(
                    (action) => _NewEntryChip(
                      action: action,
                      l10n: l10n,
                      onTap: onQuickAction,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AppSpacingTokens.md),
            Material(
              color: Colors.transparent,
              child: Opacity(
                opacity: onNewEntry == null ? 0.5 : 1.0,
                child: InkWell(
                  onTap: onNewEntry,
                  borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.secondary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
                      border: Border.all(color: colors.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacingTokens.md),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            FLucideIcons.mic,
                            color: Color(0xFF16A34A),
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacingTokens.sm),
                          Flexible(
                            child: Text(
                              l10n.recordVoiceAction,
                              style: textTheme.labelLarge?.copyWith(
                                color: Color(0xFF16A34A),
                                fontWeight: FontWeight.w700,
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
            ),
          ],
        ),
      ),
    );
  }
}

class _NewEntryChip extends StatelessWidget {
  const _NewEntryChip({required this.action, required this.l10n, this.onTap});

  final RecordQuickAction action;
  final AppLocalizations l10n;
  final ValueChanged<RecordQuickAction>? onTap;

  @override
  Widget build(BuildContext context) {
    final label = recordCopy(l10n, action.titleKey);
    final textTheme = Theme.of(context).textTheme;

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
                  style: textTheme.labelSmall?.copyWith(
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
