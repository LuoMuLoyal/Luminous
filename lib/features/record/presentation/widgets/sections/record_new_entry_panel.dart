import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_colors.dart';
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

    return FCard.raw(
      key: const Key('record-new-entry-panel'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.level4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.recordNewEntrySectionTitle,
              style: AppTypographyToken.level5
                  .body(context)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacingTokens.level4),
            Wrap(
              spacing: AppSpacingTokens.level3,
              runSpacing: AppSpacingTokens.level3,
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
            const SizedBox(height: AppSpacingTokens.level4),
            FButton(
              onPress: onNewEntry,
              variant: FButtonVariant.ghost,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              style: .delta(
                decoration: .delta([
                  .all(
                    .shapeDelta(
                      color: colors.secondary.withValues(alpha: 0.18),
                      shape: RoundedSuperellipseBorder(
                        side: BorderSide(color: colors.border),
                        borderRadius: context.theme.style.borderRadius.sm,
                      ),
                    ),
                  ),
                ]),
                contentStyle: .delta(
                  padding: .value(
                    const EdgeInsets.all(AppSpacingTokens.level4),
                  ),
                ),
              ),
              prefix: Icon(
                FLucideIcons.mic,
                color: context.theme.colors.primary,
                size: 20,
              ),
              child: Flexible(
                child: Text(
                  l10n.recordVoiceAction,
                  style: AppTypographyToken.level5
                      .body(context)
                      .copyWith(
                        color: context.theme.colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                  overflow: TextOverflow.ellipsis,
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
    final colors = context.theme.colors;

    return FButton.raw(
      onPress: onTap == null ? null : () => onTap!(action),
      variant: FButtonVariant.ghost,
      style: .delta(
        decoration: .delta([
          .all(
            .shapeDelta(
              color: action.softColor.resolve(colors).withValues(alpha: 0.68),
              shape: RoundedSuperellipseBorder(
                borderRadius: context.theme.style.borderRadius.sm,
              ),
            ),
          ),
        ]),
        contentStyle: .delta(
          padding: .value(
            const EdgeInsets.symmetric(
              horizontal: AppSpacingTokens.level3,
              vertical: AppSpacingTokens.level3,
            ),
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(action.icon, color: action.accent.resolve(colors), size: 16),
          const SizedBox(width: AppSpacingTokens.level2),
          Text(
            label,
            style: AppTypographyToken.level3
                .body(context)
                .copyWith(
                  color: action.accent.resolve(colors),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
