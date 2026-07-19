import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/shared/copy.dart';
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
        padding: const EdgeInsets.all(Spacing.level4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.recordNewEntrySectionTitle,
              style: TypographyToken.level5
                  .body(context)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: Spacing.level4),
            Wrap(
              spacing: Spacing.level3,
              runSpacing: Spacing.level3,
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
            const SizedBox(height: Spacing.level4),
            FButton(
              onPress: onNewEntry,
              variant: FButtonVariant.ghost,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              style: .delta(
                decoration: .delta([
                  .all(
                    .shapeDelta(
                      color: SemanticColor.neutral.subtle(context),
                      shape: RoundedSuperellipseBorder(
                        side: BorderSide(color: colors.border),
                        borderRadius: context.theme.style.borderRadius.sm,
                      ),
                    ),
                  ),
                ]),
                contentStyle: const .delta(
                  padding: .value(EdgeInsets.all(Spacing.level4)),
                ),
              ),
              prefix: Icon(
                FLucideIcons.plus,
                color: context.theme.colors.primary,
                size: 20,
              ),
              child: Flexible(
                child: Text(
                  l10n.recordNewEntrySectionTitle,
                  style: TypographyToken.level5
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

    return FButton.raw(
      onPress: onTap == null ? null : () => onTap!(action),
      variant: FButtonVariant.ghost,
      style: .delta(
        decoration: .delta([
          .all(
            .shapeDelta(
              color: action.softColor.solid(context).withValues(alpha: 0.68),
              shape: const RoundedSuperellipseBorder(),
            ),
          ),
        ]),
        contentStyle: const .delta(
          padding: .value(
            EdgeInsets.symmetric(
              horizontal: Spacing.level3,
              vertical: Spacing.level3,
            ),
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(action.icon, color: action.accent.solid(context), size: 16),
          const SizedBox(width: Spacing.level2),
          Text(
            label,
            style: TypographyToken.level3
                .body(context)
                .copyWith(
                  color: action.accent.solid(context),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
